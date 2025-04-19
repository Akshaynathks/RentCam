import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final VoidCallback onTap;

  const ClickableText({
    super.key,
    required this.text,
    required this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: style ??
            const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
        recognizer: TapGestureRecognizer()..onTap = onTap,
      ),
    );
  }
}
