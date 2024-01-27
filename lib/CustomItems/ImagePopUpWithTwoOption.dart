import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/Notifications/CustomNotificationMessages.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:http/http.dart' as http;

import '../All_Notifications/customizeNotification.dart';
import '../fetchDataFromMongodb.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



class ImagePopUpWithTwoOption extends StatelessWidget {
  final String imagePath;
  final String textField;
  final String what;
  VoidCallback? option1CallBack,option2Callback;
  final String? extraText;
  final String? meetId;
  final String? helperId;
  final String? meetStatus;



  ImagePopUpWithTwoOption({
    required this.imagePath,
    required this.textField,
    required this.what,
    this.extraText,
    this.meetId,
    this.option1CallBack,
    this.option2Callback,
    this.helperId,
    this.meetStatus,

  });

  Future<void> updateLocalUserPings(String userId,String meetId,String meetStatus) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/updateLocalUserPings');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId": userId,
      'meetId':meetId,
      'meetStatus':meetStatus,
    };
    print('Messa::$requestData');
    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final responseData = jsonDecode(response.body);
        print("Response: $responseData");
      } else {
        print("Failed to update pings. Status code: ${response.statusCode}");
        throw Exception("Failed to update pings");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }



  Future<void> updateMeetingChats(String meetId,List<String>meetDetails)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'meetId':meetId,
        'conversation':meetDetails,
      };
      print('Meeting Chats Request Sent : $data');
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/storeLocalMeetingConversation'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );


      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        print('Failed to update meeting chats : ${response.statusCode}');
      }
    }catch(err){
      print("failed to update meeting chats : $err");
    }
  }


  Future<void> updatePaymentStatus(String paymentStatus,String meetId) async {
    try {
      final http.Response response = await http.patch(
        Uri.parse('${Constant().serverUrl}/updateLocalMeetingHelperIds/$meetId'),
        headers: {
          "Content-Type": "application/json",
        },
        body:jsonEncode({"paymentStatus":paymentStatus,"time":DateTime.now().toIso8601String()}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Meeting Conversation Restored');
        print(responseData);
      } else {
        print('Failed to save meeting data : ${response.statusCode}');
      }
    }catch(err){
      print("Error in updating meeting status: $err");
    }
  }




  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 32),
        color: Theme.of(context).backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(

              color: Colors.white, // Set the background color to white
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Container(width: 150,child: Image.asset(imagePath)),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                      child: Text(
                        textField,
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (extraText != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            // Check if extraText is not null
                            Container(
                              child: Text(
                                extraText!,
                                style: Theme.of(context).textTheme.subtitle2,
                                textAlign: TextAlign.center,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[100],
                      fontSize: 20,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {

                    // User confirmed, do something
                    // print('User confirmed');
                    // await updateLocalUserPings(userID, meetId!, 'close');
                    // await updateLocalUserPings(helperId!, meetId!, 'close');
                    // await updatePaymentStatus('close',meetId!);
                    //
                    //
                    // // Remove video logic here
                    // Navigator.of(context).pop();
                    option2Callback!();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    meetStatus == 'schedule' ? ' Close ' : 'Cancel',
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
    );

  }

}

void gotocameraapp(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CameraApp()),
  );
}