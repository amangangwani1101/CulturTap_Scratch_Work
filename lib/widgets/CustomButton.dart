import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FiledButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  final Color backgroundColor;

  const FiledButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape:RoundedRectangleBorder(),
        primary: backgroundColor,
      ),
      child: child,
    );
  }
}
