import '../core/network/supabase_config.dart';
import '../core/storage/offline_cache_service.dart';
import '../models/sermon_block.dart';
import '../models/sermon_model.dart';
import '../models/sermon_template_model.dart';

class SermonRepository {
  List<Sermon> _inMemorySermons = [];
  bool _initialized = false;

  /// Inicializa repositório carregando cache offline
  Future<void> init() async {
    if (_initialized) return;

    final cached = await OfflineCacheService.getCachedSermons();
    if (cached.isNotEmpty) {
      _inMemorySermons = cached;
    } else {
      _inMemorySermons = _getDefaultSeedSermons();
      await OfflineCacheService.cacheSermons(_inMemorySermons);
    }
    _initialized = true;

    // Tenta sincronizar com Supabase se houver conexão
    _trySyncWithSupabase();
  }

  Future<void> _trySyncWithSupabase() async {
    final client = SupabaseConfig.client;
    if (client == null || client.auth.currentUser == null) return;

    try {
      final response = await client
          .from('sermons')
          .select()
          .order('updated_at', ascending: false)
          .timeout(const Duration(milliseconds: 3500));

      final remoteSermons = (response as List)
          .map((data) => Sermon.fromJson(data as Map<String, dynamic>))
          .toList();

      if (remoteSermons.isNotEmpty) {
        _inMemorySermons = remoteSermons;
        await OfflineCacheService.cacheSermons(_inMemorySermons);
      }
    } catch (_) {
      // Falha silenciosa de rede mantendo cache offline
    }
  }

  /// Retorna sermões com filtros aplicados
  Future<List<Sermon>> getSermons({
    String? category,
    String? searchQuery,
    String? status,
    bool onlyFavorites = false,
  }) async {
    await init();

    var filtered = List<Sermon>.from(_inMemorySermons);

    if (category != null && category.isNotEmpty && category != 'Todas') {
      filtered = filtered.where((s) => s.category.toLowerCase() == category.toLowerCase()).toList();
    }

    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((s) => s.status == status).toList();
    }

    if (onlyFavorites) {
      filtered = filtered.where((s) => s.isFavorite).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      filtered = filtered.where((s) {
        final inTitle = s.title.toLowerCase().contains(q);
        final inRef = s.biblicalReference.toLowerCase().contains(q);
        final inCat = s.category.toLowerCase().contains(q);
        final inIntro = s.introduction.toLowerCase().contains(q);
        return inTitle || inRef || inCat || inIntro;
      }).toList();
    }

    // Ordenar por atualização mais recente
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  /// Busca sermão por ID
  Future<Sermon?> getSermonById(String id) async {
    await init();
    final index = _inMemorySermons.indexWhere((s) => s.id == id);
    if (index >= 0) return _inMemorySermons[index];
    return null;
  }

