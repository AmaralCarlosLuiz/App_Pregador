// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'bible_tts_engine_stub.dart';
import 'gemini_homiletics_agent.dart';
export 'bible_tts_engine_stub.dart' show TtsVoiceOption, BibleTtsEngine, VoidCallback;

/// Motor de leitura em voz da Bíblia (Web / PWA).
///
/// Duas camadas, com queda automática de uma para a outra:
///  1. VOZ NEURAL HUMANA (Gemini TTS) — quando há chave Gemini configurada. Voz masculina
///     e feminina realmente distintas, com sotaque carioca (Rio de Janeiro) por instrução.
///  2. VOZ DO APARELHO (Web Speech API) — selecionada por gênero e qualidade
///     (Luciana/Felipe/Eddy/Flo etc. no iOS; Francisca/Antonio no Edge; Google no Chrome).
class WebBibleTtsEngine implements BibleTtsEngine {
  html.SpeechSynthesis? _synth;
  Timer? _chromeKeepAliveTimer;
  int _utteranceToken = 0;
  List<html.SpeechSynthesisVoice> _rawVoices = [];

  // --- Camada neural (Gemini TTS) ---
  static const String _geminiTtsModel = 'gemini-2.5-flash-preview-tts';
  static const String _maleCloudVoice = 'Charon'; // grave, sereno
  static const String _femaleCloudVoice = 'Aoede'; // suave, acolhedora
  html.AudioElement? _audio;
  StreamSubscription<html.Event>? _audioEndSub;
  StreamSubscription<html.Event>? _audioErrorSub;
  bool _audioUnlocked = false;
  bool _hasCloudKey = false;
  DateTime _cloudBackoffUntil = DateTime.fromMillisecondsSinceEpoch(0);
  final Map<String, Future<String?>> _cloudAudioCache = {};
  final List<String> _cloudCacheOrder = [];

  WebBibleTtsEngine() {
    try {
      _synth = html.window.speechSynthesis;
    } catch (_) {
      _synth = null;
    }
  }

  @override
  bool get isSupported => _synth != null || _hasCloudKey;

