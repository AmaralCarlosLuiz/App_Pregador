import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/services/pdf_export_service.dart';
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
        title: const Text('Biblioteca de Sermões', style: TextStyle(fontWeight: FontWeight.bold)),
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
        children: [
          // 1. BARRA DE BUSCA INSTANTÂNEA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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

          // 2. CHIPS DE FILTRO POR CATEGORIA
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AppConstants.sermonCategories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.sermonCategories[index];
                final isSelected = sermonState.selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      sermonNotifier.setCategory(category);
                    },
                    selectedColor: AppColors.accentGold.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.accentGold,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? (isDark ? AppColors.goldLight : AppColors.goldDark)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? (isDark ? AppColors.surfaceVariantDark : const Color(0xFFEFF6FF))
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.primaryBlue
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sermon.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      sermon.isFavorite ? Icons.star : Icons.star_border,
                      size: 20,
                      color: sermon.isFavorite ? AppColors.accentGold : Colors.grey,
                    ),
                    onPressed: () {
                      ref.read(sermonListProvider.notifier).toggleFavorite(sermon.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    sermon.biblicalReference,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sermon.category,
                      style: const TextStyle(fontSize: 10, color: AppColors.accentGold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${sermon.blocks.length} pontos • ${sermon.estimatedDurationMinutes} min',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  if (sermon.preachCount > 0)
                    Text(
                      'Pregado ${sermon.preachCount}x',
                      style: const TextStyle(fontSize: 11, color: AppColors.statusReady, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ],
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
}
