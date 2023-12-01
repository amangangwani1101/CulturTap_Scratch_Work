import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/Notify/NotificationHandler.dart';
import 'package:learn_flutter/Notify/notification.dart';
import 'package:http/http.dart'as http;
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
    // notificationServices.isTokenRefresh();
    f();
  }

  void f()async{
    String?token = await notificationServices.getDeviceToken();
    print('Token $token');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Scaffold(
        body: InkWell(
            onTap: ()async{
                sendCustomNotificationToUser(
                    'dw2WEUNtRJ-8zy3DO_dKd9:APA91bEZXSkhq03cBaKwTCSEd_mKVVDKkK7NqPqKNK2z87rfKHAcAVKkY0-47LmEp7NOv_5tt0nyfnybxXHraS05ekuZv8muK79e2Ky4_Q80fB3ZpXimXNDyZO5Dvf36yFMf4Rv01BkR',
                    'CulturTap',
                    'Call requested by | Aishwary',
                    '<br> <b>8:00 PM - 8:20 PM India</b> <br> <b>Date : 15 Nov 2022 “Monday”</b>');
            },
            child: Center(child: Text('Send Notification'))),
      ),
    );
  }
}