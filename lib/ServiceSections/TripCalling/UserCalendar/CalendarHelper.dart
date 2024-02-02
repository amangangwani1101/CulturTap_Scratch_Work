

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../BackendStore/BackendStore.dart';
import '../../../UserProfile/ProfileHeader.dart';
// import '../../rating.dart';
import '../../../widgets/CustomDropDowns.dart';
import '../../../widgets/hexColor.dart';



class CalendarHelper extends StatefulWidget{
  Map<String,dynamic>?plans;
  String ?choosenDate,startTime,endTime,slotChossen,date,text,userName;
  List<bool>?daysChoosen;
  CalendarHelper({this.plans,this.choosenDate,this.startTime,this.endTime,this.slotChossen,this.date,this.text,this.userName,this.daysChoosen});
  @override
  _CalendarHelperState createState()=> _CalendarHelperState();
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

class _CalendarHelperState  extends State<CalendarHelper>{
  late List<String> meetStartTimes=[],meetEndTimes=[];
  String? selectedDate,sendDate;

  @override
  void initState(){
    if(widget.choosenDate!=null){
      printMeetTimes(widget.choosenDate!);
      sendDate= widget.choosenDate;
    }
    print('Plans:${widget.plans}');

  }
  void printMeetTimes(String key) {
    try {
      if(widget.plans==null) return;
      Map<String, dynamic> parsedData = widget.plans as Map<String, dynamic>;
      print(parsedData);
      if (parsedData.containsKey(key)) {
        print(2);
        List<dynamic> value = parsedData[key]['meetingStatus'];
        print('xxxx');
        print(value);
        for (int index=0;index<value.length;index++){
          if(value[index]!='close' && value[index]!='closed' && value[index]!='cancel'){
            meetStartTimes.add(parsedData[key]['meetStartTime'][index]);
            meetEndTimes.add(parsedData[key]['meetEndTime'][index]);
          }
        }
        // meetStartTimes = List<String>.from(value['meetStartTime'] ?? []);
        // meetEndTimes = List<String>.from(value['meetEndTime'] ?? []);
        print("Meet Start Times: $meetStartTimes");
        print("Meet End Times: $meetEndTimes");
        print('----------------------------------');
      } else {
        print("No data available for $key.");
        meetStartTimes = [];
        meetEndTimes = [];
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
    return WillPopScope(
      onWillPop: ()async{
        if(widget.text=='calendarhelper'){
          print(1);
          Navigator.of(context).pop();
          // Navigator.of(context).pop();
        }else{
          print(2);
          Navigator.pop(context,sendDate);
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: ProfileHeader(reqPage: 5,text: widget.text,fromWhichPage: 'trip_planning_schedule_profile',onButtonPressed: (){
          Navigator.pop(context,sendDate);
        },),automaticallyImplyLeading: false,shadowColor: Colors.transparent,backgroundColor: Colors.white,),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: 25,right:35),
            // color: Colors.red,
            // decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Column(
              children: [
                SizedBox(height: 40,),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Check Calendar',style:Theme.of(context).textTheme.subtitle1,),
                      SizedBox(height: 25,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.userName}’s provided avilable time for trip planning interaction calls -',style: Theme.of(context).textTheme.subtitle1,),
                          SizedBox(height: 8,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Image.asset('assets/images/clock.png',width: 22,height: 22,),
                              ),
                              SizedBox(width: 10,),
                              Text('${widget.startTime} - ${widget.endTime}\t',style: Theme.of(context).textTheme.subtitle2),
                            ],
                          ),
                          Container(
                              padding: EdgeInsets.only(left: 27),
                              child: Text('(${daysLetter(widget.daysChoosen!).join(',')})',style: TextStyle(fontSize: (13),color : Color(0xFF001B33) ,),)),

                        ],
                      ),
                      SizedBox(height: 25,),
                      CustomDOBDropDown(
                        initData: widget.date==null?'15 NOV':widget.date,
                        label: 'Select Date',
                        disableDays:daysInt(widget.daysChoosen!),
                        selectedDate: sendDate==null?formatTodayDate(findNextAvailableDate(daysInt(widget.daysChoosen!))):sendDate,
                        deviceWidth: 260,
                        onDateSelected: widget.slotChossen=='choice_1'?((DateTime? newDate) {
                          setState(() {
                            selectedDate = ('${newDate?.day}/${getThreeLetterMonth(newDate!.month)}');
                            sendDate = ('${newDate?.day}/${getThreeLetterMonth(newDate!.month)}/${newDate!.year}');
                            print('Selected: ${sendDate}');
                            printMeetTimes(sendDate!);
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
                              print('Selected: ${newDate}');
                              printMeetTimes(sendDate!);
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
                ),
                SizedBox(height: 45,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Day Plans',style: Theme.of(context).textTheme.subtitle1,),
                    SizedBox(height:20),
                    meetStartTimes.length!=0
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        meetStartTimes.length,
                            (index) =>  Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Container(
                            width: 369,
                            height: 101,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child:Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('${meetStartTimes[index]} - ${meetEndTimes[index]} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                  Text('Trip Planning call with customer',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    :Container(
                      width: 369,
                      height: 90,
                      decoration:BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      // padding: EdgeInsets.all(15),
                      child: Center(child: Container(
                          width: 250,
                          // color: Colors.red,
                          child: Text('Nothing planned this day, You can scheduled your slots for interaction',style: Theme.of(context).textTheme.subtitle2,))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class CustomDOBDropDown extends StatelessWidget{
  final String label;
  final String? selectedDate;
  List<int> ?disableDays;
  final ValueChanged<DateTime?> onDateSelected;
  final String?initData;
  double deviceWidth;

  CustomDOBDropDown({
    this.initData,
    required this.label,
    required this.onDateSelected,
    required this.selectedDate,
    required this.deviceWidth,
    this.disableDays,
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
            child: Padding(
              padding: const EdgeInsets.only(left: 0.0,right: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.calendar_today_rounded,color: Colors.white,size: 25,), // Calendar icon
                  Text(
                    selectedDate != null
                        ? "${selectedDate}"
                        : '${initData}',
                    style: Theme.of(context).textTheme.headline5,),
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
