import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../../models/sermon_model.dart';
import '../../repositories/sermon_repository.dart';

class BackupResult {
  final bool success;
  final int restoredCount;
  final String message;

  const BackupResult({
    required this.success,
    this.restoredCount = 0,
    required this.message,
  });
}

class BackupService {
  /// Gera JSON completo de backup de todos os sermões locais e da nuvem
  static Future<String> generateBackupJson(SermonRepository repository) async {
    final sermons = await repository.getSermons();
    final backupData = {
      'app': 'Pregador Pro',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'total_sermons': sermons.length,
      'sermons': sermons.map((s) => s.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  /// Compartilha o backup como arquivo de texto/JSON para salvar no Drive, iCloud, WhatsApp ou Email
  static Future<void> shareBackup(SermonRepository repository) async {
    final jsonString = await generateBackupJson(repository);
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final fileName = 'backup_pregador_pro_$dateStr.json';

    await Share.share(
      jsonString,
      subject: 'Ponto de Restauração - Pregador Pro ($fileName)',
    );
  }

  /// Restaura sermões a partir de um JSON de backup com validação de esquema
  static Future<BackupResult> restoreBackupFromJson(
    String jsonString,
    SermonRepository repository,
  ) async {
    try {
      if (jsonString.trim().isEmpty) {
        return const BackupResult(
          success: false,
          message: 'O conteúdo do backup está vazio.',
        );
      }

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return const BackupResult(
          success: false,
          message: 'Formato de arquivo inválido. Esperava-se um JSON estruturado.',
        );
      }

      final rawSermons = decoded['sermons'];
      if (rawSermons is! List) {
        return const BackupResult(
          success: false,
          message: 'Nenhum sermão encontrado dentro do arquivo de backup.',
        );
      }

      int imported = 0;
      for (final item in rawSermons) {
        if (item is Map<String, dynamic>) {
          try {
            final sermon = Sermon.fromJson(item);
            await repository.saveSermon(sermon);
            imported++;
          } catch (_) {
            // Ignora itens individuais corrompidos
          }
        }
      }

      if (imported == 0) {
        return const BackupResult(
          success: false,
          message: 'Nenhum sermão válido pôde ser importado deste arquivo.',
        );
      }

      return BackupResult(
        success: true,
        restoredCount: imported,
        message: '$imported sermões restaurados com sucesso para o seu acervo.',
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Falha ao processar o backup: ${e.toString()}',
      );
    }
  }
}
