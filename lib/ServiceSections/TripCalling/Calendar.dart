import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learn_flutter/UserProfile/ProfileHeader.dart';
import 'package:provider/provider.dart';

import '../../widgets/hexColor.dart';
import '../../BackendStore/BackendStore.dart';
import 'package:http/http.dart' as http;
import '../../widgets/CustomButton.dart';
import 'CalendarHelper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create:(context) => ProfileDataProvider(),
    child: ProfileApp(),
  ),
  );
}

class ProfileApp extends StatelessWidget {
  String? currentUser,clickedUser;
  @override
  Widget build(BuildContext context) {
    final profileDataProvider = Provider.of<ProfileDataProvider>(context);
    return MaterialApp(
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      home: CalendarPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalendarPage extends StatefulWidget{
  String currentUser = '652a578b7ff9b6023a1483ba' , clickedUser = '652b2cfe59629378c2c7dacb';
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>{
  Map<String, dynamic>? clickedUserDataSet,currentUserDataSet;
  @override
  void initState() {
    super.initState();
    fetchDatasets(widget.clickedUser,clickedUserDataSet);
    fetchDatasets(widget.currentUser,currentUserDataSet);
  }
  Future<void> fetchDatasets(userId,dataset) async {
    final String serverUrl = 'http://192.168.53.54:8080'; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Path ${data}');
      setState(() {
        if(dataset==clickedUserDataSet)
            clickedUserDataSet = data;
        else
          currentUserDataSet = data;
      });
    } else {
      // Handle error
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ProfileHeader(reqPage: 1),),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CallTime(clickedUserDataSet:clickedUserDataSet),
            CalendarCheck(plans:clickedUserDataSet?['userServiceTripCallingData']['dayPlans'],slotChoosen:clickedUserDataSet?['userServiceTripCallingData']['slotsChossen']),
            TimeSet(),
          ],
        ),
      ),
    );
  }
}

class CallTime extends StatefulWidget{
  Map<String, dynamic>? clickedUserDataSet;
  CallTime({this.clickedUserDataSet});
  @override
  _CallTimeState createState() => _CallTimeState();
}

ServiceTripCallingData? parseServiceTripCallingData(Map<String, dynamic>? data) {
  return ServiceTripCallingData(
    setStartTime: data?['startTimeFrom'] as String?,
    setEndTime: data?['endTimeTo'] as String?,
    slots: data?['slotsChossen'] as String?,
  );
}

class _CallTimeState extends State<CallTime>{
  @override
  Widget build(BuildContext context) {
    ServiceTripCallingData? userDataSet = parseServiceTripCallingData(widget.clickedUserDataSet?['userServiceTripCallingData']);
    return Column(
      children: [
        Column(
          children: [
            Text('Schedual Call With',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
            Text("${widget.clickedUserDataSet!=null ?widget.clickedUserDataSet!['userName']:'Wait...'}"),
          ],
        ),
        Column(
          children: [
              Text('User provided available time for trip \n planning interaction calls -',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight:FontWeight.bold),),
              Text('${userDataSet?.setStartTime} - ${userDataSet?.setEndTime}'),
          ],
        ),
      ],
    );
  }
}


class CalendarCheck extends StatefulWidget{
  Map<String,dynamic>? plans;
  String?slotChoosen;
  CalendarCheck({this.plans,this.slotChoosen});

  @override
  _CalendarCheckState createState() => _CalendarCheckState();
}

String getThreeLetterMonth(int monthNumber) {
  if (monthNumber < 1 || monthNumber > 12) {
    return ''; // Handle invalid month numbers
  }

  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  return months[monthNumber - 1];
}

class _CalendarCheckState extends State<CalendarCheck>{

  String? selectedDate;
  bool showCalendar =false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        CustomDOBDropDown(
          label: 'Select Date',
          selectedDate: selectedDate,
          deviceWidth: screenWidth*0.60,
          onDateSelected: widget.slotChoosen=='choice_1'?((DateTime? newDate) {
            setState(() {
              selectedDate = ('${newDate?.day}/${getThreeLetterMonth(newDate!.month)}');
              showCalendar = !showCalendar;
              print('Selected: ${newDate}');
            });
          })
          :((DateTime? newDate) {
            // Check if the selected date is a weekend day (Saturday or Sunday)
            if (newDate != null &&
                (newDate.weekday == DateTime.saturday ||
                    newDate.weekday == DateTime.sunday)) {
              setState(() {
                selectedDate = ('${newDate.day}/${getThreeLetterMonth(newDate.month)}');
                showCalendar = true;
                print('Selected: ${newDate}');
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select a weekend day.'),
                ),
              );
            }
          }),
        ),
        showCalendar
          ?Column(
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarHelper(plans:widget.plans,choosenDate:selectedDate!),
                    ),
                  );
                },
                child: Row(
                children: [
                  Text('Check User Calendar',style: TextStyle(fontSize: 14,color: HexColor('FB8C00'),fontWeight: FontWeight.bold),),
                  Icon(Icons.arrow_forward_ios,color: HexColor('FB8C00'),size: 10,),
                  ],
                ),
              ),
              Text('*Calendar will help you to select the time \n for interaction with the user.',style: TextStyle(color: HexColor('#FF0000')),)
            ],
          )
          :SizedBox(height: 0,),
      ],
    );
  }
}



