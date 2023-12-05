//searchbar

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StoryBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  StoryBar({required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(

      height : 60,
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.symmetric(horizontal: 19.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Adjust shadow color and opacity
            spreadRadius: 2,  // Adjust the spread radius of the shadow
            blurRadius: 2,    // Adjust the blur radius of the shadow
            offset: Offset(0, 1), // Adjust the shadow offset
          ),
        ],
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Color(0xFF001B33).withOpacity(0.2)),

        color : Colors.white,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/search_icon.svg', // Replace with the path to your SVG icon

            width: 28,
            height: 28,
          ),
          SizedBox(width: 20.0),
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
