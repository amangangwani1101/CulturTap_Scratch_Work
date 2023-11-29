import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

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
}