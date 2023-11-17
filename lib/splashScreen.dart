import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/SignUp/FirstPage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';

class splashScreen extends StatefulWidget {
  @override
  State<splashScreen> createState() => _splashScreenState();

}
class _splashScreenState extends State<splashScreen>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      currentUserStatus();
    });

  }

  void currentUserStatus() async{
    User? user = _auth.currentUser;
    if (user != null) {
      // User is already signed in, navigate to the desired screen
      var userQuery = await firestore.collection('users').where('uid',isEqualTo:user.uid).limit(1).get();

      var userData = userQuery.docs.first.data();
      String userName = userData['name'];
      String userId = userData['userMongoId'];
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(userName: userName,userId: userId,)),
      );
    }
    else {
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => FirstPage()));
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:Container(
        width : double.infinity,
        height : double.infinity,
        child : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin:EdgeInsets.only(bottom : 20),
                height : 400,
                width : double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width : 215,
                        child: Image.asset('assets/images/logo.png')
                    ),
                    Container(
                        child : Column(
                          children: [
                            Text('All right reserve to ',style:TextStyle(fontSize : 20)),
                            Text('Culturtap Tourism India Pvt. Ltd.',style:TextStyle(fontSize : 20,fontWeight: FontWeight.bold)),
                          ],
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),



      ),

    );
  }

}


