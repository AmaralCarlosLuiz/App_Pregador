import 'dart:async';

class TtsVoiceOption {
  final String id;
  final String name;
  final String lang;
  final bool isMale;
  final bool isNaturalNeural;

  const TtsVoiceOption({
    required this.id,
    required this.name,
    required this.lang,
    required this.isMale,
    this.isNaturalNeural = false,
  });
}

abstract class BibleTtsEngine {
  bool get isSupported;
  Future<void> init({VoidCallback? onVoicesReady});
  List<TtsVoiceOption> getAvailableVoices();
  Future<void> speak({
    required String text,
    required bool preferMale,
    String? specificVoiceId,
    double rate = 1.0,
    double pitch = 1.0,
    VoidCallback? onComplete,
    void Function(String error)? onError,
  });
  void stop();
  void pause();
  void resume();
}

typedef VoidCallback = void Function();

class StubBibleTtsEngine implements BibleTtsEngine {
  @override
  bool get isSupported => false;

  @override
  Future<void> init({VoidCallback? onVoicesReady}) async {
    onVoicesReady?.call();
  }

  @override
  List<TtsVoiceOption> getAvailableVoices() => const [];

  @override
  Future<void> speak({
    required String text,
    required bool preferMale,
    String? specificVoiceId,
    double rate = 1.0,
    double pitch = 1.0,
    VoidCallback? onComplete,
    void Function(String error)? onError,
  }) async {
    onError?.call('Síntese de voz nativa não disponível neste dispositivo.');
  }

  @override
  void stop() {}

  @override
  void pause() {}

  @override
  void resume() {}
}

BibleTtsEngine createBibleTtsEngine() => StubBibleTtsEngine();

