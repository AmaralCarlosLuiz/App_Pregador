import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🛡️ Módulo de Trava de Segurança e Proteção de Código Fonte (Defense-in-Depth)
/// Intercepta clique direito (contextmenu) e atalhos de inspeção (F12, Ctrl+Shift+I/J/C, Ctrl+U, Shift+F10)
/// preservando edição normal em campos de formulário (EditableText).
class SourceProtectionWrapper extends StatefulWidget {
  final Widget child;

  const SourceProtectionWrapper({
    super.key,
    required this.child,
  });

  @override
  State<SourceProtectionWrapper> createState() => _SourceProtectionWrapperState();
}

class _SourceProtectionWrapperState extends State<SourceProtectionWrapper> {
  String? _toastTitle;
  String? _toastDescription;
  bool _isErrorToast = false;
  Timer? _toastTimer;
  DateTime _lastTriggered = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _toastTimer?.cancel();
    super.dispose();
  }

  bool _isEditableFocused() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    final ctx = primaryFocus?.context;
    if (ctx == null) return false;
    if (ctx.widget is EditableText) return true;
    return ctx.findAncestorWidgetOfExactType<EditableText>() != null ||
        ctx.findAncestorWidgetOfExactType<TextField>() != null ||
        ctx.findAncestorWidgetOfExactType<TextFormField>() != null;
  }

  void _showSecurityToast({
    required String title,
    required String description,
    required bool isError,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    final now = DateTime.now();
    if (now.difference(_lastTriggered).inMilliseconds < 900) return;
    _lastTriggered = now;

    _toastTimer?.cancel();
    if (!mounted) return;

    setState(() {
      _toastTitle = title;
      _toastDescription = description;
      _isErrorToast = isError;
    });

    _toastTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          _toastTitle = null;
          _toastDescription = null;
        });
      }
    });
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final logicalKey = event.logicalKey;
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    final isCtrl = keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
        keysPressed.contains(LogicalKeyboardKey.controlRight);
    final isMeta = keysPressed.contains(LogicalKeyboardKey.metaLeft) ||
        keysPressed.contains(LogicalKeyboardKey.metaRight);
    final isCtrlOrCmd = isCtrl || isMeta;
    final isShift = keysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        keysPressed.contains(LogicalKeyboardKey.shiftRight);
    final isAlt = keysPressed.contains(LogicalKeyboardKey.altLeft) ||
        keysPressed.contains(LogicalKeyboardKey.altRight);

    final isF12 = logicalKey == LogicalKeyboardKey.f12;
    final isShiftF10 = isShift && logicalKey == LogicalKeyboardKey.f10;
    final isCtrlU = isCtrlOrCmd && logicalKey == LogicalKeyboardKey.keyU;
    final isCtrlS = isCtrlOrCmd && logicalKey == LogicalKeyboardKey.keyS;

    final isInspect = (isCtrlOrCmd &&
            isShift &&
            (logicalKey == LogicalKeyboardKey.keyI ||
                logicalKey == LogicalKeyboardKey.keyJ ||
                logicalKey == LogicalKeyboardKey.keyC ||
                logicalKey == LogicalKeyboardKey.keyK ||
                logicalKey == LogicalKeyboardKey.keyE)) ||
        (isMeta &&
            isAlt &&
            (logicalKey == LogicalKeyboardKey.keyI ||
                logicalKey == LogicalKeyboardKey.keyJ ||
                logicalKey == LogicalKeyboardKey.keyC ||
                logicalKey == LogicalKeyboardKey.keyU));

    if (isF12 || isShiftF10 || isCtrlU || isCtrlS || isInspect) {
      _showSecurityToast(
        title: 'Acesso Restrito',
        description:
            'Os atalhos de desenvolvedor e inspeção de código fonte estão desabilitados neste ambiente.',
        isError: true,
        duration: const Duration(milliseconds: 3500),
      );
      return true; // Consome o atalho bloqueando a propagação
    }

    return false;
  }

  void _handlePointerDown(PointerDownEvent event) {
    // kSecondaryMouseButton == 2 (Clique com botão direito do mouse)
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      if (!_isEditableFocused()) {
        _showSecurityToast(
          title: 'Proteção de Código Ativa',
          description:
              'A inspeção e cópia do código fonte do Sistema são restritas por políticas de segurança corporativa.',
          isError: false,
          duration: const Duration(milliseconds: 3000),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          widget.child,
          if (_toastTitle != null && !kIsWeb)
            Positioned(
              bottom: 24,
              right: 24,
              child: IgnorePointer(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 380, minWidth: 280),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: _isErrorToast
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFF59E0B),
                          width: 4,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _isErrorToast ? Icons.block : Icons.shield_outlined,
                          color: _isErrorToast
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _toastTitle!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _toastDescription ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

