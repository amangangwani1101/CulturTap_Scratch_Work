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
        width: 377,
        child: AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
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
                Center(
                  child: Text(
                    textField,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center, // Align the text to center
                  ),
                ),

                if (extraText != null)
                  Center(
                  child: Padding(
                    padding: const EdgeInsets.only(),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                         // Check if extraText is not null
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
        ),
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