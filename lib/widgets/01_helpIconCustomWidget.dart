import 'dart:convert';
// import 'dart:html';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/CalendarHelper.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:learn_flutter/Settings.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/slider.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:learn_flutter/widgets/sample.dart';
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
        }else
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
              SizedBox(height: 16),
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
                      navigate == 'pop') {
                    onButtonPressed!();

                  } else if (navigate == 'pings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PingsSection(
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


  @override
  Widget build(BuildContext context) {
    if(widget.data!=null){
      startTime = widget.data?.setStartTime;
      endTime = widget.data?.setEndTime;
      slots = widget.data?.slots;
      globalStartTime = startTime;
      globalEndTime = endTime;
      globalSlots = slots;
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
        appBar:AppBar(title: ProfileHeader(reqPage: 0,userId: widget.userId,text: widget.profileDataProvider==null?'':'calendar',),automaticallyImplyLeading: false,shadowColor: Colors.transparent, toolbarHeight: 90,),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              color : Theme.of(context).backgroundColor,
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      Container(
                        width:318,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height : 40),
                            Text('Timing for interaction calls',style: Theme.of(context).textTheme.subtitle1,),
                            Text('Select Your Time',style: Theme.of(context).textTheme.subtitle1,)
                          ],
                        ),
                      ),
                      TimePicker(profileDataProvider:widget.profileDataProvider,startTime:startTime,endTime:endTime),
                      SizedBox(height : 50),
                      BandWidthSelect(text:widget.text,profileDataProvider:widget.profileDataProvider,slots:slots,userId:widget.userId,haveCards:widget.haveCards,onButtonPressed:widget.onButtonPressed),

                    ],
                  ),
            ),
          ),
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
      initialEntryMode: TimePickerEntryMode.dialOnly,
      context: context, initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(

          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child:Theme(
            data: Theme.of(context).copyWith(
            // Modify the TimePickerThemeData here
            // primaryTextTheme: TextTheme(),
            timePickerTheme: TimePickerThemeData(
              padding:EdgeInsets.all(10),
              entryModeIconColor: Theme.of(context).primaryColor,
               helpTextStyle: TextStyle(fontSize: 16,color: Theme.of(context).primaryColor,fontFamily: 'Poppins',fontWeight: FontWeight.bold),
               dialBackgroundColor: Theme.of(context).primaryColor,
            dialTextColor: Theme.of(context).backgroundColor,
             dialTextStyle: Theme.of(context).textTheme.headline5,
            dialHandColor:Colors.white.withOpacity(0.5),
            backgroundColor: Theme.of(context).backgroundColor, // Background color of the picker
            hourMinuteTextStyle: Theme.of(context).textTheme.headline1,
            hourMinuteTextColor: Colors.white, // Text color for hour and minute
            // dialHandColor: Colors.orange.withOpacity(0.2), // Color of the dial hand
            hourMinuteColor: Theme.of(context).primaryColor, // Color of the hour and minute hands
            dayPeriodTextColor: Colors.white, // Text color for AM/PM
            dayPeriodColor:Theme.of(context).primaryColor, // Color of AM/PM indicator
            dayPeriodTextStyle: Theme.of(context).textTheme.headline2,
              // shape: ShapeBorder().dimensions,
              // Add other properties as needed
            ),
            ),
        child: Column(
          children: [
            SizedBox(height: 10,),
            TextButtonTheme(
            data: TextButtonThemeData(
            style: ButtonStyle(
            // Style the Cancel button
              textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline5),
            foregroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor), // Text color// Background color
            // Add other styles for the OK button
            ),
            ),
            child: child!,),
          ],
        )
        ));
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
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,color : Theme.of(context).primaryColor),
                    ),
                    SizedBox(width: 6,),
                    Container(

                      padding: EdgeInsets.all(5),
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
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,color : Theme.of(context).primaryColor),
                    ),
                    SizedBox(width: 6,),
                    Container(

                      padding: EdgeInsets.all(5),
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
  final String?slots,userId,text;
  VoidCallback? onButtonPressed;
  bool?haveCards;
  BandWidthSelect({this.profileDataProvider,this.slots,this.userId,this.haveCards,this.text,this.onButtonPressed});
  @override
  _BandWidthSelectState createState() => _BandWidthSelectState();
}

