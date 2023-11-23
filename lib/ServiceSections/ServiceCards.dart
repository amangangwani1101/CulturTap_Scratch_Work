
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../BackendStore/BackendStore.dart';
import '../widgets/01_helpIconCustomWidget.dart';
import '../widgets/hexColor.dart';


// Single Service Cards
class ServiceCard extends StatefulWidget{
  final String titleLabel,iconImage,serviceImage,subTitleLabel,endLabel;
  final ProfileDataProvider? profileDataProvider;
  ServiceCard({
    required this.titleLabel,
    required this.serviceImage,
    required this.iconImage,
    required this.subTitleLabel,
    required this.endLabel,
    this.profileDataProvider,
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
              Text(widget.titleLabel,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
              IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                showDialog(context: context, builder: (BuildContext context){
                  return Container(child: CustomHelpOverlay(imagePath: widget.iconImage,serviceSettings: false),);
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
                      Text(widget.subTitleLabel,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
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
                                style: TextStyle(fontFamily: 'Poppins',fontSize: 16,color: Colors.green),
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
              ConcentricCircles(profileDataProvider:widget.profileDataProvider),
            ],
          ),
        ],
      ),
    );
  }
}
class ConcentricCircles extends StatefulWidget{
  bool isToggled = false;
  final ProfileDataProvider? profileDataProvider;
  ConcentricCircles({this.profileDataProvider});
  final animationDuration = Duration(milliseconds: 500);
  @override
  _ConcentricCirclesState createState() => _ConcentricCirclesState();
}
class _ConcentricCirclesState extends State<ConcentricCircles> {

  @override
  void initState(){
    super.initState();
    setState(() {
      widget.isToggled  =widget.profileDataProvider!.retServide1();
    });
  }
  void onPressedHandler() {
      showDialog(context: context, builder: (BuildContext context){
        return Container(child: CustomHelpOverlay(imagePath: 'assets/images/clock_icon.jpg',serviceSettings: true,profileDataProvider:widget.profileDataProvider),);
      },);
      widget.isToggled  =widget.profileDataProvider!.retServide1();
   }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          widget.isToggled = widget.profileDataProvider!.retServide1();
        });
        onPressedHandler();
      },
      child: AnimatedContainer(
        width: 90,
        height: 54,
        duration:widget.animationDuration,
        child: Stack(
          children: [
            Center(
              child: Container(
                height: 35,
                width: 77,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: widget.isToggled?HexColor('#FB8C00'):HexColor('#EDEDED'),
                ),
              ),
            ),
            Align(
              alignment: widget.isToggled?Alignment.centerRight:Alignment.centerLeft,
              child:Stack(
                children: [
                  Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 3,
                    left: 3,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.isToggled?HexColor('#128807'):Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HexColor('#FB8C00'),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Container(
              width: 83,
              height: 54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('OFF',style: widget.isToggled?TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white,):TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00'),),),
                  Text('ON',style: widget.isToggled?TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white,):TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#0A8100'),),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

