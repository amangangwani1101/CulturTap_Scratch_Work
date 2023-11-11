import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:learn_flutter/CulturTap/HomePage.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:flutter_svg/flutter_svg.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



class ImagePopUpWithOK extends StatelessWidget {
  final String imagePath;
  final String textField;
  final String what;
  final String? extraText;



  ImagePopUpWithOK({
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
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

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

              TextButton(
                onPressed: () {
                  // Navigate to the CameraApp page when OK is clicked
                  if(what == 'home'){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }
                  if(what == 'camera'){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraApp()),
                    );
                  }
                  //condition for just using back functionality
                  if(what == 'ok'){
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
          backgroundColor: Color(0xFF263238),
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