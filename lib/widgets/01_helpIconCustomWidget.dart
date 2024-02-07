import 'dart:convert';
// import 'dart:html';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/Payments/RazorPay.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/CalendarHelper.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:learn_flutter/Settings.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/slider.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:learn_flutter/widgets/sample.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../BackendStore/BackendStore.dart';
import '../CustomItems/CustomPopUp.dart';
import 'AlertBox2Option.dart';
import 'Constant.dart';
import 'package:http/http.dart' as http;
import 'CustomButton.dart';
import 'CustomDialogBox.dart';
import 'hexColor.dart';
import '../UserProfile/ProfileHeader.dart';


String? globalStartTime='6:00 PM';
String? globalEndTime='9:00 PM';
String? globalSlots = 'choice_1';
List<bool>?globalAvailable = List.generate(7, (index) => true);
List<PaymentDetails> globalCards =[];
bool isGone=false;


class CustomHelpOverlay extends StatelessWidget {
  VoidCallback? onButtonPressed,onBackPressed;
  final String imagePath;
  bool? serviceSettings=false;
  String?text,navigate;
  final String? button;
  final String? extraText;
  final helper,helper2;
  final ProfileDataProvider? profileDataProvider;
  CustomHelpOverlay({required this.imagePath,this.serviceSettings,this.profileDataProvider,this.text,this.navigate,this.button,this.extraText,this.helper,this.helper2,this.onButtonPressed,this.onBackPressed});
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: ()async{
        if(navigate=='pings'){
          onBackPressed!();
        }else if(navigate=='edit'){
          onBackPressed!();
        }
          print(1);
        return true;
      },

      child: AlertDialog(
        contentPadding: EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height : 10),
              SvgPicture.asset(
                imagePath,
                height: 166,
                width: 166,
              ),
              SizedBox(height: 26),
              if(text!=null)
                Text(
                text!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
                textAlign: TextAlign.center,
              ),
              text==null?SizedBox(height: 0,):SizedBox(height: 16),
              if(extraText != null)
                Text(
                extraText!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,

                  color: Color(0xFF263238),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              if(button != null)
                TextButton(
                onPressed: () {
                  if (navigate == 'calendarhelper' ||
                      navigate == 'edit' ||
                      navigate == 'pop' || navigate=='pings') {
                    onButtonPressed!();

                  } else if (navigate == 'pings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PingsSection(
                          selectedService:'',
                          userId: helper!,
                          userName: helper2!,
                          text: 'meetingPings',
                        ),
                      ),
                    );
                  }
                },

                child: Text(
                  button!,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Set the background color
      ),


      );

  }
}





