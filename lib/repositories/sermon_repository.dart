import '../core/data/curated_sermon_templates.dart';
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
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final response = await client
            .from('sermon_templates')
            .select()
            .order('title', ascending: true)
            .timeout(const Duration(milliseconds: 3500));

        final list = (response as List)
            .map((data) => SermonTemplate.fromJson(data as Map<String, dynamic>))
            .toList();

        if (list.isNotEmpty) {
          return list;
        }
      } catch (_) {
        // Fallback offline caso haja instabilidade de rede
      }
    }

    return _getDefaultSeedTemplates();
  }

  List<SermonTemplate> _getDefaultSeedTemplates() {
    return kCuratedSermonTemplates;
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
