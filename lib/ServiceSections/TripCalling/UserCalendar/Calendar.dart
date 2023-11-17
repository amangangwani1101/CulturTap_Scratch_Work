import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learn_flutter/UserProfile/ProfileHeader.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:provider/provider.dart';


import '../../../widgets/01_helpIconCustomWidget.dart';
import '../../../widgets/hexColor.dart';
import '../../../BackendStore/BackendStore.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/CustomButton.dart';
import './CalendarHelper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create:(context) => ProfileDataProvider(),
    child: ProfileApps(),
  ),
  );
}

class ProfileApps  extends StatelessWidget {
  String? currentUser,clickedUser;
  @override
  Widget build(BuildContext context) {
    final profileDataProvider = Provider.of<ProfileDataProvider>(context);
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      home: CalendarPage(clickedUser: '655558c9bbfaf0599da445e9',currentUser: Constant().receiversId,),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalendarPage extends StatefulWidget{
  String currentUser,clickedUser;
  CalendarPage({required this.clickedUser,required this.currentUser});
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
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('DataSet :::  ${data['_id']}');
      setState(() {
        if(data['_id']==widget.clickedUser)
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
      appBar: AppBar(title: ProfileHeader(reqPage: 1,userId:widget.currentUser),automaticallyImplyLeading: false,),
      body: SingleChildScrollView(
        child: Container(
          width: 390,
          // decoration: BoxDecoration(
          //   border:Border.all(
          //     width: 1,
          //   ),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40,),
              CallTime(clickedUserDataSet:clickedUserDataSet),
              SizedBox(height: 33,),
              CalendarCheck(plans:clickedUserDataSet?['userServiceTripCallingData']['dayPlans']
                  ,slotChoosen:clickedUserDataSet?['userServiceTripCallingData']['slotsChossen']
                  ,userStartTime:clickedUserDataSet?['userServiceTripCallingData']['startTimeFrom']
                  ,userEndTime:clickedUserDataSet?['userServiceTripCallingData']['endTimeTo'],
                   id:widget.currentUser,userName:clickedUserDataSet?['userName'],userPhoto:clickedUserDataSet?['userPhoto']
                  ,uName:currentUserDataSet?['userName'],uPhoto:currentUserDataSet?['userPhoto'],id2:widget.clickedUser),
            ],
          ),
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
  String ? country = 'India';
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ServiceTripCallingData? userDataSet = parseServiceTripCallingData(widget.clickedUserDataSet?['userServiceTripCallingData']);
    return Container(
      height: 144,
      // decoration: BoxDecoration(
      //   border:Border.all(
      //     width: 1,
      //   ),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: screenWidth*0.77,
              // decoration: BoxDecoration(
              //   border:Border.all(
              //     width: 1,
              //   ),
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Schedual Call With',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                  Text("${widget.clickedUserDataSet!=null ?widget.clickedUserDataSet!['userName']:'Wait...'}"),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: screenWidth*0.77,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text('User provided available time for trip \nplanning interaction calls -',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight:FontWeight.bold),),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        Image.asset('assets/images/clock.png',width: 22,height: 22,),
                        SizedBox(width: 5,),
                        Text('${userDataSet?.setStartTime} - ${userDataSet?.setEndTime} ${country} (${userDataSet?.slots=='choice_1'?'Daily':'Weekly'})'),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class CalendarCheck extends StatefulWidget{
  Map<String,dynamic>? plans;
  String?slotChoosen;
  String ?id,id2;
  String ?userStartTime,userEndTime,userName,userPhoto,uName,uPhoto;
  CalendarCheck({this.plans,this.slotChoosen,this.userEndTime,this.userStartTime,this.id,this.userName,this.userPhoto,this.uName,this.uPhoto,this.id2});

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

  String? selectedDate,sendDate;
  bool showCalendar =false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      // decoration: BoxDecoration(
      //   border:Border.all(
      //     width: 1,
      //   ),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: screenWidth*0.09,),
              CustomDOBDropDown(
                label: 'Select Date',
                selectedDate: selectedDate,
                deviceWidth: screenWidth*0.60,
                onDateSelected: widget.slotChoosen=='choice_1'?((DateTime? newDate) {
                  setState(() {
                    String cmp = getThreeLetterMonth(newDate!.month);
                    selectedDate = ('${newDate?.day}/${cmp.toUpperCase()}');
                    sendDate = ('${newDate?.day}/${cmp}/${newDate!.year}');
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
                      selectedDate = ('${newDate?.day}/${getThreeLetterMonth(newDate!.month)}');
                      sendDate = ('${newDate?.day}/${getThreeLetterMonth(newDate!.month)}/${newDate!.year}');
                      showCalendar = true;
                      print('Selected: ${newDate}');
                    });
                  } else if(newDate!=null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a weekend day.'),
                      ),
                    );
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a date.'),
                      ),
                    );
                  }
                }),
              ),
            ],
          ),
          showCalendar? SizedBox(height: 30,): SizedBox(height: 0,),
          showCalendar
            ?Center(
              child: Container(
              width: screenWidth*0.77,
                height: 94,
                // decoration: BoxDecoration(border: Border.all(width: 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CalendarHelper(plans:widget.plans,choosenDate:sendDate!,startTime:widget.userStartTime!,endTime:widget.userEndTime!,slotChossen: widget.slotChoosen!,date:selectedDate!),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text('Check User Calendar',style: TextStyle(fontSize: 12,color: HexColor('FB8C00'),fontWeight: FontWeight.bold),),
                        Icon(Icons.arrow_forward_ios,color: HexColor('FB8C00'),size: 15,),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Text('*Calendar will help you to select the time \n for interaction with the user.',style: TextStyle(color: HexColor('#FF0000')),)
                  ],
                ),
              ),
            )
            :SizedBox(height: 0,),
            SizedBox(height: 20,),
            TimeSet(setDate:sendDate,userStartTime:widget.userStartTime,userEndTime:widget.userEndTime,plans:widget.plans,id:widget.id,id2:widget.id2,userName:widget.userName,userPhoto:widget.userPhoto,user2Name:widget.uName,user2Photo:widget.uPhoto),
        ],
      ),
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

  DateTime currentDate = DateTime.now();
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
              firstDate: DateTime(currentDate.year-1),
              lastDate:  DateTime(currentDate.year+5),
            );
            onDateSelected(selected);

          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.white60), // Border style
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              color: HexColor('#FB8C00'),
            ),
            width: deviceWidth*0.60,
            height: 45,
            child: Padding(
              padding: const EdgeInsets.only(left: 0.0,right: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.calendar_today_rounded,color: Colors.white,), // Calendar icon
                  Text(
                    selectedDate != null
                        ? "${selectedDate}"
                        : '15/NOV',
                    style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: Colors.white),),
                  Image.asset('assets/images/arrow_down.png',color: Colors.white,),
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
  String? setDate,userStartTime,userEndTime,userName,userPhoto,user2Name,user2Photo;
  Map<String,dynamic>? plans;
  String?id,id2;
  TimeSet({this.setDate,this.userEndTime,this.userStartTime,this.plans,this.id,this.userName,this.userPhoto,this.user2Name,this.user2Photo,this.id2});
  @override
  _TimeSetState createState() => _TimeSetState();
}

