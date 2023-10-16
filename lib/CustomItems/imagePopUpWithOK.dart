import 'package:flutter/material.dart';

class ImagePopUpWithOK extends StatelessWidget {
  final String imagePath;
  final String textField;

  ImagePopUpWithOK({
    required this.imagePath,
    required this.textField,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 380,
        width: 377,
        child: AlertDialog(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
            children: [
              SizedBox(height: 66),
              Image.asset(
                imagePath,
                height: 66,
                width: 66, // Adjust the image width and height as needed
              ),
              SizedBox(height: 46), // Add space between the image and text
              Text(
                textField,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center, // Center the text
              ),
              SizedBox(height: 26), // Add space between text and the "OK" button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.orange, // Set the text color to orange
                    fontSize: 24, // Set the font size to 24
                    fontWeight: FontWeight.bold, // Use a bold font
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF263238),
        ),
      ),
    );
  }
}
