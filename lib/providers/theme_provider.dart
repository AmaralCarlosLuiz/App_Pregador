import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/offline_cache_service.dart';

class ThemeState {
  final ThemeMode themeMode;
  final bool isPulpitHighContrast;
  final bool isPulpitAmberTone;
  final double pulpitFontSize;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.isPulpitHighContrast = true,
    this.isPulpitAmberTone = false,
    this.pulpitFontSize = 22.0,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isPulpitHighContrast,
    bool? isPulpitAmberTone,
    double? pulpitFontSize,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isPulpitHighContrast: isPulpitHighContrast ?? this.isPulpitHighContrast,
      isPulpitAmberTone: isPulpitAmberTone ?? this.isPulpitAmberTone,
      pulpitFontSize: pulpitFontSize ?? this.pulpitFontSize,
    );
  }
}

/// Tema e preferências de leitura do púlpito, PERSISTIDOS no aparelho.
/// O estado inicial é carregado antes do primeiro frame (ver `main.dart`),
/// então o app nunca "pisca" no tema errado ao abrir.
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _kThemeBundle = 'pregador_pro_theme_bundle_v2';
  static const _kThemeMode = 'pregador_pro_theme_mode_v1';
  static const _kHighContrast = 'pregador_pro_pulpit_high_contrast_v1';
  static const _kAmberTone = 'pregador_pro_pulpit_amber_tone_v1';
  static const _kFontSize = 'pregador_pro_pulpit_font_size_v1';

  ThemeNotifier([super.initial = const ThemeState()]);

  /// Lê as preferências salvas (chamado uma única vez no boot).
  static Future<ThemeState> loadSaved() async {
    try {
      final bundleRaw = await OfflineCacheService.readResilientString(_kThemeBundle);
      if (bundleRaw != null && bundleRaw.isNotEmpty) {
        final map = jsonDecode(bundleRaw) as Map<String, dynamic>;
        final mode = switch (map['themeMode'] as String?) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        };
        return ThemeState(
          themeMode: mode,
          isPulpitHighContrast: (map['highContrast'] as bool?) ?? true,
          isPulpitAmberTone: (map['amberTone'] as bool?) ?? false,
          pulpitFontSize: ((map['fontSize'] as num?)?.toDouble() ?? 22.0).clamp(16.0, 38.0),
        );
      }

      // Migração de chaves antigas se existirem
      final prefs = await SharedPreferences.getInstance();
      final mode = switch (prefs.getString(_kThemeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      return ThemeState(
        themeMode: mode,
        isPulpitHighContrast: prefs.getBool(_kHighContrast) ?? true,
        isPulpitAmberTone: prefs.getBool(_kAmberTone) ?? false,
        pulpitFontSize: (prefs.getDouble(_kFontSize) ?? 22.0).clamp(16.0, 38.0),
      );
    } catch (e) {
      debugPrint('[ThemeNotifier] Falha ao carregar preferências: $e');
      return const ThemeState();
    }
  }

  Future<void> _save() async {
    try {
      final modeStr = switch (state.themeMode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await OfflineCacheService.writeResilientString(
        _kThemeBundle,
        jsonEncode({
          'themeMode': modeStr,
          'highContrast': state.isPulpitHighContrast,
          'amberTone': state.isPulpitAmberTone,
          'fontSize': state.pulpitFontSize,
        }),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeMode, modeStr);
      await prefs.setBool(_kHighContrast, state.isPulpitHighContrast);
      await prefs.setBool(_kAmberTone, state.isPulpitAmberTone);
      await prefs.setDouble(_kFontSize, state.pulpitFontSize);
    } catch (e) {
      debugPrint('[ThemeNotifier] Falha ao salvar preferências: $e');
    }
  }

  void _update(ThemeState next) {
    state = next;
    _save();
  }

  void toggleTheme() {
    // Considera o tema efetivamente exibido (inclusive quando estava em "sistema").
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkNow = state.themeMode == ThemeMode.dark ||
        (state.themeMode == ThemeMode.system && brightness == Brightness.dark);
    _update(state.copyWith(
      themeMode: isDarkNow ? ThemeMode.light : ThemeMode.dark,
    ));
  }

  void setThemeMode(ThemeMode mode) {
    _update(state.copyWith(themeMode: mode));
  }

  void togglePulpitHighContrast() {
    _update(state.copyWith(isPulpitHighContrast: !state.isPulpitHighContrast));
  }

  void togglePulpitAmberTone() {
    _update(state.copyWith(isPulpitAmberTone: !state.isPulpitAmberTone));
  }

  void increasePulpitFontSize() {
    if (state.pulpitFontSize < 38.0) {
      _update(state.copyWith(pulpitFontSize: state.pulpitFontSize + 2.0));
    }
  }

  void decreasePulpitFontSize() {
    if (state.pulpitFontSize > 16.0) {
      _update(state.copyWith(pulpitFontSize: state.pulpitFontSize - 2.0));
    }
  }

  void setPulpitFontSize(double size) {
    _update(state.copyWith(pulpitFontSize: size.clamp(16.0, 38.0)));
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