  @override
  Future<void> init({VoidCallback? onVoicesReady}) async {
    _hasCloudKey = (await GeminiHomileticsAgent.getSavedApiKey()) != null;

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

      // Listener assíncrono para quando o navegador terminar de carregar as vozes
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

  // ---------------------------------------------------------------------------
  // Classificação de vozes locais
  // ---------------------------------------------------------------------------

  static const _maleKeywords = [
    // iOS / macOS (pt-BR)
    'felipe', 'eddy', 'reed', 'rocko', 'grandpa',
    // Windows / Edge (pt-BR)
    'antonio', 'antônio', 'donato', 'fabio', 'fábio', 'humberto', 'julio', 'júlio',
    'nicolau', 'valerio', 'valério', 'daniel', 'ricardo', 'tiago', 'marcos', 'paulo',
    'carlos', 'luca',
    // Genéricos
    'male', 'masculin', 'homem',
  ];

  static const _femaleKeywords = [
    // iOS / macOS (pt-BR)
    'luciana', 'flo', 'sandy', 'shelley', 'grandma',
    // Windows / Edge (pt-BR)
    'francisca', 'thalita', 'maria', 'brenda', 'giovanna', 'leila', 'manuela',
    'yara', 'heloisa', 'heloísa', 'vitória', 'vitoria', 'camila', 'fernanda',
    // Genéricos
    'female', 'feminin', 'mulher',
  ];

  bool _hasKeyword(String nameLower, List<String> keywords) {
    for (final kw in keywords) {
      if (nameLower.contains(kw)) return true;
    }
    return false;
  }

  bool _isVoiceMale(String nameLower) => _hasKeyword(nameLower, _maleKeywords);
  bool _isVoiceFemale(String nameLower) => _hasKeyword(nameLower, _femaleKeywords);

  /// Pontuação de qualidade: vozes "aprimoradas/premium/neurais" soam muito mais humanas.
  int _voiceQuality(html.SpeechSynthesisVoice v) {
    final n = (v.name ?? '').toLowerCase();
    var score = 0;
    if (n.contains('premium') || n.contains('enhanced') || n.contains('aprimorad')) {
      score += 4;
    }
    if (n.contains('natural') || n.contains('neural') || n.contains('online')) {
      score += 4;
    }
    if (n.contains('google')) score += 2;
    if (n.contains('francisca') || n.contains('antonio') || n.contains('thalita')) {
      score += 3;
    }
    if (n.contains('luciana') || n.contains('felipe')) score += 1;
    if (v.localService == false) score += 1;
    return score;
  }

  bool _isNaturalOrNeural(html.SpeechSynthesisVoice v) => _voiceQuality(v) >= 3;

  List<html.SpeechSynthesisVoice> _ptBrCandidates() {
    final ptBr = _rawVoices.where((v) {
      final lang = (v.lang ?? '').toLowerCase().replaceAll('_', '-');
      return lang.startsWith('pt-br');
    }).toList();
    if (ptBr.isNotEmpty) return ptBr;
    return _rawVoices.where((v) {
      final lang = (v.lang ?? '').toLowerCase();
      return lang.startsWith('pt') && !lang.startsWith('pt-pt');
    }).toList();
  }

  @override
  List<TtsVoiceOption> getAvailableVoices() {
    _refreshVoices();
    final options = <TtsVoiceOption>[];
    final ranked = _ptBrCandidates()
      ..sort((a, b) => _voiceQuality(b).compareTo(_voiceQuality(a)));

    for (final v in ranked) {
      final name = v.name ?? 'Voz Português (Brasil)';
      final nameLower = name.toLowerCase();
      options.add(
        TtsVoiceOption(
          id: v.voiceUri ?? name,
          name: name,
          lang: v.lang ?? 'pt-BR',
          isMale: _isVoiceMale(nameLower),
          isNaturalNeural: _isNaturalOrNeural(v),
        ),
      );
    }
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

    final candidates = _ptBrCandidates();
    if (candidates.isEmpty) return null;

    // 2. Voz do gênero desejado, priorizando a de maior qualidade
    final genderMatches = candidates.where((v) {
      final nameLower = (v.name ?? '').toLowerCase();
      return preferMale ? _isVoiceMale(nameLower) : _isVoiceFemale(nameLower);
    }).toList()
      ..sort((a, b) => _voiceQuality(b).compareTo(_voiceQuality(a)));
    if (genderMatches.isNotEmpty) return genderMatches.first;

    // 3. Sem voz do gênero: usa a melhor pt-BR disponível (ajustando o timbre via pitch)
    candidates.sort((a, b) => _voiceQuality(b).compareTo(_voiceQuality(a)));
    return candidates.first;
  }

  // ---------------------------------------------------------------------------
  // Camada neural: Gemini TTS
  // ---------------------------------------------------------------------------

  /// iOS/Safari só permite tocar áudio se o elemento foi "destravado" dentro de um toque
  /// do usuário. Fazemos isso de forma síncrona, no início de `speak`.
  void _unlockAudio() {
    if (_audioUnlocked) return;
    try {
      final audio = _audio ??= html.AudioElement();
      audio.src = _silentWavDataUri();
      audio.play().then((_) {
        audio.pause();
        _audioUnlocked = true;
      }).catchError((_) {});
    } catch (_) {}
  }

  String _silentWavDataUri() {
    final wav = _pcmToWav(Uint8List(2400), 24000); // 50 ms de silêncio
    return 'data:audio/wav;base64,${base64Encode(wav)}';
  }

  Uint8List _pcmToWav(Uint8List pcm, int sampleRate) {
    final header = ByteData(44);
    void writeTag(int offset, String tag) {
      for (var i = 0; i < tag.length; i++) {
        header.setUint8(offset + i, tag.codeUnitAt(i));
      }
    }

    writeTag(0, 'RIFF');
    header.setUint32(4, 36 + pcm.length, Endian.little);
    writeTag(8, 'WAVE');
    writeTag(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // mono
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    writeTag(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);

    final out = BytesBuilder(copy: false)
      ..add(header.buffer.asUint8List())
      ..add(pcm);
    return out.toBytes();
  }

  /// Busca (ou reaproveita do cache) o áudio neural de um trecho. Retorna a URL do blob
  /// ou `null` em caso de falha.
  Future<String?> _cloudAudioUrl(String text, bool preferMale) {
    final cacheKey = '${preferMale ? 'm' : 'f'}|$text';
    final cached = _cloudAudioCache[cacheKey];
    if (cached != null) return cached;

    final future = _fetchGeminiAudio(text, preferMale);
    _cloudAudioCache[cacheKey] = future;
    _cloudCacheOrder.add(cacheKey);

    // Cache curto (evita crescer sem limite e libera memória do navegador)
    while (_cloudCacheOrder.length > 10) {
      final oldKey = _cloudCacheOrder.removeAt(0);
      final old = _cloudAudioCache.remove(oldKey);
      old?.then((url) {
        if (url != null) html.Url.revokeObjectUrl(url);
      });
    }

    // Falhas não ficam em cache
    future.then((url) {
      if (url == null) {
        _cloudAudioCache.remove(cacheKey);
        _cloudCacheOrder.remove(cacheKey);
      }
    });
    return future;
  }

  Future<String?> _fetchGeminiAudio(String text, bool preferMale) async {
    try {
      final apiKey = await GeminiHomileticsAgent.getSavedApiKey();
      if (apiKey == null) return null;

      final direction = preferMale
          ? 'Diga com sotaque carioca natural do Rio de Janeiro, em tom caloroso, sereno e pausado de um pastor'
          : 'Diga com sotaque carioca natural do Rio de Janeiro, em tom suave, acolhedor e pausado de uma pastora';

      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/$_geminiTtsModel:generateContent',
            ),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': '$direction: $text'},
                  ],
                },
              ],
              'generationConfig': {
                'responseModalities': ['AUDIO'],
                'speechConfig': {
                  'voiceConfig': {
                    'prebuiltVoiceConfig': {
                      'voiceName': preferMale ? _maleCloudVoice : _femaleCloudVoice,
                    },
                  },
                },
              },
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        debugPrint('[WebBibleTtsEngine] Gemini TTS HTTP ${response.statusCode}');
        // Cota/chave inválida: não insiste por 2 minutos (cai para a voz do aparelho)
        _cloudBackoffUntil = DateTime.now().add(const Duration(minutes: 2));
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final parts = ((json['candidates'] as List).first['content']['parts']) as List;
      final inline = parts.first['inlineData'] as Map<String, dynamic>;
      final mime = (inline['mimeType'] as String?) ?? '';
      final rate = int.tryParse(RegExp(r'rate=(\d+)').firstMatch(mime)?.group(1) ?? '') ?? 24000;
      final pcm = base64Decode(inline['data'] as String);

