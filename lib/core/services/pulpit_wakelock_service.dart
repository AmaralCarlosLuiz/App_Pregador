import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PulpitWakelockService {
  static bool _isEnabled = false;
  static bool get isEnabled => _isEnabled;

  /// Mantém a tela ligada sem apagar durante a ministração no púlpito
  static Future<void> enableWakelock() async {
    try {
      await WakelockPlus.enable();
      _isEnabled = true;
      debugPrint('[PulpitWakelockService] Tela travada como ativa.');
    } catch (e) {
      debugPrint('[PulpitWakelockService] Erro ao ativar wakelock: $e');
    }
  }

  /// Restaura o comportamento padrão do sistema de tela ao sair do púlpito
  static Future<void> disableWakelock() async {
    try {
      await WakelockPlus.disable();
      _isEnabled = false;
      debugPrint('[PulpitWakelockService] Wakelock desativado.');
    } catch (e) {
      debugPrint('[PulpitWakelockService] Erro ao desativar wakelock: $e');
    }
  }
}
