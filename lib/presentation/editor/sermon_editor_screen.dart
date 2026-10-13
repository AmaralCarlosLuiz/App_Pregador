import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/services/pdf_export_service.dart';
import '../../models/sermon_model.dart';
import '../../providers/sermon_editor_provider.dart';
import '../ai_assistant/ai_assistant_sheet.dart';
import '../bible/bible_screen.dart';
import '../pulpit/pulpit_mode_screen.dart';
import 'widgets/biblical_picker_bar.dart';
import 'widgets/homiletic_block_card.dart';

class SermonEditorScreen extends ConsumerWidget {
  final Sermon initialSermon;

  const SermonEditorScreen({
    super.key,
    required this.initialSermon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(sermonEditorProvider(initialSermon));
    final editorNotifier = ref.read(sermonEditorProvider(initialSermon).notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = Breakpoints.isMobile(context);

    final sermon = editorState.sermon;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sermon.title.isEmpty ? 'Novo Sermão' : sermon.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                if (editorState.isSaving) ...[
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                  const SizedBox(width: 6),
                  const Text('Salvando...', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ] else if (editorState.hasUnsavedChanges) ...[
                  const Text('Modificações pendentes', style: TextStyle(fontSize: 11, color: AppColors.accentGold)),
                ] else ...[
                  const Icon(Icons.cloud_done_outlined, size: 12, color: AppColors.statusReady),
                  const SizedBox(width: 4),
                  const Text('Salvo (Offline & Nuvem)', style: TextStyle(fontSize: 11, color: AppColors.statusReady)),
                ],
              ],
            ),
          ],
        ),
        actions: [
          // Consultar Bíblia Sagrada
          IconButton(
            tooltip: 'Consultar Bíblia Sagrada',
            icon: const Icon(Icons.menu_book, color: AppColors.accentGold),
            onPressed: () => _openBibleReader(context, editorNotifier),
          ),

          // Assistente de IA
          IconButton(
            tooltip: 'Assistente de IA para Homilética',
            icon: const Icon(Icons.psychology_alt, color: Color(0xFF8B5CF6)),
            onPressed: () => _openAiAssistant(context, ref, editorNotifier, sermon),
          ),

          // Prévia Markdown
          IconButton(
            tooltip: 'Pré-visualização Markdown',
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () => _showMarkdownPreview(context, sermon),
          ),

          // Exportar PDF para Impressão A4
          IconButton(
            tooltip: 'Exportar PDF A4 / Imprimir',
            icon: const Icon(Icons.print_outlined),
            onPressed: () => PdfExportService.exportAndPrintSermon(sermon),
          ),

          // Compartilhar
          IconButton(
            tooltip: 'Compartilhar Texto',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share(sermon.toMarkdown(), subject: sermon.title);
            },
          ),

          const SizedBox(width: 8),

          // Botão Ir para o Púlpito
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              icon: const Icon(Icons.mic, size: 16),
              label: Text(isMobile ? 'Púlpito' : 'Modo Púlpito'),
              onPressed: () {
                editorNotifier.saveImmediately();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PulpitModeScreen(sermon: sermon),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 20,
            ),
            children: [
              // 1. TÍTULO DO SERMÃO
              TextFormField(
                initialValue: sermon.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Título do Sermão / Mensagem',
                  hintText: 'Ex: A Paz que Excede Todo Entendimento',
                ),
                onChanged: editorNotifier.updateTitle,
              ),

              const SizedBox(height: 16),

              // 2. TEXTO-BASE BÍBLICO (Com Seletor de Livros)
              const Text(
                'Texto-Base Bíblico:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              BiblicalPickerBar(
                currentReference: sermon.biblicalReference,
                onReferenceChanged: editorNotifier.updateBiblicalReference,
              ),

              const SizedBox(height: 16),

