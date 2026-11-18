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

/// Motor de leitura em voz da Bíblia (Web / PWA / iPhone Safari).
///
/// Duas camadas, com transição automática:
///  1. VOZ NEURAL HUMANA (Gemini TTS) — quando há chave Gemini configurada.
///     Voz masculina (`Charon`) e feminina (`Aoede`) realmente distintas, com sotaque
///     carioca natural do Rio de Janeiro (Brasil).
///  2. VOZ DO APARELHO (Web Speech API) — selecionada por gênero estrito e qualidade
///     em `pt-BR` (Felipe/Eddy/Reed/Antonio vs Luciana/Flo/Francisca/Google pt-BR),
///     com modelagem acústica diferenciada quando o aparelho possui apenas um timbre instalado.
class WebBibleTtsEngine implements BibleTtsEngine {
  html.SpeechSynthesis? _synth;
  Timer? _chromeKeepAliveTimer;
  int _utteranceToken = 0;
  List<html.SpeechSynthesisVoice> _rawVoices = [];

  // --- Camada neural (Gemini TTS) ---
  static const String _geminiTtsModel = 'gemini-2.5-flash-preview-tts';
  static const String _maleCloudVoice = 'Charon'; // grave, sereno, masculino
  static const String _femaleCloudVoice = 'Aoede'; // suave, clara, feminina
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
  bool get isCloudNeuralActive =>
      _hasCloudKey && DateTime.now().isAfter(_cloudBackoffUntil);

  @override
  void resetCloudBackoff() {
    _cloudBackoffUntil = DateTime.fromMillisecondsSinceEpoch(0);
  }

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
      onVoicesReady?.call();

      synth.addEventListener('voiceschanged', (_) {
        _refreshVoices();
        onVoicesReady?.call();
      });

