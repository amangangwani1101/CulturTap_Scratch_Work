import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/Calendar.dart';
import 'package:learn_flutter/SignUp/FirstPage.dart';
import 'package:learn_flutter/UserProfile/FinalUserProfile.dart';
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
    return WillPopScope(
      onWillPop: () async {
        // You can perform any additional checks here if needed
        // For simplicity, we just navigate to the same page again
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => HomePage(userId: userId,userName: userName,)),
        );
        // Navigator.of(context).pop();
        return Future.value(true); // Returning false to prevent default back behavior
      },
      child: MaterialApp(
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
          useMaterial3: true,
        ),
        home: HomePageWidget(userName:userName,userId:userId,phoneNumber:phoneNumber,latitude:latitude,longitude:longitude,token:token),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomePageWidget extends StatefulWidget {
  String ?userName,userId,phoneNumber,latitude,longitude,token;
  HomePageWidget({this.longitude,this.latitude,this.phoneNumber,this.userId,this.userName,this.token});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {


  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  void initState(){
    super.initState();

  }

  Future<void> fetchDataFromMongoDB() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // User is already signed in, navigate to the desired screen
      var userQuery = await firestore.collection('users').where('uid',isEqualTo:user.uid).limit(1).get();

      var userData = userQuery.docs.first.data();
      String uName = userData['name'];
      String uId = userData['userMongoId'];
      widget.userName = uName;
      widget.userId =uId;
    }
  }
  Future<void> _refreshPage() async {
    await Future.delayed(Duration(seconds: 0));
    setState(() {
      fetchDataFromMongoDB();
    });
  }

  Widget build(BuildContext context) {

    Future<void> _signOut() async {
      try {
        await _auth.signOut();
        // Redirect to the login or splash screen after logout
        // For example:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FirstPage()));
       } catch (e) {
        print('Error while logging out: $e');
        // Handle the error as needed
      }
    }
    _refreshPage();
    return Scaffold(
      appBar:AppBar(title: ProfileHeader(reqPage: 0,userId: widget.userId,),),

      body: RefreshIndicator(
        onRefresh:_refreshPage,
        child: Container(
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
                      child: ProfileApp(userName: widget.userName,userId: widget.userId,),
                    ),),
                  );
                },
                  child: Text('Create Profile')
              ),
              InkWell(
                onTap: (){
                    _refreshPage();
                },
                  child: Text('Home Screen')
              ),
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                      create:(context) => ProfileDataProvider(),
                      child: FinalProfile(userId: widget.userId!,clickedId: '652bb97a2310b75ec11cd2ed',),
                    ),),
                  );
                },
                  child: Text('Avail Trip Calling Services From Hemant')
              ),
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                      create:(context) => ProfileDataProvider(),
                      child: FinalProfile(userId: widget.userId!,clickedId: widget.userId!,),
                    ),),
                  );
                },
                child: Text('User Profile'),
              ),
              InkWell(
                onTap: (){
                  _signOut();
                },
                child: Text('LogOut'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}