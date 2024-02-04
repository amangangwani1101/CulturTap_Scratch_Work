import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/UserProfile/ProfileHeader.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:provider/provider.dart';


import '../../../All_Notifications/customizeNotification.dart';
import '../../../UserProfile/FinalUserProfile.dart';
import '../../../widgets/01_helpIconCustomWidget.dart';
import '../../../widgets/hexColor.dart';
import '../../../BackendStore/BackendStore.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/CustomButton.dart';
import '../../PingsSection/Pings.dart';
import 'CalendarHelper.dart';

void main() async{
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
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

      home: CalendarPage(clickedUser: '6572cc23e816febdac42873b',currentUser: '65757af829ebda8841770c4c',),
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
  bool isDataFetched = false;
  Map<String, dynamic>? clickedUserDataSet,currentUserDataSet;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData()async{
    await fetchDatasets(widget.clickedUser,clickedUserDataSet);
    await fetchDatasets(widget.currentUser,currentUserDataSet);
    setState(() {
      isDataFetched = true;
    });
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
      appBar: AppBar(title: ProfileHeader(reqPage: 1,userId:widget.currentUser,fromWhichPage: 'trip_planning_schedule_profile',onButtonPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
            create:(context) => ProfileDataProvider(),
            child: FinalProfile(userId: widget.currentUser,clickedId: widget.clickedUser,),
          ),),
        );
      },),automaticallyImplyLeading: false,shadowColor: Colors.transparent,backgroundColor: Colors.white,),
      body: WillPopScope(
        onWillPop: () async{
          Navigator.of(context).pop();
          return true;
        },
        child: isDataFetched
            ? SingleChildScrollView(
          child: Container(
            // decoration: BoxDecoration(
            //   border:Border.all(
            //     width: 1,
            //   ),
            // ),
            // color: Colors.red,
            width: MediaQuery.of(context).size.width,
            margin:EdgeInsets.only(left:20,right:20),
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
                     daysChoosen:clickedUserDataSet?['userServiceTripCallingData']['daysChoosen'].where((dynamic element) => element is bool) // Filter out non-bool values
                         .cast<bool>() // Cast the remaining values to bool
                         .toList(),
                     id:widget.currentUser,userName:clickedUserDataSet?['userName'],userPhoto:clickedUserDataSet?['userPhoto']
                    ,uName:currentUserDataSet?['userName'],uPhoto:currentUserDataSet?['userPhoto'],id2:widget.clickedUser
                    ,userToken:currentUserDataSet?['uniqueToken'],plannerToken:clickedUserDataSet?['uniqueToken']),
              ],
            ),
          ),
        )
            : Center(
          child: Container(
            color : Theme.of(context).backgroundColor,
            height : double.infinity,
            width : double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(child: CircularProgressIndicator(color : Theme.of(context).primaryColor,)),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: SingleChildScrollView(
      //   child: Container(
      //     margin: EdgeInsets.only(left: 25,right:35),
      //     // color: Colors.red,
      //     // decoration: BoxDecoration(border: Border.all(width: 1)),
      //     child: Column(
      //       children: [
      //         SizedBox(height: 40,),
      //         Container(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text('Check Calendar',style:Theme.of(context).textTheme.subtitle1,),
      //               SizedBox(height: 25,),
      //               Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text('${userName}’s provided avilable time for trip planning interaction calls -',style: Theme.of(context).textTheme.subtitle1,),
      //                   SizedBox(height: 8,),
      //                   Row(
      //                     mainAxisAlignment: MainAxisAlignment.start,
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Container(
      //                         child: Image.asset('assets/images/clock.png',width: 22,height: 22,),
      //                       ),
      //                       SizedBox(width: 10,),
      //                       Text('${data} - ${endTime}\t',style: Theme.of(context).textTheme.subtitle2),
      //                     ],
      //                   ),
      //                   Container(
      //                       padding: EdgeInsets.only(left: 27),
      //                       child: Text('(${daysLetter(widget.daysChoosen!).join(',')})',style: TextStyle(fontSize: (13),color : Color(0xFF001B33) ,),)),
      //
      //                 ],
      //               ),
      //               SizedBox(height: 25,),
      //               CustomDOBDropDown(
      //                 initData: widget.date==null?'15 NOV':widget.date,
      //                 label: 'Select Date',
      //                 disableDays:daysInt(widget.daysChoosen!),
      //                 selectedDate: sendDate==null?formatTodayDate(findNextAvailableDate(daysInt(widget.daysChoosen!))):sendDate,
      //                 deviceWidth: 260,
      //                 onDateSelected: widget.slotChossen=='choice_1'?((DateTime? newDate) {
      //                   setState(() {
      //                     selectedDate = ('${newDate?.day}/${getThreeLetterMonth(newDate!.month)}');
      //                     sendDate = ('${newDate?.day}/${getThreeLetterMonth(newDate!.month)}/${newDate!.year}');
      //                     print('Selected: ${sendDate}');
      //                     printMeetTimes(sendDate!);
      //                   });
      //                 })
      //                     :((DateTime? newDate) {
      //                   // Check if the selected date is a weekend day (Saturday or Sunday)
      //                   if (newDate != null &&
      //                       (newDate.weekday == DateTime.saturday ||
      //                           newDate.weekday == DateTime.sunday)) {
      //                     setState(() {
      //                       selectedDate = ('${newDate?.day}/${getThreeLetterMonth(newDate!.month)}');
      //                       sendDate = ('${newDate?.day}/${getThreeLetterMonth(newDate!.month)}/${newDate!.year}');
      //                       print('Selected: ${newDate}');
      //                       printMeetTimes(sendDate!);
      //                     });
      //                   } else if(newDate!=null) {
      //                     ScaffoldMessenger.of(context).showSnackBar(
      //                       SnackBar(
      //                         content: Text('Please select a weekend day.'),
      //                       ),
      //                     );
      //                   }else{
      //                     ScaffoldMessenger.of(context).showSnackBar(
      //                       SnackBar(
      //                         content: Text('Please select a date.'),
      //                       ),
      //                     );
      //                   }
      //                 }),
      //               ),
      //             ],
      //           ),
      //         ),
      //         SizedBox(height: 45,),
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text('Day Plans',style: Theme.of(context).textTheme.subtitle1,),
      //             SizedBox(height:20),
      //             meetStartTimes.length!=0
      //                 ? Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: List.generate(
      //                 meetStartTimes.length,
      //                     (index) =>  Padding(
      //                   padding: const EdgeInsets.only(bottom: 20.0),
      //                   child: Container(
      //                     width: 369,
      //                     height: 101,
      //                     decoration: BoxDecoration(
      //                       color: Colors.white,
      //                       borderRadius: BorderRadius.circular(12.0),
      //                       boxShadow: [
      //                         BoxShadow(
      //                           color: Colors.grey.withOpacity(0.5),
      //                           spreadRadius: 2,
      //                           blurRadius: 5,
      //                           offset: Offset(0, 3),
      //                         ),
      //                       ],
      //                     ),
      //                     child:Container(
      //                       padding: EdgeInsets.only(left: 10),
      //                       child: Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                         children: [
      //                           Text('${meetStartTimes[index]} - ${meetEndTimes[index]} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
      //                           Text('Trip Planning call with customer',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             )
      //                 :Container(
      //               width: 369,
      //               height: 90,
      //               decoration:BoxDecoration(
      //                 color: Colors.white,
      //                 borderRadius: BorderRadius.circular(12.0),
      //                 boxShadow: [
      //                   BoxShadow(
      //                     color: Colors.grey.withOpacity(0.5),
      //                     spreadRadius: 2,
      //                     blurRadius: 5,
      //                     offset: Offset(0, 3),
      //                   ),
      //                 ],
      //               ),
      //               // padding: EdgeInsets.all(15),
      //               child: Center(child: Container(
      //                   width: 250,
      //                   // color: Colors.red,
      //                   child: Text('Nothing planned this day, You can scheduled your slots for interaction',style: Theme.of(context).textTheme.subtitle2,))),
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
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
    availabilityChoosen:data?['daysChoosen'].where((dynamic element) => element is bool) // Filter out non-bool values
        .cast<bool>() // Cast the remaining values to bool
        .toList(),
    //evedv
  );
}

class _CallTimeState extends State<CallTime>{
  String ? country = 'India';
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ServiceTripCallingData? userDataSet = parseServiceTripCallingData(widget.clickedUserDataSet?['userServiceTripCallingData']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Schedual Call With',style: Theme.of(context).textTheme.subtitle1,),
            Text("${widget.clickedUserDataSet!=null ?widget.clickedUserDataSet!['userName']:'Wait...'}",style: Theme.of(context).textTheme.subtitle2,),
          ],
        ),
        SizedBox(height: 15,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

              Container(
                  width: 300,
                  child: Text('User provided available time for trip planning interaction calls -',style: Theme.of(context).textTheme.subtitle1,)),
              SizedBox(height: 8,),
              Row(
                children: [
                  Image.asset('assets/images/clock.png',width: 22,height: 22,),
                  SizedBox(width: 5,),
                  Text('${userDataSet?.setStartTime} - ${userDataSet?.setEndTime} ${country} ',style: TextStyle(fontWeight: FontWeight.w600,color:Colors.orange,fontSize: 14,),),
                ],
              ),
              Container(
                  padding: EdgeInsets.only(left: 27),
                  child: Text('(${daysLetter(userDataSet!.availabilityChoosen!).join(',')})',style: TextStyle(fontWeight: FontWeight.w600,color:Colors.orange,fontSize: 13,),)),
          ],
        ),
      ],
    );
  }
}


