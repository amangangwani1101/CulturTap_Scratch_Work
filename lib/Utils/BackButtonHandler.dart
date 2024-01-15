import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/Settings.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';


class BackButtonHandler extends StatelessWidget {
  final String imagePath;
  final String textField;
  final String what;
  final String? extraText;
  final String button1;
  final String button2;

  BackButtonHandler({
    required this.imagePath,
    required this.textField,
    required this.what,
    this.extraText,
    required this.button1,
    required this.button2,
  });

  @override
  Widget build(BuildContext context) {
    // This is where you would return the UI for your BackButtonHandler.
    // You can put your UI elements or widgets here.
    return Container(
      // Your widget content goes here.
    );
  }

  Future<bool> onWillPop(BuildContext context, bool canExit) async {
    if (canExit) {
      return await showDialog(
        context: context,
        builder: (context) => Center(


        child: Container(
        height : 390,
        width: 377,
        child: AlertDialog(
          backgroundColor: Colors.white, // Use the theme's background color
          content: Container(
            child: Column(
              children: [
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: SvgPicture.asset(imagePath),
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
                  textAlign: TextAlign.center, // Align the text to center
                ),
                if (extraText != null)
                  Column(
                    children: [
                      SizedBox(height: 20),Center(
                        child: Padding(
                          padding: const EdgeInsets.only(),
                          child: Column(
                            children: [

                              Text(
                                extraText!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    button1,
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
                    if (what == "exit") {
                      SystemNavigator.pop();
                    }
                    if (what == 'Home' || what == 'v_p_h') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                    if (what == 'settings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage(userId: userID)),
                      );
                    }
                  },
                  child: Text(
                    button2,
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

    ),
      );
    } else {
      Navigator.pop(context);
      return false;
    }
  }
}
