import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/sermon_block.dart';

class HomileticBlockCard extends StatelessWidget {
  final int index;
  final HomileticBlock block;
  final ValueChanged<HomileticBlock> onChanged;
  final VoidCallback onRemove;

  const HomileticBlockCard({
    super.key,
    required this.index,
    required this.block,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do Bloco
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.homileticPoint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ponto ${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.homileticPoint,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: block.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Título do Ponto (Ex: 1. O Chamado à Oração)',
                      border: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => onChanged(block.copyWith(title: val)),
                  ),
                ),
                IconButton(
                  tooltip: 'Remover Ponto',
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: onRemove,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Versículo Específico do Ponto
            TextFormField(
              initialValue: block.biblicalReference,
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.bookmark_border, size: 18),
                hintText: 'Versículo específico do ponto (Ex: v. 6a)',
                isDense: true,
              ),
              onChanged: (val) => onChanged(block.copyWith(biblicalReference: val)),
            ),

            const SizedBox(height: 12),

            // Explanação Teológica
            const Text(
              'Explanação Teológica / Exegética:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: block.explanation,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Explicação detalhada do texto, contexto histórico e doutrina...',
              ),
              onChanged: (val) => onChanged(block.copyWith(explanation: val)),
            ),

            const SizedBox(height: 12),

            // Ilustração Prática
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: AppColors.homileticIllustration),
                SizedBox(width: 6),
                Text(
                  'Ilustração Prática:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.homileticIllustration,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: block.illustration,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Metáfora, história real ou analogia cotidiana para fixar a verdade...',
              ),
              onChanged: (val) => onChanged(block.copyWith(illustration: val)),
            ),

            const SizedBox(height: 12),

            // Aplicação Prática
            const Row(
              children: [
                Icon(Icons.ads_click, size: 16, color: AppColors.homileticApplication),
                SizedBox(width: 6),
                Text(
                  'Aplicação para a Vida do Ouvinte:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.homileticApplication,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: block.application,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'O que o ouvinte deve fazer na prática segunda-feira de manhã?',
              ),
              onChanged: (val) => onChanged(block.copyWith(application: val)),
            ),
          ],
        ),
      ),
    );
  }
}