class CalendarCheck extends StatefulWidget{
  Map<String,dynamic>? plans;
  String?slotChoosen;
  String ?id,id2;
  String ?userStartTime,userEndTime,userName,userPhoto,uName,uPhoto,userToken,plannerToken;
  List<bool>?daysChoosen;
  CalendarCheck({this.plans,this.slotChoosen,this.userEndTime,this.userStartTime,this.id,this.userName,this.userPhoto,this.uName,this.uPhoto,this.id2,this.daysChoosen,this.userToken,this.plannerToken});

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

List<String> daysLetter(List<bool>intDays){
  List<String> days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],retDays=[];
  for(int i=0;i<7;i++){
    if(intDays[i]){
      retDays.add(days[i]);
    }
  }
  return retDays;
}
List<int> daysInt(List<bool>days){
  List<int>retDays = [];
  for(int i=0;i<7;i++){
    if(days[i]){
      retDays.add(i+1);
    }
  }
  return retDays;
}

String formatTodayDate(DateTime date) {
  // Format day, month, and year separately
  List<String>months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  String day = date.day.toString();
  String month = date.month.toString();
  String year = date.year.toString();

  // Format with leading zeros if needed
  if (day.length == 1) day = '$day';
  if (month.length == 1) month = '$month';

  return '$day/${months[int.parse(month)-1]}/$year';
}

