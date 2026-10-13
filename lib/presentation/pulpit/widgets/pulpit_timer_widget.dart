import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/pulpit_mode_provider.dart';

class PulpitTimerWidget extends ConsumerWidget {
  const PulpitTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulpitState = ref.watch(pulpitProvider);
    final pulpitNotifier = ref.read(pulpitProvider.notifier);

    // Cor do cronômetro baseado no tempo restante
    Color timerColor = const Color(0xFF10B981); // Verde normal
    if (pulpitState.timerMode == PulpitTimerMode.regressive) {
      if (pulpitState.isOvertime) {
        timerColor = const Color(0xFFEF4444); // Vermelho Estourado
      } else if (pulpitState.remainingSeconds < 300) {
        timerColor = AppColors.accentGold; // Âmbar últimos 5 minutos
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: timerColor.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: timerColor.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play / Pause
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              pulpitState.isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: timerColor,
              size: 26,
            ),
            onPressed: pulpitNotifier.toggleTimer,
          ),

          const SizedBox(width: 8),

          // Display do Tempo
          InkWell(
            onTap: pulpitNotifier.toggleTimerMode,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pulpitState.formattedDisplayTime,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: timerColor,
                        letterSpacing: 1,
                      ),
                    ),
                    if (pulpitState.isOvertime) ...[
                      const SizedBox(width: 4),
                      const Text(
                        'EXCEDIDO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  pulpitState.timerMode == PulpitTimerMode.regressive
                      ? 'Regressivo (Toque p/ cronômetro)'
                      : 'Progressivo (Toque p/ contagem)',
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Reset
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.refresh, color: Colors.grey, size: 18),
            tooltip: 'Reiniciar cronômetro',
            onPressed: pulpitNotifier.resetTimer,
          ),
        ],
      ),
    );
  }
}
