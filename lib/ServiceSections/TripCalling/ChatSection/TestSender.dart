import 'package:flutter/cupertino.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/ChatSection.dart';
// import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/TestReceiver.dart';

void main() {
  runApp(Sender());
}

class Sender extends StatefulWidget{
  @override
  _SenderState createState()=> _SenderState();
}

class _SenderState extends State<Sender>{
  @override
  String meetingId = '655c3052908875e010f5d7bc';
  String sendersId  = '652a31f77ff9b6023a14838a';
  String receiverId = '';
  Widget build(BuildContext context) {
    return ChatApps(senderId:sendersId,receiverId:receiverId,meetingId:meetingId);
  }

}