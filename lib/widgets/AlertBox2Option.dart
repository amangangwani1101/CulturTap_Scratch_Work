import 'package:flutter/material.dart';
import 'package:camera/camera.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



class ImagePopUpWithTwoOption extends StatelessWidget {
  final String imagePath;
  final String textField;
  String? what;
  String? extraText, option1, option2;
  VoidCallback? onButton1Pressed;
  VoidCallback? onButton2Pressed;

  ImagePopUpWithTwoOption({
    required this.imagePath,
    required this.textField,
    this.what,
    this.extraText,
    this.option1,
    this.option2,
    this.onButton1Pressed,
    this.onButton2Pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust padding as needed
        child: AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            constraints: BoxConstraints(
              maxWidth: 400, // Set maximum width for content
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Set to min to take required height
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Image.asset(imagePath),
                  ),
                ),
                Text(
                  textField,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 20),
                if (extraText != null)
                  Text(
                    extraText!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    onButton1Pressed!();
                  },
                  child: Text(
                    option1!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 20,
                    ),
                  ),
                ),
                Text(
                  '|',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 20,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onButton2Pressed!();
                  },
                  child: Text(
                    option2!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
