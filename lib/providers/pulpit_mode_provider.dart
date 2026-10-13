import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/pulpit_wakelock_service.dart';

enum PulpitTimerMode { progressive, regressive }

class PulpitState {
  final bool isWakelockActive;
  final bool isControlsOverlayVisible;
  final PulpitTimerMode timerMode;
  final bool isTimerRunning;
  final int elapsedSeconds;
  final int totalTargetSeconds; // Duração estimada em segundos (ex: 40 min = 2400s)

  const PulpitState({
    this.isWakelockActive = true,
    this.isControlsOverlayVisible = true,
    this.timerMode = PulpitTimerMode.regressive,
    this.isTimerRunning = false,
    this.elapsedSeconds = 0,
    this.totalTargetSeconds = 2400, // 40 minutos padrão
  });

  PulpitState copyWith({
    bool? isWakelockActive,
    bool? isControlsOverlayVisible,
    PulpitTimerMode? timerMode,
    bool? isTimerRunning,
    int? elapsedSeconds,
    int? totalTargetSeconds,
  }) {
    return PulpitState(
      isWakelockActive: isWakelockActive ?? this.isWakelockActive,
      isControlsOverlayVisible:
          isControlsOverlayVisible ?? this.isControlsOverlayVisible,
      timerMode: timerMode ?? this.timerMode,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalTargetSeconds: totalTargetSeconds ?? this.totalTargetSeconds,
    );
  }

  int get remainingSeconds => totalTargetSeconds - elapsedSeconds;
  bool get isOvertime => remainingSeconds < 0;

  double get progressFraction {
    if (totalTargetSeconds <= 0) return 0.0;
    return (elapsedSeconds / totalTargetSeconds).clamp(0.0, 1.0);
  }

  String get formattedDisplayTime {
    if (timerMode == PulpitTimerMode.progressive) {
      final m = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
      final s = (elapsedSeconds % 60).toString().padLeft(2, '0');
      return '$m:$s';
    } else {
      final rem = remainingSeconds.abs();
      final m = (rem ~/ 60).toString().padLeft(2, '0');
      final s = (rem % 60).toString().padLeft(2, '0');
      final sign = isOvertime ? '+ ' : '';
      return '$sign$m:$s';
    }
  }
}

class PulpitNotifier extends StateNotifier<PulpitState> {
  Timer? _ticker;

  PulpitNotifier() : super(const PulpitState()) {
    _initWakelock();
  }

  Future<void> _initWakelock() async {
    await PulpitWakelockService.enableWakelock();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    PulpitWakelockService.disableWakelock();
    super.dispose();
  }

  void setEstimatedDurationMinutes(int minutes) {
    state = state.copyWith(
      totalTargetSeconds: (minutes > 0 ? minutes : 40) * 60,
    );
  }

  void toggleControlsOverlay() {
    state = state.copyWith(
      isControlsOverlayVisible: !state.isControlsOverlayVisible,
    );
  }

  void toggleTimerMode() {
    final nextMode = state.timerMode == PulpitTimerMode.regressive
        ? PulpitTimerMode.progressive
        : PulpitTimerMode.regressive;
    state = state.copyWith(timerMode: nextMode);
  }

  void startTimer() {
    if (state.isTimerRunning) return;
    state = state.copyWith(isTimerRunning: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void pauseTimer() {
    _ticker?.cancel();
    state = state.copyWith(isTimerRunning: false);
  }

  void resetTimer() {
    _ticker?.cancel();
    state = state.copyWith(isTimerRunning: false, elapsedSeconds: 0);
  }

  void toggleTimer() {
    if (state.isTimerRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }
}

final pulpitProvider =
    StateNotifierProvider.autoDispose<PulpitNotifier, PulpitState>((ref) {
  return PulpitNotifier();
});
