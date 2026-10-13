import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/bible_model.dart';

class BibleVerseActionsDialog extends StatelessWidget {
  final BibleVerse verse;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final Function(BibleVerse verse)? onInsertToSermon;

  const BibleVerseActionsDialog({
    super.key,
    required this.verse,
    required this.isBookmarked,
    required this.onToggleBookmark,
    this.onInsertToSermon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                verse.reference,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              verse.version,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.accentGold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Text(
              '"${verse.text}"',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de Ações
          ListTile(
            dense: true,
            leading: const Icon(Icons.copy, size: 20, color: AppColors.primaryBlue),
            title: const Text('Copiar com Referência'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: verse.formattedCitation));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Versículo copiado para a área de transferência!'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            dense: true,
            leading: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
              color: AppColors.accentGold,
            ),
            title: Text(isBookmarked ? 'Remover Marcador' : 'Destacar / Salvar Marcador'),
            onTap: () {
              onToggleBookmark();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBookmarked
                        ? 'Marcador removido.'
                        : 'Versículo destacado nos seus marcadores!',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.share, size: 20, color: Colors.teal),
            title: const Text('Compartilhar Versículo'),
            onTap: () {
              Navigator.of(context).pop();
              Share.share(verse.formattedCitation);
            },
          ),
          if (onInsertToSermon != null)
            ListTile(
              dense: true,
              leading: const Icon(Icons.note_add, size: 20, color: AppColors.homileticPoint),
              title: const Text(
                'Inserir no Sermão Aberto',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.homileticPoint),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onInsertToSermon!(verse);
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
