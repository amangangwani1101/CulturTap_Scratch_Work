import 'package:flutter/material.dart';

class CustomImagePopup extends StatelessWidget {
  final String imagePath;

  CustomImagePopup({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height : 281,
        width : 361,
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: [
              Image.asset(imagePath
              ),
              Positioned(
                top: 10.0,
                right: 10.0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the popup
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// showDialog(
//    context: context,
//    builder: (BuildContext context) {
//    return CustomImagePopup(
//    imagePath: 'assets/images/fourthPage.png',
//   );
//  },
// );