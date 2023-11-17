import 'package:flutter/cupertino.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/ChatSection.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
// import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/TestReceiver.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/widgets/Constant.dart';

import '../../UserProfile/ProfileHeader.dart';
// import '../../rating.dart';
import '../../widgets/hexColor.dart';
import '../TripCalling/ChatSection/ChatSection.dart';
import '../../UserProfile/ProfileHeader.dart';
void main() {
  runApp(Receiver());
}

class Receiver extends StatefulWidget{
  @override
  _ReceiverState createState()=> _ReceiverState();
}

class _ReceiverState extends State<Receiver>{
  String id = Constant().receiversId;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      home:Scaffold(
      // debugShowCheckedModeBanner: false,
      body : PingsSection(userId:id),
    ),
      debugShowCheckedModeBanner: false,
    );
  }
}