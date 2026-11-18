import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/bible_tts_engine_stub.dart'
    if (dart.library.html) '../core/services/bible_tts_engine_web.dart';
import '../core/storage/offline_cache_service.dart';
import '../models/bible_model.dart';

enum BibleVoiceGender {
  male,
  female,
}

class BibleTtsState {
  final bool isSupported;
  final bool isPlaying;
  final bool isPaused;
  final BibleVoiceGender gender;
  final double speechRate;
  final String? selectedVoiceId;
  final List<TtsVoiceOption> availableVoices;
  final String activeVoiceLabel;
  final bool isCloudNeural;
  final List<BibleVerse> queue;
  final int currentQueueIndex;
  final bool isSelectionMode;
  final Set<int> selectedVerseNumbers;
  final String? errorMessage;

  const BibleTtsState({
    this.isSupported = true,
    this.isPlaying = false,
    this.isPaused = false,
    this.gender = BibleVoiceGender.male,
    this.speechRate = 0.96, // Cadência natural do Rio de Janeiro
    this.selectedVoiceId,
    this.availableVoices = const [],
    this.activeVoiceLabel = 'Voz Masculina (Brasil • RJ)',
    this.isCloudNeural = false,
    this.queue = const [],
    this.currentQueueIndex = 0,
    this.isSelectionMode = false,
    this.selectedVerseNumbers = const {},
    this.errorMessage,
  });

  BibleVerse? get currentVerse {
    if (currentQueueIndex >= 0 && currentQueueIndex < queue.length) {
      return queue[currentQueueIndex];
    }
    return null;
  }

  String get voiceProfileLabel {
    return gender == BibleVoiceGender.male
        ? 'Voz Masculina (Brasil • RJ)'
        : 'Voz Feminina (Brasil • RJ)';
  }

