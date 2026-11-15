import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/data/curated_sermon_templates.dart';
import '../core/network/supabase_config.dart';
import '../core/storage/offline_cache_service.dart';
import '../models/sermon_block.dart';
import '../models/sermon_model.dart';
import '../models/sermon_template_model.dart';

/// Repositório de sermões — offline-first.
///
/// Garantias de arquitetura:
///  1. A memória é a fonte de verdade durante a sessão; o disco (localStorage) é espelhado
///     a cada alteração por uma FILA SERIALIZADA de gravações (sem condição de corrida
///     entre salvamentos simultâneos → nenhum sermão é sobrescrito/perdido).
///  2. O boot NÃO instancia o acervo de modelos (646 KB). Os sermões de exemplo são
///     gravados uma única vez (primeiro uso) e depois lidos do próprio cache.
///  3. A sincronização com a nuvem faz MESCLAGEM (nunca substitui o que só existe no aparelho).
class SermonRepository {
  List<Sermon> _inMemorySermons = [];
  Set<String> _deletedIds = {};
  bool _initialized = false;
  Future<void>? _initFuture;
  Future<void> _persistChain = Future.value();

  SermonRepository();

  /// Inicializa o repositório carregando os sermões persistidos.
  Future<void> init() {
    if (_initialized) return Future.value();
    _initFuture ??= _performInit();
    return _initFuture!;
  }

  Future<void> _performInit() async {
    try {
      final cached = await OfflineCacheService.getCachedSermons();
      _deletedIds = await OfflineCacheService.getDeletedIds();
      final map = <String, Sermon>{for (final s in cached) s.id: s};

      // Sermões de exemplo: gravados UMA vez, a partir daí são sermões do usuário.
      final seeded = await OfflineCacheService.wasSeeded();
      if (!seeded) {
        // Cede o thread para a UI pintar antes do trabalho pesado do primeiro uso.
        await Future<void>.delayed(Duration.zero);
        for (final s in _buildStarterSermons()) {
          if (!map.containsKey(s.id) && !_deletedIds.contains(s.id)) {
            map[s.id] = s;
          }
        }
        _inMemorySermons = map.values.toList();
        final ok = await _persist();
        if (ok) await OfflineCacheService.markSeeded();
      } else {
        _inMemorySermons = map.values.toList();
      }
    } catch (e) {
      debugPrint('[SermonRepository] Falha ao inicializar: $e');
    }

    _initialized = true;

    // Sincronização em background não-bloqueante com Supabase
    unawaited(_trySyncWithSupabase());
  }

  /// Fila serializada de gravação: sempre grava o estado MAIS RECENTE da memória.
  Future<bool> _persist() {
    final run = _persistChain.then(
      (_) => OfflineCacheService.cacheSermons(List<Sermon>.of(_inMemorySermons)),
    );
    _persistChain = run.then((_) {}, onError: (_) {});
    return run;
  }

  Future<void> _trySyncWithSupabase() async {
    final client = SupabaseConfig.client;
    if (client == null || client.auth.currentUser == null) return;

    try {
      final response = await client
          .from('sermons')
          .select()
          .order('updated_at', ascending: false)
          .timeout(const Duration(milliseconds: 2500));

      final remoteSermons = (response as List)
          .map((data) => Sermon.fromJson(data as Map<String, dynamic>))
          .toList();

      if (remoteSermons.isEmpty) return;

      // MESCLAGEM: nunca descarta o que existe só no aparelho.
      final map = <String, Sermon>{for (final s in _inMemorySermons) s.id: s};
      for (final remote in remoteSermons) {
        if (_deletedIds.contains(remote.id)) continue;
        final local = map[remote.id];
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          map[remote.id] = remote;
        }
      }
      _inMemorySermons = map.values.toList();
      unawaited(_persist());
    } catch (_) {
      // Falha silenciosa de rede mantendo cache offline
    }
  }

  /// Retorna todos os sermões em memória sem filtros
  Future<List<Sermon>> getAllSermons() async {
    if (!_initialized) await init();
    return List.unmodifiable(_inMemorySermons);
  }

  /// Retorna sermões com filtros aplicados
  Future<List<Sermon>> getSermons({
    String? category,
    String? searchQuery,
    String? status,
    bool onlyFavorites = false,
    bool onlyPreached = false,
  }) async {
    if (!_initialized) await init();

    var filtered = List<Sermon>.from(_inMemorySermons);

    if (category != null && category.isNotEmpty && category != 'Todas') {
      filtered = filtered
          .where((s) => s.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((s) => s.status == status).toList();
    }

    if (onlyFavorites) {
      filtered = filtered.where((s) => s.isFavorite).toList();
    }

    if (onlyPreached) {
      filtered = filtered.where((s) => s.preachCount > 0).toList();
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
    if (!_initialized) await init();
    final index = _inMemorySermons.indexWhere((s) => s.id == id);
    if (index >= 0) return _inMemorySermons[index];
    return null;
  }

  /// Salva ou atualiza sermão. Só retorna após a gravação em disco ser CONFIRMADA;
  /// lança exceção se o armazenamento falhar (a UI exibe o erro em vez de fingir que salvou).
  Future<void> saveSermon(Sermon sermon) async {
    if (!_initialized) await init();

    final index = _inMemorySermons.indexWhere((s) => s.id == sermon.id);
    if (index >= 0) {
      _inMemorySermons[index] = sermon;
    } else {
      _inMemorySermons.insert(0, sermon);
    }
    if (_deletedIds.remove(sermon.id)) {
      await OfflineCacheService.saveDeletedIds(_deletedIds);
    }

    // 1. Persistência local confirmada (fila serializada)
    final ok = await _persist();
    if (!ok) {
      throw StateError('Não foi possível gravar no armazenamento do aparelho.');
    }

    // 2. Persistência remota assíncrona em background no Supabase
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      unawaited(
        client
            .from('sermons')
            .upsert(sermon.toJson())
            .timeout(const Duration(milliseconds: 2500))
            .catchError((_) => null),
      );
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

  /// Exclui um sermão (registra a exclusão para que exemplos não reapareçam)
  Future<void> deleteSermon(String id) async {
    if (!_initialized) await init();
    _inMemorySermons.removeWhere((s) => s.id == id);
    _deletedIds.add(id);
    await OfflineCacheService.saveDeletedIds(_deletedIds);
    await _persist();

    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      unawaited(
        client.from('sermons').delete().eq('id', id).catchError((_) => null),
      );
    }
  }

  /// Lista de Modelos Homiléticos Curados (carregada somente quando a aba é aberta)
  Future<List<SermonTemplate>> getTemplates() async {
    return kCuratedSermonTemplates;
  }

  /// 6 sermões de exemplo — criados apenas no primeiro uso do aplicativo.
  List<Sermon> _buildStarterSermons() {
    final now = DateTime.now();
    final starterTemplates = kCuratedSermonTemplates.take(6).toList();
    return starterTemplates.asMap().entries.map((entry) {
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
        isFavorite: index < 3,
        preachCount: index == 0 ? 3 : (index == 1 ? 1 : 0),
        estimatedDurationMinutes: 40,
        createdAt: now.subtract(Duration(days: 30 - index % 25)),
        updatedAt: now.subtract(Duration(days: index % 10)),
      );
    }).toList();
  }
}
