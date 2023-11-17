import 'package:flutter/cupertino.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/ChatSection.dart';


void main() {
  runApp(Receiver());
}

class Receiver extends StatefulWidget{
  @override
  _ReceiverState createState()=> _ReceiverState();
}

class _ReceiverState extends State<Receiver>{
  @override
  String meetingId = '653d7f5933940af362c13f40';
  String sendersId  = '';
  String receiverId = '652b2cfe59629378c2c7dacb';
  Widget build(BuildContext context) {
    return ChatApps(senderId:sendersId,receiverId:receiverId,meetingId:meetingId);
  }

}