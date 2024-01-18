import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/hexColor.dart';
import 'dart:ui' as ui;


// Expert Cards -> User Experiences Section Have To Work
class ExpertCardDetails extends StatelessWidget{
  List<String> expertLocations = [];
  String profileStatus = "Out Standing";
  int visitedplace = 0,coveredLocation = 0;
  double ratings = 0;
  GlobalKey containerKey = GlobalKey();


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
    final screenWidth = MediaQuery.of(context).size.width;
    return RepaintBoundary(
      key: containerKey,
      child: Container(
        width: screenWidth*0.90,
        padding: EdgeInsets.only(top : 25, left : 15, right : 15, bottom : 25),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          border: Border.all(color: Colors.white30),
          borderRadius: BorderRadius.circular(20),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black,
          //     // offset: Offset(0.0,0.0),
          //     blurRadius: 5.0,
          //     spreadRadius: 7.9,
          //   ),
          //   BoxShadow(
          //     color: Colors.white,
          //     // offset: Offset(0.0,0.0),
          //     blurRadius:5,
          //     spreadRadius: 12.9,
          //   ),
          // ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Expert Cards' ,style: Theme.of(context).textTheme.subtitle1,),
                InkWell(
                    onTap: (){
                      shareContainerImage();
                    },
                    child: Icon(Icons.share_outlined, color : Theme.of(context).primaryColor,)),
              ],
            ),
            SizedBox(height : 20),
            Container(
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Expert in locations',style: Theme.of(context).textTheme.subtitle1,),
                  Container(
                    child: expertLocations.isEmpty ? Text('iufbiqbgl lvhi3goh evhb3yobvhefhbl3rvhj ergyu4bvejligrbv eruig efj4vui efiubewvjkebgiuefjk vewuibgekj', style: Theme.of(context).textTheme.subtitle2,):
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
                                      Text(',', style: Theme.of(context).textTheme.subtitle2,),
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
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visited Places ', style: Theme.of(context).textTheme.subtitle1,),
                    Text('Covered Locations ', style: Theme.of(context).textTheme.subtitle1,),
                    Text('Expertise Rating ', style: Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
                SizedBox(width: 40,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${visitedplace}', style: Theme.of(context).textTheme.subtitle2,),
                    Text('${coveredLocation}', style: Theme.of(context).textTheme.subtitle2,),
                    Container(
                        child: ratings == 0
                            ? Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('N/A'),
                            ],
                          ),
                        )
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(ratings.toInt(), (index) {
                            return Icon(Icons.star, color: HexColor('#FB8C00'));
                          })
                            ..add(
                              (ratings % 1 != 0) // Check if there is a decimal part
                                  ? Icon(Icons.star_half, color: HexColor('#FB8C00'))
                                  : SizedBox(), // If no decimal part, add an empty SizedBox
                            ),
                        )
                    ),
                  ],
                ),

              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Text('Your Culturtap Status',style: Theme.of(context).textTheme.subtitle1,),
                SizedBox(width: 20,),
                Container(
                  child: visitedplace==0 || coveredLocation==0?
                  Text('N/A',style: TextStyle(color: HexColor('#0A8100'),fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),):
                  Text(profileStatus,style: TextStyle(color: HexColor('#0A8100'),fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
