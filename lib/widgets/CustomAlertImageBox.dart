import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  String? title;
  String? message,imagePath,option1,option2;
  VoidCallback? onButton1Pressed;
  VoidCallback? onButton2Pressed;

  CustomAlertDialog({
    this.title,
    this.message,
    this.imagePath,
    this.option1,
    this.option2,
    this.onButton1Pressed,
    this.onButton2Pressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 277,
        width: 363,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.close,
                size: 13,
              ),
            ),
            Image.asset('assets/images/${imagePath}.png',width: 32,height: 32,),
            Text(
              title!,
              style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),
            ),
            Text(
              message!,
              style: TextStyle(fontSize: 18,fontFamily: 'Poppins'),
            ),
            // SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: onButton1Pressed,
                  child: Text(option1!,style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold),),
                ),
                ElevatedButton(
                  onPressed: onButton2Pressed,
                  child:  Text(option2!,style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
