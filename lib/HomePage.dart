import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/Calendar.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:learn_flutter/widgets/hexColor.dart';
import 'package:provider/provider.dart';

import 'BackendStore/BackendStore.dart';
import 'UserProfile/ProfileHeader.dart';
import 'UserProfile/UserProfileEntry.dart';

class HomePage extends StatelessWidget{
  String ?userName,userId,phoneNumber,latitude,longitude,token;
  HomePage({this.longitude,this.latitude,this.phoneNumber,this.userId,this.userName,this.token});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      home: HomePageWidget(userName:userName,userId:userId,phoneNumber:phoneNumber,latitude:latitude,longitude:longitude,token:token),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePageWidget extends StatelessWidget {
  String ?userName,userId,phoneNumber,latitude,longitude,token;
  HomePageWidget({this.longitude,this.latitude,this.phoneNumber,this.userId,this.userName,this.token});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: ProfileHeader(reqPage: 0,userId: userId,),),
      body: Container(
        width: double.infinity,
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            InkWell(
              onTap: () async {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                    create:(context) => ProfileDataProvider(),
                    child: ProfileApp(userName: userName,userId: userId,),
                  ),),
                );
              },
                child: Text('Create Profile')
            ),
            InkWell(
              onTap: (){

              },
                child: Text('Home Screen')
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                    create:(context) => ProfileDataProvider(),
                    child: CalendarPage(currentUser: userId!,clickedUser: Constant().receiversId,),
                  ),),
                );
              },
                child: Text('Avail Trip Calling Services From Hemant')
            ),
          ],
        ),
      ),
    );
  }
}