import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomAnimateWidget extends StatelessWidget {
  final Widget child;

  const CustomAnimateWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: Duration(milliseconds: 800)),
        SlideEffect(curve: Curves.easeIn),
      ],
      child: child,
    );
  }
}
