import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/data/curated_sermon_templates.dart';
import '../core/network/supabase_config.dart';
import '../core/storage/offline_cache_service.dart';
import '../models/sermon_block.dart';
import '../models/sermon_model.dart';
import '../models/sermon_template_model.dart';

/// Repositório de sermões — offline-first com Delta Storage.
///
/// Garantias de arquitetura:
///  1. A memória é a fonte de verdade durante a sessão; apenas os sermões criados ou
///     editados pelo usuário são persistidos no delta local (`pregador_pro_user_sermons_delta_v1`),
///     com gravação SÍNCRONA no `localStorage` + `SharedPreferences` via fila serializada.
///  2. Os 150 sermões base do acervo usam datas determinísticas fixas (`2026-01-15`),
///     garantindo que qualquer novo sermão ou edição fique SEMPRE no topo da lista.
///  3. A sincronização com a nuvem faz MESCLAGEM por `updatedAt` (nunca descarta alterações locais).
class SermonRepository {
  List<Sermon> _inMemorySermons = [];
  Map<String, Sermon> _userModifiedSermons = {};
  Set<String> _deletedIds = {};
  bool _initialized = false;
  Future<void>? _initFuture;
  Future<void> _persistChain = Future.value();

  SermonRepository();

  bool get isInitialized => _initialized;
  int get modifiedUserSermonsCount => _userModifiedSermons.length;

  /// Inicializa o repositório carregando os sermões persistidos sem bloquear o boot.
  Future<void> init() {
    if (_initialized) return Future.value();
    _initFuture ??= _performInit();
    return _initFuture!;
  }

  Future<void> _performInit() async {
    try {
      final results = await Future.wait<Object?>([
        OfflineCacheService.getUserSermonsDelta(),
        OfflineCacheService.getDeletedIds(),
        OfflineCacheService.isLegacyMigrated(),
      ]);

      _userModifiedSermons = Map<String, Sermon>.from(
        results[0] as Map<String, Sermon>,
      );
      _deletedIds = Set<String>.from(results[1] as Set<String>);
      final isMigrated = results[2] as bool;

      // 1. Constrói os 150 sermões base com datas fixas determinísticas
      final starterList = _buildStarterSermons();
      final starterMap = <String, Sermon>{
        for (final s in starterList) s.id: s,
      };

      // 2. Migração única e segura do cache legado pesado (se houver dados prévios)
      if (!isMigrated) {
        final legacyCached = await OfflineCacheService.getCachedSermons();
        bool migratedAny = false;
        for (final s in legacyCached) {
          if (_deletedIds.contains(s.id)) continue;
          final starter = starterMap[s.id];
          final isUserCreatedOrEdited =
              starter == null || _isDifferentFromStarter(s, starter);
          if (isUserCreatedOrEdited) {
            final existing = _userModifiedSermons[s.id];
            if (existing == null || s.updatedAt.isAfter(existing.updatedAt)) {
              _userModifiedSermons[s.id] = s;
              migratedAny = true;
            }
          }
        }
        if (migratedAny) {
          await OfflineCacheService.saveUserSermonsDelta(_userModifiedSermons);
        }
        await OfflineCacheService.markLegacyMigrated();
        await OfflineCacheService.clearLegacySermonsCache();
      }

      // 3. Mescla acervo base + sermões criados/editados pelo usuário
      final mergedMap = <String, Sermon>{};
      for (final s in starterList) {
        if (!_deletedIds.contains(s.id)) {
          mergedMap[s.id] = s;
        }
      }
      for (final entry in _userModifiedSermons.entries) {
        if (!_deletedIds.contains(entry.key)) {
          mergedMap[entry.key] = entry.value;
        }
      }

      _inMemorySermons = mergedMap.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('[SermonRepository] Falha ao inicializar: $e');
    }

    _initialized = true;

    // Sincronização em background não-bloqueante com Supabase
    unawaited(_trySyncWithSupabase());
  }

  bool _isDifferentFromStarter(Sermon candidate, Sermon starter) {
    if (candidate.title != starter.title ||
        candidate.biblicalReference != starter.biblicalReference ||
        candidate.category != starter.category ||
        candidate.sermonType != starter.sermonType ||
        candidate.introduction != starter.introduction ||
        candidate.conclusion != starter.conclusion ||
        candidate.appeal != starter.appeal ||
        candidate.isFavorite != starter.isFavorite ||
        candidate.status != starter.status ||
        candidate.preachCount != starter.preachCount ||
        candidate.estimatedDurationMinutes != starter.estimatedDurationMinutes ||
        candidate.blocks.length != starter.blocks.length) {
      return true;
    }
    for (int i = 0; i < candidate.blocks.length; i++) {
      final cb = candidate.blocks[i];
      final sb = starter.blocks[i];
      if (cb.title != sb.title ||
          cb.biblicalReference != sb.biblicalReference ||
          cb.explanation != sb.explanation ||
          cb.illustration != sb.illustration ||
          cb.application != sb.application) {
        return true;
      }
    }
    return false;
  }

