import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learn_flutter/Notify/Chat.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      if(kDebugMode){
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
        print(message.data['type']);
      }
      if(Platform.isAndroid){
        initLocalNotification(context, message);
      }else{

      }
      showNotification(message);
    });
  }

  void initLocalNotification(BuildContext context,RemoteMessage message)async{
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse:(payload){
        handleMessage(context, message);
      }
    );
  }

  Future<void> showNotification(RemoteMessage message)async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'Notification',
        importance: Importance.max
    );


    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: 'Your Description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker'
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

    if(initialMessage!=null){
      handleMessage(context, initialMessage);
    }

    // when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context,RemoteMessage message){
    print('hereeee');
      if(message.data['type']=='msj'){
        print('kabgi');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(),
          ),
        );
      }
  }
}