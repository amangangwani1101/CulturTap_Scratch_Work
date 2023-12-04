//searchbar

import 'package:flutter/material.dart';

class StoryBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  StoryBar({required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(

      height : 60,
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Color(0xFF2E2C43)),
        color : Colors.white,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Color(0xFF2E2C43)),
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
