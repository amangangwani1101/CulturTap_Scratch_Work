import 'package:flutter/material.dart';
import 'package:learn_flutter/widgets/01_helpIconCustomWidget.dart';



class HexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex =  "FF" + hex.toUpperCase().replaceAll("#", "");
    return int.parse(formattedHex, radix: 16);
  }
  HexColor(final String hex) : super(_getColor(hex));
}

class ServiceCard extends StatefulWidget{
  final String titleLabel,iconImage,serviceImage,subTitleLabel,endLabel;

  ServiceCard({
    required this.titleLabel,
    required this.serviceImage,
    required this.iconImage,
    required this.subTitleLabel,
    required this.endLabel,
  });

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>{
  bool buttonState = false;
  void toggleButton(){
    setState(() {
      buttonState = !buttonState;
    });
  }

  void onPressedHandler() {
    if (!buttonState) {
      showDialog(context: context, builder: (BuildContext context){
        return Container(child: CustomHelpOverlay(imagePath: 'assets/images/clock_icon.jpg',),);
      },
    );

    }else {
      (){};
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(widget.titleLabel,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
              IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                showDialog(context: context, builder: (BuildContext context){
                  return Container(child: CustomHelpOverlay(imagePath: widget.iconImage,),);
                },
                );
              },
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: Container(

              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(widget.serviceImage,width: 160,height: 89,fit: BoxFit.contain,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(widget.subTitleLabel,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Container(
                        child: RichText(
                          text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                TextSpan(
                                  text: 'Earn Easy'
                                ),
                                TextSpan(
                                  text: ' 500 INR',
                                  style: TextStyle(fontFamily: 'Poppins',fontSize: 14,color: Colors.green),
                                ),
                                TextSpan(
                                    text: '\nper Call'
                                ),
                              ],
                          ),
                        ),
                      ),
                      Text('*Terms & Conditions applied',style: TextStyle(fontSize: 7,fontFamily: 'Poppins',color: Colors.red),),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(widget.endLabel),
              ElevatedButton(
                onPressed: onPressedHandler,
                child: Text(buttonState ? 'On' : 'Off'),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
