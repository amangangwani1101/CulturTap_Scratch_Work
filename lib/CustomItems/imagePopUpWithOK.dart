import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// import 'package:learn_flutter/VIdeoSection/CameraApp.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 66),
              Image.asset(
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
              SizedBox(height: 26),
              TextButton(
                onPressed: () {
                  // Navigate to the CameraApp page when OK is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraApp()),
                  );


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
