import 'package:flutter_test/flutter_test.dart';
import 'package:pregador_pro/core/services/gemini_homiletics_agent.dart';
import 'package:pregador_pro/models/sermon_block.dart';
import 'package:pregador_pro/models/sermon_model.dart';
import 'package:pregador_pro/repositories/auth_repository.dart';
import 'package:pregador_pro/repositories/sermon_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Persistência de Sermões (Delta Storage & Ordenação)', () {
    test('Novo sermão e edições ficam no topo e sobrevivem a reinicialização', () async {
      final repo1 = SermonRepository();
      await repo1.init();

      final initialAll = await repo1.getAllSermons();
      expect(initialAll.length, 150);

      final now = DateTime.now();
      final custom = Sermon(
        id: 'sermon-user-test-1',
        userId: 'admin-master-01',
        title: 'Sermão Criado no iPhone',
        biblicalReference: 'Salmos 91:1-2',
        category: 'Fé',
        introduction: 'Introdução persistente',
        blocks: const [
          HomileticBlock(
            id: 'b1',
            title: '1. Abrigo no Altíssimo',
            explanation: 'Explanação detalhada',
            orderIndex: 0,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      await repo1.saveSermon(custom);

      // Nova instância simulando reabertura do app
      final repo2 = SermonRepository();
      await repo2.init();

      final allAfterRestart = await repo2.getSermons();
      expect(allAfterRestart.length, 151);
      expect(allAfterRestart.first.id, 'sermon-user-test-1');
      expect(allAfterRestart.first.title, 'Sermão Criado no iPhone');
      expect(allAfterRestart.first.blocks.first.title, '1. Abrigo no Altíssimo');
    });

    test('Edição em sermão existente do acervo sobrevive ao reiniciar', () async {
      final repo1 = SermonRepository();
      await repo1.init();

      final firstStarter = (await repo1.getAllSermons()).first;
      final edited = firstStarter.copyWith(
        title: 'Título Editado pelo Pastor',
        isFavorite: true,
        updatedAt: DateTime.now(),
      );
      await repo1.saveSermon(edited);

      final repo2 = SermonRepository();
      await repo2.init();
      final reloaded = await repo2.getSermonById(firstStarter.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.title, 'Título Editado pelo Pastor');
      expect(reloaded.isFavorite, isTrue);

      final ordered = await repo2.getSermons();
      expect(ordered.first.id, firstStarter.id);
    });

    test('Exclusão e restauração de sermão persistem após reinicialização', () async {
      final repo1 = SermonRepository();
      await repo1.init();

      final target = (await repo1.getAllSermons()).first;
      await repo1.deleteSermon(target.id);

      final repo2 = SermonRepository();
      await repo2.init();
      expect(await repo2.getSermonById(target.id), isNull);
      expect((await repo2.getAllSermons()).length, 149);

      await repo2.restoreSermon(target);
      expect(await repo2.getSermonById(target.id), isNotNull);
      expect((await repo2.getAllSermons()).length, 150);
    });

    test('Exclusão e restauração de modelo do Acervo persistem', () async {
      final repo1 = SermonRepository();
      await repo1.init();

      final templatesBefore = await repo1.getTemplates();
      expect(templatesBefore.length, 150);
      final targetTpl = templatesBefore.first;

      await repo1.deleteTemplate(targetTpl.id);

      final repo2 = SermonRepository();
      await repo2.init();
      final templatesAfter = await repo2.getTemplates();
      expect(templatesAfter.length, 149);
      expect(templatesAfter.any((t) => t.id == targetTpl.id), isFalse);
      expect(await repo2.getSermonById('sermon-${targetTpl.id}'), isNull);

      await repo2.restoreTemplate(targetTpl.id);
      expect((await repo2.getTemplates()).length, 150);
      expect(await repo2.getSermonById('sermon-${targetTpl.id}'), isNotNull);
    });
  });

  group('Persistência de Perfil Ministerial', () {
    test('Alterações no perfil sobrevivem ao reiniciar AuthRepository', () async {
      final auth1 = AuthRepository();
      await auth1.init();
      expect(auth1.isAuthenticated, isTrue);

      await auth1.updateProfile(
        fullName: 'Pr. Carlos Amaral (Teste)',
        ministryTitle: 'Pastor Presidente',
        churchName: 'Igreja Batista RJ',
      );

      final auth2 = AuthRepository();
      await auth2.init();
      expect(auth2.currentUserProfile, isNotNull);
      expect(auth2.currentUserProfile!.fullName, 'Pr. Carlos Amaral (Teste)');
      expect(auth2.currentUserProfile!.ministryTitle, 'Pastor Presidente');
      expect(auth2.currentUserProfile!.churchName, 'Igreja Batista RJ');
    });
  });

  group('Configuração Padrão Gemini Pro', () {
    test('Modelo padrão é gemini-2.5-pro e persiste chave/modelo', () async {
      expect(GeminiHomileticsAgent.defaultModel, 'gemini-2.5-pro');
      expect(await GeminiHomileticsAgent.getSavedModel(), 'gemini-2.5-pro');

      await GeminiHomileticsAgent.saveApiKey('AIzaSyTestKey123456');
      await GeminiHomileticsAgent.saveModel('gemini-3-pro-preview');

      expect(await GeminiHomileticsAgent.getSavedApiKey(), 'AIzaSyTestKey123456');
      expect(await GeminiHomileticsAgent.getSavedModel(), 'gemini-3-pro-preview');

      final offlineResult = await GeminiHomileticsAgent.generateSermon(
        theme: 'A Graça de Cristo',
        biblicalReference: 'Efésios 2:8',
        sermonType: 'Expositivo',
      );
      expect(offlineResult.blocks.length, 5);
    });
  });
}

