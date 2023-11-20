

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
  CalendarHelper({this.plans,this.choosenDate,this.startTime,this.endTime,this.slotChossen,this.date,this.text,this.userName});
  @override
  _CalendarHelperState createState()=> _CalendarHelperState();
}

class _CalendarHelperState  extends State<CalendarHelper>{
  late List<String> meetStartTimes=[],meetEndTimes=[];
  String? selectedDate,sendDate;

  @override
  void initState(){
    if(widget.choosenDate!=null)
     printMeetTimes(widget.choosenDate!);
    print('Plans:${widget.plans}');
  }
  void printMeetTimes(String key) {
    try {
      Map<String, dynamic> parsedData = widget.plans as Map<String, dynamic>;
      print(parsedData);
      if (parsedData.containsKey(key)) {
        print(2);
        List<dynamic> value = parsedData[key]['meetingStatus'];
        print(value);
        for (int index=0;index<value.length;index++){
          if(value[index]!='close'){
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
    return WillPopScope(
      onWillPop: ()async{
        if(widget.text=='calendarhelper'){
          print(1);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }else{
          print(2);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 5,text: widget.text,),automaticallyImplyLeading: false,),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: screenWidth*0.83,
              // decoration: BoxDecoration(border: Border.all(width: 1)),
              child: Column(
                children: [
                  SizedBox(height: 48,),
                  Container(
                    height: 241,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Check Calendar',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                        Container(
                          height: 76,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${widget.userName}’s provided avilable time for trip \n planning interaction calls -',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                              Row(
                                children: [
                                  Container(
                                    child: Image.asset('assets/images/clock.png',width: 22,height: 22,),
                                  ),
                                  SizedBox(width: 10,),
                                  Text('${widget.startTime} - ${widget.endTime} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                  Text('India',style: TextStyle(fontWeight: FontWeight.bold,fontSize:14,fontFamily: 'Poppins'),)
                                ],
                              ),
                            ],
                          ),
                        ),
                        CustomDOBDropDown(
                          initData: widget.date==null?'15 NOV':widget.date,
                          label: 'Select Date',
                          selectedDate: selectedDate,
                          deviceWidth: screenWidth*0.60,
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
                  SizedBox(height: 50,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Day Plans',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
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
                        height: 112,
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
                        child: Center(child: Text('Nothing planned this day, You \ncan scheduled your slots for \ninteraction',style: TextStyle(fontSize: 16,fontFamily: 'Poppins'),)),
                      ),
                    ],
                  ),
                ],
              ),
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
  final ValueChanged<DateTime?> onDateSelected;
  final String?initData;
  double deviceWidth;

  CustomDOBDropDown({
    this.initData,
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
                        : '${initData}',
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
