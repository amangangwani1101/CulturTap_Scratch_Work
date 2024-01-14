import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/hexColor.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// Expert Cards -> User Experiences Section Have To Work
class ExpertCardDetails extends StatelessWidget{
  List<String> expertLocations = [];
  final GlobalKey containerKey = GlobalKey();
  String profileStatus = "Out Standing";
  int visitedplace = 0,coveredLocation = 0, ratings = 0;

  Future<void> shareContainerImage() async {
    try {
      RenderRepaintBoundary boundary =
      containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get temporary directory path
      String tempDirPath = (await getTemporaryDirectory()).path;
      String filePath = '$tempDirPath/image.png';

      // Write the image bytes to a file
      await File(filePath).writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile('${filePath}')],text:'Expert Card Details');
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          width: 600,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              // border: Border.all(
              //   color: Colors.black,
              //   width: 2,
              // ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  // offset: Offset(0.0,0.0),
                  blurRadius: 5.0,
                  spreadRadius: 7.9,
                ),
                BoxShadow(
                  color: Colors.white,
                  // offset: Offset(0.0,0.0),
                  blurRadius:5,
                  spreadRadius: 12.9,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20.0,top: 5.0,bottom: 9.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Expert Cards' ,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      IconButton(onPressed: (){
                        shareContainerImage();
                      }, icon: Icon(Icons.share_outlined)),
                    ],
                  ),
                  Column(
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text('Expert in locations -',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                          SizedBox(width: 31,),
                          Container(
                            child: expertLocations.isEmpty ? Text('NA', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')):
                            Wrap(
                              runSpacing: 8.0, // Vertical spacing between lines of items
                              children: [
                                Row(
                                  children: [
                                    for (int i = 0; i < expertLocations.length; i++)
                                      Container(
                                        margin: EdgeInsets.only(right: 8.0),
                                        child: Row(
                                          children: [
                                            Text(expertLocations[i]),
                                            if (i < expertLocations.length - 1)
                                              Text(',', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Text('Visited Places - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                          SizedBox(width: 61,),
                          Text('${visitedplace}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Covered Locations - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                          SizedBox(width: 23,),
                          Text('${coveredLocation}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Expertise Rating - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                          SizedBox(width: 37,),
                          Container(
                            child: ratings == 0
                                ? Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star,color: HexColor('#FB8C00'),),
                                  SizedBox(width: 5),
                                  Text('N/A'),
                                ],
                              ),
                            )
                                : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(ratings, (index) {
                                return Icon(Icons.star, color: HexColor('#FB8C00'));
                              }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40,),
                      Row(
                        children: [
                          Text('Your Culturtap Status',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                          SizedBox(width: 30,),
                          Container(
                            child: profileStatus=='Out Standing'?
                            Text(profileStatus,style: TextStyle(color: HexColor('#0A8100'),fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),):
                            Text('Working',style: TextStyle(color: Colors.red,fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}