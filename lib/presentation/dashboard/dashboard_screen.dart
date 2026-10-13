import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/services/sermon_share_service.dart';
import '../../models/sermon_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sermon_provider.dart';
import '../../providers/theme_provider.dart';
import '../ai_assistant/ai_assistant_sheet.dart';
import '../editor/sermon_editor_screen.dart';
import '../pulpit/pulpit_mode_screen.dart';
import 'widgets/dashboard_metrics_card.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToTemplates;
  final VoidCallback? onNavigateToLibrary;

  const DashboardScreen({
    super.key,
    this.onNavigateToTemplates,
    this.onNavigateToLibrary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonState = ref.watch(sermonListProvider);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = Breakpoints.isMobile(context);

    final now = DateTime.now();
    final formattedDate = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now);
    final capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. BANNER HERO EXECUTIVO 3D COM SAUDAÇÃO & VERSÍCULO DO DIA
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 32,
                isMobile ? 16 : 24,
                isMobile ? 16 : 32,
                16,
              ),
              child: _buildHeroBanner(
                context,
                ref,
                authState,
                capitalizedDate,
                isMobile,
                isDark,
              ),
            ),
          ),

          // 2. CONTEÚDO PRINCIPAL (MÉTRICAS + AÇÕES + SERMÕES)
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: 8,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // CABEÇALHO DA SEÇÃO DE MÉTRICAS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Visão Geral Ministerial',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'Clique nos cards para filtrar',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // CARDS DE MÉTRICAS RÁPIDAS COM LINKS FILTRADOS
                if (isMobile) ...[
                  Row(
                    children: [
                      DashboardMetricItem(
                        label: 'Total de Sermões',
                        value: '${sermonState.totalSermons}',
                        subtitle: 'Acervo pessoal completo',
                        icon: Icons.auto_stories,
                        color: AppColors.primaryElectricBlue,
                        onTap: () {
                          ref.read(sermonListProvider.notifier).resetFilters();
                          onNavigateToLibrary?.call();
                        },
                      ),
                      const SizedBox(width: 12),
                      DashboardMetricItem(
                        label: 'Sermões Ministrados',
                        value: '${sermonState.preachedSermonsCount}',
                        subtitle: '${sermonState.totalPreachCount} ministrações registradas',
                        icon: Icons.mic,
                        color: const Color(0xFF10B981),
                        onTap: () {
                          ref.read(sermonListProvider.notifier).filterByPreached();
                          onNavigateToLibrary?.call();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      DashboardMetricItem(
                        label: 'Prontos p/ Púlpito',
                        value: '${sermonState.readySermons}',
                        subtitle: 'Estruturados com 5 pontos',
                        icon: Icons.check_circle_outline,
                        color: AppColors.sacredGoldLuminous,
                        onTap: () {
                          ref.read(sermonListProvider.notifier).filterByStatus('ready', label: 'Prontos para Ministrar');
                          onNavigateToLibrary?.call();
                        },
                      ),
                      const SizedBox(width: 12),
                      DashboardMetricItem(
                        label: 'Favoritos',
                        value: '${sermonState.favoriteSermons.length}',
                        subtitle: 'Destaques ministeriais',
                        icon: Icons.star_outline,
                        color: const Color(0xFFEC4899),
                        onTap: () {
                          ref.read(sermonListProvider.notifier).filterByFavorites();
                          onNavigateToLibrary?.call();
                        },
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      DashboardMetricItem(
                        label: 'Total de Sermões',
                        value: '${sermonState.totalSermons}',
                        subtitle: 'Acervo pessoal completo',
                        icon: Icons.auto_stories,
                        color: AppColors.primaryElectricBlue,
                        onTap: () {
                          ref.read(sermonListProvider.notifier).resetFilters();
                          onNavigateToLibrary?.call();
                        },
                      ),
                      const SizedBox(width: 16),
                      DashboardMetricItem(
                        label: 'Sermões Ministrados',
                        value: '${sermonState.preachedSermonsCount}',
                        subtitle: '${sermonState.totalPreachCount} ministrações registradas',
                        icon: Icons.mic,
                        color: const Color(0xFF10B981),
                        onTap: () {
                          ref.read(sermonListProvider.notifier).filterByPreached();
                          onNavigateToLibrary?.call();
                        },
                      ),
                      const SizedBox(width: 16),
                      DashboardMetricItem(
                        label: 'Prontos p/ Púlpito',
                        value: '${sermonState.readySermons}',
                        subtitle: 'Estruturados com 5 pontos',
                        icon: Icons.check_circle_outline,
                        color: AppColors.sacredGoldLuminous,
                        onTap: () {
                          ref.read(sermonListProvider.notifier).filterByStatus('ready', label: 'Prontos para Ministrar');
                          onNavigateToLibrary?.call();
                        },
                      ),
                      const SizedBox(width: 16),
                      DashboardMetricItem(
                        label: 'Sermões Favoritos',
                        value: '${sermonState.favoriteSermons.length}',
                        subtitle: 'Destaques ministeriais',
                        icon: Icons.star_outline,
                        color: const Color(0xFFEC4899),
                        onTap: () {
                          ref.read(sermonListProvider.notifier).filterByFavorites();
                          onNavigateToLibrary?.call();
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // SEÇÃO DE AÇÕES RÁPIDAS COM DESIGN 3D PROFISSIONAL
                Text(
                  'Ações Rápidas & Ferramentas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 14),
                _buildQuickActions(context, ref, isMobile, isDark),

                const SizedBox(height: 36),

                // CABEÇALHO SERMÕES RECENTES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sermões Recentes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryElectricBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${sermonState.recentSermons.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryElectricBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: onNavigateToLibrary,
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Ver Todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // LISTA DE SERMÕES RECENTES
                if (sermonState.recentSermons.isEmpty)
                  _buildEmptySermonsCard(context, ref)
                else
                  ...sermonState.recentSermons.map(
                    (sermon) => _buildRecentSermonCard(context, ref, sermon, isDark),
                  ),

                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BANNER HERO EXECUTIVO 3D
  // ==========================================
  Widget _buildHeroBanner(
    BuildContext context,
    WidgetRef ref,
    dynamic authState,
    String capitalizedDate,
    bool isMobile,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF090D16), // Obsidian Dark
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E3A8A), // Royal Navy Blue
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Efeito de Luz / Glow no canto superior direito
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 18 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Data & Badge PRO + Alternar Tema
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 6),
                          Text(
                            capitalizedDate,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFBBF24),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'PREGADOR PRO',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Alternar Tema Claro / Escuro',
                          icon: Icon(
                            ref.watch(themeProvider).themeMode == ThemeMode.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Título & Saudação Pastoral
                Text(
                  'Paz do Senhor, ${authState.userProfile?.fullName ?? 'Pastor'} 🕊️',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sua bancada homilética de alta performance. Crie, edite e ministre mensagens com profunda exegese bíblica.',
                  style: TextStyle(
                    fontSize: isMobile ? 12.5 : 14,
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),

                // Card de Versículo Devocional Inspirador
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.format_quote, color: Color(0xFFFBBF24), size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '"Procura apresentar-te a Deus aprovado, como obreiro que não tem de que se envergonhar, que maneja bem a palavra da verdade." ',
                                style: TextStyle(
                                  fontSize: isMobile ? 11.5 : 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white.withValues(alpha: 0.92),
                                  height: 1.35,
                                ),
                              ),
                              const TextSpan(
                                text: '— 2 Timóteo 2:15',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFBBF24),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SEÇÃO DE AÇÕES RÁPIDAS (CARDS 3D EM GRADIENTE)
  // ==========================================
  Widget _buildQuickActions(BuildContext context, WidgetRef ref, bool isMobile, bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildTactile3DButton(
          icon: Icons.add,
          label: 'Novo Sermão',
          gradient: const LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadowColor: const Color(0xFF2563EB),
          onTap: () => _openNewSermon(context),
        ),
        _buildTactile3DButton(
          icon: Icons.psychology_alt,
          label: 'Gerar com IA',
          gradient: const LinearGradient(
            colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadowColor: const Color(0xFF8B5CF6),
          onTap: () => _openAiAssistant(context),
        ),
        _buildTactile3DButton(
          icon: Icons.mic,
          label: 'Modo Púlpito',
          gradient: const LinearGradient(
            colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadowColor: const Color(0xFFF59E0B),
          onTap: () => _openPulpitMode(context, ref),
        ),
        _buildTactile3DButton(
          icon: Icons.folder_copy_outlined,
          label: 'Acervo de Modelos',
          gradient: const LinearGradient(
            colors: [Color(0xFF047857), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadowColor: const Color(0xFF10B981),
          onTap: onNavigateToTemplates,
        ),
      ],
    );
  }

  Widget _buildTactile3DButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required Color shadowColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.38),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CARD DE SERMÃO RECENTE (DESIGN 3D EXECUTIVO)
  // ==========================================
  Widget _buildRecentSermonCard(
    BuildContext context,
    WidgetRef ref,
    Sermon sermon,
    bool isDark,
  ) {
    final isReady = sermon.status == 'ready';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: AppColors.cardShadow3D(isDark: isDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sermon.title,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: sermon.isFavorite ? 'Remover dos Favoritos' : 'Marcar como Favorito',
                  icon: Icon(
                    sermon.isFavorite ? Icons.star : Icons.star_border,
                    color: sermon.isFavorite ? AppColors.accentGold : Colors.grey,
                  ),
                  onPressed: () {
                    ref.read(sermonListProvider.notifier).toggleFavorite(sermon.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                // Referência Bíblica
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryElectricBlue.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryElectricBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book, size: 13, color: AppColors.primaryElectricBlue),
                      const SizedBox(width: 6),
                      Text(
                        sermon.biblicalReference,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryElectricBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                // Categoria
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sermon.category,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
                // Status Pronto / Rascunho
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isReady ? const Color(0xFF10B981) : Colors.grey).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isReady ? Icons.check_circle : Icons.edit_note,
                        size: 13,
                        color: isReady ? const Color(0xFF10B981) : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isReady ? 'Pronto p/ Púlpito' : 'Rascunho',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isReady ? const Color(0xFF10B981) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Contagem de pregações
                if (sermon.preachCount > 0)
                  Text(
                    'Pregado ${sermon.preachCount}x',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (sermon.introduction.isNotEmpty) ...[
              Text(
                sermon.introduction,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
            ],
            // Botões de Ação Direta no Card
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SermonEditorScreen(initialSermon: sermon),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 15),
                  label: const Text('Editar'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(color: Color(0xFF25D366)),
                  ),
                  onPressed: () {
                    SermonShareService.showShareOptionsModal(context, sermon);
                  },
                  icon: const Icon(Icons.share, size: 15),
                  label: const Text('WhatsApp'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.white,
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PulpitModeScreen(sermon: sermon),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mic, size: 15),
                  label: const Text('Púlpito'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySermonsCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.menu_book, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Nenhum sermão encontrado',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Comece criando seu primeiro esboço ou utilize um dos modelos prontos.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _openNewSermon(context),
            child: const Text('Criar Primeiro Sermão'),
          ),
        ],
      ),
    );
  }

  void _openNewSermon(BuildContext context) {
    final newSermon = Sermon(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'pastor-local-01',
      title: 'Novo Sermão',
      biblicalReference: 'João 3:16',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SermonEditorScreen(initialSermon: newSermon),
      ),
    );
  }

  void _openAiAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiAssistantSheet(),
    );
  }

  void _openPulpitMode(BuildContext context, WidgetRef ref) {
    final sermonState = ref.read(sermonListProvider);
    final readyOrRecent = sermonState.recentSermons.firstOrNull ?? sermonState.sermons.firstOrNull;
    if (readyOrRecent != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PulpitModeScreen(sermon: readyOrRecent),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum sermão cadastrado ainda. Crie um sermão para iniciar o Modo Púlpito.'),
        ),
      );
    }
  }
}
