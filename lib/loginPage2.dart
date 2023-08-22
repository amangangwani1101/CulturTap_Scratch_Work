// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a blue toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: Center(
//         child: const MyHomePage(title: 'LogIn'),
//       ),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//
//
//   const MyHomePage({super.key, required this.title});
//
//
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//
//   var nameText = TextEditingController();
//   bool validate = false;
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//             backgroundColor: Colors.white,
//             title: Center(child : Text('CULTURTAP',style:TextStyle(color : Colors.orange, fontWeight: FontWeight.bold, fontSize: 30, )),)
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(30),
//             child: Container(
//                 width : double.infinity,
//
//
//                 child: Center(
//                   child: SingleChildScrollView(
//                     child: Column(
//
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment : CrossAxisAlignment.start,
//
//
//                       children: [
//
//                         //image
//
//                         Container(margin: const EdgeInsets.only(bottom: 35), height : 300,color : Colors.white54),
//
//                         Text('SIGNUP',style:TextStyle(fontSize: 35, color : Colors.black, fontWeight: FontWeight.bold)),
//                         Container(
//                             margin: EdgeInsets.only(bottom: 31),
//                             child: Text('Explore, Update, Guide & Earn !', style:TextStyle(fontSize:25, color:Colors.black))),
//
//                         Text('Please Enter Your Name', style:TextStyle(fontSize:20, color:Colors.black, fontWeight: FontWeight.bold)),
//
//
//
//                         Container(
//                           margin: EdgeInsets.only(bottom:19),
//                           width: 300,
//                           child: TextField(
//                             controller: nameText,
//                             decoration: InputDecoration(
//                               hintText: 'Ex : Kishor Kumar',
//
//                             ),
//                           ),
//                         ),
//
//                         Container(
//                             margin:EdgeInsets.only(bottom:21),
//                             child : Row(
//                               children: [
//                                 Text('Already User ?',style:TextStyle(fontSize: 20,fontWeight: FontWeight.w100)),
//                                 TextButton(onPressed: (){}
//                                     , child: Text('Sign In',style: TextStyle(color : Colors.orange, fontWeight: FontWeight.w900, fontSize: 25,),))
//                               ],
//                             )
//                         ),
//
//                         Container(
//                             width: 330,
//                             height : 80,
//                             child: FilledButton(
//                                 style: FilledButton.styleFrom(
//                                   backgroundColor: Colors.orange, //<-- SEE HERE
//                                 ),
//                                 onPressed: () {
//                                   String Name = nameText.text.toString();
//                                   print('Name  : ${Name} ');
//                                 },
//                                 child: Center(child : Text('Next',style:TextStyle(fontWeight: FontWeight.bold,color : Colors.white,fontSize: 25,))))),
//                       ],
//                     ),
//                   ),
//                 )),
//           ),
//         ));
//   }
// }
