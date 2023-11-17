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
  String meetingId = '653d7f5933940af362c13f40';
  String sendersId  = '652a578b7ff9b6023a1483ba';
  String receiverId = '';
  Widget build(BuildContext context) {
    return ChatApps(senderId:sendersId,receiverId:receiverId,meetingId:meetingId);
  }

}