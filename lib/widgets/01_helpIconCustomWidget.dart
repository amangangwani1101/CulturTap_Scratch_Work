import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:learn_flutter/userProfile1.dart';

class CustomHelpOverlay extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.grey.withOpacity(0),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              width: screenWidth*0.95,
              height: 315,
              decoration: BoxDecoration(
                color: HexColor('#D9D9D9'),
                // border: Border.all(
                //   color: Colors.brown,
                //   width: 2,
                // ),
                // borderRadius: BorderRadius.circular(10.0),
              ),
              // child: Align(
              //   alignment: Alignment.topRight,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //     child: (Icon(Icons.crop_sharp)),
              //   ),
              // ),

              child: Container(
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.black), // Optional border
                // ),
                child: Stack(
                  children: [
                    Center(child: Image.asset('assets/images/help_motivation_icon.jpg',width: 361,height: 281,fit: BoxFit.contain,),),
                    Positioned(
                      top: 25,
                      right: 15,
                      child:IconButton(
                        icon: Icon(Icons.close),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),


            ),
          ),
        ],
      ),
    );
  }
}
