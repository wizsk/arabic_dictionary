import 'package:flutter/material.dart';

/// A widget that uses a CustomPainter to render text and a GestureDetector
/// to detect taps. When the user taps a word, it computes which word was tapped.
class ClickableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final void Function(String) onWordTap;

  const ClickableText({
    super.key,
    required this.text,
    required this.style,
    required this.onWordTap,
  });

  @override
  State<ClickableText> createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText> {
  late TextPainter _textPainter;

  @override
  void initState() {
    super.initState();
    _textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
  }

  @override
  void didUpdateWidget(ClickableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _textPainter.text = TextSpan(text: widget.text, style: widget.style);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Layout the text with the maximum available width.
      _textPainter.layout(maxWidth: constraints.maxWidth);
      return GestureDetector(
        onTapDown: (details) {
          _handleTap(details.localPosition);
        },
        child: CustomPaint(
          size: _textPainter.size,
          painter: _TextPainterWrapper(_textPainter),
        ),
      );
    });
  }

  /// Handle the tap by determining which word was tapped.
  void _handleTap(Offset localPosition) {
    // Get the text position based on the tap offset.
    final pos = _textPainter.getPositionForOffset(localPosition);
    final int offset = pos.offset;

    if (offset < 0 || offset >= widget.text.length) return;

    // Determine word boundaries by scanning for whitespace.
    final text = widget.text;
    int start = offset;
    int end = offset;

    // Move backward until a whitespace (or start of string) is encountered.
    while (start > 0 && !text[start - 1].contains(RegExp(r'\s'))) {
      start--;
    }
    // Move forward until a whitespace (or end of string) is encountered.
    while (end < text.length && !text[end].contains(RegExp(r'\s'))) {
      end++;
    }
    final word = text.substring(start, end);
    if (word.trim().isNotEmpty) {
      widget.onWordTap(word);
    }
  }
}

/// A simple CustomPainter that paints the text using a TextPainter.
class _TextPainterWrapper extends CustomPainter {
  final TextPainter textPainter;

  _TextPainterWrapper(this.textPainter);

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant _TextPainterWrapper oldDelegate) {
    return oldDelegate.textPainter.text != textPainter.text;
  }
}
