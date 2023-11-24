import 'package:flutter/cupertino.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/Receiver.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/Pings.dart';
// import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/TestReceiver.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/widgets/Constant.dart';

import '../../UserProfile/ProfileHeader.dart';
import '../../rating.dart';
import 'ChatSection/Receiver.dart';
import '../../UserProfile/ProfileHeader.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = Constant().publishableKey;
  Stripe.instance.applySettings();
  runApp(Receiver());
}

class Receiver extends StatefulWidget{
  @override
  _ReceiverState createState()=> _ReceiverState();
}

class _ReceiverState extends State<Receiver>{
  String id = '65581291f46f5794689c1ffd';
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