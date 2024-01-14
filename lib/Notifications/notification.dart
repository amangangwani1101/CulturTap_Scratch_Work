import 'dart:io';
import 'dart:math';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learn_flutter/LocalAssistance/ChatsPage.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'Chat.dart';
// import 'package:learn_flutter/Notify/Chat.dart';
// import 'package:learn_flutter/rating.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Map<String, List<String>> chatMessages = {};
  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      if(kDebugMode){
        print('Notification Received :)');
      }
      if(Platform.isAndroid){
        initLocalNotification(context, message);
      }else{}
      // showNotification(message);

      if(message.data['type']=='local_assistant_request_pending')
        _scheduleNotification();
      else if(message.data['type']=='local_assistant_request_updated')
        _removeNotification();
      else if(message.data['type']=='local_assistant_service')
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
        print('Payload Received :| ');
        print(payload);
        handleMessage(context, message);
      }
    );
  }


  Future<void> _scheduleNotification() async {
    const int minutesDelay = 10;
    // Initialize the timezone
    tz.initializeTimeZones();

    // Get the local timezone
    final String timeZoneName = tz.local.name;

    // Convert the scheduled time to TZDateTime
    final tz.TZDateTime scheduledDate =
    tz.TZDateTime.now(tz.getLocation(timeZoneName))
        .add(Duration(minutes: minutesDelay));

    await _flutterLocalNotificationsPlugin.show(
      Random.secure().nextInt(100000),
      'Local Assistant Scheuled',
      'Waiting for helping hands...',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'Local Assistant Ongoing Notificaion',
          'Local Assistant',
          channelDescription: 'Ongoing Meet',
          ongoing: true,
        ),
      ),

    );
  }

    Future<void> _removeNotification() async {
      await _flutterLocalNotificationsPlugin.cancel(0);
    }

  Future<void> showNotification(RemoteMessage message)async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'Trip Calling',
        description: 'i am description',
        groupId: message.data['meetId']??null,
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
      channelDescription: 'Trip Planning Services',
      // sound: RawResourceAndroidNotificationSound('assets/sounds/camera_sound.mp3'),
      // icon: 'Iconing',
      vibrationPattern: Int64List.fromList([0, 500, 1000, 500]),
      groupKey: 'Grouping',
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
      color: Color.fromARGB(255, 255, 255, 255),
      timeoutAfter: 300000, // Timeout after 5 minutes (300,000 milliseconds)
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

  // Future<void> showProgressBarNotification(int progressPercentage) async {
  //   AndroidNotificationChannel channel = AndroidNotificationChannel(
  //       Random.secure().nextInt(100000).toString(),
  //       'Notification',
  //       importance: Importance.max
  //   );
  //   if (progressPercentage == 100) {
  //     // Upload completed, show notification without progress bar
  //     AndroidNotificationDetails androidNotificationDetails =
  //     AndroidNotificationDetails(
  //       channel.id.toString(),
  //       channel.name.toString(),
  //       channelDescription: 'Your channel description',
  //       importance: Importance.high,
  //       priority: Priority.high,
  //       ticker: 'ticker',
  //       color: const Color.fromARGB(255, 255, 165, 0), // Orange color
  //       // Other details...
  //       showProgress: false, // Hide progress bar
  //     );
  //   } else {
  //     // Upload in progress, show notification with progress bar
  //     AndroidNotificationDetails androidNotificationDetails =
  //     AndroidNotificationDetails(
  //       channel.id.toString(),
  //       channel.name.toString(),
  //       channelDescription: 'Your channel description',
  //       importance: Importance.high,
  //       priority: Priority.high,
  //       ticker: 'ticker',
  //       showProgress: true, // Show progress bar
  //       maxProgress: 100, // The maximum progress value
  //       progress: progressPercentage, // Current progress value (0-100)
  //       color: const Color.fromARGB(255, 255, 165, 0), // Orange color
  //       enableLights: true,
  //       ledColor: const Color.fromARGB(255, 255, 165, 0), // Orange color
  //     );
  //   }
  //
  //   AndroidNotificationDetails androidNotificationDetails =
  //   AndroidNotificationDetails(
  //     channel.id.toString(),
  //     channel.name.toString(),
  //     channelDescription: 'Your channel description',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //     color: const Color.fromARGB(255, 255, 165, 0), // Orange color
  //     showProgress: true,
  //     maxProgress: 100, // The maximum progress value
  //     progress: progressPercentage, // Current progress value (0-100)
  //     enableLights: true,
  //     // Other details...
  //   );
  //
  //   const DarwinNotificationDetails darwinNotificationDetails =
  //   DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );
  //
  //   NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidNotificationDetails,
  //     iOS: darwinNotificationDetails,
  //   );
  //
  //   if (progressPercentage >= 100) {
  //     await _flutterLocalNotificationsPlugin.show(
  //       0,
  //       'Upload Complete',
  //       'Uploaded successfully!',
  //       notificationDetails,
  //     );
  //   } else {
  //     await _flutterLocalNotificationsPlugin.show(
  //       0,
  //       'Uploading Progress',
  //       'Uploading to server...',
  //       notificationDetails,
  //     );
  //   }
  // }
  //
  // Future<void> showChatMessageNotification(RemoteMessage message) async {
  //   String chatId = message.data['chatId'];
  //   String title = 'New Message';
  //   String body = 'You have new messages';
  //
  //   if (!chatMessages.containsKey(chatId)) {
  //     chatMessages[chatId] = [];
  //   }
  //   chatMessages[chatId]!.add(message.data['message']);
  //
  //   AndroidNotificationDetails androidNotificationDetails =
  //   AndroidNotificationDetails(
  //     'Chat Notification',
  //     'Notification for new chat messages',
  //     groupKey: chatId,
  //     importance: Importance.high,
  //     priority: Priority.high,
  //   );
  //
  //   NotificationDetails notificationDetails =
  //   NotificationDetails(android: androidNotificationDetails);
  //
  //   await _flutterLocalNotificationsPlugin.show(
  //     0,
  //     title,
  //     body,
  //     notificationDetails,
  //   );
  // }


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
      if(message.data['type']=='chat'){
        print('Local Assistant');
        // print(message.data.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatsPage(userId: message.data['userId'],state: message.data['state'],meetId:  message.data['meetId'],),
          ),
        );
      }
    else if (message.data['type'] == 'local_assistant_service') {
      // String chatId = message.data['chatId'];
        print('inside boy');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            navigationData: message.data['userId'],
          ),
        ),
      );
    }
  }
}