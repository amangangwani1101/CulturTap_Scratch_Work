import 'package:flutter/cupertino.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/Receiver.dart';
// import 'package:learn_flutter/ServiceSections/TripCalling/ChatSection/TestReceiver.dart';


void main() {
  runApp(Receiver());
}

class Receiver extends StatefulWidget{
  @override
  _ReceiverState createState()=> _ReceiverState();
}

class _ReceiverState extends State<Receiver>{
  @override
  String meetingId = '6538c0bd0e6e10a5ad9eadbc';
  String sendersId  = '';
  String receiverId = '652b2cfe59629378c2c7dacb';
  Widget build(BuildContext context) {
    return ChatApps(senderId:sendersId,receiverId:receiverId,meetingId:meetingId);
  }

}