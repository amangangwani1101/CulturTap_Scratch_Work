import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';




final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



class CustomPopUp extends StatelessWidget {
  final String imagePath;
  final String textField;
  final String what;
  final String? extraText;
  final String button;
  final String? isDarkMode;

  CustomPopUp({
    required this.imagePath,
    required this.textField,
    required this.what,
    this.extraText,
    this.isDarkMode,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = (isDarkMode=='dark') ? Color(0xFF263238) : Colors.white; // Set background color based on the condition

    return Center(
      child: Container(
        padding : EdgeInsets.all(20),
        margin:EdgeInsets.only(left : 30,right : 30),
        color : Theme.of(context).backgroundColor,
        child : Column(
          mainAxisSize: MainAxisSize.min, // Set the mainAxisSize to min
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close,color : Theme.of(context).primaryColorDark)),
              ],
            ),
            SvgPicture.asset(
              imagePath,
              height : 200,
              width: 316, // Adjust the width as needed
            ),
            SizedBox(height: 26),
            Text(
              textField,
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
            if (extraText != null) SizedBox(height: 15),
            if (extraText != null)
              Container(
                child: Text(
                  extraText!,
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height : 20),
            if(button!=null)
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text(
                  button,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),

    );
  }
}




