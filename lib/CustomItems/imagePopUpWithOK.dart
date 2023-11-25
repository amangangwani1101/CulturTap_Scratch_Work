import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:flutter_svg/flutter_svg.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



class ImagePopUpWithOK extends StatelessWidget {
  final String imagePath;
  final String textField;
  final String what;
  final String? extraText;
  final String? isDarkMode; // Add a boolean variable for background color condition

  ImagePopUpWithOK({
    required this.imagePath,
    required this.textField,
    required this.what,
    this.extraText,
    this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = (isDarkMode=='') ? Color(0xFF263238) : Colors.white; // Set background color based on the condition

    return Center(
      child: Container(
        height: 440,
        width: 377,
        child: AlertDialog(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 66),
              SvgPicture.asset(
                imagePath,
                height: 66,
                width: 66,
              ),
              SizedBox(height: 46),
              Text(
                textField,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: (isDarkMode=='') ? Colors.white : Colors.black, // Text color based on condition
                ),
                textAlign: TextAlign.center,
              ),
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
              SizedBox(height: 26),
              TextButton(
                onPressed: () {
                  if (what == 'home') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }
                  if (what == 'camera') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraApp()),
                    );
                  }
                  if (what == 'ok') {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor, // Set the background color
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



