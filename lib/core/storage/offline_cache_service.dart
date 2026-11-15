import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/sermon_model.dart';

/// Camada de persistência local (localStorage no Web/PWA, NSUserDefaults no iOS nativo).
///
/// Regras de robustez:
///  - Leitura tolerante: um sermão corrompido NUNCA descarta os demais.
///  - JSON ilegível é preservado em uma chave de quarentena (nada é apagado silenciosamente).
///  - Escrita sempre confirmada (retorna `true` apenas se o dado foi gravado).
class OfflineCacheService {
  static const String _sermonsCacheKey = 'pregador_pro_sermons_cache';
  static const String _sermonsCorruptKey = 'pregador_pro_sermons_cache_corrupt';
  static const String _deletedIdsKey = 'pregador_pro_sermons_deleted_ids';
  static const String _seededKey = 'pregador_pro_sermons_seeded_v2';
  static const String _pulpitSettingsKey = 'pregador_pro_pulpit_settings';

  /// Grava a lista completa de sermões. Retorna `true` se persistiu com sucesso.
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

  /// Recupera sermões persistidos (leitura tolerante item a item).
  static Future<List<Sermon>> getCachedSermons() async {
    final prefs = await SharedPreferences.getInstance();
    final rawString = prefs.getString(_sermonsCacheKey);
    if (rawString == null || rawString.isEmpty) return [];

    final List<dynamic> decoded;
    try {
      decoded = jsonDecode(rawString) as List<dynamic>;
    } catch (e) {
      // Preserva o conteúdo ilegível para recuperação em vez de perdê-lo.
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

  /// IDs excluídos pelo usuário (impede que sermões de exemplo reapareçam).
  static Future<Set<String>> getDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_deletedIdsKey) ?? const <String>[]).toSet();
  }

  static Future<void> saveDeletedIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_deletedIdsKey, ids.toList());
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pulpitSettingsKey,
      jsonEncode({
        'fontSize': fontSize,
        'highContrast': highContrast,
        'amberTone': amberTone,
      }),
    );
  }

  /// Carrega preferências do púlpito
  static Future<Map<String, dynamic>?> getPulpitSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pulpitSettingsKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
