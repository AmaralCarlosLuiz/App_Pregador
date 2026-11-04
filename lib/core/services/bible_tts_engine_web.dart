// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'bible_tts_engine_stub.dart';
export 'bible_tts_engine_stub.dart' show TtsVoiceOption, BibleTtsEngine, VoidCallback;

class WebBibleTtsEngine implements BibleTtsEngine {
  html.SpeechSynthesis? _synth;
  html.SpeechSynthesisUtterance? _activeUtterance;
  Timer? _chromeKeepAliveTimer;
  int _utteranceToken = 0;
  List<html.SpeechSynthesisVoice> _rawVoices = [];

  WebBibleTtsEngine() {
    try {
      _synth = html.window.speechSynthesis;
    } catch (_) {
      _synth = null;
    }
  }

  @override
  bool get isSupported => _synth != null;

  @override
  Future<void> init({VoidCallback? onVoicesReady}) async {
    final synth = _synth;
    if (synth == null) {
      onVoicesReady?.call();
      return;
    }

    try {
      _refreshVoices();
      if (_rawVoices.isNotEmpty) {
        onVoicesReady?.call();
      }

      // Listener assíncrono para quando o navegador terminar de carregar as vozes neurais
      synth.addEventListener('voiceschanged', (_) {
        _refreshVoices();
        onVoicesReady?.call();
      });

      // Fallback de polling rápido caso o evento voiceschanged já tenha disparado antes
      for (int i = 0; i < 6; i++) {
        await Future.delayed(const Duration(milliseconds: 250));
        _refreshVoices();
        if (_rawVoices.isNotEmpty) {
          onVoicesReady?.call();
          break;
        }
      }
    } catch (_) {
      onVoicesReady?.call();
    }
  }

  void _refreshVoices() {
    try {
      final voices = _synth?.getVoices() ?? [];
      _rawVoices = List<html.SpeechSynthesisVoice>.from(voices);
    } catch (_) {
      _rawVoices = [];
    }
  }

  /// Identifica se o nome da voz indica timbre masculino em PT-BR
  bool _isVoiceMale(String nameLower) {
    const maleKeywords = [
      'antonio',
      'antônio',
      'daniel',
      'donato',
      'fabio',
      'fábio',
      'felipe',
      'humberto',
      'julio',
      'júlio',
      'luca',
      'nicolau',
      'valerio',
      'valério',
      'male',
      'masculin',
      'homem',
      'ricardo',
      'tiago',
      'marcos',
      'paulo',
      'carlos',
    ];
    for (final kw in maleKeywords) {
      if (nameLower.contains(kw)) return true;
    }
    return false;
  }

  /// Identifica se o nome da voz indica timbre feminino em PT-BR
  bool _isVoiceFemale(String nameLower) {
    const femaleKeywords = [
      'francisca',
      'thalita',
      'maria',
      'luciana',
      'brenda',
      'giovanna',
      'leila',
      'manuela',
      'yara',
      'heloisa',
      'heloísa',
      'female',
      'feminin',
      'mulher',
      'vitória',
      'vitoria',
      'camila',
      'fernanda',
    ];
    for (final kw in femaleKeywords) {
      if (nameLower.contains(kw)) return true;
    }
    return false;
  }

  bool _isNaturalOrNeural(String nameLower) {
    return nameLower.contains('natural') ||
        nameLower.contains('neural') ||
        nameLower.contains('online') ||
        nameLower.contains('google') ||
        nameLower.contains('francisca') ||
        nameLower.contains('antonio') ||
        nameLower.contains('thalita');
  }

  @override
  List<TtsVoiceOption> getAvailableVoices() {
    _refreshVoices();
    final ptBrVoices = _rawVoices.where((v) {
      final lang = (v.lang ?? '').toLowerCase().replaceAll('_', '-');
      return lang.startsWith('pt-br') || lang == 'pt';
    }).toList();

    final options = <TtsVoiceOption>[];
    for (final v in ptBrVoices) {
      final name = v.name ?? 'Voz Português (Brasil)';
      final nameLower = name.toLowerCase();
      final isMale = _isVoiceMale(nameLower);
      final isNatural = _isNaturalOrNeural(nameLower);

      options.add(
        TtsVoiceOption(
          id: v.voiceUri ?? name,
          name: name,
          lang: v.lang ?? 'pt-BR',
          isMale: isMale,
          isNaturalNeural: isNatural,
        ),
      );
    }

    // Ordena priorizando vozes Neurais/Naturais primeiro
    options.sort((a, b) {
      if (a.isNaturalNeural != b.isNaturalNeural) {
        return a.isNaturalNeural ? -1 : 1;
      }
      return a.name.compareTo(b.name);
    });

    return options;
  }

