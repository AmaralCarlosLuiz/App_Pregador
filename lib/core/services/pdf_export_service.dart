import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/sermon_model.dart';

class PdfExportService {
  /// Gera documento PDF formatado em A4 e abre caixa de diálogo de impressão / compartilhamento
  static Future<void> exportAndPrintSermon(Sermon sermon) async {
    try {
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
          header: (context) => _buildHeader(sermon),
          footer: (context) => _buildFooter(context),
          build: (context) => [
            if (sermon.introduction.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _buildSectionTitle('1. INTRODUÇÃO'),
              pw.SizedBox(height: 4),
              pw.Text(
                sermon.introduction,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
              ),
              pw.SizedBox(height: 14),
            ],

            _buildSectionTitle('2. DESENVOLVIMENTO HOMILÉTICO'),
            pw.SizedBox(height: 8),

            ...sermon.blocks.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final block = entry.value;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '$idx. ${block.title}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                    if (block.biblicalReference.isNotEmpty) ...[
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Texto: ${block.biblicalReference}',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ],
                    if (block.explanation.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Explanação: ${block.explanation}',
                        style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 1.5),
                      ),
                    ],
                    if (block.illustration.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Ilustração: ${block.illustration}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.purple900),
                      ),
                    ],
                    if (block.application.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Aplicação: ${block.application}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.green900),
                      ),
                    ],
                  ],
                ),
              );
            }),

            if (sermon.conclusion.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _buildSectionTitle('3. CONCLUSÃO'),
              pw.SizedBox(height: 4),
              pw.Text(
                sermon.conclusion,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
              ),
            ],

            if (sermon.appeal.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _buildSectionTitle('4. APELO E MINISTRAÇÃO'),
              pw.SizedBox(height: 4),
              pw.Text(
                sermon.appeal,
                style: const pw.TextStyle(
                  fontSize: 11,
                  fontStyle: pw.FontStyle.italic,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: '${sermon.title.replaceAll(' ', '_')}.pdf',
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
              style: const pw.TextStyle(
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
          sermon.title,
          style: const pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Text(
              'Texto Base: ${sermon.biblicalReference}',
              style: const pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(width: 14),
            pw.Text(
              'Tipo: ${sermon.sermonType}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(width: 14),
            pw.Text(
              'Categoria: ${sermon.category}',
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
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: const pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }
}
