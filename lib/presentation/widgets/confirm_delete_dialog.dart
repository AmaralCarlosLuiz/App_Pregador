import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/sermon_model.dart';
import '../../providers/sermon_provider.dart';

/// Exibe um diálogo de confirmação seguro antes de excluir um sermão ou modelo.
Future<bool> showConfirmDeleteDialog(
  BuildContext context, {
  required String itemLabel,
  required String itemTitle,
  String? extraNote,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Excluir $itemLabel?',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.45),
                children: [
                  const TextSpan(text: 'Tem certeza que deseja excluir '),
                  TextSpan(
                    text: '"$itemTitle"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            if (extraNote != null) ...[
              const SizedBox(height: 8),
              Text(
                extraNote,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever, size: 17),
            label: const Text('Excluir'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}

/// Fluxo completo de confirmação, exclusão e SnackBar com opção "Desfazer" para sermões.
Future<bool> confirmAndDeleteSermon({
  required BuildContext context,
  required WidgetRef ref,
  required Sermon sermon,
  VoidCallback? onBeforeDelete,
}) async {
  final confirmed = await showConfirmDeleteDialog(
    context,
    itemLabel: 'Sermão',
    itemTitle: sermon.title.trim().isEmpty ? 'Novo Sermão' : sermon.title,
    extraNote: 'Você poderá desfazer esta ação logo em seguida se excluir por engano.',
  );
  if (!confirmed) return false;

  onBeforeDelete?.call();
  final messenger = context.mounted ? ScaffoldMessenger.of(context) : null;
  final notifier = ref.read(sermonListProvider.notifier);

  await notifier.deleteSermon(sermon.id);

  messenger?.clearSnackBars();
  messenger?.showSnackBar(
    SnackBar(
      content: Text('Sermão "${sermon.title}" excluído.'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: const Color(0xFFFBBF24),
        onPressed: () {
          notifier.restoreSermon(sermon);
        },
      ),
    ),
  );
  return true;
}

