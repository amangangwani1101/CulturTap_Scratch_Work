import 'package:flutter/material.dart';

class Chat  extends StatelessWidget {
  String ? navigationData;
  Chat({this.navigationData});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('navigationData')),
      ),
    );
  }
}
