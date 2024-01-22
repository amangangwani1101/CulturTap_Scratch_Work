import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/splashScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Received FCM notification: ${message.notification?.body}");
  });



  // Initialise the plugin.
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('culturtap_logo');
  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final LinuxInitializationSettings initializationSettingsLinux =
  LinuxInitializationSettings(
      defaultActionName: 'Open notification');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SecondScreen extends StatelessWidget {
  final String? payload;

  SecondScreen(this.payload);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: Text('Payload: $payload'),
      ),
    );
  }
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // Display a dialog with the notification details, tap ok to go to another page
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title!),
      content: Text(body!),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Ok'),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SecondScreen(payload),
              ),
            );
          },
        )
      ],
    ),
  );
}

Future<void> onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {

  // Handle notification response here if needed
  print('Notification response: ${notificationResponse.payload}');
}



@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();
  print('Background message came:${message.notification!.title.toString()}');
}


Future<void> onSelectNotification(String? payload) async {
  // Handle notification click here (optional)
}

String darkMode = 'ys';


class MyApp extends StatelessWidget {


  const MyApp({super.key});

  // This widget is the root of your application.
  @override



  Widget build(BuildContext context) {



    return MaterialApp(

      title: 'CulturTap',
      debugShowCheckedModeBanner: false,

      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      theme: darkMode == 'yes' ?


      ThemeData(





        fontFamily: 'Poppins',



        primaryColor: Colors.white,
        primaryColorLight : Color(0xFF1E2529),
        primaryColorDark : Color(0xFF151B1E),

        // backgroundColor:Color(0xFF1E2529) ,
        // backgroundColor:Color(0xFF1E2522) ,
        // backgroundColor:Color(0xFF101619) ,
        // backgroundColor:Color(0xFF151B1E) ,
        backgroundColor:Color(0xFF151B1E) ,
        scaffoldBackgroundColor: Color(0xFF151B1E),// Change the background color


        // Custom Text Styles
        textTheme: TextTheme(

          bodyText1: TextStyle(fontSize: (10),color : Colors.white, fontWeight: FontWeight.w600),
          bodyText2: TextStyle(fontSize: (12),color : Colors.white, fontWeight: FontWeight.w600),
          button: TextStyle(fontSize: (10 ),color : Colors.white ,fontWeight: FontWeight.bold),

          subtitle1: TextStyle(fontSize: (14),color : Colors.white, fontWeight: FontWeight.bold),
          subtitle2: TextStyle(fontSize: (14),color : Colors.white),


          headline4: TextStyle(fontSize: (14),color :Colors.white , ),
          headline6: TextStyle(fontSize: (14),color :Color(0xFF263238), fontWeight: FontWeight.w600),

          headline1: TextStyle(fontSize: (25),color : Colors.white, fontWeight: FontWeight.bold), // Adjust the font size and weight as needed
          headline2: TextStyle(fontSize: (18),color :Colors.white , fontWeight: FontWeight.bold),
          headline5: TextStyle(fontSize: (16),color :Colors.white , fontWeight: FontWeight.bold),


          headline3: TextStyle(fontSize: (12),color : Colors.white, fontWeight: FontWeight.bold),

          caption: TextStyle(fontSize: (18 ),color :Colors.white , fontWeight: FontWeight.bold),


        ),

        // Optional: Define colors for specific components
        appBarTheme: AppBarTheme(
          backgroundColor : Color(0xFF151B1E), // Change the AppBar background color
          foregroundColor: Color(0xFF1E2529),

          // Change the AppBar text color
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange, // Change the FloatingActionButton color
        ),
      ) :

      ThemeData(




        fontFamily: 'Poppins',


        primaryColor: Color(0xFF001B33), // Change the primary color
        primaryColorLight : Color(0xFFF2F2F2),
        primaryColorDark : Color(0xFF1E2529),
        // accentColor: Colors.orange, // Change the accent color
        backgroundColor: Colors.white,



        textTheme: TextTheme(

          bodyText1: TextStyle(fontSize: (10 ),color : Color(0xFF001B33), fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: (12 ),color : Color(0xFF001B33) ,),
          button: TextStyle(fontSize: (10 ),color : Colors.white ,fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontSize: (14  ),color : Color(0xFF001B33), fontWeight: FontWeight.bold),
          subtitle2: TextStyle(fontSize: (14  ),color : Color(0xFF001B33), fontWeight : FontWeight.w600),

          headline4: TextStyle(fontSize: (14 ),color :Colors.white , ),
          headline1: TextStyle(fontSize: (25  ),color : Color(0xFF001B33), fontWeight: FontWeight.bold), // Adjust the font size and weight as needed
          headline2: TextStyle(fontSize: (18  ),color :Color(0xFF001B33) ,fontWeight : FontWeight.bold ),
          headline5: TextStyle(fontSize: (16 ),color :Colors.white , fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: (14 ),color : Color(0xFF001B33),),
          headline3: TextStyle(fontSize: (12 ),color : Colors.white, fontWeight: FontWeight.bold),

          caption: TextStyle(fontSize: (18 ),color :Colors.white , fontWeight: FontWeight.bold),


        ),

        // Optional: Define colors for specific components
        appBarTheme: AppBarTheme(
          color : Colors.white,
          elevation : 0,

          foregroundColor: Colors.black,

          // Change the AppBar text color
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange, // Change the FloatingActionButton color
        ),
      ),

      home: splashScreen(),
    );
  }


}
