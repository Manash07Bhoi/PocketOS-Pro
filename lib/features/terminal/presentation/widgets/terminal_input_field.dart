import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';

class TerminalInputField extends StatefulWidget {
  final String prompt;
  final String initialValue;
  final Function(String) onSubmit;
  final VoidCallback onUpArrow;
  final VoidCallback onDownArrow;
  final bool isExecuting;

  const TerminalInputField({super.key, required this.prompt, required this.onSubmit, required this.onUpArrow, required this.onDownArrow, this.initialValue = '', this.isExecuting = false});
  @override State<TerminalInputField> createState() => _TerminalInputFieldState();
}

class _TerminalInputFieldState extends State<TerminalInputField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override void didUpdateWidget(TerminalInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    }
  }

  @override void dispose() { _controller.dispose(); _focusNode.dispose(); super.dispose(); }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) { widget.onUpArrow(); }
      else if (event.logicalKey == LogicalKeyboardKey.arrowDown) { widget.onDownArrow(); }
    }
  }

  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: KeyboardListener(
        focusNode: FocusNode(), onKeyEvent: _handleKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.prompt, style: AppTypography.terminalPrompt),
            const SizedBox(width: 8),
            Expanded(
              child: widget.isExecuting ? const SizedBox.shrink() : TextField(
                controller: _controller, focusNode: _focusNode, style: AppTypography.terminalText,
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                cursorColor: AppColors.termCursor, cursorWidth: 8, keyboardAppearance: Brightness.dark, textInputAction: TextInputAction.done,
                onSubmitted: (value) { if (value.isNotEmpty) { widget.onSubmit(value); _controller.clear(); } _focusNode.requestFocus(); },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