  /// Fila serializada de gravação: sempre grava o estado MAIS RECENTE do delta do usuário.
  Future<bool> _persist() {
    final snapshot = Map<String, Sermon>.from(_userModifiedSermons);
    final run = _persistChain.then(
      (_) => OfflineCacheService.saveUserSermonsDelta(snapshot),
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

      // MESCLAGEM: nunca descarta o que existe de mais recente no aparelho.
      final map = <String, Sermon>{for (final s in _inMemorySermons) s.id: s};
      bool updatedFromRemote = false;
      for (final remote in remoteSermons) {
        if (_deletedIds.contains(remote.id)) continue;
        final local = map[remote.id];
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          map[remote.id] = remote;
          _userModifiedSermons[remote.id] = remote;
          updatedFromRemote = true;
        }
      }
      if (updatedFromRemote) {
        _inMemorySermons = map.values.toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        unawaited(_persist());
      }
    } catch (_) {
      // Falha silenciosa de rede mantendo cache offline
    }
  }

  /// Retorna todos os sermões em memória ordenados por atualização mais recente.
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

  /// Busca síncrona imediata em memória (evita abrir versões antigas no editor)
  Sermon? getSermonByIdSync(String id) {
    final index = _inMemorySermons.indexWhere((s) => s.id == id);
    if (index >= 0) return _inMemorySermons[index];
    return null;
  }

  /// Busca sermão por ID
  Future<Sermon?> getSermonById(String id) async {
    if (!_initialized) await init();
    return getSermonByIdSync(id);
  }

  /// Salva ou atualiza sermão. Só retorna após a gravação local ser CONFIRMADA;
  /// lança exceção se o armazenamento falhar.
  Future<void> saveSermon(Sermon sermon) async {
    if (!_initialized) await init();

    _userModifiedSermons[sermon.id] = sermon;

    final index = _inMemorySermons.indexWhere((s) => s.id == sermon.id);
    if (index >= 0) {
      _inMemorySermons[index] = sermon;
    } else {
      _inMemorySermons.insert(0, sermon);
    }
    _inMemorySermons.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (_deletedIds.remove(sermon.id)) {
      await OfflineCacheService.saveDeletedIds(_deletedIds);
    }

    // 1. Persistência local confirmada (síncrona no webLocal + fila serializada SharedPreferences)
    final ok = await _persist();
    if (!ok) {
      throw StateError('Não foi possível gravar no armazenamento do aparelho.');
    }

    // 2. Persistência remota assíncrona em background no Supabase (quando autenticado no BaaS)
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
    _userModifiedSermons.remove(id);
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

  /// Restaura um sermão recém-excluído (usado pelo botão "Desfazer")
  Future<void> restoreSermon(Sermon sermon) async {
    if (!_initialized) await init();
    _deletedIds.remove(sermon.id);
    await OfflineCacheService.saveDeletedIds(_deletedIds);
    await saveSermon(sermon);
  }

  /// Exclui um modelo do Acervo de Modelos (e remove seu sermão base associado)
  Future<void> deleteTemplate(String templateId) async {
    if (!_initialized) await init();
    final sermonId = 'sermon-$templateId';
    _deletedIds.add(templateId);
    _deletedIds.add(sermonId);
    _inMemorySermons.removeWhere((s) => s.id == sermonId);
    _userModifiedSermons.remove(sermonId);
    await OfflineCacheService.saveDeletedIds(_deletedIds);
    await _persist();
  }

  /// Restaura um modelo excluído no Acervo de Modelos (usado pelo botão "Desfazer")
  Future<void> restoreTemplate(String templateId) async {
    if (!_initialized) await init();
    final sermonId = 'sermon-$templateId';
    _deletedIds.remove(templateId);
    _deletedIds.remove(sermonId);
    await OfflineCacheService.saveDeletedIds(_deletedIds);

    final tplIdx = kCuratedSermonTemplates.indexWhere((t) => t.id == templateId);
    if (tplIdx >= 0 && !_inMemorySermons.any((s) => s.id == sermonId)) {
      _inMemorySermons.add(
        _buildStarterSermon(tplIdx, kCuratedSermonTemplates[tplIdx]),
      );
      _inMemorySermons.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }

  /// Lista de Modelos Homiléticos Curados (filtra modelos excluídos pelo usuário)
  Future<List<SermonTemplate>> getTemplates() async {
    if (!_initialized) await init();
    return kCuratedSermonTemplates
        .where((t) => !_deletedIds.contains(t.id))
        .toList();
  }

  /// Todos os 150 sermões do acervo homilético com datas determinísticas fixas
  /// para que nunca sobrescrevam nem passem à frente de sermões criados/editados pelo usuário.
  List<Sermon> _buildStarterSermons() {
    return kCuratedSermonTemplates.asMap().entries.map((entry) {
      return _buildStarterSermon(entry.key, entry.value);
    }).toList();
  }

  Sermon _buildStarterSermon(int index, SermonTemplate tpl) {
    final baseDate = DateTime(2026, 1, 15, 12, 0);
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
      createdAt: baseDate.subtract(Duration(days: 30 - index % 25)),
      updatedAt: baseDate.subtract(Duration(days: index % 10, minutes: index)),
    );
  }
}
