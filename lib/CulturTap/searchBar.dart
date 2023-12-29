//searchbar

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_flutter/SearchEngine/searchPage.dart';

class StoryBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSubmitted;

  StoryBar({this.controller, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
      },
      child: Container(
        height: 60,
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.symmetric(horizontal: 19.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: Color(0xFF001B33).withOpacity(0)),
          color: Theme.of(context).backgroundColor,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/search_icon.svg',
              color: Theme.of(context).primaryColor,
              width: 18,
              height: 18,
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: false, // Disable text editing
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusColor: Colors.orange,
                  hintText: 'Search here your Mood, Food, Places...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
