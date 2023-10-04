
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

// Converts hex string to color
class HexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex =  "FF" + hex.toUpperCase().replaceAll("#", "");
    return int.parse(formattedHex, radix: 16);
  }
  HexColor(final String hex) : super(_getColor(hex));
}

class MyApp extends StatelessWidget {
  bool videoUploaded =  false;
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Rating Section Example'),
        ),
        // body: Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: RatingSection(ratings: ratings,reviewCnt:currentReview),
        // ),
        body:
        !videoUploaded?
        Container(
          width: 410,
          height: 195,
          child: Center(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Other visits',
                  style: TextStyle(fontSize: 24,
                  fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                  Text('No visits till yet, You can start it now even, Just click on add “ + “ button at the bottom of your screen & '
                      ' record your outside surroundings.',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                  SizedBox(height: 7,),
                  Text('You can make video post private & public as per your choice. ',
                  style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                  SizedBox(height:7,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profile Strength Now',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily:'Poppins',),),
                      Text('Medium',style: TextStyle(fontSize: 12,fontFamily: 'Poppins',color: HexColor('#FB8C00'),fontWeight: FontWeight.bold),),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ):Text('Hello'),
      ),
    );
  }
}


