import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                var data = {
                  'to':'eAfNtczsSN2z7HgG_91tkW:APA91bGGERhv8g3wiyh4y5bGGOZ5dl_LZYcLYKk--6kicyjc__lyPDWkkU3ISUlix73ZScVVlXLsvfAYif_esfLjGRy5AYvVK_Nu-1QkvqJND26MZtZWqA8v-0u-6tikib1JbM-xLC7X',
                  'priority':'high',
                  'notification':{
                    'title':'CulturTap',
                    'body':'Call requested by | Aishwary',
                  },
                  'data':{
                    'type':'msj',
                    'innerBody':'<br> <b>8:00 PM - 8:20 PM India</b> <br> <b>Date : 15 Nov 2022 “Monday”</b> '
                  }
                };
                await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  body: jsonEncode(data),
                  headers: {
                      'Content-Type' :'application/json; charset=UTF-8',
                      'Authorization':'key=AAAAPpVuKrI:APA91bF7BA61C5dlBD65HIs4KY1Ljw5rHZ1FyNxuqjEpQUjfnQJMkhxf71XKlk2dK3fkjRVYG7gErT4lZj2lluhZVsdaHPeyjWKGQ6AcUZlNeXLTiuKxnnVgO21EowO0ATcxKSBd2EK7',
                  }
                );
            },
            child: Center(child: Text('Send Notification'))),
      ),
    );
  }
}