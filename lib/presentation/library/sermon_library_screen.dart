import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/services/pdf_export_service.dart';
import '../../core/services/sermon_share_service.dart';
import '../../models/sermon_model.dart';
import '../../providers/sermon_provider.dart';
import '../editor/sermon_editor_screen.dart';
import '../pulpit/pulpit_mode_screen.dart';

class SermonLibraryScreen extends ConsumerStatefulWidget {
  const SermonLibraryScreen({super.key});

  @override
  ConsumerState<SermonLibraryScreen> createState() => _SermonLibraryScreenState();
}

class _SermonLibraryScreenState extends ConsumerState<SermonLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sermonState = ref.watch(sermonListProvider);
    final sermonNotifier = ref.read(sermonListProvider.notifier);
    final isDesktopOrTabletLandscape = Breakpoints.isTabletLandscapeOrDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Meus Sermões', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              '${sermonState.totalSermons} mensagens em seu acervo pessoal',
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar / Sincronizar',
            icon: const Icon(Icons.sync),
            onPressed: sermonNotifier.loadSermons,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo Sermão'),
              onPressed: () => _createNewSermon(context),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. BARRA DE BUSCA INSTANTÂNEA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por título, texto bíblico ou palavra-chave...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          sermonNotifier.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: sermonNotifier.setSearchQuery,
            ),
          ),

          // 2. BANNER DE FILTRO ATIVO (SE FILTRADO PELO DASHBOARD OU STATUS)
          if (sermonState.activeFilterLabel != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 2, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtro Ativo: ${sermonState.activeFilterLabel} (${sermonState.sermons.length} de ${sermonState.totalSermons} mensagens)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Limpar', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      _searchController.clear();
                      sermonNotifier.resetFilters();
                    },
                  ),
                ],
              ),
            ),

          // 3. BARRA DE FILTROS COMPACTA (DESIGN PROFISSIONAL - SEM OVERFLOW)
          _buildCompactFilterBar(sermonState, sermonNotifier, isDark),

          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),

          // 3. CONTEÚDO PRINCIPAL (Master-Detail em telas amplas, lista comum em mobile)
          Expanded(
            child: sermonState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : sermonState.sermons.isEmpty
                    ? _buildEmptyState()
                    : isDesktopOrTabletLandscape
                        ? _buildMasterDetailView(sermonState, isDark)
                        : _buildMobileListView(sermonState, isDark),
          ),
        ],
      ),
    );
  }

  // MASTER-DETAIL FLOW (Tablet Horizontal & Desktop/Web)
  Widget _buildMasterDetailView(SermonListState state, bool isDark) {
    final selectedSermon = state.selectedSermon;

    return Row(
      children: [
        // MASTER: LISTA À ESQUERDA (380px)
        SizedBox(
          width: 380,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.sermons.length,
            itemBuilder: (context, index) {
              final sermon = state.sermons[index];
              final isSelected = sermon.id == selectedSermon?.id;

              return _buildSermonListTile(
                sermon: sermon,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  ref.read(sermonListProvider.notifier).selectSermonForDetail(sermon.id);
                },
              );
            },
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderLight),

        // DETAIL: PRÉ-VISUALIZAÇÃO / LEITURA À DIREITA
        Expanded(
          child: selectedSermon != null
              ? _buildSermonDetailPane(selectedSermon, isDark)
              : const Center(child: Text('Selecione um sermão para visualizar')),
        ),
      ],
    );
  }

  // LISTA SMARTPHONE
  Widget _buildMobileListView(SermonListState state, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.sermons.length,
      itemBuilder: (context, index) {
        final sermon = state.sermons[index];
        return _buildSermonListTile(
          sermon: sermon,
          isSelected: false,
          isDark: isDark,
          onTap: () => _openSermonInEditor(context, sermon),
        );
      },
    );
  }

  Widget _buildSermonListTile({
    required Sermon sermon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
            : (isDark ? const Color(0xFF131B2E) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryElectricBlue
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          width: isSelected ? 1.8 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryElectricBlue.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppColors.cardShadow3D(isDark: isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          letterSpacing: -0.2,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Compartilhar no WhatsApp',
                          icon: const Icon(Icons.share_outlined, size: 17, color: Color(0xFF25D366)),
                          onPressed: () {
                            SermonShareService.showShareOptionsModal(context, sermon);
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            sermon.isFavorite ? Icons.star : Icons.star_border,
                            size: 19,
                            color: sermon.isFavorite ? AppColors.accentGold : Colors.grey,
                          ),
                          onPressed: () {
                            ref.read(sermonListProvider.notifier).toggleFavorite(sermon.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryElectricBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sermon.biblicalReference,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryElectricBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sermon.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${sermon.blocks.length} pontos • ${sermon.estimatedDurationMinutes} min',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    if (sermon.preachCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pregado ${sermon.preachCount}x',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PAINEL DE DETALHES (SPLIT VIEW DIREITA)
  Widget _buildSermonDetailPane(Sermon sermon, bool isDark) {
    return Column(
      children: [
        // Ações Rápidas do Detalhe
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: const Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 620;

              final titleSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sermon.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${sermon.biblicalReference} • ${sermon.category}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );

              final actionButtons = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    onPressed: () => _openSermonInEditor(context, sermon),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                    ),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Compartilhar'),
                    onPressed: () => SermonShareService.showShareOptionsModal(context, sermon),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Imprimir'),
                    onPressed: () => PdfExportService.exportAndPrintSermon(sermon),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.accentGold),
                    icon: const Icon(Icons.mic, size: 16),
                    label: const Text('Púlpito'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PulpitModeScreen(sermon: sermon),
                        ),
                      );
                    },
                  ),
                ],
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 10),
                    actionButtons,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleSection),
                  const SizedBox(width: 16),
                  actionButtons,
                ],
              );
            },
          ),
        ),

        // Leitura Markdown Formatada
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: MarkdownBody(
              data: sermon.toMarkdown(),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                p: const TextStyle(fontSize: 14, height: 1.6),
                blockquote: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Nenhum sermão corresponde aos filtros aplicados'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              ref.read(sermonListProvider.notifier).setSearchQuery('');
              ref.read(sermonListProvider.notifier).setCategory('Todas');
            },
            child: const Text('Limpar Filtros'),
          ),
        ],
      ),
    );
  }

  void _createNewSermon(BuildContext context) {
    final newSermon = Sermon(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'pastor-local-01',
      title: 'Novo Sermão',
      biblicalReference: 'Salmos 23:1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _openSermonInEditor(context, newSermon);
  }

  void _openSermonInEditor(BuildContext context, Sermon sermon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SermonEditorScreen(initialSermon: sermon),
      ),
    );
  }

  // BARRA DE FILTROS COMPACTA (DESIGN PROFISSIONAL - SEM OVERFLOW)
  Widget _buildCompactFilterBar(
    SermonListState state,
    SermonListNotifier notifier,
    bool isDark,
  ) {
    final hasCategoryFilter = state.selectedCategory != 'Todas';
    final activeCount = state.activeCategoriesWithCounts[state.selectedCategory] ?? 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: Row(
        children: [
          // 1. Botão Seletor de Categoria
          ActionChip(
            avatar: Icon(
              Icons.folder_outlined,
              size: 16,
              color: hasCategoryFilter ? AppColors.accentGold : AppColors.primaryBlue,
            ),
            label: Text(
              hasCategoryFilter
                  ? 'Categoria: ${state.selectedCategory} ($activeCount)'
                  : 'Todas as Categorias (${state.totalSermons})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: hasCategoryFilter ? FontWeight.bold : FontWeight.w500,
                color: hasCategoryFilter ? (isDark ? AppColors.goldLight : AppColors.goldDark) : null,
              ),
            ),
            backgroundColor: hasCategoryFilter ? AppColors.accentGold.withValues(alpha: 0.15) : null,
            onPressed: () => _showCategoryPickerDialog(context, state, notifier, isDark),
          ),
          if (hasCategoryFilter) ...[
            const SizedBox(width: 4),
            ActionChip(
              avatar: const Icon(Icons.close, size: 14),
              label: const Text('Limpar Categoria', style: TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
              onPressed: () => notifier.setCategory('Todas'),
            ),
          ],
          const SizedBox(width: 8),

          // 2. Menu Dropdown de Status
          PopupMenuButton<String>(
            tooltip: 'Filtrar por Status',
            onSelected: notifier.setStatus,
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: '', child: Text('Todos os Status')),
              const PopupMenuItem(value: 'ready', child: Text('Pronto p/ Ministrar')),
              const PopupMenuItem(value: 'in_review', child: Text('Em Revisão')),
              const PopupMenuItem(value: 'draft', child: Text('Rascunho')),
            ],
            child: Chip(
              avatar: const Icon(Icons.flag_outlined, size: 15),
              label: Text(
                state.selectedStatus.isEmpty
                    ? 'Status: Todos'
                    : 'Status: ${_formatStatusName(state.selectedStatus)}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Chip Rápido de Favoritos
          FilterChip(
            avatar: Icon(
              state.onlyFavorites ? Icons.star : Icons.star_border,
              size: 15,
              color: state.onlyFavorites ? AppColors.accentGold : Colors.grey,
            ),
            label: Text('Favoritos (${state.favoriteSermons.length})', style: const TextStyle(fontSize: 12)),
            selected: state.onlyFavorites,
            selectedColor: AppColors.accentGold.withValues(alpha: 0.2),
            onSelected: (_) => notifier.toggleOnlyFavorites(),
          ),
          const SizedBox(width: 8),

          // 4. Chip Rápido de Já Ministrados
          FilterChip(
            avatar: const Icon(Icons.mic, size: 15),
            label: Text(
              'Ministrados (${state.allSermons.where((s) => s.preachCount > 0).length})',
              style: const TextStyle(fontSize: 12),
            ),
            selected: state.onlyPreached,
            selectedColor: AppColors.primaryBlue.withValues(alpha: 0.18),
            onSelected: (_) => notifier.toggleOnlyPreached(),
          ),

          // 5. Botão Limpar Filtros
          if (state.isAnyFilterActive) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: Colors.red.shade400,
              ),
              icon: const Icon(Icons.filter_alt_off, size: 14),
              label: const Text('Limpar Filtros', style: TextStyle(fontSize: 12)),
              onPressed: () {
                _searchController.clear();
                notifier.resetFilters();
              },
            ),
          ],
        ],
      ),
    );
  }

  // DIÁLOGO BUSCÁVEL DE CATEGORIAS (UX PROFISSIONAL PARA DEZENAS DE CATEGORIAS)
  void _showCategoryPickerDialog(
    BuildContext context,
    SermonListState state,
    SermonListNotifier notifier,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final categories = state.activeCategoriesWithCounts.entries.where((e) {
              if (query.trim().isEmpty) return true;
              return e.key.toLowerCase().contains(query.toLowerCase().trim());
            }).toList();

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.folder_outlined, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Text('Filtrar por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 440,
                height: 480,
                child: Column(
                  children: [
                    TextField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar categoria...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () => setDialogState(() => query = ''),
                              )
                            : null,
                      ),
                      onChanged: (val) => setDialogState(() => query = val),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.all_inclusive, size: 18, color: AppColors.primaryBlue),
                            title: const Text('Todas as Categorias', style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Badge(
                              label: Text('${state.totalSermons}'),
                              backgroundColor: AppColors.primaryBlue,
                            ),
                            selected: state.selectedCategory == 'Todas',
                            onTap: () {
                              Navigator.pop(ctx);
                              notifier.setCategory('Todas');
                            },
                          ),
                          const Divider(),
                          ...categories.map((entry) {
                            final isSel = state.selectedCategory.toLowerCase() == entry.key.toLowerCase();
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                isSel ? Icons.check_circle : Icons.folder,
                                size: 18,
                                color: isSel ? AppColors.accentGold : Colors.grey,
                              ),
                              title: Text(entry.key),
                              trailing: Badge(
                                label: Text('${entry.value}'),
                                backgroundColor: isSel ? AppColors.accentGold : Colors.grey.shade600,
                              ),
                              selected: isSel,
                              onTap: () {
                                Navigator.pop(ctx);
                                notifier.setCategory(entry.key);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatStatusName(String status) {
    switch (status) {
      case 'ready':
        return 'Pronto';
      case 'in_review':
        return 'Em Revisão';
      case 'draft':
        return 'Rascunho';
      default:
        return status;
    }
  }
}
