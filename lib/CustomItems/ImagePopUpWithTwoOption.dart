import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:flutter_svg/flutter_svg.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



class ImagePopUpWithTwoOption extends StatelessWidget {
  final String imagePath;
  final String textField;
  final String what;
  final String? extraText;



  ImagePopUpWithTwoOption({
    required this.imagePath,
    required this.textField,
    required this.what,
    this.extraText,

  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(

        height: 440,
        width: 377,
        child: AlertDialog(
          backgroundColor: Color(0xFF263238),
          content: Container(
            height: 269,
            width: 300,
            child: Column(
              children: [
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Image.asset(imagePath),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  textField,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(),
                    child: Column(
                      children: [
                        if (extraText != null) // Check if extraText is not null
                    Text(
                    extraText!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 26),

                      ],
                    ),
                  ),
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
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 20,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Remove video logic here

                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        )
      ),
    );
  }

}

void gotocameraapp(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CameraApp()),
  );
}