DateTime findNextAvailableDate(List<int>disable) {
  List<int> disabledDays = disable; // Sunday, Friday, Saturday

  DateTime currentDate = DateTime.now();
  int currentWeekday = currentDate.weekday;

  if (disabledDays.contains(currentWeekday)) {
    // If today is not in the disable list, return today's date
    return currentDate;
  } else {
    // Find the next available date that is not in the disable list
    int daysToAdd = 1;
    while (!disabledDays.contains((currentWeekday + daysToAdd) % 7)) {
      daysToAdd++;
    }

    return currentDate.add(Duration(days: daysToAdd));
  }
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
          CustomDOBDropDown(
            label: 'Select Date',
            disableDays:daysInt(widget.daysChoosen!),
            selectedDate: sendDate==null?formatTodayDate(findNextAvailableDate(daysInt(widget.daysChoosen!))):sendDate,
            deviceWidth: 270,
            onDateSelected: widget.slotChoosen=='choice_1'?((DateTime? newDate) {
              setState(() {
                if( newDate!=null){
                  String cmp = getThreeLetterMonth(newDate!.month);
                  selectedDate = ('${newDate?.day}/${cmp.toUpperCase()}');
                  sendDate = ('${newDate?.day}/${cmp}/${newDate!.year}');
                  showCalendar = true;
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a date.'),
                    ),
                  );
                }
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
          showCalendar? SizedBox(height: 20,): SizedBox(height: 0,),
          showCalendar
            ?Container(
              // color: Colors.red,
            padding: EdgeInsets.only(top: 10,bottom: 10),
            margin: EdgeInsets.only(right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: ()async{
                      String choosenDate = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarHelper(userName:widget.userName,plans:widget.plans,choosenDate:sendDate!,startTime:widget.userStartTime!,endTime:widget.userEndTime!,slotChossen: widget.slotChoosen!,daysChoosen:widget.daysChoosen,date:sendDate!),
                        ),
                      );
                      setState(() {
                        sendDate = choosenDate;
                      });
                    },
                    child: Container(

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text('Check User Calendar',style: TextStyle(fontSize: 14,color: Colors.orange,fontWeight: FontWeight.w700),),
                        Icon(Icons.arrow_forward_ios,color: HexColor('FB8C00'),size: 20,),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text('Calendar will help you to select the time for interaction with the user.',style: TextStyle(color: HexColor('#FF0000'),fontSize: 12,fontWeight: FontWeight.w500),)
                ],
              ),
            )
            :SizedBox(height: 0,),
            !showCalendar?SizedBox(height: 30,):SizedBox(height: 15,),
            TimeSet(slotChoosen:widget.slotChoosen,selectedDate:selectedDate,setDate:sendDate,userStartTime:widget.userStartTime,userEndTime:widget.userEndTime,plans:widget.plans,id:widget.id,id2:widget.id2,userName:widget.userName,userPhoto:widget.userPhoto,user2Name:widget.uName,user2Photo:widget.uPhoto,userToken:widget.userToken,plannerToken:widget.plannerToken,daysChoosen:widget.daysChoosen),
        ],
      ),
    );
  }
}



