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
    var androidInitializationSettings = const AndroidInitializationSettings('@drawable/trip_calling_logo');
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


    // AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    //     channel.id.toString(),
    //     channel.name.toString(),
    //     channelDescription: 'Your Description',
    //     importance: Importance.high,
    //     priority: Priority.high,
    //     ticker: 'ticker'
    // );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'Trip Planning Services',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      subText: 'Trip Calling Service',
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
      color: const Color.fromRGBO(255, 165, 0, 1.0), // Orange color
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