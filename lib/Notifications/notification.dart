import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learn_flutter/LocalAssistance/ChatsPage.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:learn_flutter/VIdeoSection/Draft/SavedDraftsPage.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/widgets/Constant.dart';

import '../ServiceSections/PingsSection/Pings.dart';
import '../UserProfile/FinalUserProfile.dart';
import 'Chat.dart';
// import 'package:learn_flutter/Notify/Chat.dart';
// import 'package:learn_flutter/rating.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Map<String, List<String>> chatMessages = {};
  String meetId = '';
  String state = '';
  String eligible = '';




  // check is meeting ongoing
  Future<void> checkIsMeetOngoing()async {
    await PingsAssistanceChecker(userID);
  }

  Future<void> checkIsEligible() async{
    await PingsAssistanceEligible(userID);
  }

  Future<void> PingsAssistanceChecker(userId) async {
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final url = Uri.parse('$serverUrl/checkLocalUserPings/${userId}'); // Replace with your backend URL
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        if(data['meetId']!=null){
          meetId = data['meetId'];
        }
        if(data['state']!=null){
          state = data['state'];
        }
        if(data['eligible']!=null){
          eligible = data['eligible'];
        }

        print('Meeting Ongoing : $meetId');

      } else {
        // Handle error
        print('Failed to fetch dataset: ${response.statusCode}');
      }
    }
    catch(err){
      print('Error $err');
    }
  }

  Future<void> PingsAssistanceEligible(userId) async {
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final url = Uri.parse('$serverUrl/checkLocalUserEligible/${userId}'); // Replace with your backend URL
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

      } else {
        // Handle error
        print('Failed to fetch dataset: ${response.statusCode}');
      }
    }
    catch(err){
      print('Error $err');
    }
  }

  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      if(kDebugMode){
        // print(message.notification!.title.toString());
        // print(message.notification!.body.toString());
        print('Messafe is ');
        print(message.data.toString());
        // print(message.data['type']);
      }
      if(Platform.isAndroid){
        initLocalNotification(context, message);
      }else{}
      showNotification(message);
      // showProgressBarNotification(100);
      // showChatMessageNotification(message);
    });
  }

  void initLocalNotification(BuildContext context,RemoteMessage message)async{
    var androidInitializationSettings = const AndroidInitializationSettings('@drawable/trip_calling_logo');
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(
        initializationSetting,
        onDidReceiveNotificationResponse:(payload){
          print(payload);
          if(payload=='action_1'){
            print('Pressed Accept');
          }
          else if(payload=='action_2'){
            print('Pressed Cancel');
          }else{
            handleMessage(context, message);
          }
        }
    );
  }

  Future<void> showNotification(RemoteMessage message)async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'Trip Calling',
        importance: Importance.max
    );

    // AndroidNotificationAction action1 = AndroidNotificationAction(
    //   'action_1', 'Action 1',
    // );
    //
    // AndroidNotificationAction action2 = AndroidNotificationAction(
    //   'action_2', 'Action 2',
    // );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: message.data['type'],
      // sound: RawResourceAndroidNotificationSound('assets/sounds/camera_sound.mp3'),
      // icon: 'Iconing',
      vibrationPattern: Int64List.fromList([0, 500, 1000, 500]),
      groupKey: 'Grouping',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: message.data['type'] == 'trip_assistance_required' ? true : false,
      ticker: 'ticker',
      subText: 'Local Assistance Services',
      ledColor: const Color.fromARGB(255, 255, 0, 0), // Replace with your LED color
      ledOnMs: 1000, // LED on duration in milliseconds
      ledOffMs: 500, // LED off duration in milliseconds
      largeIcon: DrawableResourceAndroidBitmap(
        '@drawable/culturtap_logo', // Replace with your icon
      ),
      styleInformation: BigTextStyleInformation(
        '${message.data['innerBody']}',
        htmlFormatBigText: true,
        contentTitle: '${message.notification!.body.toString()}',
        htmlFormatContentTitle: true,
        summaryText: 'Summary text',
        htmlFormatSummaryText: true,
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
      color: Color.fromARGB(255, 255, 255, 255),
      timeoutAfter: null,
      // actions: [
      //   AndroidNotificationAction(
      //     'action_button_1',
      //     'Cancel',
      //     titleColor: Colors.orange,
      //     // inputs:[AndroidNotificationActionInput(
      //     //   label: 'action_button_1',
      //     // )],
      //   ),
      //   AndroidNotificationAction(
      //     'action_button_2',
      //     'Accept',
      //     titleColor:Colors.orange,
      //     icon: DrawableResourceAndroidBitmap(
      //       '@drawable/culturtap_logo', // Replace with your icon
      //     ),
      //     // contextual: true,
      //     // allowGeneratedReplies: true,
      //     // showsUserInterface: true,
      //     inputs: [
      //       AndroidNotificationActionInput(
      //         // label: 'true',
      //         // choices: ['fck','mck'],
      //         // allowedMimeTypes: {
      //         //   'col','man'
      //         // },
      //         // allowFreeFormInput: false
      //       )
      //     ],
      //     // inputs:[AndroidNotificationActionInput(
      //     //   label: 'action_button_1',
      //     // )],
      //   ),
      // ],
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(Duration.zero,(){
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails
      );
    });
  }



  void requestNotificationPermission()async{
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        criticalAlert: true,
        provisional: true,
        sound: true
    );

    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print('user granted permisson');
    }else if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print('user granted provisonal permisson');
    }else{
      print('user denied permisson');
    }
  }

  Future<String> getDeviceToken() async{
    String? token = await messaging.getToken();
    print('Token ::: $token');
    return token!;
  }

  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('Refresh token');
    });
  }


  Future<void> setupInteractMessage(BuildContext context)async{
    // when app is terminated
    RemoteMessage ? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    print(initialMessage);
    if(initialMessage!=null){
      handleMessage(context, initialMessage);
    }

    // when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((payload) {
      print('Payload us $payload');
      handleMessage(context, payload);
    });
  }





  void handleMessage(BuildContext context,RemoteMessage message){
    // if(message.)
    if(message.data['type']=='local_assistant_cancel'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => PingsSection(userId: userID,selectedService:message.data['service'],)));
    }
    // else if(message.data['type'].contains('local_assistant')){
    //   print('yes its me');
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ChatsPage(userId : message.data['userId'],state: message.data['state'],meetId:message.data['meetId'],),
    //     ),
    //   );
    // }
    else if(message.data['type']=='local_assistant_service'){
      print('yha print kr rha hu');
      print(message.data);
      print('yha ki meet id');
      print(message.data['meetId']);
      print('yha ki state yeh h');
      print(message.data['state']);


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PingsSection(userId: userID,selectedService: 'Local Assistant',),
        ),
      );

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => CameraApp(),
      //   ),
      // );


    }
    else if (message.data['type'] == 'chat') {
      String chatId = message.data['chatId'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatsPage(
            userId: userID,
            // navigationData: message.data['navigationData'],
          ),
        ),
      );
    }
    else if (message.data['type'] == 'trip_assistance_required') {
      String meetId = message.data['meetId'];
      String status = message.data['state'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatsPage(
            state: status,
            userId: userID,
            meetId: meetId,
            // navigationData: message.data['navigationData'],
          ),
        ),
      );
    }
    else if (message.data['type'] == 'chat') {
      String chatId = message.data['chatId'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatsPage(
            userId: userID,
            // navigationData: message.data['navigationData'],
          ),
        ),
      );
    }
    else if (message.data['type'] == 'draft') {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavedDraftsPage(

            // navigationData: message.data['navigationData'],
          ),
        ),
      );
    }
    else  if(message.data['type']=='Publishing Story') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalProfile(userId: userID, clickedId: userID,),
        ),
      );

    }
  }
}
