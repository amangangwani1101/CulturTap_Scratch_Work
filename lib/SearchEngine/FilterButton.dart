import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class FilterButton extends StatelessWidget {
  final String filterName;
  final bool selected;
  final Function(String) onPressed;

  FilterButton(this.filterName, {required this.selected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left : 16),
      child: ElevatedButton(
        onPressed: () {
          onPressed(filterName);
        },
        style: ElevatedButton.styleFrom(
          primary: selected ? Colors.orange : Theme.of(context).primaryColorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.0),
            side: BorderSide(
              color : selected ? Colors.transparent :Theme.of(context).primaryColorLight, // Set the border color
              width: 0.5,          // Set the border width
            ),
            // Adjust the value as needed
          ),
          elevation: 0.0,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/$filterName.svg', // Update with your SVG file path
              width: 20.0,
              height: 20.0,
              color: selected ? Colors.white : Theme.of(context).primaryColor, // Set the color of the SVG icon
            ),
            SizedBox(width: 10), // Add some spacing between the icon and text
            Text(
              filterName,
              style: TextStyle(color: selected ? Colors.white :Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
