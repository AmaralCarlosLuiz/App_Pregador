import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/breakpoints.dart';
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
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = Breakpoints.isMobile(context);

    final now = DateTime.now();
    final formattedDate = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now);
    final capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar Moderna com Saudação Pastoral
          SliverAppBar(
            floating: true,
            pinned: false,
            expandedHeight: isMobile ? 120 : 100,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          capitalizedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Paz do Senhor, ${authState.userProfile?.fullName ?? 'Pastor'}',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Alternar Tema',
                          icon: Icon(
                            themeState.themeMode == ThemeMode.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          onPressed: () {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                          child: const Icon(Icons.person, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo Principal do Dashboard
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. CARDS DE MÉTRICAS RÁPIDAS COM LINKS FILTRADOS
                if (isMobile) ...[
                  Row(
                    children: [
                      DashboardMetricItem(
                        label: 'Total de Sermões',
                        value: '${sermonState.totalSermons}',
                        icon: Icons.auto_stories,
                        color: AppColors.primaryBlue,
                        onTap: () {
                          ref.read(sermonListProvider.notifier).resetFilters();
                          onNavigateToLibrary?.call();
                        },
                      ),
                      const SizedBox(width: 12),
                      DashboardMetricItem(
                        label: 'Ministrados',
                        value: '${sermonState.totalPreachCount}',
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
                        icon: Icons.check_circle_outline,
                        color: AppColors.accentGold,
                        onTap: () {
                          ref.read(sermonListProvider.notifier).filterByStatus('ready', label: 'Prontos para Ministrar');
                          onNavigateToLibrary?.call();
                        },
                      ),
                      const SizedBox(width: 12),
                      DashboardMetricItem(
                        label: 'Favoritos',
                        value: '${sermonState.favoriteSermons.length}',
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
                        icon: Icons.auto_stories,
                        color: AppColors.primaryBlue,
                        onTap: () {
                          ref.read(sermonListProvider.notifier).resetFilters();
                          onNavigateToLibrary?.call();
                        },
                      ),
                      const SizedBox(width: 16),
                      DashboardMetricItem(
                        label: 'Pregações Realizadas',
                        value: '${sermonState.totalPreachCount}',
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
                        icon: Icons.check_circle_outline,
                        color: AppColors.accentGold,
                        onTap: () {
                          ref.read(sermonListProvider.notifier).filterByStatus('ready', label: 'Prontos para Ministrar');
                          onNavigateToLibrary?.call();
                        },
                      ),
                      const SizedBox(width: 16),
                      DashboardMetricItem(
                        label: 'Sermões Favoritos',
                        value: '${sermonState.favoriteSermons.length}',
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

                const SizedBox(height: 28),

                // 2. AÇÕES RÁPIDAS
                Text(
                  'Ações Rápidas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActions(context, ref, isMobile),

                const SizedBox(height: 32),

                // 3. CABEÇALHO SERMÕES RECENTES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sermões Recentes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToLibrary,
                      child: const Row(
                        children: [
                          Text('Ver Todos'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. LISTA DE SERMÕES RECENTES
                if (sermonState.recentSermons.isEmpty)
                  _buildEmptySermonsCard(context, ref)
                else
                  ...sermonState.recentSermons.map(
                    (sermon) => _buildRecentSermonCard(context, ref, sermon, isDark),
                  ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, bool isMobile) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.add,
          label: 'Novo Sermão',
          color: AppColors.primaryBlue,
          isPrimary: true,
          onTap: () => _openNewSermon(context),
        ),
        _buildActionButton(
          context: context,
          icon: Icons.psychology_alt,
          label: 'Gerar com IA',
          color: const Color(0xFF8B5CF6),
          isPrimary: false,
          onTap: () => _openAiAssistant(context),
        ),
        _buildActionButton(
          context: context,
          icon: Icons.folder_copy_outlined,
          label: 'Acervo de Modelos',
          color: AppColors.accentGold,
          isPrimary: false,
          onTap: onNavigateToTemplates,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isPrimary,
    VoidCallback? onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? color : color.withValues(alpha: 0.12),
        foregroundColor: isPrimary ? Colors.white : color,
        elevation: isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary ? BorderSide.none : BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildRecentSermonCard(
    BuildContext context,
    WidgetRef ref,
    Sermon sermon,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sermon.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
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
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book, size: 14, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    Text(
                      sermon.biblicalReference,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    sermon.category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
                Text(
                  '${sermon.blocks.length} pontos',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],
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
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PulpitModeScreen(sermon: sermon),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mic, size: 16),
                  label: const Text('Modo Púlpito'),
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
}