      final wav = _pcmToWav(pcm, rate);
      final blob = html.Blob([wav], 'audio/wav');
      return html.Url.createObjectUrlFromBlob(blob);
    } catch (e) {
      debugPrint('[WebBibleTtsEngine] Falha no Gemini TTS: $e');
      _cloudBackoffUntil = DateTime.now().add(const Duration(minutes: 1));
      return null;
    }
  }

  /// Tenta falar com a voz neural. Retorna `true` se assumiu a leitura (ou se foi
  /// substituída por outra), `false` se o chamador deve usar a voz do aparelho.
  Future<bool> _speakWithCloud({
    required String text,
    required bool preferMale,
    required double rate,
    required int token,
    String? nextText,
    VoidCallback? onComplete,
  }) async {
    if (!_hasCloudKey || DateTime.now().isBefore(_cloudBackoffUntil)) return false;

    final url = await _cloudAudioUrl(text, preferMale);
    if (token != _utteranceToken) return true; // usuário já trocou de faixa/parou
    if (url == null) return false;

    final audio = _audio ??= html.AudioElement();
    await _audioEndSub?.cancel();
    await _audioErrorSub?.cancel();

    var finished = false;
    void completeOnce() {
      if (finished || token != _utteranceToken) return;
      finished = true;
      onComplete?.call();
    }

    _audioEndSub = audio.onEnded.listen((_) => completeOnce());
    _audioErrorSub = audio.onError.listen((_) => completeOnce());

    try {
      audio.src = url;
      audio.playbackRate = rate.clamp(0.5, 2.0);
      await audio.play();
    } catch (e) {
      debugPrint('[WebBibleTtsEngine] Reprodução neural bloqueada: $e');
      await _audioEndSub?.cancel();
      await _audioErrorSub?.cancel();
      return false;
    }

    // Pré-carrega o próximo versículo enquanto este toca → leitura contínua, sem pausas.
    if (nextText != null && nextText.isNotEmpty) {
      unawaited(_cloudAudioUrl(nextText, preferMale));
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Fala
  // ---------------------------------------------------------------------------

  @override
  Future<void> speak({
    required String text,
    required bool preferMale,
    String? specificVoiceId,
    double rate = 1.0,
    double pitch = 1.0,
    String? nextText,
    VoidCallback? onComplete,
    void Function(String error)? onError,
  }) async {
    // IMPORTANTE: executa de forma síncrona dentro do toque do usuário (exigência do iOS).
    if (_hasCloudKey) _unlockAudio();

    final synth = _synth;
    final currentToken = ++_utteranceToken;
    _cancelKeepAlive();
    try {
      _audio?.pause();
    } catch (_) {}
    try {
      synth?.cancel();
    } catch (_) {}

    // Atualiza a existência da chave (o pastor pode tê-la salvo agora)
    _hasCloudKey = (await GeminiHomileticsAgent.getSavedApiKey()) != null;
    if (currentToken != _utteranceToken) return;

    // 1. Voz neural humana (Gemini TTS) — se indisponível, cai para a voz do aparelho
    if (_hasCloudKey) {
      final handled = await _speakWithCloud(
        text: text,
        preferMale: preferMale,
        rate: rate,
        token: currentToken,
        nextText: nextText,
        onComplete: onComplete,
      );
      if (handled) return;
      if (currentToken != _utteranceToken) return;
    }

    // 2. Voz do aparelho (Web Speech API)
    if (synth == null) {
      onError?.call('Navegador sem suporte a leitura em voz.');
      return;
    }

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
        final voiceIsMale = _isVoiceMale(vName);
        final voiceIsFemale = _isVoiceFemale(vName);

        // Só ajusta o timbre quando o aparelho NÃO tem uma voz do gênero pedido.
        if (preferMale && !voiceIsMale) {
          effectivePitch = (pitch * 0.86).clamp(0.7, 1.0);
          effectiveRate = (rate * 0.97).clamp(0.75, 1.5);
        } else if (!preferMale && !voiceIsFemale) {
          effectivePitch = (pitch * 1.14).clamp(1.0, 1.35);
        } else {
          effectivePitch = 1.0; // voz do gênero correto: timbre natural, sem distorção
        }
      } else {
        effectivePitch = preferMale ? 0.88 : 1.05;
      }

      utterance.rate = effectiveRate.clamp(0.5, 2.0);
      utterance.pitch = effectivePitch.clamp(0.5, 2.0);
      utterance.volume = 1.0;

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
      _audio?.pause();
    } catch (_) {}
  }

  @override
  void resume() {
    try {
      _synth?.resume();
      _audio?.play();
    } catch (_) {}
  }

  @override
  void stop() {
    _utteranceToken++;
    _cancelKeepAlive();
    try {
      _synth?.cancel();
    } catch (_) {}
    try {
      _audio?.pause();
    } catch (_) {}
  }
}

BibleTtsEngine createBibleTtsEngine() => WebBibleTtsEngine();
