import 'package:flutter/material.dart';

class StoryBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  StoryBar({required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Color(0xFF263238)),
          SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: 'Serch here your Mood, Food ,Places.....',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
