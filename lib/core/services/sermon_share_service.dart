import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sermon_model.dart';
import '../constants/app_colors.dart';
import 'pdf_export_service.dart';

class SermonShareService {
  /// Gera a mensagem formatada especialmente para o WhatsApp (com negritos * e itálicos _)
  static String formatSermonForWhatsApp(Sermon sermon, {bool isSummary = false}) {
    final buffer = StringBuffer();

    buffer.writeln('📖 *${sermon.title.toUpperCase()}*');
    buffer.writeln('📍 *Texto Bíblico:* ${sermon.biblicalReference}');
    buffer.writeln('🏷️ *Tipo:* ${sermon.sermonType} | *Categoria:* ${sermon.category}');
    buffer.writeln();

    if (sermon.introduction.isNotEmpty) {
      buffer.writeln('*INTRODUÇÃO:*');
      buffer.writeln(sermon.introduction.trim());
      buffer.writeln();
    }

    if (sermon.blocks.isNotEmpty) {
      buffer.writeln('*DIVISÕES HOMILÉTICAS:*');
      for (int i = 0; i < sermon.blocks.length; i++) {
        final b = sermon.blocks[i];
        final numEmoji = _getNumberEmoji(i + 1);
        buffer.writeln();
        buffer.writeln('$numEmoji *${b.title}*');
        if (b.biblicalReference.isNotEmpty && b.biblicalReference != sermon.biblicalReference) {
          buffer.writeln('📖 _Ref: ${b.biblicalReference}_');
        }
        if (b.explanation.isNotEmpty) {
          buffer.writeln(b.explanation.trim());
        }
        if (!isSummary) {
          if (b.illustration.isNotEmpty) {
            buffer.writeln('💡 *Ilustração:* ${b.illustration.trim()}');
          }
          if (b.application.isNotEmpty) {
            buffer.writeln('🎯 *Aplicação:* ${b.application.trim()}');
          }
        }
      }
      buffer.writeln();
    }

    if (sermon.conclusion.isNotEmpty) {
      buffer.writeln('*CONCLUSÃO:*');
      buffer.writeln(sermon.conclusion.trim());
      buffer.writeln();
    }

    if (sermon.appeal.isNotEmpty) {
      buffer.writeln('*APELO & ORAÇÃO:*');
      buffer.writeln(sermon.appeal.trim());
      buffer.writeln();
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('_Preparado na Plataforma Pregador Pro_');

    return buffer.toString();
  }

  static String _getNumberEmoji(int n) {
    switch (n) {
      case 1:
        return '1️⃣';
      case 2:
        return '2️⃣';
      case 3:
        return '3️⃣';
      case 4:
        return '4️⃣';
      case 5:
        return '5️⃣';
      default:
        return '$n.';
    }
  }

  /// Compartilha o sermão diretamente no WhatsApp
  static Future<void> shareViaWhatsApp(BuildContext context, Sermon sermon) async {
    // Para URL Web do WhatsApp, usamos a versão essencial para não exceder limites de query string
    var text = formatSermonForWhatsApp(sermon, isSummary: false);
    if (text.length > 2800) {
      text = formatSermonForWhatsApp(sermon, isSummary: true);
    }

    final encodedText = Uri.encodeComponent(text);
    final whatsappUrl = Uri.parse('https://api.whatsapp.com/send?text=$encodedText');

    try {
      final launched = await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback: copia para área de transferência e avisa o usuário
        await Clipboard.setData(ClipboardData(text: text));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o WhatsApp automaticamente. O texto foi copiado para a área de transferência!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Texto do sermão copiado para a área de transferência. Cole no WhatsApp!'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    }
  }

  /// Exibe o Modal Completo de Compartilhamento
  static void showShareOptionsModal(BuildContext context, Sermon sermon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.share, color: AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Compartilhar: ${sermon.title}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // 1. WHATSAPP (Destaque Principal com cor oficial #25D366)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble, color: Color(0xFF25D366), size: 22),
                  ),
                  title: const Text(
                    'Compartilhar no WhatsApp',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text('Envia mensagem formatada com texto bíblico e tópicos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.pop(ctx);
                    shareViaWhatsApp(context, sermon);
                  },
                ),

                // 2. COPIAR TEXTO FORMATADO (Área de Transferência)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.copy, color: AppColors.primaryBlue, size: 22),
                  ),
                  title: const Text(
                    'Copiar Esboço Formatado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text('Copia todo o sermão para colar onde desejar'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final formatted = formatSermonForWhatsApp(sermon);
                    await Clipboard.setData(ClipboardData(text: formatted));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Esboço completo copiado para a área de transferência!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),

                // 3. COMPARTILHAR PELO SISTEMA (Nativo)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.purple, size: 22),
                  ),
                  title: const Text(
                    'Mais Opções do Sistema',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text('Outros aplicativos (Email, Telegram, Redes)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.pop(ctx);
                    Share.share(sermon.toMarkdown(), subject: sermon.title);
                  },
                ),

                // 4. EXPORTAR PDF / IMPRIMIR
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 22),
                  ),
                  title: const Text(
                    'Exportar PDF / Imprimir',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text('Gera documento A4 formatado para impressão'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.pop(ctx);
                    PdfExportService.exportAndPrintSermon(sermon);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
