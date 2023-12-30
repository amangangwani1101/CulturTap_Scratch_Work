import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';




final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



class CustomPopUp extends StatelessWidget {
  final String imagePath;
  final String textField;
  final String what;
  final String? extraText;
  final String? isDarkMode;

  CustomPopUp({
    required this.imagePath,
    required this.textField,
    required this.what,
    this.extraText,
    this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = (isDarkMode=='dark') ? Color(0xFF263238) : Colors.white; // Set background color based on the condition

    return Center(
      child: Container(
        height: 340,

        width: double.infinity,
        child: AlertDialog(
          content: Column(


            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),

              ],),

              SvgPicture.asset(
                imagePath,
                height: 96,
                width: 116,
              ),
              SizedBox(height: 16),
              Text(
                textField,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              if (extraText != null)
                SizedBox(height: 16),
                Container(
                  child: Text(
                    extraText!,
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
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




