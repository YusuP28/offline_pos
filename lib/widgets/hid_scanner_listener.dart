import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HidScannerListener extends StatefulWidget {
  final ValueChanged<String> onScan;
  final Widget child;

  const HidScannerListener({
    super.key,
    required this.onScan,
    required this.child,
  });

  @override
  State<HidScannerListener> createState() =>
      _HidScannerListenerState();
}

class _HidScannerListenerState
    extends State<HidScannerListener> {
  final FocusNode _focusNode = FocusNode();
  String _buffer = '';

  DateTime? _lastKeyTime;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final now = DateTime.now();

      if (_lastKeyTime != null &&
          now.difference(_lastKeyTime!).inMilliseconds > 120) {
        _buffer = '';
      }

      _lastKeyTime = now;

      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_buffer.isNotEmpty) {
          widget.onScan(_buffer);
        }

        _buffer = '';
        return KeyEventResult.handled;
      }

      final character = event.character;

      if (character != null &&
          character.isNotEmpty &&
          character.codeUnitAt(0) >= 32) {
        _buffer += character;
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: widget.child,
    );
  }
}
