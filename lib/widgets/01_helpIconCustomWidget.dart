import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/CalendarHelper.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/Pings.dart';
import 'package:learn_flutter/slider.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:learn_flutter/widgets/sample.dart';
import '../BackendStore/BackendStore.dart';
import 'Constant.dart';
import 'package:http/http.dart' as http;
import 'hexColor.dart';
import '../UserProfile/ProfileHeader.dart';


String? globalStartTime;
String? globalEndTime;
String? globalSlots;

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
  final ServiceTripCallingData?data;
  String?userId;
  ServicePage({this.profileDataProvider,this.userId,this.data});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage>{
  String?startTime,endTime,slots;


  @override
  Widget build(BuildContext context) {
    if(widget.data!=null){
      startTime = widget.data?.setStartTime;
      endTime = widget.data?.setEndTime;
      slots = widget.data?.slots;
    }
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
                        TimePicker(profileDataProvider:widget.profileDataProvider,startTime:startTime,endTime:endTime),
                      ],
                    ),
                  ),
                  BandWidthSelect(profileDataProvider:widget.profileDataProvider,slots:slots,userId:widget.userId),
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
  final String?startTime,endTime;
  TimePicker({this.profileDataProvider,this.endTime,this.startTime});
  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker>{
  TimeOfDay _startTime = TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 21,minute:0);

  TimeOfDay convertStringToTimeOfDay(String timeString) {
    final List<String> timeParts = timeString.split(' ');

    // Extract hours and minutes
    final List<String> timeDigits = timeParts[0].split(':');
    int hours = int.parse(timeDigits[0]);
    int minutes = int.parse(timeDigits[1]);

    // Adjust hours for PM
    if (timeParts[1] == 'PM' && hours < 12) {
      hours += 12;
    }

    // Create and return TimeOfDay object
    return TimeOfDay(hour: hours, minute: minutes);
  }

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
        if(widget.startTime==null)
          widget.profileDataProvider?.setStartTime(_formatTime(pickedTime));
        else{
          globalStartTime = _formatTime(_startTime);
        }
        print(pickedTime);
        print("Start Time: ${_startTime}");
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
        if(widget.endTime==null)
          widget.profileDataProvider?.setEndTime(_formatTime(pickedTime));
        else{
          globalEndTime = _formatTime(_endTime);
        }
        print("End Time: ${_endTime.format(context)}");
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize _startTime and _endTime with values from widget
    if (widget.startTime != null) {
      _startTime = convertStringToTimeOfDay(widget.startTime!);
      globalStartTime=widget.startTime!;
    }

    if (widget.endTime != null) {
      _endTime = convertStringToTimeOfDay(widget.endTime!);
      globalEndTime = widget.endTime!;
    }

  }
  @override
  Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth*0.77,
            height: 120,
            // decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('From',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w400),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,),
                    ),
                    SizedBox(width: 6,),
                    Container(

                      padding: EdgeInsets.all(2),
                      height: 57,
                      decoration: BoxDecoration(
                        color: HexColor('#5EEBEB').withOpacity(0.2),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: GestureDetector(
                            onTap: (){
                              _selectStartTime(context);
                              print(_startTime);

                            },
                            child: Text('${_formatTime(_startTime)}',style: TextStyle(fontSize: 27,fontFamily: 'Poppins'),)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            width: screenWidth*0.77,
            height: 120,
            // decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('To',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w400),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,),
                    ),
                    SizedBox(width: 6,),
                    Container(

                      padding: EdgeInsets.all(2),
                      height: 57,
                      decoration: BoxDecoration(
                        color: HexColor('#5EEBEB').withOpacity(0.2),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: GestureDetector(
                            onTap: (){
                              _selectEndTime(context);
                              print(_endTime);

                            },
                            child: Text('${_formatTime(_endTime)}',style: TextStyle(fontSize: 27,fontFamily: 'Poppins'),)),
                      ),
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
  final String?slots,userId;
  BandWidthSelect({this.profileDataProvider,this.slots,this.userId});
  @override
  _BandWidthSelectState createState() => _BandWidthSelectState();
}

class _BandWidthSelectState extends State<BandWidthSelect>{
  String _radioValue = "choice_1";

  @override
  void initState(){
    if(widget.slots!=null){
      _radioValue = widget.slots!;
    }
  }

  void updateUserTime (String userId,String startTime,String endTime,String slot) async{
    try {
      Map<String,dynamic>data = {
        "userId":userId,
        "startTime":startTime,
        "endTime":endTime,
        "slot":slot
      };
      print('User$data');
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final http.Response response = await http.put(
        Uri.parse('$serverUrl/updateUserTime'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Your Time Is Set :) '),
        //   ),
        // );
        print('Data saved successfully');
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Try Again!!'),
        //   ),
        // );
        print('Failed to update time: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }
  }


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
                        if(widget.slots==null)
                          widget.profileDataProvider?.setSlots(_radioValue);
                        else {
                          globalSlots = _radioValue;
                        }
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
                        if(widget.slots==null)
                          widget.profileDataProvider?.setSlots(_radioValue);
                        else {
                          globalSlots = _radioValue;
                        }
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
                  if(widget.userId==null){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentSection()));
                  }else{
                    print(1);
                    print(widget.userId!);
                    updateUserTime(widget.userId!,globalStartTime!,globalEndTime!,globalSlots!);
                    // Navigator.of(context).pop();
                  }
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
