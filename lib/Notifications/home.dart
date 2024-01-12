import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:learn_flutter/Notify/NotificationHandler.dart';
// import 'package:learn_flutter/Notify/notification.dart';
import 'package:http/http.dart'as http;

import 'NotificationData.dart';
import 'NotificationHandler.dart';
import 'notification.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD_Q30r4nDBH0HOpvpclE4U4V8ny6QPJj4",
      authDomain: "culturtap-19340.web.app",
      projectId: "culturtap-19340",
      storageBucket: "culturtap-19340.appspot.com",
      messagingSenderId: "268794997426",
      appId: "1:268794997426:android:694506cda12a213f13f7ab ",
    ),
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(Home());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD_Q30r4nDBH0HOpvpclE4U4V8ny6QPJj4",
      authDomain: "culturtap-19340.web.app",
      projectId: "culturtap-19340",
      storageBucket: "culturtap-19340.appspot.com",
      messagingSenderId: "268794997426",
      appId: "1:268794997426:android:694506cda12a213f13f7ab ",
    ),
  );
  print(message.notification!.title.toString());
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  NotificationServices notificationServices  = NotificationServices();
  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    f();
  }

  void f()async{
    String?token = await notificationServices.getDeviceToken();
    print('Token $token');
  }
  var notificationSchema = createNotificationSchema(
    to: 'cTFrw1v1Tfy67O9yRLGQya:APA91bGmtJYw-kUVCaXMME3FzwBDHUfSLVfq9fWU99FmuXq1S8y4kJj3XP6DPoJVncqycSjQ_6a1KCRFA_79-OFyUR2suuc-LRB3naI-QGPS6CiTqd52Tuz-xur955XzrqHLmvSab29k',
    priority: 'high',
    title: 'CulturTap',
    body: 'Call requested by | Aishwary',
    type: 'local_assistant_service',
    meetId: '12345',
    userId: '0',
    state: 'helper',
    innerBody: '<br> <b>8:00 PM - 8:20 PM India</b> <br> <b>Date : 15 Nov 2022 “Monday”</b>'
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Scaffold(
        body: InkWell(
            onTap: ()async{
                sendCustomNotificationToUser2(notificationSchema.toJson());
            },
            child: Center(child: Text('Send Notification'))),
      ),
    );
  }
}

// token : csXW7v91SE6uq_0xC5GSHd:APA91bFa8DrFB8NufB1DwyAMK7TOE3fZFurn5uFgAg6B7zv2bx-ACSlT18T4ZgsAg5RQTbV5TBuMM1NbGA0iJuUQ0DlpGztTYw-nh-2HLk0ysHQTBruDGddTp4jfiMaZtt48f0dF8d89
// token : dykmYyTASBaxWdc6_MWupE:APA91bGsfEORr82tsQAfBOewZePe-dqGedHyq-wN0XrzyAn8H9_3QQTRBttBuP6kjDNfu_4NbD2Dsp91h96k_5ZYvC-WNizMJhvnFCftGinwBmdvA8fHNuu5ldfgnCbreH6f0KleIqdG

// cTFrw1v1Tfy67O9yRLGQya:APA91bGmtJYw-kUVCaXMME3FzwBDHUfSLVfq9fWU99FmuXq1S8y4kJj3XP6DPoJVncqycSjQ_6a1KCRFA_79-OFyUR2suuc-LRB3naI-QGPS6CiTqd52Tuz-xur955XzrqHLmvSab29k
// c7saCPIvTbGQTMX9n23Wt2:APA91bFuAWwKUapZSlsQB3nN7TTzBkyU4GPh1u_Y5k5qFwKvM3d443ggqRjo46c45t-fghXkbcvk1l9Yk87GfwfSpUNw9Bha9Hz1QgctyYkRcCx8HEZ89VpetkfauVPdLoC6fnJtN65m