              // 3. METADADOS: CATEGORIA & TIPO HOMILÉTICO
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: AppConstants.sermonCategories.contains(sermon.category)
                          ? sermon.category
                          : 'Geral',
                      decoration: const InputDecoration(
                        labelText: 'Categoria Temática',
                        isDense: true,
                      ),
                      items: AppConstants.sermonCategories
                          .where((c) => c != 'Todas')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) editorNotifier.updateCategory(val);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: AppConstants.sermonTypes.contains(sermon.sermonType)
                          ? sermon.sermonType
                          : 'Expositivo',
                      decoration: const InputDecoration(
                        labelText: 'Tipo Homilético',
                        isDense: true,
                      ),
                      items: AppConstants.sermonTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) editorNotifier.updateSermonType(val);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. INTRODUÇÃO
              _buildSectionHeader(
                icon: Icons.menu_book,
                title: 'Introdução da Mensagem',
                color: AppColors.homileticIntro,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: sermon.introduction,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, height: 1.5),
                decoration: const InputDecoration(
                  hintText: 'Captação de atenção, problematização e ponte para o texto sagrado...',
                ),
                onChanged: editorNotifier.updateIntroduction,
              ),

              const SizedBox(height: 28),

              // 5. PONTOS PRINCIPAIS HOMILÉTICOS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(
                    icon: Icons.format_list_numbered,
                    title: 'Pontos Principais (${sermon.blocks.length})',
                    color: AppColors.homileticPoint,
                  ),
                  TextButton.icon(
                    onPressed: editorNotifier.addBlock,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar Ponto'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (sermon.blocks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          'Nenhum ponto homilético adicionado ainda.',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: editorNotifier.addBlock,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Criar Ponto 1'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...sermon.blocks.asMap().entries.map((entry) {
                  return HomileticBlockCard(
                    index: entry.key,
                    block: entry.value,
                    onChanged: (updated) => editorNotifier.updateBlock(entry.key, updated),
                    onRemove: () => editorNotifier.removeBlock(entry.key),
                  );
                }),

              const SizedBox(height: 24),

              // 6. CONCLUSÃO
              _buildSectionHeader(
                icon: Icons.flag_outlined,
                title: 'Conclusão',
                color: AppColors.homileticConclusion,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: sermon.conclusion,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, height: 1.5),
                decoration: const InputDecoration(
                  hintText: 'Recapitulação dos pontos e sintetização da mensagem central...',
                ),
                onChanged: editorNotifier.updateConclusion,
              ),

              const SizedBox(height: 24),

              // 7. APELO E CONVOCAÇÃO
              _buildSectionHeader(
                icon: Icons.favorite_border,
                title: 'Apelo & Oração Ministerial',
                color: AppColors.homileticAppeal,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: sermon.appeal,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, height: 1.5),
                decoration: const InputDecoration(
                  hintText: 'Chamada à decisão, oração pastoral e ministração do Espírito...',
                ),
                onChanged: editorNotifier.updateAppeal,
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showMarkdownPreview(BuildContext context, Sermon sermon) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(sermon.title),
          content: SizedBox(
            width: 600,
            height: 500,
            child: SingleChildScrollView(
              child: MarkdownBody(data: sermon.toMarkdown()),
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
  }

  void _openAiAssistant(
    BuildContext context,
    WidgetRef ref,
    SermonEditorNotifier notifier,
    Sermon currentSermon,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiAssistantSheet(
        initialTheme: currentSermon.title,
        initialReference: currentSermon.biblicalReference,
        onApplyGeneratedOutline: (outline) {
          notifier.updateTitle(outline.title);
          notifier.updateBiblicalReference(outline.biblicalReference);
          notifier.updateSermonType(outline.sermonType);
          notifier.updateIntroduction(outline.introduction);
          notifier.updateConclusion(outline.conclusion);
          notifier.updateAppeal(outline.appeal);

          // Substituir blocos
          for (var i = 0; i < outline.blocks.length; i++) {
            if (i < currentSermon.blocks.length) {
              notifier.updateBlock(i, outline.blocks[i]);
            } else {
              notifier.addBlock();
              notifier.updateBlock(i, outline.blocks[i]);
            }
          }
          notifier.saveImmediately();
        },
      ),
    );
  }

  void _openBibleReader(BuildContext context, SermonEditorNotifier editorNotifier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleScreen(
          onVerseSelectedForSermon: (verse) {
            editorNotifier.insertVerseBlock(verse);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Versículo ${verse.reference} inserido como novo ponto!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }
}