class CustomDOBDropDown extends StatelessWidget{
  final String label;
  final String? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  double deviceWidth;

  CustomDOBDropDown({
    required this.label,
    required this.onDateSelected,
    required this.selectedDate,
    required this.deviceWidth,
  });

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
        SizedBox(height: 10,),
        InkWell(
          onTap: () async {
            DateTime? selected = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            onDateSelected(selected);

          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.grey), // Border style
              borderRadius: BorderRadius.circular(5.0), // Rounded corners
            ),
            width: deviceWidth*0.86,
            height: 55,
            child: Padding(
              padding: const EdgeInsets.only(left: 11.0,right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.calendar_today_rounded,color: HexColor('#FB8C00'),), // Calendar icon
                  Text(
                    selectedDate != null
                        ? "${selectedDate}"
                        : '15/Nov',
                    style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                  Icon(Icons.arrow_drop_down_circle,color: HexColor('#FB8C00'),),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}




class TimeSet extends StatefulWidget{
  @override
  _TimeSetState createState() => _TimeSetState();
}

class _TimeSetState extends State<TimeSet>{
  TimeOfDay _startTime = TimeOfDay(hour: 18, minute: 0);
  @override


  void checkSetDate_Time () async{
    print('Status');
    try {
      final String serverUrl = 'http://192.168.53.54:8080'; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId':'652b2cfe59629378c2c7dacb',
        'chosenDate':"15/Nov" ,
        'chosenStartTime':'8:20PM',
        'chosenEndTime':'8:40PM'
      };
      final http.Response response = await http.post(
        Uri.parse('$serverUrl/checkMeetingTime'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Data Validator Condition : ${responseData}');
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }
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
        // widget.profileDataProvider?.setStartTime(_formatTime(pickedTime));
        print(pickedTime);
        // print("Start Time: ${_formatTime(_startTime)}");
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

  String addMinutesToTime(String timeString, int minutesToAdd) {
    // Split the input time string into components
    List<String> timeComponents = timeString.split(' ');
    if (timeComponents.length != 2) {
      return 'Invalid date format';
    }

    String timePart = timeComponents[0]; // "6:00"
    String amPmPart = timeComponents[1]; // "PM" or "AM"

    // Parse the time part into hours and minutes
    List<String> timeParts = timePart.split(':');
    if (timeParts.length != 2) {
      return 'Invalid date format';
    }

    int hours = int.tryParse(timeParts[0]) ?? 0;
    int minutes = int.tryParse(timeParts[1]) ?? 0;

    // Convert AM/PM time to 24-hour format
    if (amPmPart == 'PM' && hours < 12) {
      hours += 12;
    } else if (amPmPart == 'AM' && hours == 12) {
      hours = 0;
    }

    // Calculate the new time
    DateTime originalTime = DateTime(2000, 1, 1, hours, minutes);
    DateTime newTime = originalTime.add(Duration(minutes: minutesToAdd));

    // Format the new time as a string in the desired format
    String newTimeString = '${newTime.hour>12?newTime.hour-12:newTime.hour}:${newTime.minute.toString().padLeft(2, '0')}';
    if (newTime.hour >= 12) {
      newTimeString += 'PM';
    } else {
      newTimeString += 'AM';
    }

    return newTimeString;
  }
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        Row(
          children: [
            Container(
              child: Image.asset('assets/images/clock.png',width: 35,height: 35,),
            ),
            Text('${_formatTime(_startTime)} - ${addMinutesToTime(_formatTime(_startTime),20)} India'),
          ],
        ),
        Container(
          width: 326,
          height: 53,
          child: FiledButton(
              backgroundColor: HexColor('#FB8C00'),
              onPressed: () {
                checkSetDate_Time();
              },
              child: Center(
                  child: Text('Request Call',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18)))),
        ),
      ],
    );
  }
}
