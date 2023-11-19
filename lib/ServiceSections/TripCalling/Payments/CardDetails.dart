import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/UserProfile/ProfileHeader.dart';
import 'package:learn_flutter/slider.dart';


void main() {
  runApp(CardDetails());
}

class CardDetails extends StatefulWidget{
  @override
  _CardDetailsState createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(

          appBar:AppBar(title: ProfileHeader(reqPage: 4,),),
        body:PaymentSection(),
    ),);
  }

}