import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class BiblicalPickerBar extends StatelessWidget {
  final String currentReference;
  final ValueChanged<String> onReferenceChanged;
  final ValueChanged<String>? onBookPickedFromModal;

  const BiblicalPickerBar({
    super.key,
    required this.currentReference,
    required this.onReferenceChanged,
    this.onBookPickedFromModal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: currentReference,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Ex: Romanos 8:28-39 ou Filipenses 4:6-7',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
              onChanged: onReferenceChanged,
            ),
          ),
          IconButton(
            tooltip: 'Selecionar Livro da Bíblia',
            icon: const Icon(Icons.list, color: AppColors.accentGold),
            onPressed: () => _showBookSelectorModal(context),
          ),
        ],
      ),
    );
  }

  void _showBookSelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DefaultTabController(
          length: 2,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Selecione o Livro Bíblico',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'Antigo Testamento (39)'),
                    Tab(text: 'Novo Testamento (27)'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBooksGrid(ctx, AppConstants.oldTestamentBooks),
                      _buildBooksGrid(ctx, AppConstants.newTestamentBooks),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBooksGrid(BuildContext context, List<String> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return InkWell(
          onTap: () {
            Navigator.pop(context);
            final newRef = '$book 1:1';
            if (onBookPickedFromModal != null) {
              onBookPickedFromModal!(newRef);
            } else {
              onReferenceChanged(newRef);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
            ),
            child: Text(
              book,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
