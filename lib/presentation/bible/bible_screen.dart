import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/bible_model.dart';
import '../../providers/bible_provider.dart';
import 'widgets/bible_quick_selector_sheet.dart';
import 'widgets/bible_verse_actions_dialog.dart';

class BibleScreen extends ConsumerStatefulWidget {
  final Function(BibleVerse verse)? onVerseSelectedForSermon;

  const BibleScreen({
    super.key,
    this.onVerseSelectedForSermon,
  });

  @override
  ConsumerState<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends ConsumerState<BibleScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openQuickSelector(BibleState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BibleQuickSelectorSheet(
        currentBookId: state.selectedBookId,
        currentChapter: state.selectedChapter,
        onSelected: (bookId, chapter) {
          ref.read(bibleStateProvider.notifier).selectBook(bookId);
          ref.read(bibleStateProvider.notifier).selectChapter(chapter);
          _scrollToTop();
        },
      ),
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bibleStateProvider);
    final versesAsync = ref.watch(currentChapterVersesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openQuickSelector(state),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book, size: 20, color: AppColors.accentGold),
                const SizedBox(width: 8),
                Text(
                  state.currentReference,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
        actions: [
          // Seletor de Tradução (ARC, NVI, ACF)
          PopupMenuButton<String>(
            tooltip: 'Alternar Versão da Bíblia',
            initialValue: state.selectedVersion,
            onSelected: (version) {
              ref.read(bibleStateProvider.notifier).setVersion(version);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ARC',
                child: Text('ARC (Revista e Corrigida)'),
              ),
              const PopupMenuItem(
                value: 'NVI',
                child: Text('NVI (Nova Versão Internacional)'),
              ),
              const PopupMenuItem(
                value: 'ACF',
                child: Text('ACF (Corrigida Fiel)'),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.selectedVersion,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),

          // Alternar Barra de Busca
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
            tooltip: 'Buscar na Bíblia',
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  ref.read(bibleStateProvider.notifier).clearSearch();
                }
              });
            },
          ),

          // Menu de Tipografia (Tamanho da Fonte)
          PopupMenuButton<double>(
            tooltip: 'Ajustar Tamanho da Fonte',
            icon: const Icon(Icons.format_size),
            onSelected: (size) {
              ref.read(bibleStateProvider.notifier).setFontSize(size);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 15.0, child: Text('Texto Pequeno (15px)')),
              const PopupMenuItem(value: 18.0, child: Text('Texto Padrão (18px)')),
              const PopupMenuItem(value: 22.0, child: Text('Texto Grande (22px)')),
              const PopupMenuItem(value: 26.0, child: Text('Modo Púlpito (26px)')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Pesquisa Condicional
          if (_isSearchVisible)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onSubmitted: (query) {
                  ref.read(bibleStateProvider.notifier).search(query);
                },
                decoration: InputDecoration(
                  hintText: 'Digite palavra ou frase (ex: "todas as coisas")...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(bibleStateProvider.notifier).clearSearch();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
              ),
            ),

          // Banner de Resultados de Busca
          if (state.searchQuery.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.accentGold.withValues(alpha: 0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resultados para "${state.searchQuery}": ${state.searchResults.length} encontrados',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(bibleStateProvider.notifier).clearSearch();
                    },
                    child: const Text('Voltar à Leitura', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Corpo Principal
          Expanded(
            child: state.searchQuery.isNotEmpty
                ? _buildSearchResults(state, isDark)
                : versesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Text('Erro ao carregar versículos: $err'),
                    ),
                    data: (verses) {
                      if (verses.isEmpty) {
                        return const Center(child: Text('Nenhum texto disponível.'));
                      }
                      return _buildVersesList(verses, state, isDark);
                    },
                  ),
          ),

          // Barra Inferior de Navegação entre Capítulos
          if (state.searchQuery.isEmpty)
            _buildBottomChapterBar(state, isDark),
        ],
      ),
    );
  }

  Widget _buildVersesList(
    List<BibleVerse> verses,
    BibleState state,
    bool isDark,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];
        final isBookmarked = state.bookmarks.any(
          (b) =>
              b.bookId.toLowerCase() == verse.bookId.toLowerCase() &&
              b.chapter == verse.chapter &&
              b.verse == verse.verse,
        );

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _showVerseActions(verse, isBookmarked);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isBookmarked
                  ? AppColors.accentGold.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Número do Versículo em Destaque
                Container(
                  width: 32,
                  margin: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${verse.verse}',
                    style: TextStyle(
                      fontSize: state.fontSize * 0.75,
                      fontWeight: FontWeight.bold,
                      color: isBookmarked ? AppColors.accentGold : AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Texto do Versículo com Tipografia Ajustável
                Expanded(
                  child: Text(
                    verse.text,
                    style: TextStyle(
                      fontSize: state.fontSize,
                      height: 1.5,
                      color: isDark ? Colors.grey[100] : Colors.grey[900],
                      letterSpacing: 0.1,
                    ),
                  ),
                ),

                if (isBookmarked)
                  const Padding(
                    padding: EdgeInsets.only(left: 6, top: 4),
                    child: Icon(Icons.bookmark, size: 16, color: AppColors.accentGold),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(BibleState state, bool isDark) {
    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.searchResults.isEmpty) {
      return const Center(
        child: Text('Nenhum versículo encontrado para os termos pesquisados.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final verse = state.searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  verse.reference,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                Text(
                  verse.version,
                  style: const TextStyle(fontSize: 11, color: AppColors.accentGold),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                verse.text,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              // Navega diretamente para o livro e capítulo do resultado
              ref.read(bibleStateProvider.notifier).selectBook(verse.bookId);
              ref.read(bibleStateProvider.notifier).selectChapter(verse.chapter);
              ref.read(bibleStateProvider.notifier).clearSearch();
              _scrollToTop();
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomChapterBar(BibleState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: state.hasPreviousChapter
                ? () {
                    ref.read(bibleStateProvider.notifier).previousChapter();
                    _scrollToTop();
                  }
                : null,
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text('Cap. Anterior'),
          ),
          Text(
            state.currentReference,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          TextButton.icon(
            onPressed: state.hasNextChapter
                ? () {
                    ref.read(bibleStateProvider.notifier).nextChapter();
                    _scrollToTop();
                  }
                : null,
            label: const Text('Próx. Cap.'),
            icon: const Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }

  void _showVerseActions(BibleVerse verse, bool isBookmarked) {
    showDialog(
      context: context,
      builder: (_) => BibleVerseActionsDialog(
        verse: verse,
        isBookmarked: isBookmarked,
        onToggleBookmark: () {
          ref.read(bibleStateProvider.notifier).toggleBookmark(verse);
        },
        onInsertToSermon: widget.onVerseSelectedForSermon,
      ),
    );
  }
}
