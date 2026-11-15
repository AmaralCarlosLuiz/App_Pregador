import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bible_model.dart';
import '../models/sermon_block.dart';
import '../models/sermon_model.dart';
import '../models/sermon_template_model.dart';
import 'sermon_provider.dart';

class SermonEditorState {
  final Sermon sermon;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final DateTime? lastSavedAt;
  final String? error;
  final int revision; // Incrementado em atualizações externas (IA, Seletor Bíblico, Exclusão de Bloco)

  const SermonEditorState({
    required this.sermon,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.lastSavedAt,
    this.error,
    this.revision = 0,
  });

  SermonEditorState copyWith({
    Sermon? sermon,
    bool? isSaving,
    bool? hasUnsavedChanges,
    DateTime? lastSavedAt,
    String? error,
    int? revision,
  }) {
    return SermonEditorState(
      sermon: sermon ?? this.sermon,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      error: error,
      revision: revision ?? this.revision,
    );
  }
}

class SermonEditorNotifier extends StateNotifier<SermonEditorState>
    with WidgetsBindingObserver {
  final Ref _ref;
  Timer? _debounceTimer;

  /// Tempo de espera após a última digitação. Curto o bastante para que sair do app
  /// quase sempre já tenha salvo; o salvamento imediato por ciclo de vida cobre o resto.
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  SermonEditorNotifier(this._ref, Sermon initialSermon)
      : super(SermonEditorState(
          sermon: initialSermon,
          lastSavedAt: initialSermon.updatedAt,
        )) {
    WidgetsBinding.instance.addObserver(this);
    // Garante persistência imediata do sermão no repositório e cache local
    _ensureInitialPersisted(initialSermon);
  }

  void _ensureInitialPersisted(Sermon initialSermon) async {
    try {
      final repo = _ref.read(sermonRepositoryProvider);
      final existing = await repo.getSermonById(initialSermon.id);
      if (existing == null) {
        await repo.saveSermon(initialSermon);
        _ref.read(sermonListProvider.notifier).loadSermons();
      }
    } catch (_) {}
  }

  /// iOS/Safari pode suspender ou encerrar o app a qualquer momento ao trocar de app
  /// ou fechar: ao sair de primeiro plano, qualquer edição pendente é gravada na hora.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState != AppLifecycleState.resumed && state.hasUnsavedChanges) {
      saveImmediately();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (state.hasUnsavedChanges) {
      final currentSermon = state.sermon.copyWith(updatedAt: DateTime.now());
      try {
        final repo = _ref.read(sermonRepositoryProvider);
        unawaited(repo.saveSermon(currentSermon).then((_) {
          try {
            _ref.read(sermonListProvider.notifier).loadSermons();
          } catch (_) {}
        }));
      } catch (_) {}
    }
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _triggerDebounceSave() {
    if (!mounted) return;
    state = state.copyWith(hasUnsavedChanges: true);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      if (mounted) {
        saveImmediately();
      }
    });
  }

  Future<void> saveImmediately() async {
    _debounceTimer?.cancel();
    if (!mounted) return;
    state = state.copyWith(isSaving: true);

    // Foto do que está sendo gravado. Se o usuário continuar digitando durante a
    // gravação, as novas edições NÃO podem ser sobrescritas pela foto antiga.
    final snapshot = state.sermon;
    final toPersist = snapshot.copyWith(updatedAt: DateTime.now());

    try {
      final repo = _ref.read(sermonRepositoryProvider);
      await repo.saveSermon(toPersist);
      // Notifica a lista geral de sermões
      _ref.read(sermonListProvider.notifier).loadSermons();

      if (!mounted) return;
      final editedMeanwhile = !identical(state.sermon, snapshot);
      state = state.copyWith(
        isSaving: false,
        hasUnsavedChanges: editedMeanwhile,
        lastSavedAt: DateTime.now(),
      );
      if (editedMeanwhile) _triggerDebounceSave();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void updateTitle(String title) {
    state = state.copyWith(sermon: state.sermon.copyWith(title: title));
    _triggerDebounceSave();
  }

  void updateBiblicalReference(String ref, {bool fromExternalPicker = false}) {
    state = state.copyWith(
      sermon: state.sermon.copyWith(biblicalReference: ref),
      revision: fromExternalPicker ? state.revision + 1 : state.revision,
    );
    _triggerDebounceSave();
  }

  void updateCategory(String category) {
    state = state.copyWith(sermon: state.sermon.copyWith(category: category));
    _triggerDebounceSave();
  }

  void updateSermonType(String type) {
    state = state.copyWith(sermon: state.sermon.copyWith(sermonType: type));
    _triggerDebounceSave();
  }

  void updateStatus(String status) {
    state = state.copyWith(sermon: state.sermon.copyWith(status: status));
    _triggerDebounceSave();
  }

  void updateIntroduction(String intro) {
    state = state.copyWith(sermon: state.sermon.copyWith(introduction: intro));
    _triggerDebounceSave();
  }

  void updateConclusion(String conc) {
    state = state.copyWith(sermon: state.sermon.copyWith(conclusion: conc));
    _triggerDebounceSave();
  }

  void updateAppeal(String appeal) {
    state = state.copyWith(sermon: state.sermon.copyWith(appeal: appeal));
    _triggerDebounceSave();
  }

  void updateEstimatedDuration(int minutes) {
    state = state.copyWith(
      sermon: state.sermon.copyWith(estimatedDurationMinutes: minutes),
    );
    _triggerDebounceSave();
  }

  // Operações de Blocos Homiléticos
  void addBlock() {
    final newBlock = HomileticBlock(
      id: UniqueKeyString.generate(),
      title: 'Ponto ${state.sermon.blocks.length + 1}',
      orderIndex: state.sermon.blocks.length,
    );
    final updatedBlocks = List<HomileticBlock>.from(state.sermon.blocks)..add(newBlock);
    state = state.copyWith(sermon: state.sermon.copyWith(blocks: updatedBlocks));
    _triggerDebounceSave();
  }

  void insertVerseBlock(BibleVerse verse) {
    final newBlock = HomileticBlock(
      id: UniqueKeyString.generate(),
      title: 'Ponto ${state.sermon.blocks.length + 1}: ${verse.reference}',
      biblicalReference: verse.reference,
      explanation: 'Texto Sagrado: "${verse.text}" (${verse.version})',
      orderIndex: state.sermon.blocks.length,
    );
    final updatedBlocks = List<HomileticBlock>.from(state.sermon.blocks)..add(newBlock);
    state = state.copyWith(
      sermon: state.sermon.copyWith(blocks: updatedBlocks),
      revision: state.revision + 1,
    );
    _triggerDebounceSave();
  }

  void updateBlock(int index, HomileticBlock updated) {
    if (index >= 0 && index < state.sermon.blocks.length) {
      final updatedBlocks = List<HomileticBlock>.from(state.sermon.blocks);
      updatedBlocks[index] = updated;
      state = state.copyWith(sermon: state.sermon.copyWith(blocks: updatedBlocks));
      _triggerDebounceSave();
    }
  }

  void removeBlock(int index) {
    if (index >= 0 && index < state.sermon.blocks.length) {
      final updatedBlocks = List<HomileticBlock>.from(state.sermon.blocks)..removeAt(index);
      state = state.copyWith(
        sermon: state.sermon.copyWith(blocks: updatedBlocks),
        revision: state.revision + 1,
      );
      _triggerDebounceSave();
    }
  }

  void applyFullOutline({
    required String title,
    required String biblicalReference,
    required String sermonType,
    required String introduction,
    required List<HomileticBlock> blocks,
    required String conclusion,
    required String appeal,
  }) {
    final updated = state.sermon.copyWith(
      title: title,
      biblicalReference: biblicalReference,
      sermonType: sermonType,
      introduction: introduction,
      blocks: List<HomileticBlock>.from(blocks),
      conclusion: conclusion,
      appeal: appeal,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      sermon: updated,
      revision: state.revision + 1,
    );
    saveImmediately();
  }

  void applyTemplate(SermonTemplate template) {
    final content = template.content;
    final rawBlocks = (content['blocks'] as List<dynamic>?) ?? [];
    final blocks = rawBlocks
        .map((b) => HomileticBlock.fromJson(b as Map<String, dynamic>))
        .toList();

    applyFullOutline(
      title: template.title,
      biblicalReference: template.keyVerse,
      sermonType: template.sermonType,
      introduction: content['introduction'] as String? ?? '',
      blocks: blocks,
      conclusion: content['conclusion'] as String? ?? '',
      appeal: content['appeal'] as String? ?? '',
    );
  }
}

final sermonEditorProvider = StateNotifierProvider.family<
    SermonEditorNotifier, SermonEditorState, Sermon>((ref, initialSermon) {
  return SermonEditorNotifier(ref, initialSermon);
});
