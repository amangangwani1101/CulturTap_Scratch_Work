import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RotatingSvgWidget extends StatefulWidget {
  final String imagePath;
  final double size;
  final Duration duration;

  RotatingSvgWidget({
    required this.imagePath,
    this.size = 28.0,
    this.duration = const Duration(seconds: 1),
  });

  @override
  _RotatingSvgWidgetState createState() => _RotatingSvgWidgetState();
}

class _RotatingSvgWidgetState extends State<RotatingSvgWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
      child: Container(
        width: widget.size,
        height: widget.size,
        child: SvgPicture.asset(
          widget.imagePath,
          fit: BoxFit.contain,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
