import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/sermon_model.dart';

class OfflineCacheService {
  static const String _sermonsCacheKey = 'pregador_pro_sermons_cache';
  static const String _pulpitSettingsKey = 'pregador_pro_pulpit_settings';

  /// Salva lista de sermões no cache local offline
  static Future<void> cacheSermons(List<Sermon> sermons) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sermons.map((s) => s.toJson()).toList();
    await prefs.setString(_sermonsCacheKey, jsonEncode(jsonList));
  }

  /// Recupera sermões cacheados offline
  static Future<List<Sermon>> getCachedSermons() async {
    final prefs = await SharedPreferences.getInstance();
    final rawString = prefs.getString(_sermonsCacheKey);
    if (rawString == null || rawString.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(rawString) as List<dynamic>;
      return decoded.map((item) => Sermon.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Salva ou atualiza um sermão específico no cache offline imediatamente (para debounce)
  static Future<void> saveSingleSermonLocally(Sermon sermon) async {
    final cached = await getCachedSermons();
    final index = cached.indexWhere((s) => s.id == sermon.id);
    if (index >= 0) {
      cached[index] = sermon;
    } else {
      cached.insert(0, sermon);
    }
    await cacheSermons(cached);
  }

  /// Remove um sermão do cache offline
  static Future<void> removeSermonLocally(String sermonId) async {
    final cached = await getCachedSermons();
    cached.removeWhere((s) => s.id == sermonId);
    await cacheSermons(cached);
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
