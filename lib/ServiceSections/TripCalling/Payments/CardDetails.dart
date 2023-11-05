import 'package:flutter/cupertino.dart';
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
    return PaymentSection();
  }

}