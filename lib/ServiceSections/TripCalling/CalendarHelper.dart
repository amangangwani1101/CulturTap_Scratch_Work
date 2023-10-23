

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../BackendStore/BackendStore.dart';
import '../../UserProfile/ProfileHeader.dart';



class CalendarHelper extends StatefulWidget{
  Map<String,dynamic>?plans;
  String choosenDate;
  CalendarHelper({this.plans,required this.choosenDate});
  @override
  _CalendarHelperState createState()=> _CalendarHelperState();
}

class _CalendarHelperState  extends State<CalendarHelper>{
  @override
  Widget build(BuildContext context) {
    final CalendarPlansData calendarData = CalendarPlansData.fromJson(widget.plans);
    void printMeetTimes(String key, CalendarPlansData data) {
      final MeetTimings? meetTimings = data.date?[key];

      if (meetTimings != null) {
        print("Meeting Start Times for $key:");
        for (var startTime in meetTimings.meetStartTime!) {
          print(startTime);
        }

        print("Meeting End Times for $key:");
        for (var endTime in meetTimings.meetEndTime!) {
          print(endTime);
        }
      } else {
        print("No data available for $key.");
      }
    }
    String date = ('${widget.choosenDate}');
    printMeetTimes(date,calendarData);

    void printAllData(CalendarPlansData data) {
      data.date!.forEach((key, meetTimings) {
        print("Date: ${key.runtimeType}");
        if (meetTimings != null) {
          print("Meeting Start Times:");
          for (var startTime in meetTimings.meetStartTime!) {
            print(startTime);
          }

          print("Meeting End Times:");
          for (var endTime in meetTimings.meetEndTime!) {
            print(endTime);
          }
        } else {
          print("No data available for $key.");
        }
        print("");
      });
    }
    // printAllData(calendarData);
    return Scaffold(
      appBar: AppBar(title: ProfileHeader(reqPage: 1),),
      body: SingleChildScrollView(
        child: Text('aaaaa'),
      ),
    );
  }

}