class _BandWidthSelectState extends State<BandWidthSelect>{
  String _radioValue='choice_1';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your Time Is Set :) '),
          ),
        );
        if(widget.haveCards==false){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentSection(text:widget.text,userId:userID)));
          widget.onButtonPressed!();
        }
        else if(widget.text=='edit'){
          showDialog(context: context, builder: (BuildContext context){
            return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Navigator.of(context).pop();
              // Navigator.of(context).pop();
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
    if((globalStartTime)==null || (globalEndTime)==null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your timing!'),
        ),
      );
      return false;
    }
    if(globalSlots==null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your slots!'),
        ),
      );
      return false;
    }
    if(isTimeDifferenceGreaterThan30Minutes(globalStartTime!,globalEndTime!) ==false){
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Give a PopUp'),
        ),
      );
      return false;
    }
    if(widget.profileDataProvider!=null){
      widget.profileDataProvider?.setStartTime(globalStartTime!);
      widget.profileDataProvider?.setEndTime(globalEndTime!);
      widget.profileDataProvider?.setSlots(globalSlots!);
    }
    return true;
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
                      });
                      if(widget.slots==null){
                        widget.profileDataProvider?.setSlots(_radioValue);
                        globalSlots = _radioValue;
                      }
                      else {
                        globalSlots = _radioValue;
                      }
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
                      });
                      if(widget.slots==null){
                        widget.profileDataProvider?.setSlots(_radioValue);
                        globalSlots = _radioValue;
                      }
                      else {
                        globalSlots = _radioValue;
                      }
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
                  // if(isGone){
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       content: Text('Already Set!!'),
                  //     ),
                  //   );
                  //   Navigator.of(context).pop();
                  // }
                  if(validator()){
                    // setState(() {
                    //   isGone = true;
                    // });
                    if(widget.userId==null){
                    // Navigator.of(context).pop();
                    //   if(widget.profileDataProvider!=null){
                    //     widget.profileDataProvider?.setServide1();
                    //   }
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentSection(profileDataProvider:widget.profileDataProvider)));
                    }else{
                      updateUserTime(widget.userId!,globalStartTime!,globalEndTime!,globalSlots!);
                      // Navigator.of(context).pop();
                    }
                  }else{}

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
  bool buttonPressed = false;

  bool cardform=false;

  @override
  void initState(){
    super.initState();
    if(widget.profileDataProvider!=null && widget.text==null)
      widget.profileDataProvider?.setServide1();
    if(widget.savedCards!=null){
      cards = widget.savedCards!;
    }
    globalCards = [];
  }

  Future<void> saveCardsToDatabase() async{
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
        if(widget.text=='edit'){
          await saveCardsToDatabase();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage(userId: userID)),
          );
          return false;
        }
        else{
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              Future.delayed(Duration(seconds: 2), () {
                if (!buttonPressed) {
                  // If the button was not pressed within 2 seconds, navigate to the home page
                  if(widget.text==null){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              });

              return Container(
                child: CustomHelpOverlay(
                  button: 'You Are All Set',
                  text: 'Set your clock',
                  extraText: 'Thank you for choosing to help other tourists on call to plan their trips.',
                  navigate: 'pop',
                  imagePath: 'assets/images/you_are_all_set.svg',
                  serviceSettings: false,
                  onButtonPressed: () {
                    // Set the flag to indicate that the button was pressed
                    buttonPressed = true;

                    // Your button pressed action
                    if(widget.text==null){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  onBackPressed: () {
                    // Set the flag to indicate that the button was pressed
                    buttonPressed = true;

                    // Your back pressed action
                    if(widget.text==null){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          );
          return true;
        }
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    showCards = widget.cardForm;
    if(widget.paymentCards!=null  && widget.paymentCards.length>0){
      cards = widget.paymentCards;
      for(int i=0;i<widget.paymentCards.length;i++){
        CardDetails card = widget.paymentCards[i];
        globalCards!.add(PaymentDetails(
          name: card.name, // Get this from user input
          month: card.month, // Get this from user input
          year: card.year, // Get this from user input
          cardNo: card.cardNo, // Get this from user input
          cvv: card.cvv, // Get this from user input
        ));
      }
    }
  }
  @override
  Widget build (BuildContext context){
    cards = widget.paymentCards;
    print('8th Page');
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
                children:List.generate(cards.length, (index) {
                  return GestureDetector(
                    onTap: (){
                      print('1');
                      if(cards[index].options!=null){
                        setState(() {
                          cards[index].options = !(cards[index].options!);
                        });
                      }
                    },
                    child: Container(
                      width: 357,
                      height: cards[index].options!=null && cards[index].options==true?192:102,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border:Border.all(
                          color: HexColor('#F5F5F5'),width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width:215,
                                height: 50,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formatNumber(cards[index].cardNo),style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                                    Text(cards[index].name,style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                                  ],
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 59,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children:[
                                    cards[index].cardChoosen==1?
                                    Image.asset('assets/images/mastercard.png',width: 40,height: 30,)
                                        :cards[index].cardChoosen==2?
                                    Image.asset('assets/images/visa.png',width: 40,height: 30,)
                                        :Image.asset('assets/images/visa.png',width: 40,height: 30,),
                                    index==0?
                                    Text('Primary',style: TextStyle(fontSize: 12,fontFamily: 'Poppnis'),)
                                        :Icon(Icons.arrow_forward_ios,color:HexColor('#00559B'),size: 12,),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          cards[index].options!=null && cards[index].options==true
                              ?Container(
                                  height: 27,
                                width: 357,
                                child: Row(
                                  mainAxisAlignment:MainAxisAlignment.spaceEvenly ,
                            children: [
                                GestureDetector(
                                  child: Text('Edit',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),),
                                  onTap: (){
                                    setState(() {
                                      nameController.text = cards[index].name;
                                      cardNoController.text = cards[index].cardNo;
                                      expMonthController.text = cards[index].month;
                                      expYearController.text = cards[index].year;
                                      cvvController.text = cards[index].cvv;
                                      showCards = !showCards;
                                    });
                                    if(widget.section=='edit'){
                                      globalCards!.removeAt(index);
                                    }
                                    else widget.profileDataProvider!.removeCard(index);
                                    editCard = CardDetails(name: nameController.text, cardChoosen: 1, cardNo: cardNoController.text,month:expMonthController.text,year: expYearController.text,cvv:cvvController.text,options: false);
                                    widget.paymentCards.removeAt(index);
                                  },
                                ),
                                Text('|',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: HexColor('#FB8C00'))),
                                GestureDetector(
                                    onTap: (){
                                      if(widget.section=='edit'){
                                        print('removed');
                                        globalCards!.removeAt(index);
                                      }
                                      else widget.profileDataProvider!.removeCard(index);
                                      setState(() {
                                        widget.paymentCards.removeAt(index);
                                      });
                                    },
                                    child: Text('Remove',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: HexColor('#FB8C00')))),
                            ],
                          ),
                              )
                              :SizedBox(width: 0,),
                        ],
                      ),
                    ),
                  );
                })
            ),
          ),

          showCards
              ? Container(
            // width: 357,
            // height: 683, 
            padding: EdgeInsets.only(left:15,right:15),
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.black,width: 1,
            //   ),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height:20,),
                Container(
                  width: 218,
                  height: 58,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Debit/Credit/ATM Card',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Container(
                        width: 126,
                        height: 22,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/mastercard.png',width: 40,height: 30,),
                            Image.asset('assets/images/visa.png',width: 40,height: 30,),
                            Image.asset('assets/images/american_express.jpg',width: 40,height: 30,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height:20,),
                Container(
                  width: 324,
                  height: 497,
                  // decoration: BoxDecoration(
                  //     border: Border.all(
                  //       color: Colors.black,
                  //       width: 1,
                  //     )
                  // ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width:323,
                        height:90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cardholder Name'),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: 'Name On Card',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                ), // Add an outline border
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 323,
                        height: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Card Number'),
                            TextFormField(
                              controller: cardNoController,
                              inputFormatters: [
                                CreditCardFormatter(),
                              ],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0000 0000 0000 0000',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                ), // Add an outline border
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 323,
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Expiration date'),
                            Container(
                              width: 189,
                              height: 53,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:72,
                                    height: 53,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: expMonthController,
                                      decoration: InputDecoration(
                                        hintText: 'MM',
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                        ), // Add an outline border
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(height: 15,),
                                      Text('/',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                    ],
                                  ),
                                  Container(
                                    width: 72,
                                    height: 53,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: expYearController,
                                      decoration: InputDecoration(
                                        hintText: 'YY',
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                        ), // Add an outline border
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 323,
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('CVV'),
                            Container(
                              width:143,
                              height:53,
                              child: TextFormField(
                                controller: cvvController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '000   or   0000',
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                  ), // Add an outline border
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 322,
                        height: 63,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: (){
                                if(editCard!=null){
                                  widget.paymentCards.add(editCard!);
                                  if(widget.profileDataProvider!=null){
                                    PaymentDetails newPayment = PaymentDetails(
                                      name: nameController.text, // Get this from user input
                                      month: expMonthController.text, // Get this from user input
                                      year: expYearController.text, // Get this from user input
                                      cardNo: cardNoController.text, // Get this from user input
                                      cvv: cvvController.text, // Get this from user input
                                    );
                                    widget.profileDataProvider!.addCardDetails(newPayment);
                                  }
                                  else{
                                    globalCards!.add(PaymentDetails(
                                      name: nameController.text, // Get this from user input
                                      month: expMonthController.text, // Get this from user input
                                      year: expYearController.text, // Get this from user input
                                      cardNo: cardNoController.text, // Get this from user input
                                      cvv: cvvController.text, // Get this from user input
                                    ));
                                  }
                                  editCard = null;
                                }
                                setState(() {
                                  nameController.text = '';
                                  cardNoController.text = '';
                                  expMonthController.text = '';
                                  expYearController.text = '';
                                  cvvController.text = '';
                                  showCards = !showCards;
                                });
                              },
                              child: Container(
                                  width: 156,
                                  height: 63,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: HexColor('#FB8C00'),
                                    ),
                                  ),
                                  child: Center(child: Text('Cancel',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: HexColor('#FB8C00'),fontFamily: 'Poppins'),))
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                if(cardValidator()){
                                  PaymentDetails newPayment = PaymentDetails(
                                    name: nameController.text, // Get this from user input
                                    month: expMonthController.text, // Get this from user input
                                    year: expYearController.text, // Get this from user input
                                    cardNo: cardNoController.text, // Get this from user input
                                    cvv: cvvController.text, // Get this from user input
                                  );
                                  print(widget.section);
                                  if(widget.section=='edit') {
                                    globalCards!.add(newPayment);
                                  }
                                  else {
                                    widget.profileDataProvider!.addCardDetails(newPayment);
                                  }
                                  if(editCard!=null){
                                    editCard = null;
                                  }
                                  setState(() {
                                    widget.paymentCards.add(CardDetails(name: nameController.text, cardChoosen: 1, cardNo: cardNoController.text,month:expMonthController.text,year: expYearController.text,cvv:cvvController.text,options: false));
                                    nameController.text = '';
                                    cardNoController.text = '';
                                    expMonthController.text = '';
                                    expYearController.text = '';
                                    cvvController.text = '';
                                    showCards = !showCards;
                                  });
                                }
                              },
                              child: Container(
                                  width: 156,
                                  height: 63,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: HexColor('#FB8C00'),
                                  ),
                                  child: Center(child: Text('SAVE',style: TextStyle(fontSize: 16,fontFamily: 'Popppins',fontWeight: FontWeight.bold,color: Colors.white),))
                              ),
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ],
            ),
          )
              : GestureDetector(
            onTap: (){
              setState(() {
                showCards = !showCards;
              });
            },
            child: Container(
              width: 357,
              height: 140,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  )
              ),
              child: Row(
                children: [
                  SizedBox(width: 30,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Add Debit/Credit/ATM Card',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Text('You can save your cards as per new RBI \nguidelines.',style: TextStyle(fontFamily: 'Poppins',fontSize: 14,),),
                      Row(
                        children: [
                          Text('Learn More',style: TextStyle(fontSize: 12,fontWeight:FontWeight.bold,color:HexColor('#00559B')),),
                          Icon(Icons.arrow_forward_ios_outlined,size:14,color: HexColor('#00559B'),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // widget.paymentCards.length>0
          // ? Container(
          // ? Container(
          //     width: 326,
          //     height: 53,
          //     margin: EdgeInsets.only(top: screenHeight * 0.2 ),
          //     child: FiledButton(
          //     backgroundColor: HexColor('#FB8C00'),
          //     onPressed: () {
          //         showDialog(context: context, builder: (BuildContext context){
          //           return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
          //             Navigator.of(context).pop();
          //             // Navigator.of(context).pop();
          //             // Navigator.of(context).pop();
          //             Navigator.of(context).pop();
          //             if(widget.profileDataProvider!=null){
          //               widget.profileDataProvider?.setServide1();
          //             }
          //           },),);
          //         },
          //       );
          //     },
          //     child: Center(
          //       child: Text('Set Cards',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18)))),
          //   )
          // :SizedBox(height: 0,),
        ],
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
