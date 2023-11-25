import 'package:flutter/material.dart';

class PulseEffect extends StatefulWidget {
  @override
  _PulseEffectState createState() => _PulseEffectState();
}

class _PulseEffectState extends State<PulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true); // Repeat the animation with a pulse effect
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(begin: 1.0, end: 1.2).animate(_controller).value,
          child: Icon(
            Icons.cloud_upload,
            color: Colors.white,
            size: 100,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Usage in your widget tree:

