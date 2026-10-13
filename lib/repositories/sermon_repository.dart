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
    if (cached.length >= kCuratedSermonTemplates.length) {
      _inMemorySermons = cached;
    } else {
      // Mescla os sermões existentes em cache com todos os 50 esboços homiléticos
      final Map<String, Sermon> sermonMap = {
        for (final s in _getDefaultSeedSermons()) s.title.toLowerCase(): s,
      };
      for (final s in cached) {
        sermonMap[s.title.toLowerCase()] = s;
      }
      _inMemorySermons = sermonMap.values.toList();
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

  /// Lista de Modelos Homiléticos Curados (Templates - 50 Esboços Homiléticos)
  Future<List<SermonTemplate>> getTemplates() async {
    // 1. Inicia com todos os 50 modelos catalogados locais (Garantia Offline-first)
    final Map<String, SermonTemplate> map = {
      for (final tpl in kCuratedSermonTemplates) tpl.title.toLowerCase(): tpl,
    };

    // 2. Mescla modelos remotos vindos do Supabase caso existam
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final response = await client
            .from('sermon_templates')
            .select()
            .order('title', ascending: true)
            .timeout(const Duration(milliseconds: 3500));

        final remoteList = (response as List)
            .map((data) => SermonTemplate.fromJson(data as Map<String, dynamic>))
            .toList();

        for (final tpl in remoteList) {
          map[tpl.title.toLowerCase()] = tpl;
        }
      } catch (_) {
        // Fallback offline seguro
      }
    }

    final result = map.values.toList();
    return result;
  }

  /// Sermões iniciais gerados a partir de todos os 50 modelos homiléticos
  List<Sermon> _getDefaultSeedSermons() {
    final now = DateTime.now();
    return kCuratedSermonTemplates.asMap().entries.map((entry) {
      final index = entry.key;
      final tpl = entry.value;
      final rawBlocks = (tpl.content['blocks'] as List<dynamic>?) ?? [];
      final blocks = rawBlocks
          .map((b) => HomileticBlock.fromJson(b as Map<String, dynamic>))
          .toList();

      return Sermon(
        id: 'sermon-${tpl.id}',
        userId: 'pastor-local-01',
        title: tpl.title,
        biblicalReference: tpl.keyVerse,
        category: tpl.tags.isNotEmpty ? tpl.tags.first : 'Geral',
        sermonType: tpl.sermonType,
        introduction: tpl.content['introduction'] as String? ?? '',
        blocks: blocks,
        conclusion: tpl.content['conclusion'] as String? ?? '',
        appeal: tpl.content['appeal'] as String? ?? '',
        status: 'ready',
        isFavorite: index < 5,
        preachCount: index == 0 ? 3 : (index == 1 ? 1 : 0),
        estimatedDurationMinutes: 40,
        createdAt: now.subtract(Duration(days: 30 - index % 25)),
        updatedAt: now.subtract(Duration(days: index % 10)),
      );
    }).toList();
  }
}