  html.SpeechSynthesisVoice? _selectBestVoice({
    required bool preferMale,
    String? specificVoiceId,
  }) {
    _refreshVoices();
    if (_rawVoices.isEmpty) return null;

    // 1. Se o usuário escolheu uma voz específica pelo ID
    if (specificVoiceId != null && specificVoiceId.isNotEmpty) {
      for (final v in _rawVoices) {
        if (v.voiceUri == specificVoiceId || v.name == specificVoiceId) {
          return v;
        }
      }
    }

    // Filtra vozes do Brasil (pt-BR) primeiro
    final ptBrVoices = _rawVoices.where((v) {
      final lang = (v.lang ?? '').toLowerCase().replaceAll('_', '-');
      return lang.startsWith('pt-br');
    }).toList();

    final candidates = ptBrVoices.isNotEmpty
        ? ptBrVoices
        : _rawVoices.where((v) {
            final lang = (v.lang ?? '').toLowerCase();
            return lang.startsWith('pt');
          }).toList();

    if (candidates.isEmpty) return null;

    // 2. Busca voz do gênero desejado priorizando Neural/Natural
    final genderMatches = candidates.where((v) {
      final nameLower = (v.name ?? '').toLowerCase();
      return preferMale ? _isVoiceMale(nameLower) : _isVoiceFemale(nameLower);
    }).toList();

    if (genderMatches.isNotEmpty) {
      genderMatches.sort((a, b) {
        final aNat = _isNaturalOrNeural((a.name ?? '').toLowerCase());
        final bNat = _isNaturalOrNeural((b.name ?? '').toLowerCase());
        if (aNat != bNat) return aNat ? -1 : 1;
        return 0;
      });
      return genderMatches.first;
    }

    // 3. Caso o navegador tenha apenas uma voz neutra/geral (ex: "Google português do Brasil"),
    // retorna a melhor voz pt-BR disponível (ajustaremos o pitch acústico para masculino/feminino).
    candidates.sort((a, b) {
      final aNat = _isNaturalOrNeural((a.name ?? '').toLowerCase());
      final bNat = _isNaturalOrNeural((b.name ?? '').toLowerCase());
      if (aNat != bNat) return aNat ? -1 : 1;
      return 0;
    });

    return candidates.first;
  }

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
    final synth = _synth;
    if (synth == null) {
      onError?.call('Navegador sem suporte a leitura em voz.');
      return;
    }

    final currentToken = ++_utteranceToken;
    _cancelKeepAlive();

    try {
      synth.cancel();
    } catch (_) {}

    // Pequeno respiro para evitar bug de cancelamento do Chrome Web Speech API
    await Future.delayed(const Duration(milliseconds: 45));
    if (currentToken != _utteranceToken) return;

    try {
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = 'pt-BR';

      final selectedVoice = _selectBestVoice(
        preferMale: preferMale,
        specificVoiceId: specificVoiceId,
      );

      double effectivePitch = pitch;
      double effectiveRate = rate;

      if (selectedVoice != null) {
        utterance.voice = selectedVoice;
        final vName = (selectedVoice.name ?? '').toLowerCase();
        final voiceIsExplicitlyMale = _isVoiceMale(vName);
        final voiceIsExplicitlyFemale = _isVoiceFemale(vName);

        // Se o navegador só tiver 1 voz padrão (ex: Google português do Brasil) e o usuário
        // pediu voz Masculina ou Feminina, calibramos a formante/pitch de forma sutil e humana:
        if (preferMale && !voiceIsExplicitlyMale) {
          effectivePitch = (pitch * 0.84).clamp(0.75, 1.0);
          effectiveRate = (rate * 0.97).clamp(0.75, 1.5);
        } else if (!preferMale && voiceIsExplicitlyMale && !voiceIsExplicitlyFemale) {
          effectivePitch = (pitch * 1.16).clamp(1.0, 1.35);
        }
      } else {
        // Sem voz específica identificada: aplica perfil masculino ou feminino
        effectivePitch = preferMale ? 0.85 : 1.05;
      }

      utterance.rate = effectiveRate.clamp(0.5, 2.0);
      utterance.pitch = effectivePitch.clamp(0.5, 2.0);
      utterance.volume = 1.0;

      _activeUtterance = utterance;

      bool finished = false;
      void completeOnce() {
        if (finished || currentToken != _utteranceToken) return;
        finished = true;
        _cancelKeepAlive();
        onComplete?.call();
      }

      utterance.addEventListener('end', (_) {
        completeOnce();
      });

      utterance.addEventListener('error', (event) {
        if (finished || currentToken != _utteranceToken) return;
        finished = true;
        _cancelKeepAlive();
        // Ignora erro 'canceled' ou 'interrupted' gerado quando o usuário troca de faixa/para
        try {
          final dynamic errEvent = event;
          final errCode = errEvent.error?.toString() ?? '';
          if (errCode.contains('cancel') || errCode.contains('interrupt')) {
            return;
          }
        } catch (_) {}
        onError?.call('Não foi possível reproduzir o áudio neste momento.');
      });

      synth.speak(utterance);

      // Watchdog anti-congelamento do Chrome (evita que falas longas travem após 14 segundos)
      _chromeKeepAliveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (currentToken != _utteranceToken) {
          _cancelKeepAlive();
          return;
        }
        try {
          if (synth.speaking == true && synth.paused != true) {
            synth.pause();
            synth.resume();
          }
        } catch (_) {}
      });
    } catch (e) {
      if (currentToken == _utteranceToken) {
        onError?.call('Falha ao iniciar leitura em voz: $e');
      }
    }
  }

  void _cancelKeepAlive() {
    _chromeKeepAliveTimer?.cancel();
    _chromeKeepAliveTimer = null;
  }

  @override
  void pause() {
    try {
      _synth?.pause();
    } catch (_) {}
  }

  @override
  void resume() {
    try {
      _synth?.resume();
    } catch (_) {}
  }

  @override
  void stop() {
    _utteranceToken++;
    _cancelKeepAlive();
    _activeUtterance = null;
    try {
      _synth?.cancel();
    } catch (_) {}
  }
}

BibleTtsEngine createBibleTtsEngine() => WebBibleTtsEngine();

