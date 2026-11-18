import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/sermon_model.dart';
import 'web_local_storage_stub.dart'
    if (dart.library.html) 'web_local_storage_web.dart';

/// Camada de persistência local (localStorage síncrono + SharedPreferences no Web/PWA,
/// NSUserDefaults no iOS nativo).
///
/// Regras de robustez:
///  - Dupla redundância na Web/iPhone: grava de forma SÍNCRONA no `window.localStorage`
///    antes de aguardar o `SharedPreferences`, impedindo perda de dados ao fechar o app.
///  - Delta Storage para sermões: grava apenas os sermões criados ou editados pelo usuário
///    (poucos KB em vez de ~750 KB do acervo estático), garantindo gravação instantânea.
///  - Leitura tolerante: um sermão corrompido NUNCA descarta os demais.
class OfflineCacheService {
  static const String _sermonsCacheKey = 'pregador_pro_sermons_cache';
  static const String _userSermonsDeltaKey = 'pregador_pro_user_sermons_delta_v1';
  static const String _legacyMigratedKey = 'pregador_pro_delta_migrated_v1';
  static const String _sermonsCorruptKey = 'pregador_pro_sermons_cache_corrupt';
  static const String _deletedIdsKey = 'pregador_pro_sermons_deleted_ids';
  static const String _seededKey = 'pregador_pro_sermons_seeded_v2';
  static const String _pulpitSettingsKey = 'pregador_pro_pulpit_settings';

  /// Gravação resiliente genérica (usada também por Auth, Tema e Config IA).
  static Future<bool> writeResilientString(String key, String value) async {
    final webOk = writeWebLocal(key, value);
    bool prefsOk = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefsOk = await prefs.setString(key, value);
    } catch (e) {
      debugPrint('[OfflineCacheService] Falha SharedPreferences ($key): $e');
    }
    return kIsWeb ? (webOk || prefsOk) : prefsOk;
  }

  /// Leitura resiliente genérica: prioriza espelho síncrono web ou SharedPreferences.
  static Future<String?> readResilientString(String key) async {
    final webVal = readWebLocal(key);
    String? prefsVal;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefsVal = prefs.getString(key);
    } catch (_) {}

    if (webVal != null && webVal.isNotEmpty) {
      return webVal;
    }
    if (prefsVal != null && prefsVal.isNotEmpty) {
      // Espelha para leitura síncrona futura
      writeWebLocal(key, prefsVal);
      return prefsVal;
    }
    return null;
  }

  static Future<void> removeResilientKey(String key) async {
    removeWebLocal(key);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (_) {}
  }

  /// Grava apenas os sermões criados ou editados pelo usuário (Delta ultrarrápido).
  static Future<bool> saveUserSermonsDelta(Map<String, Sermon> deltaMap) async {
    try {
      final jsonList = deltaMap.values.map((s) => s.toJson()).toList();
      final encoded = jsonEncode(jsonList);
      return await writeResilientString(_userSermonsDeltaKey, encoded);
    } catch (e) {
      debugPrint('[OfflineCacheService] Falha ao gravar delta de sermões: $e');
      return false;
    }
  }

  /// Recupera os sermões criados/editados pelo usuário, mesclando webLocal e SharedPreferences
  /// para garantir que a versão mais recente seja sempre preservada.
  static Future<Map<String, Sermon>> getUserSermonsDelta() async {
    final result = <String, Sermon>{};

    void mergeRaw(String? raw) {
      if (raw == null || raw.isEmpty) return;
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          try {
            final sermon = Sermon.fromJson(Map<String, dynamic>.from(item as Map));
            if (sermon.id.isEmpty) continue;
            final existing = result[sermon.id];
            if (existing == null || sermon.updatedAt.isAfter(existing.updatedAt)) {
              result[sermon.id] = sermon;
            }
          } catch (e) {
            debugPrint('[OfflineCacheService] Sermão delta inválido ignorado: $e');
          }
        }
      } catch (e) {
        debugPrint('[OfflineCacheService] Falha ao decodificar delta: $e');
      }
    }

    final webRaw = readWebLocal(_userSermonsDeltaKey);
    mergeRaw(webRaw);

    try {
      final prefs = await SharedPreferences.getInstance();
      mergeRaw(prefs.getString(_userSermonsDeltaKey));
    } catch (_) {}

    return result;
  }

  static Future<bool> isLegacyMigrated() async {
    final webVal = readWebLocal(_legacyMigratedKey);
    if (webVal == 'true') return true;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_legacyMigratedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> markLegacyMigrated() async {
    writeWebLocal(_legacyMigratedKey, 'true');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_legacyMigratedKey, true);
    } catch (_) {}
  }

  /// Grava a lista completa de sermões (legado/compatibilidade).
  static Future<bool> cacheSermons(List<Sermon> sermons) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = sermons.map((s) => s.toJson()).toList();
      return await prefs.setString(_sermonsCacheKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[OfflineCacheService] Falha ao gravar sermões: $e');
      return false;
    }
  }

  /// Recupera sermões persistidos no cache legado (para migração transparente).
  static Future<List<Sermon>> getCachedSermons() async {
    final prefs = await SharedPreferences.getInstance();
    final rawString = prefs.getString(_sermonsCacheKey);
    if (rawString == null || rawString.isEmpty) return [];

    final List<dynamic> decoded;
    try {
      decoded = jsonDecode(rawString) as List<dynamic>;
    } catch (e) {
      await prefs.setString(_sermonsCorruptKey, rawString);
      debugPrint('[OfflineCacheService] Cache ilegível movido para quarentena: $e');
      return [];
    }

    final result = <Sermon>[];
    for (final item in decoded) {
      try {
        final sermon = Sermon.fromJson(Map<String, dynamic>.from(item as Map));
        if (sermon.id.isNotEmpty) result.add(sermon);
      } catch (e) {
        debugPrint('[OfflineCacheService] Sermão inválido ignorado: $e');
      }
    }
    return result;
  }

  /// Remove o cache legado pesado após migração segura para delta.
  static Future<void> clearLegacySermonsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sermonsCacheKey);
    } catch (_) {}
  }

  /// IDs excluídos pelo usuário (impede que sermões de exemplo reapareçam).
  static Future<Set<String>> getDeletedIds() async {
    final ids = <String>{};
    final webRaw = readWebLocal(_deletedIdsKey);
    if (webRaw != null && webRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(webRaw) as List<dynamic>;
        ids.addAll(decoded.map((e) => e.toString()));
      } catch (_) {}
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      ids.addAll(prefs.getStringList(_deletedIdsKey) ?? const <String>[]);
    } catch (_) {}
    return ids;
  }

  static Future<void> saveDeletedIds(Set<String> ids) async {
    final list = ids.toList();
    writeWebLocal(_deletedIdsKey, jsonEncode(list));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_deletedIdsKey, list);
    } catch (_) {}
  }

  static Future<bool> wasSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seededKey) ?? false;
  }

  static Future<void> markSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, true);
  }

  /// Salva preferências de leitura do púlpito (tamanho de fonte, modo contraste)
  static Future<void> savePulpitSettings({
    required double fontSize,
    required bool highContrast,
    required bool amberTone,
  }) async {
    final encoded = jsonEncode({
      'fontSize': fontSize,
      'highContrast': highContrast,
      'amberTone': amberTone,
    });
    await writeResilientString(_pulpitSettingsKey, encoded);
  }

  /// Carrega preferências do púlpito
  static Future<Map<String, dynamic>?> getPulpitSettings() async {
    final raw = await readResilientString(_pulpitSettingsKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