class ServicePage extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  final ServiceTripCallingData?data;
  VoidCallback? onButtonPressed;
  String?userId,text;
  bool?haveCards;
  ServicePage({this.profileDataProvider,this.userId,this.data,this.text,this.haveCards,this.onButtonPressed});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage>{
  String?startTime,endTime,slots;
  List<bool>?daysChoosen;

  @override
  Widget build(BuildContext context) {
    if(widget.data!=null){
      startTime = widget.data?.setStartTime;
      endTime = widget.data?.setEndTime;
      slots = widget.data?.slots;
      daysChoosen = widget.data?.availabilityChoosen;
      globalStartTime = startTime;
      globalEndTime = endTime;
      globalSlots = slots;
      globalAvailable = daysChoosen;
    }
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: ()async{
        if(widget.text=='edit' && isGone==true){
          widget.onButtonPressed!();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
        else if(widget.profileDataProvider==null && widget.text=='edit'){
          print(1);
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditServices()));
        }
        else if(widget.profileDataProvider==null){
          Navigator.of(context).pop();
        }
        else{
          print(2);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:AppBar(title: ProfileHeader(reqPage: 0,userId: widget.userId,text: widget.profileDataProvider==null?'':'calendar',),automaticallyImplyLeading: false,shadowColor: Colors.transparent, toolbarHeight: 90,),
        body: SingleChildScrollView(
          child: Container(
            color : Theme.of(context).backgroundColor,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  // color: Colors.red,
                  margin: EdgeInsets.only(left: 30,right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Timing for interaction calls',style: Theme.of(context).textTheme.subtitle1,),
                      SizedBox(height: 5,),
                      Text('Select Your Time',style: Theme.of(context).textTheme.subtitle1,)
                    ],
                  ),
                ),
                SizedBox(height: 30,),
                TimePicker(profileDataProvider:widget.profileDataProvider,startTime:startTime,endTime:endTime),
                SizedBox(height : 60),
                BandWidthSelect(text:widget.text,profileDataProvider:widget.profileDataProvider,slots:slots,daysChoosen:daysChoosen,userId:widget.userId,haveCards:widget.haveCards,onButtonPressed:widget.onButtonPressed),

              ],
            ),
          ),
          ),
        // bottomNavigationBar:
        // InkWell(
        //   onTap: (){
        //     // updateUserTime(widget.userId!,globalStartTime!,globalEndTime!,globalSlots!);
        //
        //
        //     // if(widget.profileDataProvider!=null){
        //     //   widget.profileDataProvider?.setServide1();
        //     //   Navigator.of(context).pop();
        //     //   Navigator.of(context).pop();
        //     // }
        //     // if(isGone){
        //     //   ScaffoldMessenger.of(context).showSnackBar(
        //     //     SnackBar(
        //     //       content: Text('Already Set!!'),
        //     //     ),
        //     //   );
        //     //   Navigator.of(context).pop();
        //     // }
        //     if(validator()){
        //       // setState(() {
        //       //   isGone = true;
        //       // });
        //       if(widget.userId==null){
        //         Navigator.of(context).pop();
        //         if(widget.profileDataProvider!=null){
        //           widget.profileDataProvider?.setServide1();
        //         }
        //       }
        //       else{
        //         updateUserTime(widget.userId!,globalStartTime!,globalEndTime!,globalSlots!);
        //         Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsPage(userId: userID)));
        //         // Navigator.of(context).pop();
        //       }
        //     // }else{}
        //   },
        //   child: Container(
        //     width: MediaQuery.of(context).size.width,
        //     // alignment: Alignment.center,
        //     margin: EdgeInsets.only(left: 30,right:30),
        //     padding: EdgeInsets.all(15),
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(10),
        //       color: Colors.orange,
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Text('SET TIME',style: Theme.of(context).textTheme.caption,),
        //       ],
        //     ),
        //   ),
        // ),
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
      // initialEntryMode: TimePickerEntryMode.dialOnly,
      context: context, initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              // change the border color
              primary: Colors.orange.withOpacity(0.6),
              // change the text color
              onSurface: Colors.grey,
            ),
            // button colors
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: Colors.green,
              ),
            ),
          ), 
          child: MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            //
          child: child!,),
        );
      },
    );

    if(pickedTime!=null){
      setState(() {
        _startTime = pickedTime;
        if(widget.startTime==null)
          {
            globalStartTime = _formatTime(_startTime);
          }
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
      context: context, initialTime: _endTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              // change the border color
              primary: Colors.orange.withOpacity(0.6),
              // change the text color
              onSurface: Colors.grey,
            ),
            // button colors
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: Colors.green,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            //
            child: child!,),
        );
      },
    );

    if(pickedTime!=null){
      setState(() {
        _endTime = pickedTime;
        if(widget.endTime==null){
          globalEndTime = _formatTime(_endTime);
        }
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
    }else{
      globalStartTime = '6:00 PM';
    }

    if (widget.endTime != null) {
      _endTime = convertStringToTimeOfDay(widget.endTime!);
      globalEndTime = widget.endTime!;
    }else{
      globalEndTime = '9:00 PM';
    }

  }
  @override
  Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(left:20,right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // width: screenWidth*0.77,
            // height: 120,
            padding: EdgeInsets.only(right:20),
            // color: Colors.red ,
            // decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('From',style: Theme.of(context).textTheme.subtitle1,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,color : Theme.of(context).primaryColor),
                    ),
                    SizedBox(width: 6,),
                    Container(

                      padding: EdgeInsets.all(5),
                      height: 57,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        // color: HexColor('#5EEBEB').withOpacity(0.2),
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
                              // start time
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
          SizedBox(height: 30,),
          Container(
            // width: screenWidth*0.77,
            // height: 120,
            padding: EdgeInsets.only(right:20),
            // decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('To',style: Theme.of(context).textTheme.subtitle1,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,color : Theme.of(context).primaryColor),
                    ),
                    SizedBox(width: 6,),
                    Container(

                      padding: EdgeInsets.all(5),
                      height: 57,
                      decoration: BoxDecoration(
                        // color: HexColor('#5EEBEB').withOpacity(0.2),
                        color: Colors.orange.withOpacity(0.2),
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
  final String?slots,userId,text;
  VoidCallback? onButtonPressed;
  bool?haveCards;
  List<bool>?daysChoosen;
  BandWidthSelect({this.profileDataProvider,this.slots,this.userId,this.haveCards,this.text,this.onButtonPressed,this.daysChoosen});
  @override
  _BandWidthSelectState createState() => _BandWidthSelectState();
}

class _BandWidthSelectState extends State<BandWidthSelect>{
  String _radioValue='choice_1';
  List<bool>selectedDays = List.generate(7, (index) => true);

  @override
  void initState(){
    if(widget.slots!=null){
      _radioValue = widget.slots!;
    }
    else{
      selectedDays = List.generate(7, (index) => true);
    }
    if(widget.daysChoosen!=null){
      print('Days are ${widget.daysChoosen}');
      selectedDays = widget.daysChoosen!;
    }
  }


  Future<void> updateUserTime (String userId,String startTime,String endTime,String slot,List<bool>daysChoosen) async{
    try {
      Map<String,dynamic>data = {
        "userId":userId,
        "startTime":startTime,
        "endTime":endTime,
        "slot":slot,
        "daysChoosen":daysChoosen,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your Time Is Set :) '),
          ),
        );

        // Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsPage(userId:userID)));


        if(widget.text=='edit'){
          showDialog(context: context, builder: (BuildContext context){
            return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
              // Navigator.of(context).pop();
              // Navigator.of(context).pop();
              // Navigator.of(context).pop();
              // Navigator.of(context).pop();
              // Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsPage(userId: userID)));
            },),);
          },
          );
          widget.onButtonPressed!();
        }
        else{
          Navigator.of(context).pop();
        }
        print('Data saved successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Try Again!!'),
          ),
        );
        print('Failed to update time: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }
  }

  Future<bool> checkUserTimeWithMeet (String userId,String startTime,String endTime,List<bool>daysChoosen) async{
    try {
      Map<String,dynamic>data = {
        "userId":userId,
        "startTime":startTime,
        "endTime":endTime,
        "daysChoosen":daysChoosen,
      };
      print('User$data');
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final http.Response response = await http.post(
        Uri.parse('$serverUrl/checkEligibilityToEditTripPlanningTime'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );
      try{
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print(responseData);
          if(responseData['isEligible']){
            return true;
          }
          else if(responseData['day']!=null){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You have a meet on ${responseData['day']}'),
              ),
            );
            return false;
          }
          else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Your meets are scheduled'),
              ),
            );
            return false;
          }
          print('Data saved successfully');
        } else {
          return false;
        }
      }catch(err){
        print("Error: $err");
        Fluttertoast.showToast(
          msg: 'Try Again!!',
          toastLength:
          Toast.LENGTH_SHORT,
          gravity:
          ToastGravity.BOTTOM,
          backgroundColor:
          Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    }catch(err){
      print("Error: $err");
      Fluttertoast.showToast(
        msg: 'Try Again!!',
        toastLength:
        Toast.LENGTH_SHORT,
        gravity:
        ToastGravity.BOTTOM,
        backgroundColor:
        Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }

  Duration calculateTimeDifference(String startTimeStr, String endTimeStr) {
    // Parse the time strings into TimeOfDay objects
    TimeOfDay startTime = _parseTimeString(startTimeStr);
    TimeOfDay endTime = _parseTimeString(endTimeStr);

    // Convert TimeOfDay objects to DateTime objects for easier manipulation
    DateTime startDateTime = DateTime(2023, 1, 1, startTime.hour, startTime.minute);
    DateTime endDateTime = DateTime(2023, 1, 1, endTime.hour, endTime.minute);

    // Calculate the difference between times
    Duration difference = endDateTime.difference(startDateTime);

    // Ensure positive time difference if end time is earlier than start time
    if (difference.isNegative) {
      difference = Duration(hours: 24) + difference;
    }

    return difference;
  }

  TimeOfDay _parseTimeString(String timeStr) {
    // Parse the time string in the format "6:00 PM" to TimeOfDay object
    List<String> splitTime = timeStr.split(' ');
    String time = splitTime[0];
    String period = splitTime[1];
    List<String> splitHourMinute = time.split(':');
    int hour = int.parse(splitHourMinute[0]);
    int minute = int.parse(splitHourMinute[1]);

    // Convert 12-hour format to 24-hour format if needed
    if (period.toLowerCase() == 'pm' && hour < 12) {
      hour += 12;
    } else if (period.toLowerCase() == 'am' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  bool isTimeDifferenceGreaterThan30Minutes(String startTimeStr, String endTimeStr) {
    Duration difference = calculateTimeDifference(startTimeStr, endTimeStr);
    return difference.inMinutes > 30;
  }



  DateTime _parseTime(String time) {
    // Split the time string into parts
    List<String> parts = time.split(' ');
    String timePart = parts[0];
    String amPmPart = parts[1];

    // Split the time part into hours and minutes
    List<String> timeParts = timePart.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    // Adjust hours for PM
    if (amPmPart.toLowerCase() == 'pm' && hours < 12) {
      hours += 12;
    }

    return DateTime(2023, 1, 1, hours, minutes);
  }



  bool validator(){
     if((globalStartTime)==null || (globalEndTime)==null) {
       Fluttertoast.showToast(
         msg: "Please select your timing!",
         toastLength: Toast.LENGTH_LONG,
         gravity: ToastGravity.BOTTOM,
       );
       return false;
     }
    else if(globalSlots==null) {
       Fluttertoast.showToast(
         msg: "Please select your slots!",
         toastLength: Toast.LENGTH_LONG,
         gravity: ToastGravity.BOTTOM,
       );
      return false;
    }
    else if(isTimeDifferenceGreaterThan30Minutes(globalStartTime!,globalEndTime!) ==false){
       Fluttertoast.showToast(
         msg: "its a pop up time :(!",
         toastLength: Toast.LENGTH_LONG,
         gravity: ToastGravity.BOTTOM,
       );
      return false;
    }
    if(widget.profileDataProvider!=null){
      widget.profileDataProvider?.setStartTime(globalStartTime!);
      widget.profileDataProvider?.setEndTime(globalEndTime!);
      widget.profileDataProvider?.setSlots(globalSlots!);
      widget.profileDataProvider?.setAvailableSlots(selectedDays);
    }
    return true;
  }
  String getDayName(int index) {
    // Returns the day name based on the index
    List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[index];
  }
  @override
  Widget build(BuildContext context){

    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor, // Container background color
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 0.4,
            blurRadius: 0.6,
            offset: Offset(0.5, 0.8),
          ),
        ],
        borderRadius: BorderRadius.only(topLeft: Radius.circular(27),topRight: Radius.circular(27)),
        border: Border.all(
          color: Colors.grey.withOpacity(0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        children:[
          Container(
            padding: EdgeInsets.only(left: 30,top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select your availability',style: Theme.of(context).textTheme.subtitle1,),
                SizedBox(height: 5.0),
                for (int i = 0; i < 7; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        activeColor: Colors.orange,
                        value: selectedDays[i],
                        onChanged: (value) {
                          setState(() {
                            selectedDays[i] = value!;

                            // widget.profileDataProvider!.setAvailableSlots(i);
                          });
                        },
                      ),
                      InkWell(
                          onTap: (){
                            setState(() {
                              selectedDays[i] = selectedDays[i]==true?false:true;
                              // widget.profileDataProvider!.setAvailableSlots(i);
                            });
                          },
                          child: Text(getDayName(i),style: selectedDays[i]==true? TextStyle(fontSize: (14  ),color : Colors.orange, fontWeight : FontWeight.w600) : Theme.of(context).textTheme.subtitle2,)),
                    ],
                  ),
                // ElevatedButton(
                //   onPressed: () {
                //     // Handle the selected days
                //     List<String> selectedDayNames = [];
                //     for (int i = 0; i < 7; i++) {
                //       if (selectedDays[i]) {
                //         selectedDayNames.add(getDayName(i));
                //       }
                //     }
                //     print('Selected days: $selectedDayNames');
                //   },
                //   child: Text('Submit'),
                // ),
              ],
            ),
          ),
          InkWell(
            onTap: ()async{


              // updateUserTime(widget.userId!,globalStartTime!,globalEndTime!,globalSlots!);


              globalAvailable = selectedDays;
              // if(isGone){
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Text('Already Set!!'),
              //     ),
              //   );
              //   Navigator.of(context).pop();
              // }
              if(selectedDays.contains(true)==false){
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text('Please select your availability!'),
                //   ),
                // );
                Fluttertoast.showToast(
                  msg: "Please select your availability!",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                );
              }
              else if(validator()){
                // setState(() {
                //   isGone = true;
                // });
                if(widget.userId==null){
                  if(widget.profileDataProvider!=null){
                    widget.profileDataProvider?.setServide1();
                  }
                  await showDialog(context: context, builder: (BuildContext context){
                    return Container(child: CustomHelpOverlay(button:'You Are All Set', text : 'Connect', extraText: 'Thank you for choosing to help other tourists on call to plan their trips. ',navigate:'edit',imagePath: 'assets/images/profile_set.svg',serviceSettings: false,profileDataProvider:widget.profileDataProvider,onButtonPressed: (){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },onBackPressed: (){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();

                    },),);
                  },);
                  // Future.delayed(Duration(seconds: 4), () {
                  //   Navigator.of(context).pop();
                  //   Navigator.of(context).pop(); // Replace this with your desired navigation logic
                  // });

                }else{
                  if(widget.text=='edit'){
                    await updateUserTime(widget.userId!,globalStartTime!,globalEndTime!,globalSlots!,globalAvailable!);
                  }
                  else{
                    bool response = await checkUserTimeWithMeet(widget.userId!,globalStartTime!,globalEndTime!,globalAvailable!);
                    if(response){
                      await updateUserTime(widget.userId!,globalStartTime!,globalEndTime!,globalSlots!,globalAvailable!);
                    }else{}
                  }
                  // Navigator.of(context).pop();
                }
              }else{}

            },
            child: Container(
              width: screenWidth,
              alignment: Alignment.center,
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(left: 30,right:30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.orange,
              ),
              child: Text('SET TIME',style: Theme.of(context).textTheme.caption,),
            ),
          ),
          // FilledButton(
          //     backgroundColor: Colors.orange,
          //     onPressed: () {
          //     },
          //     child: Center(
          //         child: Text('SET TIME',
          //             style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.white,
          //                 fontSize: 18,fontFamily: 'Poppins')))),
        ],
      ),
    );
  }
}

