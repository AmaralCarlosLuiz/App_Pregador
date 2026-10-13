import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/bible_model.dart';
import '../../../repositories/bible_repository.dart';

class BibleQuickSelectorSheet extends StatefulWidget {
  final String currentBookId;
  final int currentChapter;
  final Function(String bookId, int chapter) onSelected;

  const BibleQuickSelectorSheet({
    super.key,
    required this.currentBookId,
    required this.currentChapter,
    required this.onSelected,
  });

  @override
  State<BibleQuickSelectorSheet> createState() => _BibleQuickSelectorSheetState();
}

class _BibleQuickSelectorSheetState extends State<BibleQuickSelectorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  BibleBookMetadata? _selectedBookForChapters;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Inicializa com o livro atual se quiser ver os capítulos
    final current = BibleRepository.getBookMetadata(widget.currentBookId);
    if (current != null) {
      if (current.isNewTestament) {
        _tabController.index = 1;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _searchController.text.toLowerCase().trim();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cabeçalho
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                if (_selectedBookForChapters != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() => _selectedBookForChapters = null);
                    },
                  ),
                Expanded(
                  child: Text(
                    _selectedBookForChapters != null
                        ? '${_selectedBookForChapters!.name} — Selecione o Capítulo'
                        : 'Selecionar Livro e Capítulo',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Se estiver na tela de seleção de capítulos
          if (_selectedBookForChapters != null)
            Expanded(
              child: _buildChaptersGrid(_selectedBookForChapters!, isDark),
            )
          else ...[
            // Barra de Busca de Livros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Filtrar livro (ex: Rom, Sal, Mat)...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Abas AT / NT
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryBlue,
              tabs: const [
                Tab(text: 'Antigo Testamento (39)'),
                Tab(text: 'Novo Testamento (27)'),
              ],
            ),

            // Lista de Livros
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBooksList(
                    BibleRepository.canonicalBooks
                        .where((b) => b.isOldTestament)
                        .where((b) => b.name.toLowerCase().contains(query))
                        .toList(),
                    isDark,
                  ),
                  _buildBooksList(
                    BibleRepository.canonicalBooks
                        .where((b) => b.isNewTestament)
                        .where((b) => b.name.toLowerCase().contains(query))
                        .toList(),
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBooksList(List<BibleBookMetadata> books, bool isDark) {
    if (books.isEmpty) {
      return const Center(child: Text('Nenhum livro encontrado'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isCurrent = book.id.toLowerCase() == widget.currentBookId.toLowerCase();

        return ListTile(
          dense: true,
          leading: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primaryBlue
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              book.id.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.white : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          title: Text(
            book.name,
            style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isCurrent ? AppColors.primaryBlue : null,
            ),
          ),
          subtitle: Text(
            '${book.category} • ${book.totalChapters} capítulos',
            style: const TextStyle(fontSize: 11),
          ),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () {
            setState(() {
              _selectedBookForChapters = book;
            });
          },
        );
      },
    );
  }

  Widget _buildChaptersGrid(BibleBookMetadata book, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 65,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: book.totalChapters,
      itemBuilder: (context, index) {
        final chapterNum = index + 1;
        final isSelected = book.id.toLowerCase() == widget.currentBookId.toLowerCase() &&
            chapterNum == widget.currentChapter;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            widget.onSelected(book.id, chapterNum);
            Navigator.of(context).pop();
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryBlue
                  : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryBlue
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
            ),
            child: Text(
              '$chapterNum',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        );
      },
    );
  }
}
