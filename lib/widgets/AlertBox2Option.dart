import 'package:flutter/material.dart';
import 'package:camera/camera.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



class ImagePopUpWithTwoOption extends StatelessWidget {
  final String imagePath;
  final String textField;
  String? what;
  String? extraText,option1,option2;
  VoidCallback? onButton1Pressed;
  VoidCallback? onButton2Pressed;

  ImagePopUpWithTwoOption({
    required this.imagePath,
    required this.textField,
    this.what,
    this.extraText,
    this.option1,this.option2,
    this.onButton1Pressed,this.onButton2Pressed
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 310,
          width: 430,
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              height: 260,
              width: 400,
              child: Column(
                children: [
                  // SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Image.asset(imagePath),
                    ),
                  ),
                  // SizedBox(height: 30),
                  Text(
                    textField,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
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
                        // SizedBox(height: 26),

                      ],
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
                  Text('|',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 20,
                  ),),
                  TextButton(
                    onPressed: () {
                      // Remove video logic here
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
              // SizedBox(height: 20),
            ],
          )
      ),
    );
  }

}