class CardItem {
  final String image;
  // final String videoUrl;
  final int countVideos;
  final String location;
  final String category;
  final int viewCnt;
  final int likes;
  final String distance;

  CardItem({
    required this.image,
    required this.location,
    required this.countVideos,
    required this.category,
    required this.viewCnt,
    required this.likes,
    required this.distance,
    // required this.videoUrl,
  });
}

class PaymentSection extends StatefulWidget{
  ProfileDataProvider?profileDataProvider;
  List<CardDetails>?savedCards;
  String?text,userId;
  PaymentSection({this.profileDataProvider,this.savedCards,this.text,this.userId});

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  List<CardDetails> cards = [];

  bool cardform=false;

  @override
  void initState(){
    super.initState();
    if(widget.profileDataProvider!=null)
      widget.profileDataProvider?.setServide1();
    if(widget.savedCards!=null){
      cards = widget.savedCards!;
    }
    globalCards = [];
  }

  void saveCardsToDatabase() async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId':widget.userId,
        'cards':globalCards
      };
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/updateCards'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        // if(widget.savedCards!=null){
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text('Cards Are Updated Successfully!'),
        //     ),
        //   );
        //   Navigator.of(context).pop();
        // }else{
        //   Navigator.of(context).pop();
        //   Navigator.of(context).pop();
        //   Navigator.of(context).pop();
        //   Navigator.of(context).pop();
        // }
        // Navigator.of(context).pop();
        return;
      } else {
        print('Failed to check data: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Try Again!!'),
          ),
        );
        return;
      }
    }catch(err){
      print("Error: $err");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try Again!!'),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        // If you want to prevent the user from going back, return false
        // return false;

        // showDialog(context: context, builder: (BuildContext context){
        //   return ImagePopUpWithTwoOption(imagePath: 'assets/images/services-icon.png',textField: 'Alert !',extraText: 'Do You Want To Save Cards ? ',option1:'No',option2:'Yes',onButton1Pressed: (){
        //     // Perform action on confirmation
        //     if(widget.text=='edit'){
        //       // if(widget.savedCards!=null){
        //       //   Navigator.of(context).pop(); // Close the dialog
        //       //   Navigator.of(context).pop(); // Close the dialog
        //       // }else{
        //       //   Navigator.of(context).pop(); // Close the dialog
        //       //   Navigator.of(context).pop(); // Close the dialog
        //       //   Navigator.of(context).pop(); // Close the dialog
        //       //   Navigator.of(context).pop(); // Close the dialog
        //       // }
        //         Navigator.of(context).pop(); // Close the dialog
        //         Navigator.of(context).pop(); // Close the dialog
        //     }
        //     else{
        //       Navigator.of(context).pop(); // Close the dialog
        //       Navigator.of(context).pop(); // Close the dialog
        //       Navigator.of(context).pop(); // Close the dialog
        //       Navigator.of(context).pop(); // Close the dialog
        //     }
        //   },onButton2Pressed: () async{
        //     if(widget.text=='edit'){
        //       // if(widget.savedCards!=null){
        //       //   await showDialog(context: context, builder: (BuildContext context){
        //       //     return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
        //       //       Navigator.of(context).pop();
        //       //     },),);
        //       //   },
        //       //   );
        //       //   saveCardsToDatabase();
        //       //   Navigator.of(context).pop();
        //       // }
        //       // else{
        //       //   await showDialog(context: context, builder: (BuildContext context){
        //       //     return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
        //       //       Navigator.of(context).pop();
        //       //     },),);
        //       //   },
        //       //   );
        //       //   saveCardsToDatabase();
        //       // }
        //       saveCardsToDatabase();
        //       Navigator.of(context).pop();
        //       Navigator.of(context).pop();
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(
        //           content: Text('Cards Are Updated Successfully!'),
        //         ),
        //       );
        //     }
        //     else{
        //       // widget.profileDataProvider?.removeAllCards();
        //       showDialog(context: context, builder: (BuildContext context){
        //         return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
        //           Navigator.of(context).pop();
        //           Navigator.of(context).pop();
        //           Navigator.of(context).pop();
        //           Navigator.of(context).pop();
        //           Navigator.of(context).pop();
        //         },),);
        //       },
        //       );
        //       // Add your action here
        //       print('Action cancelled');
        //     }
        //   },);
        // },);

        // If you want to navigate directly to the homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage(userId: userID)),
        );

        return false; // Returning true will allow the user to pop the page
      },
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 90, shadowColor: Colors.transparent,title: ProfileHeader(reqPage: 3,text:'You are all set',profileDataProvider:widget.profileDataProvider,  onButtonPressed: ()async{
          if(widget.text=='edit'){
            print('6th Page');
            saveCardsToDatabase();
            await CustomPopUp(
              imagePath: "assets/images/tripPlanningHelp.svg",
              textField: "Accept trip planning calls for your expert regions to earn. connect with tourists and help them plan their future trips." ,
              extraText:' You will earn dynamically in future, for now 800 INR for 20 min of professional trip planning call.' ,
              what:'OK',
              button: 'OK, Get it',
            );
            Navigator.of(context).pop();
            // Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cards Are Updated Successfully!'),
              ),
            );
          }else{
            showDialog(context: context, builder: (BuildContext context){
              return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                // Navigator.of(context).pop();
              },),);
            },
            );
          }
        },),automaticallyImplyLeading: false,),
        body: SingleChildScrollView(
          child: Container(
            color : Theme.of(context).backgroundColor,
            height : MediaQuery.of(context).size.height,
            padding : EdgeInsets.only(left: 22, right : 22,),
            child: Column(

              children: [
                SizedBox(height: 30,),
                Container(
                    width: 357,
                    height: 25,
                    child: Text('Payments',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),)),
                SizedBox(height: 30,),
                PaymentCard(paymentCards:cards,cardForm: cardform,profileDataProvider:widget.profileDataProvider,section: widget.text,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardDetails{
  final String name;
  final String cardNo;
  int? cardChoosen;
  final String month,year,cvv;
  bool? options;

  CardDetails({
    required this.name,
    required this.cardChoosen,
    required this.cardNo,
    required this.month,
    required this.year,
    required this.cvv,
    this.options
  });
}



class PaymentCard extends StatefulWidget{
  final List<CardDetails> paymentCards;
  List<PaymentDetails>? paymentCard;
  ProfileDataProvider? profileDataProvider;
  String?section;
  bool cardForm;

  PaymentCard({required this.paymentCards,required this.cardForm,this.profileDataProvider,this.section,this.paymentCard});

  @override
  _PaymentCardState createState() => _PaymentCardState();
}


class _PaymentCardState extends State<PaymentCard> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cardNoController = TextEditingController();
  TextEditingController expMonthController = TextEditingController();
  TextEditingController expYearController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  bool isCreditCardNumberValid(String creditCardNumber) {
    // Remove any spaces or non-digit characters
    creditCardNumber = creditCardNumber.replaceAll(RegExp(r'\D'), '');

    if (creditCardNumber.isEmpty) {
      return false; // Invalid if the number is empty after removing non-digits
    }

    int sum = 0;
    bool alternate = false;

    for (int i = creditCardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(creditCardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
  bool showCards=false;
  bool cardValidator(){
    if((nameController.text.length==0)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name Field Is Empty!'),
        ),
      );
      return false;
    }
    if(!(int.parse(expMonthController.text)>=1 && int.parse(expMonthController.text)<=12)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Month Is Invalid! Kindly Choose Value Between 1 to 12'),
        ),
      );
      return false;
    }
    if(!(int.parse(expYearController.text)>=1 && int.parse(expYearController.text)<=99)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Year Is Invalid!'),
        ),
      );
      return false;
    }
    if(!(cvvController.text.length==3 || cvvController.text.length==4)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CVV Number Is Invalid'),
        ),
      );
      return false;
    }
    if(!isCreditCardNumberValid(cardNoController.text)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card Number Is Invalid!'),
        ),
      );
      return false;
    }
    return true;
  }

  String formatNumber(String number) {
    if (number.length != 16) {
      // Ensure that the number has 16 digits
      return 'Invalid number';
    }

    // Split the number into chunks of 4 digits
    List<String> chunks = [];
    for (int i = 0; i < number.length; i += 4) {
      int endIndex = i + 4;
      chunks.add(number.substring(i, endIndex));
    }

    // Join the chunks with spaces
    return chunks.join(' ');
  }

  CardDetails?editCard;
  List<CardDetails> cards=[];
  @override
  void initState(){
    print('init');
    super.initState();

  }
  @override
  Widget build (BuildContext context){
    cards = widget.paymentCards;
    print('8th Page');

    return Container(


      child: InkWell(
        onTap : (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RazorPayIntegration(),
            ),
          );
          },
        child: Container(

          child : Text('add Cards'),

        ),
      ),
    );
  }
}


class CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any non-digit characters
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Insert a space after every 4 digits
    if (newText.length > 4 && newText.length % 4 == 1) {
      newText = newText.substring(0, newText.length - 1) + ' ' + newText.substring(newText.length - 1);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
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
