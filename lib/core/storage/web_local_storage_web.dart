// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

const String _webPrefix = 'pp_sync_';

/// Lê imediatamente do `window.localStorage` de forma síncrona.
/// Garante disponibilidade imediata mesmo antes de chamadas assíncronas e atua
/// como espelho resiliente no Safari/WebClip do iPhone.
String? readWebLocal(String key) {
  try {
    return html.window.localStorage['$_webPrefix$key'];
  } catch (e) {
    debugPrint('[WebLocalStorage] Erro ao ler $key: $e');
    return null;
  }
}

/// Grava de forma síncrona no `window.localStorage`.
/// Como é síncrono, a gravação é efetivada antes mesmo de o iOS suspender o Safari/WebClip.
bool writeWebLocal(String key, String value) {
  try {
    html.window.localStorage['$_webPrefix$key'] = value;
    return true;
  } catch (e) {
    debugPrint('[WebLocalStorage] Erro ao gravar $key: $e');
    return false;
  }
}

void removeWebLocal(String key) {
  try {
    html.window.localStorage.remove('$_webPrefix$key');
  } catch (_) {}
}