  BibleTtsState copyWith({
    bool? isSupported,
    bool? isPlaying,
    bool? isPaused,
    BibleVoiceGender? gender,
    double? speechRate,
    String? selectedVoiceId,
    bool clearSelectedVoiceId = false,
    List<TtsVoiceOption>? availableVoices,
    String? activeVoiceLabel,
    bool? isCloudNeural,
    List<BibleVerse>? queue,
    int? currentQueueIndex,
    bool? isSelectionMode,
    Set<int>? selectedVerseNumbers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BibleTtsState(
      isSupported: isSupported ?? this.isSupported,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      gender: gender ?? this.gender,
      speechRate: speechRate ?? this.speechRate,
      selectedVoiceId:
          clearSelectedVoiceId ? null : (selectedVoiceId ?? this.selectedVoiceId),
      availableVoices: availableVoices ?? this.availableVoices,
      activeVoiceLabel: activeVoiceLabel ?? this.activeVoiceLabel,
      isCloudNeural: isCloudNeural ?? this.isCloudNeural,
      queue: queue ?? this.queue,
      currentQueueIndex: currentQueueIndex ?? this.currentQueueIndex,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedVerseNumbers: selectedVerseNumbers ?? this.selectedVerseNumbers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BibleTtsNotifier extends StateNotifier<BibleTtsState> {
  late final BibleTtsEngine _engine;
  int _playbackSession = 0;

  static const _prefVoiceGenderKey = 'bible_tts_voice_gender_rj';
  static const _prefSpeechRateKey = 'bible_tts_speech_rate_rj';
  static const _prefSpecificVoiceKey = 'bible_tts_specific_voice_rj';

  BibleTtsNotifier() : super(const BibleTtsState()) {
    _engine = createBibleTtsEngine();
    _initEngine();
  }

  void _syncActiveVoiceLabel() {
    if (!mounted) return;
    final preferMale = state.gender == BibleVoiceGender.male;
    state = state.copyWith(
      isCloudNeural: _engine.isCloudNeuralActive,
      activeVoiceLabel: _engine.describeActiveVoice(
        preferMale: preferMale,
        specificVoiceId: state.selectedVoiceId,
      ),
    );
  }

  Future<void> _initEngine() async {
    try {
      final savedGender = await OfflineCacheService.readResilientString(_prefVoiceGenderKey);
      final savedVoiceId = await OfflineCacheService.readResilientString(_prefSpecificVoiceKey);
      final prefs = await SharedPreferences.getInstance();
      final savedRate = prefs.getDouble(_prefSpeechRateKey);

      if (mounted) {
        state = state.copyWith(
          isSupported: _engine.isSupported,
          gender: savedGender == 'female'
              ? BibleVoiceGender.female
              : BibleVoiceGender.male,
          speechRate: savedRate ?? 0.96,
          selectedVoiceId: (savedVoiceId != null && savedVoiceId.isNotEmpty)
              ? savedVoiceId
              : null,
        );
      }

      await _engine.init(
        onVoicesReady: () {
          if (!mounted) return;
          final voices = _engine.getAvailableVoices();
          state = state.copyWith(availableVoices: voices);
          _syncActiveVoiceLabel();
        },
      );
      _syncActiveVoiceLabel();
    } catch (_) {}
  }

  /// Alterna entre Voz Masculina e Feminina (Brasil / RJ) em tempo real
  Future<void> setGender(BibleVoiceGender gender) async {
    if (state.gender == gender) return;
    _engine.resetCloudBackoff();
    state = state.copyWith(
      gender: gender,
      clearSelectedVoiceId: true,
      clearError: true,
    );
    _syncActiveVoiceLabel();

    await OfflineCacheService.writeResilientString(
      _prefVoiceGenderKey,
      gender == BibleVoiceGender.female ? 'female' : 'male',
    );
    await OfflineCacheService.removeResilientKey(_prefSpecificVoiceKey);

    if (state.isPlaying) {
      _speakCurrentQueueItem(announceHeader: false, interruptPrevious: true);
    }
  }

  /// Define manualmente uma voz específica `pt-BR` do aparelho (ou `null` para modo automático RJ)
  Future<void> setSpecificVoice(String? voiceId) async {
    final cleanId = (voiceId != null && voiceId.trim().isNotEmpty) ? voiceId.trim() : null;
    if (cleanId == null) {
      state = state.copyWith(clearSelectedVoiceId: true, clearError: true);
      await OfflineCacheService.removeResilientKey(_prefSpecificVoiceKey);
    } else {
      // Ajusta o gênero da UI se a voz escolhida tiver gênero explícito conhecido
      final match = state.availableVoices.where((v) => v.id == cleanId).firstOrNull;
      BibleVoiceGender nextGender = state.gender;
      if (match != null) {
        if (match.isMale && !match.isFemale) {
          nextGender = BibleVoiceGender.male;
        } else if (match.isFemale && !match.isMale) {
          nextGender = BibleVoiceGender.female;
        }
      }
      state = state.copyWith(
        selectedVoiceId: cleanId,
        gender: nextGender,
        clearError: true,
      );
      await OfflineCacheService.writeResilientString(_prefSpecificVoiceKey, cleanId);
      await OfflineCacheService.writeResilientString(
        _prefVoiceGenderKey,
        nextGender == BibleVoiceGender.female ? 'female' : 'male',
      );
    }
    _syncActiveVoiceLabel();

    if (state.isPlaying) {
      _speakCurrentQueueItem(announceHeader: false, interruptPrevious: true);
    }
  }

  /// Reproduz um trecho rápido de teste para o usuário conferir o timbre (Masculino/Feminino RJ)
  void speakSample() {
    speakVerses(const [
      BibleVerse(
        bookId: 'salmos',
        bookName: 'Salmos',
        chapter: 23,
        verse: 1,
        text: 'O Senhor é o meu pastor; nada me faltará.',
        version: 'ARC',
      ),
    ]);
  }

  /// Altera a velocidade / cadência da leitura
  Future<void> setSpeechRate(double rate) async {
    final clamped = rate.clamp(0.75, 1.35);
    state = state.copyWith(speechRate: clamped, clearError: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefSpeechRateKey, clamped);
    } catch (_) {}

    if (state.isPlaying) {
      _speakCurrentQueueItem(announceHeader: false, interruptPrevious: true);
    }
  }

  /// Ativa/desativa o modo de seleção de múltiplos versículos ("Trecho Selecionado")
  void toggleSelectionMode({int? initialVerseNumber}) {
    final nextMode = !state.isSelectionMode;
    final initialSet = <int>{};
    if (nextMode && initialVerseNumber != null) {
      initialSet.add(initialVerseNumber);
    }
    state = state.copyWith(
      isSelectionMode: nextMode,
      selectedVerseNumbers: initialSet,
      clearError: true,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      isSelectionMode: false,
      selectedVerseNumbers: const {},
    );
  }

  void toggleVerseSelection(int verseNumber) {
    final updated = Set<int>.from(state.selectedVerseNumbers);
    if (updated.contains(verseNumber)) {
      updated.remove(verseNumber);
    } else {
      updated.add(verseNumber);
    }
    state = state.copyWith(
      isSelectionMode: true,
      selectedVerseNumbers: updated,
    );
  }

  void selectVerseRange(List<BibleVerse> allChapterVerses) {
    final allNums = allChapterVerses.map((v) => v.verse).toSet();
    state = state.copyWith(
      isSelectionMode: true,
      selectedVerseNumbers: allNums,
    );
  }

  /// Lê um único versículo imediatamente
  void speakSingleVerse(BibleVerse verse) {
    speakVerses([verse]);
  }

  /// Lê os versículos selecionados no capítulo atual (ou o capítulo inteiro se nenhum estiver marcado)
  void speakSelectedOrChapter(List<BibleVerse> chapterVerses) {
    if (chapterVerses.isEmpty) return;

    if (state.selectedVerseNumbers.isNotEmpty) {
      final selectedList = chapterVerses
          .where((v) => state.selectedVerseNumbers.contains(v.verse))
          .toList()
        ..sort((a, b) => a.verse.compareTo(b.verse));

      if (selectedList.isNotEmpty) {
        speakVerses(selectedList);
        return;
      }
    }

    speakVerses(chapterVerses);
  }

  /// Lê o capítulo a partir de um versículo específico
  void speakFromVerse(BibleVerse startVerse, List<BibleVerse> chapterVerses) {
    final filtered = chapterVerses
        .where((v) => v.verse >= startVerse.verse)
        .toList();
    speakVerses(filtered.isNotEmpty ? filtered : [startVerse]);
  }

  /// Inicia a leitura sequencial e segura de uma lista de versículos
  void speakVerses(List<BibleVerse> verses) {
    if (verses.isEmpty) return;
    _playbackSession++;
    _engine.stop();

    state = state.copyWith(
      queue: List<BibleVerse>.unmodifiable(verses),
      currentQueueIndex: 0,
      isPlaying: true,
      isPaused: false,
      clearError: true,
    );

    _speakCurrentQueueItem(announceHeader: true, interruptPrevious: true);
  }

  void _speakCurrentQueueItem({
    required bool announceHeader,
    bool interruptPrevious = true,
  }) {
    final current = state.currentVerse;
    if (current == null) {
      stop();
      return;
    }

    final session = ++_playbackSession;
    final spokenText = _prepareNaturalRjSpeechText(
      current,
      includeBookHeader: announceHeader && state.currentQueueIndex == 0,
      isSingleVerseQueue: state.queue.length == 1,
    );

    final bool isMale = state.gender == BibleVoiceGender.male;
    final double naturalPitch = isMale ? 0.94 : 1.08;

    final nextIndex = state.currentQueueIndex + 1;
    final String? nextText = nextIndex < state.queue.length
        ? _prepareNaturalRjSpeechText(
            state.queue[nextIndex],
            includeBookHeader: false,
            isSingleVerseQueue: false,
          )
        : null;

    _syncActiveVoiceLabel();

    _engine.speak(
      text: spokenText,
      preferMale: isMale,
      specificVoiceId: state.selectedVoiceId,
      rate: state.speechRate,
      pitch: naturalPitch,
      nextText: nextText,
      interruptPrevious: interruptPrevious,
      onComplete: () {
        if (!mounted || session != _playbackSession) return;
        _advanceQueue();
      },
      onError: (err) {
        if (!mounted || session != _playbackSession) return;
        state = state.copyWith(
          isPlaying: false,
          isPaused: false,
          errorMessage: err,
        );
      },
    );
  }

  void _advanceQueue() {
    final nextIndex = state.currentQueueIndex + 1;
    if (nextIndex < state.queue.length) {
      state = state.copyWith(
        currentQueueIndex: nextIndex,
        isPlaying: true,
        isPaused: false,
      );
      _speakCurrentQueueItem(announceHeader: false, interruptPrevious: false);
    } else {
      state = state.copyWith(
        isPlaying: false,
        isPaused: false,
        currentQueueIndex: 0,
      );
    }
  }

  void pauseOrResume() {
    if (!state.isPlaying) return;
    if (state.isPaused) {
      state = state.copyWith(isPaused: false);
      _speakCurrentQueueItem(announceHeader: false, interruptPrevious: true);
    } else {
      _playbackSession++;
      _engine.stop();
      state = state.copyWith(isPaused: true);
    }
  }

  void nextVerse() {
    if (state.queue.isEmpty) return;
    final nextIndex = state.currentQueueIndex + 1;
    if (nextIndex < state.queue.length) {
      state = state.copyWith(
        currentQueueIndex: nextIndex,
        isPlaying: true,
        isPaused: false,
      );
      _speakCurrentQueueItem(announceHeader: false, interruptPrevious: true);
    }
  }

  void previousVerse() {
    if (state.queue.isEmpty) return;
    final prevIndex = state.currentQueueIndex - 1;
    if (prevIndex >= 0) {
      state = state.copyWith(
        currentQueueIndex: prevIndex,
        isPlaying: true,
        isPaused: false,
      );
      _speakCurrentQueueItem(announceHeader: false, interruptPrevious: true);
    }
  }

  void stop() {
    _playbackSession++;
    _engine.stop();
    if (!mounted) return;
    state = state.copyWith(
      isPlaying: false,
      isPaused: false,
      queue: const [],
      currentQueueIndex: 0,
    );
  }

  /// Adapta a prosódia e dicção bíblica para leitura humana natural (Brasil / RJ)
  String _prepareNaturalRjSpeechText(
    BibleVerse verse, {
    required bool includeBookHeader,
    required bool isSingleVerseQueue,
  }) {
    String cleanText = verse.text
        .replaceAll(RegExp(r'\[([^\]]+)\]'), r'$1')
        .replaceAll('—', ', ')
        .replaceAll(';', ', ')
        .replaceAll(':', ', ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final bookSpoken = _naturalizeBookName(verse.bookName);

    if (includeBookHeader) {
      if (isSingleVerseQueue) {
        return '$bookSpoken, capítulo ${verse.chapter}, versículo ${verse.verse}. $cleanText';
      } else {
        return '$bookSpoken, capítulo ${verse.chapter}. Versículo ${verse.verse}. $cleanText';
      }
    }

    return 'Versículo ${verse.verse}. $cleanText';
  }

  String _naturalizeBookName(String bookName) {
    final trimmed = bookName.trim();
    if (trimmed.startsWith('1 ')) {
      final rest = trimmed.substring(2);
      if (rest.startsWith('Pedro') ||
          rest.startsWith('João') ||
          rest.startsWith('Timóteo') ||
          rest.startsWith('Tessalonicenses') ||
          rest.startsWith('Coríntios')) {
        return 'Primeira $rest';
      }
      return 'Primeiro $rest';
    }
    if (trimmed.startsWith('2 ')) {
      final rest = trimmed.substring(2);
      if (rest.startsWith('Pedro') ||
          rest.startsWith('João') ||
          rest.startsWith('Timóteo') ||
          rest.startsWith('Tessalonicenses') ||
          rest.startsWith('Coríntios')) {
        return 'Segunda $rest';
      }
      return 'Segundo $rest';
    }
    if (trimmed.startsWith('3 ')) {
      final rest = trimmed.substring(2);
      return 'Terceira $rest';
    }
    return trimmed;
  }

  @override
  void dispose() {
    _playbackSession++;
    _engine.stop();
    super.dispose();
  }
}

final bibleTtsProvider =
    StateNotifierProvider<BibleTtsNotifier, BibleTtsState>((ref) {
  return BibleTtsNotifier();
});