class CustomDOBDropDown extends StatelessWidget{
  final String label;
  final String? selectedDate;
  List<int> ?disableDays;
  final ValueChanged<DateTime?> onDateSelected;
  double deviceWidth;

  CustomDOBDropDown({
    required this.label,
    required this.onDateSelected,
    required this.selectedDate,
    required this.deviceWidth,
    this.disableDays
  });

  DateTime currentDate = DateTime.now();
  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,style: Theme.of(context).textTheme.subtitle1,),
        SizedBox(height: 10,),
        InkWell(
          onTap: () async {
            DateTime? selected = await showDatePicker(
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.orange, // header background color
                      onPrimary: Colors.white, // header text color
                      onSurface: Colors.orange, // body text color
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.subtitle1,
                        foregroundColor: Colors.orange, // button text color
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
              context: context,
              initialDate: findNextAvailableDate(disableDays!),
              firstDate: findNextAvailableDate(disableDays!),
              lastDate:  DateTime(currentDate.year+2),
              selectableDayPredicate: (DateTime day){
                return (disableDays!.contains(day.weekday));
              }
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.calendar_today_rounded,color: Colors.white,size: 25,), // Calendar icon
                Text(
                  selectedDate != null
                      ? "${selectedDate}"
                      : '15/NOV',
                  style: Theme.of(context).textTheme.headline5,),
                Image.asset('assets/images/arrow_down.png',color: Colors.white,),
              ],
            ),
          ),
        ),
      ],
    );
  }
}




class TimeSet extends StatefulWidget{
  String? setDate,userStartTime,userEndTime,userName,userPhoto,user2Name,user2Photo,slotChoosen,selectedDate;
  Map<String,dynamic>? plans;
  String?id,id2,userToken,plannerToken;
  List<bool>?daysChoosen;
  TimeSet({this.slotChoosen,this.selectedDate,this.setDate,this.userEndTime,this.userStartTime,this.plans,this.id,this.userName,this.userPhoto,this.user2Name,this.user2Photo,this.id2,this.userToken,this.plannerToken,this.daysChoosen});
  @override
  _TimeSetState createState() => _TimeSetState();
}