  /// Salva ou atualiza sermão (Offline-first com Debounce sync)
  Future<void> saveSermon(Sermon sermon) async {
    await init();
    final index = _inMemorySermons.indexWhere((s) => s.id == sermon.id);
    if (index >= 0) {
      _inMemorySermons[index] = sermon;
    } else {
      _inMemorySermons.insert(0, sermon);
    }

    // 1. Persistência imediata offline
    await OfflineCacheService.saveSingleSermonLocally(sermon);

    // 2. Persistência remota assíncrona no Supabase
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client
            .from('sermons')
            .upsert(sermon.toJson())
            .timeout(const Duration(milliseconds: 4000));
      } catch (_) {
        // Enfileiramento offline pode ser tratado aqui
      }
    }
  }

  /// Alterna status de favorito
  Future<void> toggleFavorite(String id) async {
    final s = await getSermonById(id);
    if (s != null) {
      final updated = s.copyWith(
        isFavorite: !s.isFavorite,
        updatedAt: DateTime.now(),
      );
      await saveSermon(updated);
    }
  }

  /// Incrementa contador de pregações ao concluir no Modo Púlpito
  Future<void> recordPreached(String id) async {
    final s = await getSermonById(id);
    if (s != null) {
      final updated = s.copyWith(
        preachCount: s.preachCount + 1,
        lastPreachedAt: DateTime.now(),
        status: 'ready',
        updatedAt: DateTime.now(),
      );
      await saveSermon(updated);
    }
  }

  /// Exclui um sermão
  Future<void> deleteSermon(String id) async {
    await init();
    _inMemorySermons.removeWhere((s) => s.id == id);
    await OfflineCacheService.removeSermonLocally(id);

    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client.from('sermons').delete().eq('id', id);
      } catch (_) {}
    }
  }

  /// Lista de Modelos Homiléticos Curados (Templates)
  Future<List<SermonTemplate>> getTemplates() async {
    return [
      const SermonTemplate(
        id: 'tpl-1',
        title: 'A Paz que Excede Todo Entendimento',
        theme: 'Vencendo a Ansiedade pela Oração e Gratidão',
        keyVerse: 'Filipenses 4:6-7',
        sermonType: 'Expositivo',
        tags: ['Ansiedade', 'Paz', 'Oração', 'Fé'],
        content: {
          'introduction': 'Em um mundo sobrecarregado, Paulo apresenta o antídoto de Deus para a inquietação da alma.',
          'blocks': [
            {
              'id': 'b1',
              'title': '1. O Mandamento: Não Andeis Ansiosos',
              'biblicalReference': 'Filipenses 4:6a',
              'explanation': 'A palavra grega merimnao significa ter a mente despedaçada ou dividida em direções opostas.',
              'illustration': 'A corda esticada além do limite rompe-se no meio; assim fica a alma que tenta carregar o futuro sozinha.',
              'application': 'Entregue o controle das incertezas no altar de Cristo hoje.',
              'orderIndex': 0,
            },
            {
              'id': 'b2',
              'title': '2. A Prática: Oração com Gratidão Antecipada',
              'biblicalReference': 'Filipenses 4:6b',
              'explanation': 'Ações de graças ativam a memória dos livramentos passados do Senhor.',
              'illustration': 'O pássaro que canta no escuro porque sabe que o sol certamente nascerá.',
              'application': 'Agradeça a Deus pelo que Ele já fez antes de pedir o que você ainda não viu.',
              'orderIndex': 1,
            },
            {
              'id': 'b3',
              'title': '3. A Guarda: A Paz Sentinela',
              'biblicalReference': 'Filipenses 4:7',
              'explanation': 'A paz de Deus age como phroureo (sentinela militar armada) guardando coração e mente.',
              'illustration': 'O mar revolto na superfície, mas o fundo oceânico permanece sereno.',
              'application': 'Deixe o Espírito Santo ser o sentinela dos seus pensamentos.',
              'orderIndex': 2,
            },
          ],
          'conclusion': 'A paz de Deus não depende do fim das tempestades, mas da presença do Senhor no barco.',
          'appeal': 'Troque o seu jugo pesado pelo fardo suave de Jesus nesta noite.',
        },
      ),
      const SermonTemplate(
        id: 'tpl-2',
        title: 'O Bom Samaritano: Amor Sem Fronteiras',
        theme: 'A Compaixão que Age Praticamente',
        keyVerse: 'Lucas 10:25-37',
        sermonType: 'Expositivo',
        tags: ['Amor', 'Misericórdia', 'Igreja Relevante'],
        content: {
          'introduction': 'Jesus desmascara a religiosidade teórica e chama a igreja à compaixão encarnada.',
          'blocks': [
            {
              'id': 'b4',
              'title': '1. O Perigo da Religiosidade Indiferente',
              'biblicalReference': 'Lucas 10:31-32',
              'explanation': 'O sacerdote e o levita viram a dor alheia, mas desviaram o caminho.',
              'illustration': 'Um hospital que mantém suas portas trancadas para não sujar o chão com sangue.',
              'application': 'Nossa fé não pode ser confinada às quatro paredes do templo.',
              'orderIndex': 0,
            },
            {
              'id': 'b5',
              'title': '2. O Amor que Paga o Preço',
              'biblicalReference': 'Lucas 10:33-35',
              'explanation': 'O samaritano cuidou com azeite, vinho e recursos financeiros da sua própria bolsa.',
              'illustration': 'As mãos que servem manifestam a glória do Evangelho com mais poder do que palavras vazias.',
              'application': 'Identifique alguém ferido na sua rua ou família para estender as mãos.',
              'orderIndex': 1,
            },
          ],
          'conclusion': 'A ordem de Jesus ressoa viva: Vai e faze tu o mesmo.',
          'appeal': 'Compromisso de viver um cristianismo autêntico e misericordioso.',
        },
      ),
      const SermonTemplate(
        id: 'tpl-3',
        title: 'Firmados Sobre a Rocha',
        theme: 'Princípios Inabaláveis para o Lar',
        keyVerse: 'Mateus 7:24-27',
        sermonType: 'Temático',
        tags: ['Família', 'Fundamento', 'Obediência'],
        content: {
          'introduction': 'As mesmas chuvas e ventos testam a casa na rocha e a casa na areia.',
          'blocks': [
            {
              'id': 'b6',
              'title': '1. Ouvir e Praticar a Palavra',
              'biblicalReference': 'Mateus 7:24',
              'explanation': 'A rocha não é apenas a Bíblia na estante, mas a obediência diária aos preceitos de Cristo.',
              'illustration': 'A fundação de um arranha-céu: invisível aos olhos de quem passa, mas responsável por toda a estabilidade.',
              'application': 'Cultive o perdão e o altar da oração na sua casa todos os dias.',
              'orderIndex': 0,
            },
          ],
          'conclusion': 'Casas na areia caem no primeiro vendaval; casas na rocha resistem para a glória de Deus.',
          'appeal': 'Consagração de casais e famílias ao Senhor.',
        },
      ),
    ];
  }

  /// Sermões iniciais de demonstração pré-carregados
  List<Sermon> _getDefaultSeedSermons() {
    final now = DateTime.now();
    return [
      Sermon(
        id: 'sermon-seed-1',
        userId: 'pastor-local-01',
        title: 'A Paz que Excede Todo Entendimento',
        biblicalReference: 'Filipenses 4:6-7',
        category: 'Fé e Esperança',
        sermonType: 'Expositivo',
        introduction:
            'Vivemos em um século acelerado, onde a ansiedade é considerada o mal do milênio. '
            'Entretanto, o apóstolo Paulo, encarcerado em uma prisão romana úmida, escreve uma das mais '
            'belas exortações de vitória sobre o medo.',
        blocks: [
          const HomileticBlock(
            id: 'sb-1',
            title: '1. O Imperativo da Confiança: Não Andeis Ansiosos',
            biblicalReference: 'Filipenses 4:6a',
            explanation:
                'O termo grego merimnao retrata a alma puxada em direções opostas. '
                'Deus nos convida a concentrar nosso olhar na Sua grandeza e não na dimensão dos problemas.',
            illustration:
                'Como uma corda que arrebenta sob tensão excessiva, o ser humano adoece quando '
                'insiste em carregar amanhãs que ainda não chegaram.',
            application:
                'Entregue ao Senhor hoje tudo aquilo que você não tem o poder de mudar com suas próprias mãos.',
            orderIndex: 0,
          ),
          const HomileticBlock(
            id: 'sb-2',
            title: '2. A Disciplina da Oração com Gratidão',
            biblicalReference: 'Filipenses 4:6b',
            explanation:
                'A oração acompanhada de ações de graças nos conecta com os memoriais da fidelidade divina. '
                'Lembrar do que Deus já fez gera combustível para crer no milagre vindouro.',
            illustration:
                'O pássaro que entoa seu cântico na escuridão da madrugada, sabendo com certeza matemática '
                'que os primeiros raios da alvorada despontarão no horizonte.',
            application:
                'Troque a murmuração pelo louvor voluntário nesta noite.',
            orderIndex: 1,
          ),
          const HomileticBlock(
            id: 'sb-3',
            title: '3. A Fortaleza da Guarda Celestial',
            biblicalReference: 'Filipenses 4:7',
            explanation:
                'A paz de Deus excede nosso intelecto humano e atua como uma sentinela armada (phroureo) '
                'defendendo nosso coração contra as flechas inflamadas do maligno.',
            illustration:
                'Enquanto o tufão devasta a superfície do oceano, a 200 metros de profundidade as águas '
                'permanecem em repouso absoluto.',
            application:
                'Permita que a paz de Cristo arbitre todas as suas decisões familiares e profissionais.',
            orderIndex: 2,
          ),
        ],
        conclusion:
            'A paz verdadeira não é a ausência de tempestades no mundo exterior, '
            'mas a presença inegociável do Deus da Paz habitando o nosso interior.',
        appeal:
            'Convido à frente todos que sentem o coração oprimido pela ansiedade para receberem a oração da fé.',
        isFavorite: true,
        status: 'ready',
        preachCount: 3,
        lastPreachedAt: now.subtract(const Duration(days: 7)),
        estimatedDurationMinutes: 45,
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      Sermon(
        id: 'sermon-seed-2',
        userId: 'pastor-local-01',
        title: 'Edificando o Altar da Família',
        biblicalReference: 'Josué 24:14-15',
        category: 'Família',
        sermonType: 'Temático',
        introduction:
            'No entardecer da sua liderança sobre Israel, Josué convoca as famílias e lança um desafio '
            'que atravessa os séculos até a nossa geração: a quem nós escolheremos servir?',
        blocks: [
          const HomileticBlock(
            id: 'sb-4',
            title: '1. A Decisão Inadiável da Liderança Espiritual',
            biblicalReference: 'Josué 24:15a',
            explanation:
                'Josué assume a responsabilidade como sacerdote do seu lar. '
                'A liderança bíblica da família não se impõe pelo grito ou coerção, mas pelo exemplo santo e amor sacrificial.',
            illustration:
                'As pegadas na neve fresca: os filhos seguem os passos exatos que os pais deixam gravados no caminho.',
            application:
                'Pais e mães, retomem o sacerdócio de oração e proteção espiritual sobre seus filhos.',
            orderIndex: 0,
          ),
          const HomileticBlock(
            id: 'sb-5',
            title: '2. Eu e a Minha Casa Serviremos ao Senhor',
            biblicalReference: 'Josué 24:15b',
            explanation:
                'Servir aqui traduz-se em submissão alegre e serviço ativo no Reino de Deus. '
                'A família cristã é um posto avançado da Igreja dentro da sociedade.',
            illustration:
                'A Arca de Noé: Deus não salvou apenas indivíduos isolados, mas preservou a família inteira da destruição.',
            application:
                'Restabeleça hoje o culto doméstico e momentos de oração diária à mesa da sua casa.',
            orderIndex: 1,
          ),
        ],
        conclusion:
            'As maiores vitórias de um ministério não acontecem sobre o púlpito, mas ao redor da mesa da própria casa.',
        appeal:
            'Oração de consagração e restauração matrimonial.',
        isFavorite: true,
        status: 'ready',
        preachCount: 1,
        lastPreachedAt: now.subtract(const Duration(days: 21)),
        estimatedDurationMinutes: 40,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 21)),
      ),
      Sermon(
        id: 'sermon-seed-3',
        userId: 'pastor-local-01',
        title: 'O Poder da Oração Eficaz',
        biblicalReference: 'Tiago 5:16-18',
        category: 'Oração e Jejum',
        sermonType: 'Textual',
        introduction:
            'Elias era homem sujeito às mesmas fraquezas que nós, mas orou com fervor e o céu se fechou e se abriu. '
            'Deus não procura super-heróis, mas corações quebrantados e dispostos.',
        blocks: [
          const HomileticBlock(
            id: 'sb-6',
            title: '1. Homens Comuns, Deus Extraordinário',
            biblicalReference: 'Tiago 5:17',
            explanation: 'O poder da oração não reside na nossa eloquência, mas no caráter fiel daquele que nos ouve.',
            illustration: 'Um pequeno interruptor que acende a iluminação de todo um estádio quando conectado à usina de força.',
            application: 'Nunca subestime o poder dos seus joelhos dobrados no secreto do seu quarto.',
            orderIndex: 0,
          ),
        ],
        conclusion: 'Quando o homem trabalha, o homem trabalha; mas quando o homem ora, Deus trabalha.',
        appeal: 'Desperte o seu clamor espiritual!',
        isFavorite: false,
        status: 'draft',
        preachCount: 0,
        estimatedDurationMinutes: 35,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
