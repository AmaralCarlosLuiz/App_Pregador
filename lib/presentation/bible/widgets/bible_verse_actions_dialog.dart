import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/bible_model.dart';
import '../../../providers/bible_tts_provider.dart';

class BibleVerseActionsDialog extends StatelessWidget {
  final BibleVerse verse;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final Function(BibleVerse verse)? onInsertToSermon;
  final Function(BibleVoiceGender gender)? onSpeakVerse;
  final VoidCallback? onSpeakFromHere;
  final VoidCallback? onStartExcerptSelection;

  const BibleVerseActionsDialog({
    super.key,
    required this.verse,
    required this.isBookmarked,
    required this.onToggleBookmark,
    this.onInsertToSermon,
    this.onSpeakVerse,
    this.onSpeakFromHere,
    this.onStartExcerptSelection,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    verse.reference,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: 14),

              // Bloco de Leitura em Voz Humana (Brasil / RJ)
              if (onSpeakVerse != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.12),
                        AppColors.accentGold.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.record_voice_over, size: 16, color: AppColors.accentGold),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Leitura em Voz Humana (Brasil • RJ)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onSpeakVerse!(BibleVoiceGender.male);
                              },
                              icon: const Icon(Icons.mic, size: 16),
                              label: const Text(
                                'Voz Masculina',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onSpeakVerse!(BibleVoiceGender.female);
                              },
                              icon: const Icon(Icons.spatial_audio_off, size: 16),
                              label: const Text(
                                'Voz Feminina',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (onSpeakFromHere != null)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.play_circle_fill, size: 20, color: AppColors.accentGold),
                  title: const Text(
                    'Ler Capítulo a partir deste Versículo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSpeakFromHere!();
                  },
                ),

              if (onStartExcerptSelection != null)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.checklist_rtl, size: 20, color: AppColors.primaryBlue),
                  title: const Text('Selecionar Trecho (Vários Versículos) p/ Ouvir'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onStartExcerptSelection!();
                  },
                ),

              const Divider(height: 12),

              // Lista de Ações Clássicas
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
                leading: const Icon(Icons.chat_bubble, size: 20, color: Color(0xFF25D366)),
                title: const Text('Enviar pelo WhatsApp'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final text =
                      '📖 *${verse.bookName} ${verse.chapter}:${verse.verse}*\n"${verse.text}"\n\n_Compartilhado via Pregador Pro_';
                  final url = Uri.parse(
                    'https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}',
                  );
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (_) {
                    await Clipboard.setData(ClipboardData(text: text));
                  }
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.share, size: 20, color: Colors.teal),
                title: const Text('Mais Opções de Compartilhar'),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.homileticPoint,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onInsertToSermon!(verse);
                  },
                ),
            ],
          ),
        ),
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
