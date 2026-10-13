import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/sermon_model.dart';
import '../../providers/pulpit_mode_provider.dart';
import '../../providers/sermon_provider.dart';
import '../../providers/theme_provider.dart';
import 'widgets/pulpit_timer_widget.dart';

class PulpitModeScreen extends ConsumerStatefulWidget {
  final Sermon sermon;

  const PulpitModeScreen({
    super.key,
    required this.sermon,
  });

  @override
  ConsumerState<PulpitModeScreen> createState() => _PulpitModeScreenState();
}

class _PulpitModeScreenState extends ConsumerState<PulpitModeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Esconder barras do sistema para imersão total no púlpito
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pulpitProvider.notifier).setEstimatedDurationMinutes(
            widget.sermon.estimatedDurationMinutes,
          );
      ref.read(pulpitProvider.notifier).startTimer();
    });
  }

  @override
  void dispose() {
    // Restaurar UI do sistema
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final pulpitState = ref.watch(pulpitProvider);
    final pulpitNotifier = ref.read(pulpitProvider.notifier);

    // Cores de Alto Contraste para Púlpito
    final isHighContrast = themeState.isPulpitHighContrast;
    final isAmberTone = themeState.isPulpitAmberTone;

    final bgColor = isHighContrast ? AppColors.pulpitBackground : const Color(0xFF131B2E);
    final textColor = isAmberTone
        ? AppColors.pulpitTextAmber
        : AppColors.pulpitTextHighContrast;
    final secondaryTextColor = isAmberTone
        ? const Color(0xFFD97706)
        : const Color(0xFF94A3B8);

    final baseFontSize = themeState.pulpitFontSize;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _promptFinishPreaching(context);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // ÁREA DE LEITURA DO SERMÃO (Com rolagem suave e fonte expansível)
            GestureDetector(
              onTap: pulpitNotifier.toggleControlsOverlay,
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      children: [
                        // Título do Sermão
                        Text(
                          widget.sermon.title,
                          style: TextStyle(
                            fontSize: baseFontSize + 10,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Texto-base e Metadados
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isHighContrast
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              Text(
                                '📖 ${widget.sermon.biblicalReference}',
                                style: TextStyle(
                                  fontSize: baseFontSize - 2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGold,
                                ),
                              ),
                              Text(
                                '🏷️ ${widget.sermon.category}',
                                style: TextStyle(
                                  fontSize: baseFontSize - 4,
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                '⏱️ ${widget.sermon.estimatedDurationMinutes} min',
                                style: TextStyle(
                                  fontSize: baseFontSize - 4,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // INTRODUÇÃO
                        if (widget.sermon.introduction.isNotEmpty) ...[
                          _buildPulpitSectionHeader('INTRODUÇÃO', AppColors.homileticIntro, baseFontSize),
                          const SizedBox(height: 8),
                          Text(
                            widget.sermon.introduction,
                            style: TextStyle(
                              fontSize: baseFontSize,
                              color: textColor,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // PONTOS HOMILÉTICOS
                        ...widget.sermon.blocks.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final b = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 28),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isHighContrast
                                  ? const Color(0xFF111111)
                                  : const Color(0xFF192238),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isHighContrast
                                    ? const Color(0xFF2E2E2E)
                                    : const Color(0xFF334155),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$idx. ${b.title}',
                                  style: TextStyle(
                                    fontSize: baseFontSize + 4,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                                if (b.biblicalReference.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '“${b.biblicalReference}”',
                                    style: TextStyle(
                                      fontSize: baseFontSize - 2,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF60A5FA),
                                    ),
                                  ),
                                ],
                                if (b.explanation.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    b.explanation,
                                    style: TextStyle(
                                      fontSize: baseFontSize,
                                      color: textColor,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                                if (b.illustration.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isHighContrast
                                          ? const Color(0xFF1C1329)
                                          : const Color(0xFF2C1F42),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.homileticIllustration.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('💡 ', style: TextStyle(fontSize: 18)),
                                        Expanded(
                                          child: Text(
                                            b.illustration,
                                            style: TextStyle(
                                              fontSize: baseFontSize - 2,
                                              color: textColor,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (b.application.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isHighContrast
                                          ? const Color(0xFF0F261B)
                                          : const Color(0xFF153B2A),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.homileticPoint.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('🎯 ', style: TextStyle(fontSize: 18)),
                                        Expanded(
                                          child: Text(
                                            b.application,
                                            style: TextStyle(
                                              fontSize: baseFontSize - 2,
                                              color: textColor,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),

                        // CONCLUSÃO
                        if (widget.sermon.conclusion.isNotEmpty) ...[
                          _buildPulpitSectionHeader('CONCLUSÃO', AppColors.homileticConclusion, baseFontSize),
                          const SizedBox(height: 8),
                          Text(
                            widget.sermon.conclusion,
                            style: TextStyle(
                              fontSize: baseFontSize,
                              color: textColor,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // APELO & CONVOCAÇÃO
                        if (widget.sermon.appeal.isNotEmpty) ...[
                          _buildPulpitSectionHeader('APELO & MINISTRAÇÃO', AppColors.homileticAppeal, baseFontSize),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isHighContrast ? const Color(0xFF2E1020) : const Color(0xFF40162D),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.homileticAppeal),
                            ),
                            child: Text(
                              widget.sermon.appeal,
                              style: TextStyle(
                                fontSize: baseFontSize + 1,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 120), // Espaço para não cobrir pelos controles
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // OVERLAY SUPERIOR: CRONÔMETRO FLUTUANTE & FECHAR
            if (pulpitState.isControlsOverlayVisible)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cronômetro Flutuante
                      const PulpitTimerWidget(),

                      // Botão de Sair do Púlpito
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212).withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          tooltip: 'Finalizar Modo Púlpito',
                          onPressed: () => _promptFinishPreaching(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // OVERLAY INFERIOR: CONTROLES DE ACESSIBILIDADE E TAMANHO DA FONTE (A- / A+)
            if (pulpitState.isControlsOverlayVisible)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212).withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFF333333)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Diminuir Fonte A-
                          IconButton(
                            icon: const Text('A-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            tooltip: 'Diminuir Fonte',
                            onPressed: themeNotifier.decreasePulpitFontSize,
                          ),

                          Text(
                            '${baseFontSize.toInt()}px',
                            style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
                          ),

                          // Aumentar Fonte A+
                          IconButton(
                            icon: const Text('A+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            tooltip: 'Aumentar Fonte',
                            onPressed: themeNotifier.increasePulpitFontSize,
                          ),

                          const SizedBox(width: 8),
                          const SizedBox(height: 24, child: VerticalDivider(color: Colors.grey)),
                          const SizedBox(width: 8),

                          // Alternar Tom Âmbar (Filtro Luz Quente)
                          IconButton(
                            icon: Icon(
                              Icons.wb_incandescent,
                              color: isAmberTone ? AppColors.accentGold : Colors.grey,
                              size: 20,
                            ),
                            tooltip: 'Tom Âmbar Quente',
                            onPressed: themeNotifier.togglePulpitAmberTone,
                          ),

                          // Alternar Alto Contraste OLED
                          IconButton(
                            icon: Icon(
                              Icons.contrast,
                              color: isHighContrast ? Colors.white : Colors.grey,
                              size: 20,
                            ),
                            tooltip: 'OLED Preto Absoluto',
                            onPressed: themeNotifier.togglePulpitHighContrast,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulpitSectionHeader(String title, Color color, double fontSize) {
    return Row(
      children: [
        Container(
          width: 4,
          height: fontSize,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize - 2,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  void _promptFinishPreaching(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Concluir Ministração?'),
          content: const Text(
            'Deseja registrar esta pregação no histórico do sermão e atualizar as estatísticas pastorais?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Sai do púlpito sem incrementar
              },
              child: const Text('Apenas Sair'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.accentGold),
              onPressed: () {
                ref.read(sermonListProvider.notifier).recordPreached(widget.sermon.id);
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Glória a Deus! Pregação registrada com sucesso.'),
                    backgroundColor: AppColors.statusReady,
                  ),
                );
              },
              child: const Text('Registrar e Sair'),
            ),
          ],
        );
      },
    );
  }
}
