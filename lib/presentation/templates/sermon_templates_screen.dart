import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/sermon_block.dart';
import '../../models/sermon_model.dart';
import '../../models/sermon_template_model.dart';
import '../../providers/templates_provider.dart';
import '../editor/sermon_editor_screen.dart';

class SermonTemplatesScreen extends ConsumerWidget {
  const SermonTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acervo de Modelos Homiléticos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar modelos: $err')),
        data: (templates) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final tpl = templates[index];
              return _buildTemplateCard(context, tpl, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, SermonTemplate template, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
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
                    template.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    template.sermonType,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Tema: ${template.theme}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.bookmark_border, size: 16, color: AppColors.accentGold),
                const SizedBox(width: 6),
                Text(
                  template.keyVerse,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: template.tags.map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Usar este Modelo'),
                  onPressed: () => _useTemplate(context, template),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _useTemplate(BuildContext context, SermonTemplate template) {
    final rawBlocks = (template.content['blocks'] as List<dynamic>?) ?? [];
    final blocks = rawBlocks
        .map((b) => HomileticBlock.fromJson(b as Map<String, dynamic>))
        .toList();

    final newSermon = Sermon(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'pastor-local-01',
      title: template.title,
      biblicalReference: template.keyVerse,
      sermonType: template.sermonType,
      category: template.tags.isNotEmpty ? template.tags.first : 'Geral',
      introduction: template.content['introduction'] as String? ?? '',
      blocks: blocks,
      conclusion: template.content['conclusion'] as String? ?? '',
      appeal: template.content['appeal'] as String? ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SermonEditorScreen(initialSermon: newSermon),
      ),
    );
  }
}
