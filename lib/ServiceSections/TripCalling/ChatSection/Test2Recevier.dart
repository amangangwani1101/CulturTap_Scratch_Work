import 'package:flutter/cupertino.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/Receiver.dart';
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
  String meetingId = '6538f5d97f4d838a1071f237';
  String sendersId  = '';
  String receiverId = '652bbc022310b75ec11cd322';
  Widget build(BuildContext context) {
    return ChatApps(senderId:sendersId,receiverId:receiverId,meetingId:meetingId);
  }

}