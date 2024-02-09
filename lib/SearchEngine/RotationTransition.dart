import 'dart:math';

import 'package:flutter/material.dart';

class CustomBlinkingLoader extends StatefulWidget {
  @override
  _CustomBlinkingLoaderState createState() => _CustomBlinkingLoaderState();
}

class _CustomBlinkingLoaderState extends State<CustomBlinkingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        child: RotationTransition(
          turns: _controller,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(
              18,
                  (index) {
                final opacityTween = TweenSequence(
                  [
                    TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
                    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
                  ],
                );

                return Positioned(
                  top: 50 - 20 * cos(index * 2 * 3.1416 / 12),
                  left: 50 - 20 * sin(index * 2 * 3.1416 / 12),
                  child: Opacity(
                    opacity: opacityTween.animate(_controller).value,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index % 2 == 0 ? Colors.transparent : Colors.white30,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