      // Fallback de polling rápido caso o evento voiceschanged já tenha disparado antes (Safari/iOS)
      for (int i = 0; i < 8; i++) {
        await Future.delayed(const Duration(milliseconds: 250));
        final prevCount = _rawVoices.length;
        _refreshVoices();
        if (_rawVoices.isNotEmpty && _rawVoices.length != prevCount) {
          onVoicesReady?.call();
        }
        if (_rawVoices.isNotEmpty && i >= 2) break;
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
  // Classificação rigorosa de vozes Brasil (pt-BR) por gênero
  // ---------------------------------------------------------------------------

  static const _maleKeywords = [
    // iOS / macOS (pt-BR)
    'felipe', 'eddy', 'reed', 'rocko', 'grandpa',
    // Windows / Edge / Android (pt-BR)
    'antonio', 'antônio', 'donato', 'fabio', 'fábio', 'humberto', 'julio', 'júlio',
    'nicolau', 'valerio', 'valério', 'daniel', 'ricardo', 'tiago', 'marcos', 'paulo',
    'carlos', 'luca', 'jorge', 'henrique', 'rafael', 'gabriel', 'lucas',
    // Genéricos
    'male', 'masculin', 'homem',
  ];

  static const _femaleKeywords = [
    // iOS / macOS (pt-BR)
    'luciana', 'flo', 'sandy', 'shelley', 'grandma',
    // Windows / Edge / Chrome / Android (pt-BR)
    'francisca', 'thalita', 'maria', 'brenda', 'giovanna', 'leila', 'manuela',
    'yara', 'heloisa', 'heloísa', 'vitória', 'vitoria', 'camila', 'fernanda',
    'leticia', 'letícia', 'raquel', 'ana', 'julia', 'júlia',
    'google português', 'google portugues',
    // Genéricos
    'female', 'feminin', 'mulher',
  ];

  static const _portugalKeywords = [
    'pt-pt', 'pt_pt', 'portugal', 'cristiano', 'inês', 'ines', 'duarte', 'joana',
  ];

  bool _hasKeyword(String nameLower, List<String> keywords) {
    for (final kw in keywords) {
      if (nameLower.contains(kw)) return true;
    }
    return false;
  }

  bool _isVoiceMale(String nameLower) => _hasKeyword(nameLower, _maleKeywords);
  bool _isVoiceFemale(String nameLower) => _hasKeyword(nameLower, _femaleKeywords);

  bool _isPortugalVoice(html.SpeechSynthesisVoice v) {
    final lang = (v.lang ?? '').toLowerCase().replaceAll('_', '-');
    if (lang.startsWith('pt-pt')) return true;
    final name = (v.name ?? '').toLowerCase();
    return _hasKeyword(name, _portugalKeywords) && !lang.startsWith('pt-br');
  }

  /// Pontuação de qualidade: prioriza vozes naturais/neurais/aprimoradas do Brasil.
  int _voiceQuality(html.SpeechSynthesisVoice v) {
    final n = (v.name ?? '').toLowerCase();
    final lang = (v.lang ?? '').toLowerCase().replaceAll('_', '-');
    var score = 0;
    if (lang.startsWith('pt-br')) score += 5;
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
    if (n.contains('felipe') || n.contains('luciana')) score += 2;
    if (v.localService == false) score += 1;
    return score;
  }

  bool _isNaturalOrNeural(html.SpeechSynthesisVoice v) => _voiceQuality(v) >= 7;

  List<html.SpeechSynthesisVoice> _ptBrCandidates() {
    // 1. Estrito pt-BR (Brasil), descartando vozes de Portugal
    final strictPtBr = _rawVoices.where((v) {
      final lang = (v.lang ?? '').toLowerCase().replaceAll('_', '-');
      return lang.startsWith('pt-br') && !_isPortugalVoice(v);
    }).toList();
    if (strictPtBr.isNotEmpty) return strictPtBr;

    // 2. Fallback para qualquer pt que não seja Portugal
    final ptOther = _rawVoices.where((v) {
      final lang = (v.lang ?? '').toLowerCase().replaceAll('_', '-');
      return lang.startsWith('pt') && !_isPortugalVoice(v);
    }).toList();
    if (ptOther.isNotEmpty) return ptOther;

    return const [];
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
          isFemale: _isVoiceFemale(nameLower),
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

    // 1. Voz específica escolhida manualmente pelo usuário
    if (specificVoiceId != null && specificVoiceId.isNotEmpty) {
      for (final v in _rawVoices) {
        if (v.voiceUri == specificVoiceId || v.name == specificVoiceId) {
          return v;
        }
      }
    }

    final candidates = _ptBrCandidates();
    if (candidates.isEmpty) return null;

    // 2. Voz do gênero desejado em pt-BR, priorizando maior qualidade
    final genderMatches = candidates.where((v) {
      final nameLower = (v.name ?? '').toLowerCase();
      return preferMale ? _isVoiceMale(nameLower) : _isVoiceFemale(nameLower);
    }).toList()
      ..sort((a, b) => _voiceQuality(b).compareTo(_voiceQuality(a)));
    if (genderMatches.isNotEmpty) return genderMatches.first;

    // 3. Se pediu masculina e só existem vozes desconhecidas/mistas, tenta evitar uma voz
    //    explicitamente feminina caso exista alguma neutra; se só houver feminina (ex.: apenas Luciana
    //    ou Google pt-BR instalada no aparelho), retorna ela para aplicar modelagem acústica grave.
    if (preferMale) {
      final nonFemale = candidates
          .where((v) => !_isVoiceFemale((v.name ?? '').toLowerCase()))
          .toList()
        ..sort((a, b) => _voiceQuality(b).compareTo(_voiceQuality(a)));
      if (nonFemale.isNotEmpty) return nonFemale.first;
    } else {
      final nonMale = candidates
          .where((v) => !_isVoiceMale((v.name ?? '').toLowerCase()))
          .toList()
        ..sort((a, b) => _voiceQuality(b).compareTo(_voiceQuality(a)));
      if (nonMale.isNotEmpty) return nonMale.first;
    }

    candidates.sort((a, b) => _voiceQuality(b).compareTo(_voiceQuality(a)));
    return candidates.first;
  }

  @override
  String describeActiveVoice({
    required bool preferMale,
    String? specificVoiceId,
  }) {
    if (specificVoiceId == null && isCloudNeuralActive) {
      return preferMale
          ? 'Neural Carioca RJ • Charon (Masculina)'
          : 'Neural Carioca RJ • Aoede (Feminina)';
    }

    final selected = _selectBestVoice(
      preferMale: preferMale,
      specificVoiceId: specificVoiceId,
    );
    if (selected == null) {
      return preferMale
          ? 'Padrão Sistema (Masculina • Brasil)'
          : 'Padrão Sistema (Feminina • Brasil)';
    }

    final vName = selected.name ?? 'Voz pt-BR';
    final nameLower = vName.toLowerCase();
    final isNativeMale = _isVoiceMale(nameLower);
    final isNativeFemale = _isVoiceFemale(nameLower);

    if (preferMale && !isNativeMale) {
      return '$vName (Timbre Masculino Grave • pt-BR)';
    }
    if (!preferMale && !isNativeFemale) {
      return '$vName (Timbre Feminino • pt-BR)';
    }
    return '$vName (Brasil • pt-BR)';
  }

  // ---------------------------------------------------------------------------
  // Camada neural: Gemini TTS (Sotaque Carioca - Rio de Janeiro / Brasil)
  // ---------------------------------------------------------------------------

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
    final wav = _pcmToWav(Uint8List(2400), 24000);
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

  Future<String?> _cloudAudioUrl(String text, bool preferMale) {
    final cacheKey = '${preferMale ? 'm' : 'f'}|$text';
    final cached = _cloudAudioCache[cacheKey];
    if (cached != null) return cached;

    final future = _fetchGeminiAudio(text, preferMale);
    _cloudAudioCache[cacheKey] = future;
    _cloudCacheOrder.add(cacheKey);

    while (_cloudCacheOrder.length > 10) {
      final oldKey = _cloudCacheOrder.removeAt(0);
      final old = _cloudAudioCache.remove(oldKey);
      old?.then((url) {
        if (url != null) html.Url.revokeObjectUrl(url);
      });
    }

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
          ? 'Read aloud in Brazilian Portuguese with an authentic Rio de Janeiro (carioca) accent, warm deep calm male pastor voice, natural carioca rhythm. Do not read these instructions, read only the Bible text below:\n\n'
          : 'Read aloud in Brazilian Portuguese with an authentic Rio de Janeiro (carioca) accent, warm gentle clear female narrator voice, natural carioca rhythm. Do not read these instructions, read only the Bible text below:\n\n';

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
                    {'text': '$direction$text'},
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
        _cloudBackoffUntil = DateTime.now().add(const Duration(seconds: 25));
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final parts = ((json['candidates'] as List).first['content']['parts']) as List;
      Map<String, dynamic>? inline;
      for (final p in parts) {
        if (p is Map && p['inlineData'] != null) {
          inline = Map<String, dynamic>.from(p['inlineData'] as Map);
          break;
        }
      }
      if (inline == null) return null;

      final mime = (inline['mimeType'] as String?) ?? '';
      final rate = int.tryParse(RegExp(r'rate=(\d+)').firstMatch(mime)?.group(1) ?? '') ?? 24000;
      final pcm = base64Decode(inline['data'] as String);

      final wav = _pcmToWav(pcm, rate);
      final blob = html.Blob([wav], 'audio/wav');
      return html.Url.createObjectUrlFromBlob(blob);
    } catch (e) {
      debugPrint('[WebBibleTtsEngine] Falha no Gemini TTS: $e');
      _cloudBackoffUntil = DateTime.now().add(const Duration(seconds: 20));
      return null;
    }
  }

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
    if (token != _utteranceToken) return true;
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
    bool interruptPrevious = true,
    VoidCallback? onComplete,
    void Function(String error)? onError,
  }) async {
    // Executa síncronamente dentro do toque do usuário (exigência iOS Safari)
    if (_hasCloudKey) _unlockAudio();

    final synth = _synth;
    final currentToken = ++_utteranceToken;
    _cancelKeepAlive();
    if (interruptPrevious) {
      try {
        _audio?.pause();
      } catch (_) {}
      try {
        synth?.cancel();
      } catch (_) {}
    }

    // Atualiza disponibilidade da chave caso o usuário tenha configurado agora
    _hasCloudKey = (await GeminiHomileticsAgent.getSavedApiKey()) != null;
    if (currentToken != _utteranceToken) return;

    // 1. Voz neural humana carioca (Gemini TTS) quando sem voz específica local selecionada
    if (_hasCloudKey && (specificVoiceId == null || specificVoiceId.isEmpty)) {
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

    // Pequeno respiro para estabilidade no iOS Safari / Chrome após cancel()
    await Future.delayed(Duration(milliseconds: interruptPrevious ? 65 : 20));
    if (currentToken != _utteranceToken) return;

    try {
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = 'pt-BR';

      final selectedVoice = _selectBestVoice(
        preferMale: preferMale,
        specificVoiceId: specificVoiceId,
      );

      double effectivePitch;
      double effectiveRate = rate;

      if (selectedVoice != null) {
        utterance.voice = selectedVoice;
        final vName = (selectedVoice.name ?? '').toLowerCase();
        final voiceIsMale = _isVoiceMale(vName);
        final voiceIsFemale = _isVoiceFemale(vName);

        if (preferMale && voiceIsMale) {
          // Voz masculina nativa real (Felipe, Eddy, Antonio, Daniel, etc.):
          // mantém timbre natural masculino levemente firme.
          effectivePitch = 0.94;
          effectiveRate = (rate * 0.98).clamp(0.72, 1.45);
        } else if (!preferMale && voiceIsFemale) {
          // Voz feminina nativa real (Luciana, Francisca, Google pt-BR, Flo, etc.):
          // mantém timbre feminino claro e natural.
          effectivePitch = 1.08;
          effectiveRate = rate.clamp(0.75, 1.45);
        } else if (preferMale && !voiceIsMale) {
          // O aparelho NÃO possui voz masculina pt-BR instalada (comum no iPhone/Chrome padrão):
          // aplica modelagem acústica grave nítida para distinguir claramente do modo feminino.
          effectivePitch = 0.62;
          effectiveRate = (rate * 0.92).clamp(0.72, 1.4);
        } else {
          // O aparelho só tem voz masculina e o usuário pediu feminina:
          effectivePitch = 1.32;
          effectiveRate = (rate * 1.03).clamp(0.75, 1.5);
        }
      } else {
        effectivePitch = preferMale ? 0.65 : 1.12;
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

      // Watchdog anti-congelamento do Chrome
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