int getDayOfWeek(String dateString) {
  // Month abbreviation to numerical value map
  Map<String, int> monthMap = {
    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
    'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
    'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
  };

  List<String> parts = dateString.split('/');

  int day = int.parse(parts[0]);
  int month = monthMap[parts[1]]!;
  int year = int.parse(parts[2]);

  DateTime date = DateTime(year, month, day);
  return date.weekday - 1; // Subtract 1 to make Monday as 0-based
}

TimeOfDay convertToTimeOfDay(String timeString) {
  List<String> parts = timeString.split(' ');
  List<String> timeParts = parts[0].split(':');

  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  if (parts[1].toLowerCase() == 'pm' && hour != 12) {
    hour += 12;
  } else if (parts[1].toLowerCase() == 'am' && hour == 12) {
    hour = 0;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

class _TimeSetState extends State<TimeSet>{
  TimeOfDay _startTime = TimeOfDay(hour: 18, minute: 0);
  String ?startTime,endTime;
  bool timeOverlap = false;
  final TextEditingController _meetingEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose(){
    _meetingEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _startTime = convertToTimeOfDay(widget.userStartTime!);
    startTime = (widget.userStartTime!);
    endTime = addMinutesToTime(_formatTime(_startTime),20);
  }

  @override
  void checkSetDate_Time () async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId':widget.id2,
        'chosenDate':widget.setDate ,
        'chosenStartTime':startTime,
        'chosenEndTime':endTime,
        'dayIndex':getDayOfWeek(widget.setDate!),
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
          await saveMeetingSchedule();
          sendCustomNotificationToOneUser(
              widget.plannerToken!,
              'Messages From ${widget.userName}',
              'Trip Planning Request',_meetingEditingController.text,
              'All Pings','trip_planning_request',widget.id2!,'helper'
          );
          sendCustomNotificationToOneUser(
              widget.userToken!,
              'Messages Sent To  ${widget.user2Name}',
              '','Trip Planning Request Sent Successfully',
              'Pending','trip_planning_request',widget.id!,'user'
          );
          await showDialog(context: context, builder: (BuildContext context){
            return Container(child: CustomHelpOverlay(button:'Check Your Pings >', extraText: 'Your request is send to the Trip Planner,you can check pings for request status.',navigate:'pings',imagePath: 'assets/images/profile_set.svg',serviceSettings: false,onButtonPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PingsSection(userId:widget.id!,state:'Pending',selectedService: 'Trip Planning',),
                ),
              );
            },onBackPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },),);
          },);
        }
        else if(responseData['problem']=='service_close'){
          await Fluttertoast.showToast(
            msg:
            responseData['message'],
            toastLength:
            Toast.LENGTH_SHORT,
            gravity:
            ToastGravity.BOTTOM,
            backgroundColor:
            Colors.orange.withOpacity(0.5),
            textColor: Theme.of(context).primaryColorDark,
            fontSize: 16.0,
          );
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
              create:(context) => ProfileDataProvider(),
              child: FinalProfile(userId: widget.id!,clickedId: widget.id2!,),
            ),),
          );
        }
        else if(responseData['problem']=='overlap'){
          await showDialog(context: context, builder: (BuildContext context){
            return Container(child: CustomHelpOverlay(button:'Check ${userName} Calendar ', extraText: 'Trip planner is not available at your selected time !',navigate:'calendarhelper',imagePath: 'assets/images/profile_set.svg',serviceSettings: false,onButtonPressed: ()async{
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarHelper(text:'calendarhelper',plans:widget.plans,choosenDate:widget.setDate!,startTime:widget.userStartTime!,endTime:widget.userEndTime!,slotChossen: widget.slotChoosen,date:widget.setDate,userName:widget.userName,daysChoosen: widget.daysChoosen,),
                ),
              );
              Navigator.of(context).pop();
            },onBackPressed: (){
              Navigator.of(context).pop();
            },),);
          },);
          print('isOverlapping change data');
          // setState(() {});
        }
        else if(responseData['problem']=='update'){
          await Fluttertoast.showToast(
            msg:
            responseData['message'],
            toastLength:
            Toast.LENGTH_SHORT,
            gravity:
            ToastGravity.BOTTOM,
            backgroundColor:
            Colors.orange.withOpacity(0.5),
            textColor: Theme.of(context).primaryColorDark,
            fontSize: 16.0,
          );
          await Navigator.push(context, MaterialPageRoute(builder: (context)=> CalendarPage(clickedUser: widget.id2!,currentUser: widget.id!,)));

        }
      }
      else {
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }
  }
  String meetingId="";
  Future<void> saveMeetingSchedule () async{
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
        }

    );

    if(pickedTime!=null){
      setState(() {
        _startTime = pickedTime;
        startTime = _formatTime(_startTime);
        endTime = addMinutesToTime(_formatTime(_startTime),20);
        bool val = isTimeInSlot(widget.userStartTime!,widget.userEndTime!,startTime!,endTime!);
        timeOverlap = val;
        print(val);
        // if(!timeOverlap){
        //   startTime = '';
        // }
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

  bool validator(String? time,String title,String? date){
    if(time!=null && title!='' && date!=null && time!=''){
      return true;
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete All The Required Fields!.'),
        ),
      );
      return false;
    }
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
  return WillPopScope(
    onWillPop: ()async{
      _focusNode.unfocus();
      return false;
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set Time',style: Theme.of(context).textTheme.subtitle1,),
            SizedBox(height: 4,),
            Text('Note : the call duration will be  for 20 min so make sure that your questions are planned.',style: Theme.of(context).textTheme.subtitle2,)
          ],
        ),
        SizedBox(height: 15,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meeting Title',style: Theme.of(context).textTheme.subtitle1,),
            Container(
              width: screenWidth,
              margin: EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                // color: Colors.red,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                ),
              ),
              child: TextField(
                cursorColor: Colors.orange,
                onTapOutside: (value){
                  print('called');
                  _focusNode.unfocus();
                },
                onSubmitted: (String value) {
                  print('Submitted: $value');
                  // Handle onSubmitted action here
                  _focusNode.unfocus(); // Unfocus the TextField on submission
                },
                maxLines: null,
                focusNode: _focusNode,
                style: Theme.of(context).textTheme.subtitle2,
                controller: _meetingEditingController,
                decoration: InputDecoration(
                  hintText: 'Type here.......', // Placeholder text
                  hintStyle: TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,fontSize: 14,fontWeight: FontWeight.w600),
                //   enabledBorder: UnderlineInputBorder(
                //   borderSide: BorderSide(color: Colors.black), // Bottom border color
                // ),
                // focusedBorder: UnderlineInputBorder(
                // borderSide: BorderSide(color: Colors.orange), // Bottom border color when focused
                // ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),),
            ),
          ],
        ),
        SizedBox(height: 25,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select your starting time',style: Theme.of(context).textTheme.subtitle1,),
            SizedBox(height: 20,),
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
                    color:HexColor('#5EEBEB').withOpacity(0.2),
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
                          print('gsiddgisa');
                          print(_startTime);
                        },
                        child: Text('${_formatTime(_startTime)}',style: TextStyle(fontSize: 27,fontFamily: 'Poppins'),)),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10,),
        startTime!=null && startTime!=''?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected slot details',style: TextStyle(fontSize: 14,fontFamily: 'Poppins')),
            SizedBox(height: 2,),
            Row(
              children: [
                Container(
                  child: Image.asset('assets/images/clock.png',width: 22,height: 22,),
                ),
                SizedBox(width: 5,),
                Text('${startTime} - ${endTime} India',style: TextStyle(color: Colors.green,fontFamily: 'Poppins',fontWeight: FontWeight.w600,fontSize: 14,),),
              ],
            ),
          ],
        ):SizedBox(height:0),
        startTime==''?
          Text('*Please select a valid time.',style: TextStyle(color: Colors.red,fontFamily: 'Poppins',fontWeight: FontWeight.w600,fontSize: 13),)
        :SizedBox(height: 0,),
        SizedBox(height: 40,),
        Container(
          width: 326,
          height: 53,
          child: FiledButton(
              backgroundColor: HexColor('#FB8C00'),
              onPressed: () {
                print('$startTime,${widget.setDate},${_meetingEditingController.text}');
                if(validator(startTime,_meetingEditingController.text,widget.setDate)){
                  checkSetDate_Time();
                }else {}
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
  );
  }
}
