import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomAnimateWidget extends StatelessWidget {
  final Widget child;

  const CustomAnimateWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 800)),
        SlideEffect(curve: Curves.easeIn),
      ],
      child: child,
    );
  }
}
