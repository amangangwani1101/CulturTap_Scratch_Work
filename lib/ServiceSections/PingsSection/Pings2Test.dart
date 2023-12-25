import 'package:flutter/cupertino.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey = Constant().publishableKey;
  // Stripe.instance.applySettings();
  runApp(Receiver());
}

class Receiver extends StatefulWidget{
  @override
  _ReceiverState createState()=> _ReceiverState();
}

class _ReceiverState extends State<Receiver>{
  String id = '656050b3030772278b8b54cd';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home:Scaffold(
        // debugShowCheckedModeBanner: false,

        body : PingsSection(userId:id,state: 'All',),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}