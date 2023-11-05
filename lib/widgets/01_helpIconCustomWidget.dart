import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/CalendarHelper.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/Pings.dart';
import 'package:learn_flutter/slider.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:learn_flutter/widgets/sample.dart';
import '../BackendStore/BackendStore.dart';
import 'hexColor.dart';
import '../UserProfile/ProfileHeader.dart';



class CustomHelpOverlay extends StatelessWidget {

  final String imagePath;
  bool? serviceSettings=false;
  String?text,navigate;
  final helper;
  final ProfileDataProvider? profileDataProvider;
  CustomHelpOverlay({required this.imagePath,this.serviceSettings,this.profileDataProvider,this.text,this.navigate,this.helper});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.grey.withOpacity(0),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              width: screenWidth*0.90,
              height: 315,
              // child: Align(
              //   alignment: Alignment.topRight,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //     child: (Icon(Icons.crop_sharp)),
              //   ),
              // ),

              child: Container(
                child: Stack(
                  children: [
                    Center(child: Image.asset(imagePath,width: 361,height: 281,fit: BoxFit.contain,),),
                    Positioned(
                      top: 15,
                      right: 15,
                      child:navigate=='pings'
                        ?SizedBox(width: 0,)
                        : IconButton(
                        icon: Icon(Icons.close),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    if (text!=null) Container(
                      height: 250,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                            onTap: (){
                              if(navigate=='calendarhelper')
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> CalendarHelper(plans:helper!)));
                              else if(navigate=='pings')
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> PingsSection(userId: helper!,)));

                            },
                            child: Text(text!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.orange,),)),
                      ),
                    ) else SizedBox(width: 0,),
                    if (serviceSettings!=null) Container(
                        height: 250,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> ServicePage(profileDataProvider:profileDataProvider)));
                              },
                              child: Text('Continue',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.orange,),)),
                        ),
                      ) else SizedBox(width: 0,)
                  ],
                ),
              ),


            ),
          ),
        ],
      ),
    );
  }
}
class ServicePage extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  ServicePage({this.profileDataProvider});
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage>{
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Set the preferred height to 0
        child: AppBar(
          elevation: 0, // Remove the shadow
          backgroundColor: Colors.transparent, // Make the background transparent
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(reqPage: 1),
            Container(
              height:screenHeight*0.85,
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //     width: 1,
              //   ),
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
                  Container(
                    height: 361,
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.orange,
                    //     width: 2,
                    //   )
                    // ),
                    child: Column(
                      children: [
                        Container(
                          width:318,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Timing for interaction calls',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                              Text('Select Your Time',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),)
                            ],
                          ),
                        ),
                        TimePicker(profileDataProvider:widget.profileDataProvider),
                      ],
                    ),
                  ),
                  BandWidthSelect(profileDataProvider:widget.profileDataProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimePicker extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  TimePicker({this.profileDataProvider});
  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker>{
  TimeOfDay _startTime = TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 21,minute:0);

  Future<void> _selectStartTime(BuildContext context) async{
    final pickedTime = await showTimePicker(
      context: context, initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if(pickedTime!=null){
      setState(() {
        _startTime = pickedTime;
        widget.profileDataProvider?.setStartTime(_formatTime(pickedTime));
        print(pickedTime);
        print("Start Time: ${_formatTime(_startTime)}");
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    // Format the hour to 12-hour format
    if (hour > 12) {
      hour -= 12;
    }

    String minuteStr = minute < 10 ? '0$minute' : '$minute';

    return '$hour:$minuteStr $period';
  }

  Future<void> _selectEndTime(BuildContext context) async{
    final pickedTime = await showTimePicker(
      context: context, initialTime: _endTime,builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      );
    },
    );

    if(pickedTime!=null){
      setState(() {
        _endTime = pickedTime;
        widget.profileDataProvider?.setEndTime(_formatTime(pickedTime));
        print("End Time: ${_endTime.format(context)}");
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Container(
      width: 162,
      height: 280,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 93,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('From'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,),
                    ),
                    Container(
                      width: 118,
                      height: 57,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                          onTap: (){
                            _selectStartTime(context);
                          },
                          child: Text('${_formatTime(_startTime)}',style: TextStyle(fontSize: 27,fontFamily: 'Poppins'),)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            height: 93,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('To'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,),
                    ),
                    Container(
                      width: 118,
                      height: 57,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                          onTap: (){
                            _selectEndTime(context);
                          },
                          child: Text('${_formatTime(_endTime)}',style: TextStyle(fontSize: 27,fontFamily: 'Poppins'),)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BandWidthSelect extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  BandWidthSelect({this.profileDataProvider});
  @override
  _BandWidthSelectState createState() => _BandWidthSelectState();
}

class _BandWidthSelectState extends State<BandWidthSelect>{
  String _radioValue = "choice_1";
  @override
  Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth*0.99,
      height: 275,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.grey,
          width: 0.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          Container(
            width: screenWidth*0.78,
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.black,
            //     width: 2,
            //   ),
            // ),
            child: Align(
                alignment: Alignment.topLeft,
                child: Text('Select Bandwidth',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),)),
          ),
          Column(
            children: [
              Row(
                children: [
                  SizedBox(width: screenWidth*0.06,),
                  Radio(
                    value: "choice_1",
                    groupValue: _radioValue,
                    activeColor: Colors.orange, // Change circle color to orange
                    onChanged: (String? value) {
                      setState(() {
                        _radioValue = value!;
                        print('Path is : $_radioValue');
                        widget.profileDataProvider?.setSlots(_radioValue);
                      });
                    },
                  ),
                  Text("Daily"),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: screenWidth*0.06,),
                  Radio(
                    value: "choice_2",
                    groupValue: _radioValue,
                    activeColor: Colors.orange, // Change circle color to orange
                    onChanged: (String? value) {
                      setState(() {
                        _radioValue = value!;
                        print('Path is : $_radioValue');
                        widget.profileDataProvider?.setSlots(_radioValue);
                      });
                    },
                  ),
                  Text("Only Weekends"),
                ],
              ),
            ],
          ),
          Container(
            width: 325,
            height: 63,
            child: FilledButton(
                backgroundColor: HexColor('#FB8C00'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentSection()));
                },
                child: Center(
                    child: Text('SET TIME',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,fontFamily: 'Poppins')))),
          ),
        ],
      ),
    );
  }
}

class FilledButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  final Color backgroundColor;

  const FilledButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape:RoundedRectangleBorder(),
        primary: backgroundColor,
      ),
      child: child,
    );
  }
}
