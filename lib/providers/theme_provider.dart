import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

  void toggleTheme() {
    if (state.themeMode == ThemeMode.dark) {
      state = state.copyWith(themeMode: ThemeMode.light);
    } else {
      state = state.copyWith(themeMode: ThemeMode.dark);
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void togglePulpitHighContrast() {
    state = state.copyWith(isPulpitHighContrast: !state.isPulpitHighContrast);
  }

  void togglePulpitAmberTone() {
    state = state.copyWith(isPulpitAmberTone: !state.isPulpitAmberTone);
  }

  void increasePulpitFontSize() {
    if (state.pulpitFontSize < 38.0) {
      state = state.copyWith(pulpitFontSize: state.pulpitFontSize + 2.0);
    }
  }

  void decreasePulpitFontSize() {
    if (state.pulpitFontSize > 16.0) {
      state = state.copyWith(pulpitFontSize: state.pulpitFontSize - 2.0);
    }
  }

  void setPulpitFontSize(double size) {
    state = state.copyWith(pulpitFontSize: size.clamp(16.0, 38.0));
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