class _TimeSetState extends State<TimeSet>{
  TimeOfDay _startTime = TimeOfDay(hour: 18, minute: 0);
  String ?startTime,endTime;
  bool timeOverlap = false;
  final TextEditingController _meetingEditingController = TextEditingController();
  @override

  void checkSetDate_Time () async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId':widget.id,
        'chosenDate':widget.setDate ,
        'chosenStartTime':startTime,
        'chosenEndTime':endTime,
      };
      print('11::${data}');
      final http.Response response = await http.post(
        Uri.parse('$serverUrl/checkMeetingTime'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        if(!responseData['isOverlap']){
          print('Very Good');
          showDialog(context: context, builder: (BuildContext context){
            return Container(child: CustomHelpOverlay(imagePath: 'assets/images/request_call_sent.png',text:'Pings',navigate:'pings',helper:widget.id),);
          },
          );
          saveMeetingSchedule();
        }else{
          showDialog(context: context, builder: (BuildContext context){
            return Container(child: CustomHelpOverlay(imagePath: 'assets/images/request_call_dialog_box.png',text:'Check  User  Calendar',navigate:'calendarhelper',helper:widget.plans),);
          },
          );
          print('isOverlapping change data');
          setState(() {});
        }
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }
  }
  String meetingId="";
  void saveMeetingSchedule () async{
    print('Status');
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'sendersId':widget.id,
        'receiversId':widget.id2 ,
        'scheduledDay':widget.setDate,
        'chosenStartTime':startTime,
        'chosenEndTime':endTime,
        'meetingTitle':_meetingEditingController.text,
        'conversation':null,
        'sendersFeedback':null,
        'receiversFeedback':null,
      };
      print('22::${data}');
      print('Aman ${_meetingEditingController.text}');
      final http.Response response = await http.post(
        Uri.parse('$serverUrl/scheduleMeeting'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        meetingId = responseData['_id'];
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }

    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': widget.id,
        'date':widget.setDate,
        'startTime' : startTime,
        'endTime' : endTime,
        'meetingId':meetingId,
        'meetingStatus' : 'pending',
        'meetingTitle':_meetingEditingController.text,
        'id':widget.id2,
        'meetingType' : 'sender',
        'userName':widget.userName,
        'userPhoto':widget.userPhoto==null?'':widget.userPhoto,
    };
      print('33::${data}');
      final http.Response response = await http.post(
        Uri.parse('$serverUrl/updateUserDayPlans'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }

    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': widget.id2,
        'date':widget.setDate,
        'startTime' : startTime,
        'endTime' : endTime,
        'meetingId':meetingId,
        'meetingStatus' : 'choose',
        'meetingTitle':_meetingEditingController.text,
        'id':widget.id ,
        'meetingType' : 'receiver',
        'userName':widget.user2Name,
        'userPhoto':widget.user2Photo==null?'':widget.user2Photo,
      };
      print('44::${data}');
      final http.Response response = await http.post(
        Uri.parse('$serverUrl/updateUserDayPlans'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }
  }



  bool isTimeInSlot(String userSlotStartTime, String userSlotEndTime, String chosenTime, String endTime) {
    DateTime now = DateTime.now();
    print('${userSlotStartTime},${userSlotEndTime},${chosenTime},${endTime}');
    DateTime slotStartDateTime = _parseTime(now, userSlotStartTime);
    DateTime slotEndDateTime = _parseTime(now, userSlotEndTime);
    DateTime chosenDateTime = _parseTime(now, chosenTime);
    DateTime endDateTime = _parseTime(now, endTime);
    print('${slotStartDateTime},${slotEndDateTime},${chosenDateTime},${endDateTime}');

    if ((chosenDateTime.isAfter(slotStartDateTime) || chosenDateTime.isAtSameMomentAs(slotStartDateTime))  &&
        (endDateTime.isBefore(slotEndDateTime)|| (endDateTime.isAtSameMomentAs(slotEndDateTime)))) {
      return true; // Both chosen time and end time are within the slot
    } else {
      return false; // Either chosen time or end time is not within the slot
    }
  }
  // ScaffoldMessenger.of(context).showSnackBar(
  // SnackBar(
  // content: Text('Please select a weekend day.'),
  // ),
  // );
  DateTime _parseTime(DateTime date, String time) {
    final hourMinute = time.replaceAll(RegExp('[a-zA-Z]+'), '').split(':');
    final isPM = time.contains('PM');
    var hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);

    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
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
        startTime = _formatTime(_startTime);
        endTime = addMinutesToTime(_formatTime(_startTime),20);
        bool val = isTimeInSlot(widget.userStartTime!,widget.userEndTime!,startTime!,endTime!);
        timeOverlap = val;
        print(val);
        if(!timeOverlap){
          startTime = '';
        }
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
      newTimeString += ' PM';
    } else {
      newTimeString += ' AM';
    }

    return newTimeString;
  }
  Widget build(BuildContext context){
  final screenWidth = MediaQuery.of(context).size.width;
  return Center(
    child: Container(
        width: screenWidth*0.91,
        // decoration: BoxDecoration(border: Border.all(width: 1)),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: screenWidth*0.07,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set Time',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                    SizedBox(height: 4,),
                    Text('Note : the call duration will be  for 20 min so \nmake sure that your questions are planned.',style: TextStyle(fontSize: 13,fontFamily: 'Poppins'),)
                  ],
                ),
              ],
            ),
            SizedBox(height: 12,),
            Container(
              width: 315,
              height: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Meeting Title',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                  TextField(
                    style: TextStyle(fontStyle: FontStyle.italic,fontSize: 14),
                    controller: _meetingEditingController,
                    decoration: InputDecoration(
                      hintText: 'Type here.......', // Placeholder text
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Bottom border color
                    ),
                    focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // Bottom border color when focused
                    ),
                    ),),
                ],
              ),
            ),
            Container(
              width: screenWidth*0.77,
              height: 120,
              // decoration: BoxDecoration(border: Border.all(width: 1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Select your starting time',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w400),),
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
            startTime!=null && startTime!=''?
            Row(
              children: [
                SizedBox(width: screenWidth*0.07,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your selected slot will be',style: TextStyle(fontSize: 14,fontFamily: 'Poppins')),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Container(
                          child: Image.asset('assets/images/clock.png',width: 22,height: 22,),
                        ),
                        SizedBox(width: 5,),
                        Text('${startTime} - ${endTime} \t',style: TextStyle(color: Colors.green,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                        Text('India',style: TextStyle(fontWeight: FontWeight.bold,fontSize:14,fontFamily: 'Poppins'),)
                      ],
                    ),
                  ],
                ),
              ],
            ):SizedBox(height:0),
            startTime==''?
              Row(
                children: [
                  SizedBox(width: screenWidth*0.07,),
                  Text('*Please select a valid time.',style: TextStyle(color: Colors.red,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                ],
              )
            :SizedBox(height: 0,),
            SizedBox(height: 53,),
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
            SizedBox(height:20),
          ],
        ),
      ),
  );
  }
}
