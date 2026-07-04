import 'package:flutter/material.dart';

class FastPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FastPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // A fast 200ms fade transition that feels snappy
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 150),
        );
}

// A helper for quick navigation
void fastPush(BuildContext context, Widget screen) {
  Navigator.push(context, FastPageRoute(page: screen));
}
