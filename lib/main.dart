import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_flutter/splashScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
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
      theme: darkMode == 'yes' ?

      ThemeData(

        fontFamily: 'Poppins',


        primaryColor: Colors.white, // Change the primary color
        primaryColorLight : Color(0xFF1E2529),
        // accentColor: Colors.orange, // Change the accent color
        backgroundColor:Color(0xFF1E2529) ,
        scaffoldBackgroundColor: Colors.black,// Change the background color
        // Change the scaffold background color
        // Add more color properties as needed

        // Custom Text Styles
        textTheme: TextTheme(

          bodyText1: TextStyle(fontSize: (10),color : Colors.white, fontWeight: FontWeight.w600),
          bodyText2: TextStyle(fontSize: (12),color : Colors.white, fontWeight: FontWeight.w600),
          button: TextStyle(fontSize: (10 * MediaQuery.of(context).textScaleFactor),color : Colors.white ,fontWeight: FontWeight.bold),

          subtitle1: TextStyle(fontSize: (14),color : Colors.white, fontWeight: FontWeight.bold),
          subtitle2: TextStyle(fontSize: (14),color : Colors.white),


          headline4: TextStyle(fontSize: (14),color :Colors.orange , fontWeight: FontWeight.w600),
          headline6: TextStyle(fontSize: (14),color :Color(0xFF263238), fontWeight: FontWeight.bold),

          headline1: TextStyle(fontSize: (25),color : Colors.white, fontWeight: FontWeight.bold), // Adjust the font size and weight as needed
          headline2: TextStyle(fontSize: (18),color :Colors.white , fontWeight: FontWeight.bold),
          headline5: TextStyle(fontSize: (16),color :Colors.white , fontWeight: FontWeight.bold),


          headline3: TextStyle(fontSize: (12),color : Colors.white, fontWeight: FontWeight.bold),

          caption: TextStyle(fontSize: (18 * MediaQuery.of(context).textScaleFactor),color :Colors.white , fontWeight: FontWeight.bold),


        ),

        // Optional: Define colors for specific components
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E2529) , // Change the AppBar background color
          foregroundColor: Colors.white,
          // Change the AppBar text color
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange, // Change the FloatingActionButton color
        ),
      ) :

      ThemeData(

        fontFamily: 'Poppins',


        primaryColor: Color(0xFF001B33), // Change the primary color
        primaryColorLight : Color(0xFF1E2529),
        // accentColor: Colors.orange, // Change the accent color
        backgroundColor: Colors.white, // Change the background color

        // Change the scaffold background color
        // Add more color properties as needed

        // Custom Text Styles
        textTheme: TextTheme(

          bodyText1: TextStyle(fontSize: (10 * MediaQuery.of(context).textScaleFactor),color : Color(0xFF001B33), fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: (12 * MediaQuery.of(context).textScaleFactor),color : Color(0xFF001B33) ,),
          button: TextStyle(fontSize: (10 * MediaQuery.of(context).textScaleFactor),color : Colors.white ,fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontSize: (14  * MediaQuery.of(context).textScaleFactor),color : Color(0xFF001B33), fontWeight: FontWeight.bold),
          subtitle2: TextStyle(fontSize: (14  * MediaQuery.of(context).textScaleFactor),color : Color(0xFF001B33), fontWeight : FontWeight.w600),

          headline4: TextStyle(fontSize: (14 * MediaQuery.of(context).textScaleFactor),color :Colors.orange , fontWeight: FontWeight.bold),
          headline1: TextStyle(fontSize: (25  * MediaQuery.of(context).textScaleFactor),color : Color(0xFF001B33), fontWeight: FontWeight.bold), // Adjust the font size and weight as needed
          headline2: TextStyle(fontSize: (18  * MediaQuery.of(context).textScaleFactor),color :Color(0xFF001B33) , fontWeight: FontWeight.bold),
          headline5: TextStyle(fontSize: (16 * MediaQuery.of(context).textScaleFactor),color :Colors.white , fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: (14 * MediaQuery.of(context).textScaleFactor),color : Color(0xFF001B33),),
          headline3: TextStyle(fontSize: (12 * MediaQuery.of(context).textScaleFactor),color : Colors.white, fontWeight: FontWeight.bold),

          caption: TextStyle(fontSize: (18 * MediaQuery.of(context).textScaleFactor),color :Colors.white , fontWeight: FontWeight.bold),


        ),

        // Optional: Define colors for specific components
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // Change the AppBar background color
          foregroundColor: Colors.black, // Change the AppBar text color
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange, // Change the FloatingActionButton color
        ),
      ),

      home: splashScreen(),
    );
  }


}

//
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override


  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
