import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learn_flutter/Notify/Chat.dart';
import 'package:learn_flutter/rating.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Map<String, List<String>> chatMessages = {};
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
      // showNotification(message);
      showProgressBarNotification(100);
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

    AndroidNotificationAction action1 = AndroidNotificationAction(
      'action_1', 'Action 1',
    );

    AndroidNotificationAction action2 = AndroidNotificationAction(
      'action_2', 'Action 2',
    );

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
      actions: [
        AndroidNotificationAction(
          'action_button_1',
          'Cancel',
          titleColor: Colors.orange,
          // inputs:[AndroidNotificationActionInput(
          //   label: 'action_button_1',
          // )],
        ),
        AndroidNotificationAction(
          'action_button_2',
          'Accept',
          titleColor:Colors.orange,
          icon: DrawableResourceAndroidBitmap(
            '@drawable/culturtap_logo', // Replace with your icon
          ),
          // contextual: true,
          // allowGeneratedReplies: true,
          // showsUserInterface: true,
          inputs: [
            AndroidNotificationActionInput(
              // label: 'true',
              // choices: ['fck','mck'],
              // allowedMimeTypes: {
              //   'col','man'
              // },
              // allowFreeFormInput: false
            )
          ],
          // inputs:[AndroidNotificationActionInput(
          //   label: 'action_button_1',
          // )],
        ),
      ],
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

  Future<void> showProgressBarNotification(int progressPercentage) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'Notification',
        importance: Importance.max
    );
    if (progressPercentage == 100) {
      // Upload completed, show notification without progress bar
      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: 'Your channel description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        color: const Color.fromARGB(255, 255, 165, 0), // Orange color
        // Other details...
        showProgress: false, // Hide progress bar
      );
    } else {
      // Upload in progress, show notification with progress bar
      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: 'Your channel description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        showProgress: true, // Show progress bar
        maxProgress: 100, // The maximum progress value
        progress: progressPercentage, // Current progress value (0-100)
        color: const Color.fromARGB(255, 255, 165, 0), // Orange color
        enableLights: true,
        ledColor: const Color.fromARGB(255, 255, 165, 0), // Orange color
      );
    }

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      color: const Color.fromARGB(255, 255, 165, 0), // Orange color
      showProgress: true,
      maxProgress: 100, // The maximum progress value
      progress: progressPercentage, // Current progress value (0-100)
      enableLights: true,
      // Other details...
    );

    const DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    if (progressPercentage >= 100) {
      await _flutterLocalNotificationsPlugin.show(
        0,
        'Upload Complete',
        'Uploaded successfully!',
        notificationDetails,
      );
    } else {
      await _flutterLocalNotificationsPlugin.show(
        0,
        'Uploading Progress',
        'Uploading to server...',
        notificationDetails,
      );
    }
  }

  Future<void> showChatMessageNotification(RemoteMessage message) async {
    String chatId = message.data['chatId'];
    String title = 'New Message';
    String body = 'You have new messages';

    if (!chatMessages.containsKey(chatId)) {
      chatMessages[chatId] = [];
    }
    chatMessages[chatId]!.add(message.data['message']);

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'Chat Notification',
      'Notification for new chat messages',
      groupKey: chatId,
      importance: Importance.high,
      priority: Priority.high,
    );

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
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
      print(payload);
      if(payload=='action_1'){
        print('Pressed Accept');
      }
      else if(payload=='action_2'){
        print('Pressed Camncel');
      }else{
        handleMessage(context, payload);
      }
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
    else if (message.data['type'] == 'chat') {
      String chatId = message.data['chatId'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            navigationData: message.data['navigationData'],
          ),
        ),
      );
    }
  }
}