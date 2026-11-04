import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/sermon_model.dart';

class PdfExportService {
  /// Sanitiza caracteres especiais/emojis fora do conjunto Latin-1 para evitar
  /// erros de glifo na fonte nativa Helvetica do motor PDF.
  static String _sanitizePdfText(String input) {
    return input
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('—', ' - ')
        .replaceAll('–', ' - ')
        .replaceAll('…', '...')
        .replaceAll('•', '-')
        // Remove emojis mantendo acentuação completa do Português (Latin-1 Supplement)
        .replaceAll(RegExp(r'[^\x00-\xFF]'), '')
        .trim();
  }

  /// Gera documento PDF formatado em A4 e abre caixa de diálogo de impressão / compartilhamento
  static Future<void> exportAndPrintSermon(Sermon sermon) async {
    try {
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          maxPages: 100,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
          header: (context) => _buildHeader(sermon),
          footer: (context) => _buildFooter(context),
          build: (context) => [
            if (sermon.introduction.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _buildSectionTitle('1. INTRODUÇÃO'),
              pw.SizedBox(height: 4),
              pw.Paragraph(
                text: _sanitizePdfText(sermon.introduction),
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
              ),
              pw.SizedBox(height: 10),
            ],

            _buildSectionTitle('2. DESENVOLVIMENTO HOMILÉTICO'),
            pw.SizedBox(height: 8),

            ...sermon.blocks.asMap().entries.expand((entry) {
              final idx = entry.key + 1;
              final block = entry.value;

              return <pw.Widget>[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.blue800, width: 3),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _sanitizePdfText('$idx. ${block.title}'),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      if (block.biblicalReference.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          _sanitizePdfText('Texto: ${block.biblicalReference}'),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.blue800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),
                if (block.explanation.isNotEmpty)
                  pw.Paragraph(
                    text: _sanitizePdfText('Explanação: ${block.explanation}'),
                    style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 1.5),
                    margin: const pw.EdgeInsets.only(left: 10, bottom: 4),
                  ),
                if (block.illustration.isNotEmpty)
                  pw.Paragraph(
                    text: _sanitizePdfText('Ilustração: ${block.illustration}'),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.purple900),
                    margin: const pw.EdgeInsets.only(left: 10, bottom: 4),
                  ),
                if (block.application.isNotEmpty)
                  pw.Paragraph(
                    text: _sanitizePdfText('Aplicação: ${block.application}'),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.green900),
                    margin: const pw.EdgeInsets.only(left: 10, bottom: 8),
                  ),
                pw.SizedBox(height: 6),
              ];
            }),

            if (sermon.conclusion.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _buildSectionTitle('3. CONCLUSÃO'),
              pw.SizedBox(height: 4),
              pw.Paragraph(
                text: _sanitizePdfText(sermon.conclusion),
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
              ),
            ],

            if (sermon.appeal.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _buildSectionTitle('4. APELO E MINISTRAÇÃO'),
              pw.SizedBox(height: 4),
              pw.Paragraph(
                text: _sanitizePdfText(sermon.appeal),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontStyle: pw.FontStyle.italic,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      );

      final safeFileName = _sanitizePdfText(sermon.title)
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: '${safeFileName.isEmpty ? "sermao" : safeFileName}.pdf',
      );
    } catch (e) {
      debugPrint('[PdfExportService] Erro ao exportar PDF: $e');
    }
  }

  static pw.Widget _buildHeader(Sermon sermon) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'PREGADOR PRO - ESBOÇO HOMILÉTICO',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey600,
              ),
            ),
            pw.Text(
              'Duração Estimada: ${sermon.estimatedDurationMinutes} min',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Divider(thickness: 1, color: PdfColors.blueGrey800),
        pw.SizedBox(height: 6),
        pw.Text(
          _sanitizePdfText(sermon.title),
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            pw.Text(
              _sanitizePdfText('Texto Base: ${sermon.biblicalReference}'),
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              _sanitizePdfText('Tipo: ${sermon.sermonType}'),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.Text(
              _sanitizePdfText('Categoria: ${sermon.category}'),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '© 2026 - Pregador Pro | Desenvolvido por Carlos Luiz Amaral',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      _sanitizePdfText(title),
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }
}
