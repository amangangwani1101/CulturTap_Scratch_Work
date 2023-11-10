import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/widgets/Constant.dart';

import '../../UserProfile/ProfileHeader.dart';
import '../../rating.dart';
import '../../widgets/CustomButton.dart';
import 'ChatSection/Receiver.dart';
// void main(){
//   runApp(Pings());
// }


class PingsDataStore{
  String userPhotoPath='';
  // List<String> status=[];
  String userName='';
  // List<String> meetStartTime=[];
  // List<String> meetEndTime=[];
  // List<String> meetDate=[];
  // List<String> meetTitle=[];
  // List<String> meetingType=[];
  // List<String> meetingId=[];
  Map<String,dynamic> meetData = {};

  PingsDataStore.fromJson(Map<String,dynamic> data){
    userPhotoPath = data['userPhoto']!=null?data['userPhoto']:'';
    userName = data['userName']!=null?data['userName']:'';
    meetData = data['userServiceTripCallingData']!=null?
    data['userServiceTripCallingData']['dayPlans']!=null?
    data['userServiceTripCallingData']['dayPlans']:[]:[];
  }
}
//
// class Pings extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
//         useMaterial3: true,
//       ),
//       home: PingsSection('123'),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }


class PingsSection extends StatefulWidget{
  String userId;
  PingsSection({required this.userId});
  @override
  _PingSectionState createState() => _PingSectionState();
}

class _PingSectionState extends State<PingsSection>{
  late PingsDataStore pingsDataStore;
  bool isLoading = true; // Add a boolean flag to indicate loading state
  @override
  void initState(){
    super.initState();
    fetchDatasets(widget.userId);
  }

  Future<void> fetchDatasets(userId) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('DataSet :::  ${data}');
      setState(() {
        pingsDataStore = PingsDataStore.fromJson(data);
        isLoading = false;
      });
      // pingsDataStore = PingsDataStore.fromJson(data);
      print('1::${pingsDataStore.meetData}');
      print('1::${pingsDataStore.userName}');
      print('1::${pingsDataStore.userPhotoPath}');
      // Map<String, dynamic> userServiceTripCallingData = data['userServiceTripCallingData'];
      // print(userServiceTripCallingData);
      // // Access and print the fields inside userServiceTripCallingData
      // print('Start Time: ${userServiceTripCallingData['startTimeFrom']}');
      // print('End Time: ${userServiceTripCallingData['endTimeTo']}');
      // print('Slots Chosen: ${userServiceTripCallingData['slotsChossen']}');

      // Access and parse the dayPlans object i nside userServiceTripCallingData
      // Map<String, dynamic> dayPlans = userServiceTripCallingData['dayPlans'];
      // dayPlans.forEach((key, value) {
      //   print('Date: $key');
      //   print('Meet Start Time: ${value['meetStartTime']}');
      //   print('Meet End Time: ${value['meetEndTime']}');
      //   print('Meeting ID: ${value['meetingId']}');
      //   print('Meeting Status: ${value['meetingStatus']}');
      //   print('Meeting Title: ${value['meetingTitle']}');
      //   print('Meeting Type: ${value['meetingType']}');
      //   print('User: ${value['meetingId']}');
      //   // Access other fields inside each date if present
      // });
    } else {
      // Handle error
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }
  Future<void> _refreshPage() async {
    // Add your data fetching logic here
    // For example, you can fetch new data from an API
    await Future.delayed(Duration(seconds: 2));
    // Update the UI with new data if needed
    setState(() {
      // Update your data
      // otherUserId= '652d671b59966d1623532468';
      isLoading = true;
      fetchDatasets(widget.userId);
    });
  }
  // late Timer _timer;
  // late Duration _refreshInterval;
  //
  // void startAutoRefresh() {
  //   // Set your refresh interval, for example:
  //   _refreshInterval = const Duration(seconds: 30);
  //
  //   // Start the timer for periodic data fetch
  //   _timer = Timer.periodic(_refreshInterval, (timer) {
  //     // Call your data fetching method here
  //     fetchDatasets(widget.userId);
  //   });
  // }
  //
  // void stopAutoRefresh() {
  //   _timer.cancel();
  // }

  void cancelMeeting(String date,int index,String status,String otherId,String otherStatus)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': widget.userId,
        'date':date,
        'index':index,
        'setStatus':status,
        'user2Id':otherId,
        'set2Status':otherStatus,
      };
      print('PPPPP::$data');
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/cancelMeeting'), // Adjust the endpoint as needed
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

  String convertToDate(String dateStr) {
    final Map<String, String> months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };

    final List<String> parts = dateStr.split('/');
    final day = int.parse(parts[0]);
    final month = months[parts[1]]!;
    final year = parts[2];

    final formattedDate = DateTime(int.parse(year), int.parse(month), day);
    final dayName = formattedDate.weekday; // Get the day of the week (1 for Monday, 7 for Sunday)

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return days[dayName - 1]; // Adjust to index of days array (0 for Monday, 6 for Sunday)
  }

  String _selectedValue = 'All';

  void _updateSelectedValue(String newValue) {
    setState(() {
      _selectedValue = newValue;
    });
  }
  bool toggle = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 1),automaticallyImplyLeading: false,),
    body: !isLoading
        ? RefreshIndicator(
          onRefresh: _refreshPage,
          child: SingleChildScrollView(
      child: Container(
        width: screenWidth,
        child: Column(
            children: [
              SizedBox(height: 40,),
              Center(
                child: Container(
                  width:screenWidth*0.95,
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: (){
                          setState(() {
                            toggle = true;
                          });
                        },
                        child: Container(
                          width: 139,
                          decoration:BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: toggle?HexColor('#FB8C00'):Colors.white, // Choose the color you want for the bottom border
                                width: 5.0, // Adjust the width of the border
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text('Requests',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold,color:toggle?HexColor('#FB8C00'):Colors.black),),
                              ),
                              SizedBox(width: 5,),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: (){
                          setState(() {
                            toggle = false;
                          });
                        },
                        child: Container(
                          width: 139,
                          decoration:BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !toggle?HexColor('#FB8C00'):Colors.white, // Choose the color you want for the bottom border
                                width: 5.0, // Adjust the width of the border
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text('Messages',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold,color: !toggle?HexColor('#FB8C00'):Colors.black),),
                              ),
                              SizedBox(width: 5,),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30,),
              toggle
              ? Center(
                child: Container(
                  width: screenWidth*0.85,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total requests : 1',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 140,
                            height: 35,
                            padding: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: HexColor('#FB8C00')
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedValue,
                              items: <String>['All','Scheduled', 'Accepted', 'Pending' , 'Closed','Cancelled']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _updateSelectedValue(newValue);
                                }
                              },
                              style: TextStyle(color: Colors.red), // Change the dropdown text style
                              underline: Container(), // Hide the underline
                              icon: Icon(Icons.keyboard_arrow_down, color: HexColor('#FB8C00')), // Change the dropdown icon
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              : SizedBox(height: 0,),
              SizedBox(height: 30,),
              toggle
              ? Column(
                children: List.generate(pingsDataStore.meetData.length, (index)  {
                  final date = pingsDataStore.meetData.keys.elementAt(index);
                  final meetDetails = pingsDataStore.meetData[date];
                  print('2::${date}');
                  print('2::${meetDetails}');
                  return Container(
                    width: screenWidth*0.85,
                    child: Column(
                      children:
                       List.generate(meetDetails['meetStartTime'].length, (index) {
                        String startTime= meetDetails['meetStartTime'][index];
                        String endTime= meetDetails['meetEndTime'][index];
                        String meetId = meetDetails['meetingId'][index];
                        String meetStatus = meetDetails['meetingStatus'][index];
                        String meetTitle = meetDetails['meetingTitle'][index];
                        String userId = meetDetails['userId'][index];
                        String meetType = meetDetails['meetingType'][index];
                        String userName = meetDetails['userName'][index];
                        String userPhoto = meetDetails['userPhoto'][index];
                        return Container(
                          child:
                          ((_selectedValue == 'Scheduled' && meetStatus =='schedule') ||
                          (_selectedValue == 'Accepted' && meetStatus =='accept')||
                          (_selectedValue == 'Pending' && meetStatus =='pending')||
                          (_selectedValue == 'Closed' && meetStatus =='close')||
                          (_selectedValue == 'Cancelled' && meetStatus =='cancel')||
                          _selectedValue =='All')
                          ? Container(
                            padding: EdgeInsets.only(top:10,bottom:20),

                            margin: EdgeInsets.only(bottom: 40),
                            decoration: BoxDecoration(
                              color: Colors.white, // Container background color
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Shadow color
                                  spreadRadius: 4, // Spread radius
                                  blurRadius: 7, // Blur radius
                                  offset: Offset(0, 3), // Changes the position of the shadow
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 10,),
                                Center(
                                  child: Container(
                                    width:screenWidth*0.73,
                                    height: 36,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            meetType=='sender'
                                                ? CircleAvatar(
                                              radius: 20.0,
                                              backgroundImage: pingsDataStore.userPhotoPath != null
                                                ? FileImage(File(pingsDataStore.userPhotoPath)) as ImageProvider<Object>?
                                                : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                              )
                                              :CircleAvatar(
                                              radius: 20.0,
                                              backgroundImage: userPhoto != null
                                                  ? FileImage(File(userPhoto)) as ImageProvider<Object>?
                                                  : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                            ),
                                            SizedBox(width: 6,),
                                            Image.asset('assets/images/arrow_dir.png'),
                                            SizedBox(width: 6,),
                                            meetType=='sender'
                                                ? CircleAvatar(
                                              radius: 20.0,
                                              backgroundImage: userPhoto!= null
                                                  ? FileImage(File(userPhoto)) as ImageProvider<Object>?
                                                  : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                            )
                                                :CircleAvatar(
                                              radius: 20.0,
                                              backgroundImage: pingsDataStore.userPhotoPath != null
                                                  ? FileImage(File(pingsDataStore.userPhotoPath)) as ImageProvider<Object>?
                                                  : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 20,),
                                        meetStatus=='pending' || meetStatus=='cancel'?
                                        Container(
                                          color: Colors.red, // Background color red
                                          height: 16  , // Height set to 16
                                          constraints: BoxConstraints(
                                            minWidth: 0,
                                            maxWidth: double.infinity, // Adjust width according to text
                                          ),
                                          child: Text('   '+
                                              (meetStatus=='pending'?'Request Pending':'Cancelled')+'   ',
                                            style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
                                          ),
                                        )
                                        : meetStatus=='accept'
                                        ? Container(
                                          color: HexColor('FB8C00'), // Background color red
                                          height: 16  , // Height set to 16
                                          constraints: BoxConstraints(
                                            minWidth: 0,
                                            maxWidth: double.infinity, // Adjust width according to text
                                          ),
                                          child: Text('   '+
                                              'Accepted'+'   ',
                                            style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
                                          ),
                                        )
                                        : meetStatus=='schedule'
                                        ? Container(
                                          color: HexColor('0A8100'), // Background color red
                                          height: 16  , // Height set to 16
                                          constraints: BoxConstraints(
                                            minWidth: 0,
                                            maxWidth: double.infinity, // Adjust width according to text
                                          ),
                                          child: Text('   '+
                                              'Scheduled'+'   ',
                                            style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
                                          ),
                                        )
                                        :meetStatus=='choose'
                                        ?SizedBox(height: 0,)
                                        : Container(
                                          color: HexColor('FB8C00'), // Background color red
                                          height: 16  , // Height set to 16
                                          constraints: BoxConstraints(
                                            minWidth: 0,
                                            maxWidth: double.infinity, // Adjust width according to text
                                          ),
                                          child: Text('   '+
                                              'Closed'+'   ',
                                            style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15,),
                                meetType=='sender'
                                ?Center(
                                  child: Container(
                                    width: screenWidth*0.71,
                                    height:21,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Trip planning Call with',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w500),),
                                        Text('${userName}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                                      ],
                                    ),
                                  ),
                                )
                                :Container(
                                  width: screenWidth*0.70,
                                  height:21,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Call requested by',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w500),),
                                      Text('${userName}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15,),
                                Center(
                                  child: Container(
                                    width:screenWidth*0.72 ,
                                    height: 22,
                                    child: Row(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Image.asset('assets/images/time_icon.png',width: 22,height: 22,),
                                        ),
                                        Text(' ${startTime} - ${endTime} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                        Text('India',style: TextStyle(fontSize:14,fontFamily: 'Poppins'),)
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4,),
                                Container(
                                  width: screenWidth*0.72,
                                  // decoration: BoxDecoration(border:Border.all(width: 1)),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Image.asset('assets/images/calendar.png',width: 22,height: 22,),
                                      ),
                                      Text(' Date ${date} "${convertToDate(date)}"',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 7,),
                                Container(
                                  width: screenWidth*0.71,
                                  // decoration: BoxDecoration(border:Border.all(width: 1)),
                                  height: 24,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(meetTitle==''?'Please Enter Tile Next Time':meetTitle,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                      ),
                                      // InkWell(
                                      //   onTap:(){
                                      //     setState(() {
                                      //
                                      //   });},
                                      //   child: Container(
                                      //     child: Image.asset('assets/images/arrow_down.png',width: 35,height: 35,),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                (meetStatus=='pending' && meetType=='sender')
                                ?InkWell(
                                    onTap: (){
                                      cancelMeeting(date,index,'close',userId,'close');
                                      print('$date,$index');
                                    },
                                    child: Container(width:screenWidth*0.72,child: Center(child: Text('Cancel',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),)),))
                                :(meetStatus=='pending' && meetType=='receiver')
                                ?Container(width:screenWidth*0.72,child: Text('*User need to unlock calendar before complete \n call scheduled.Please wait for event. ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300,fontFamily: 'Poppins',color: HexColor('#FF0000')),),)
                                :(meetStatus=='choose')
                                ? Container(
                                  width:screenWidth*0.70,
                                  // decoration: BoxDecoration(border:Border.all(width:1)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                          onTap: (){
                                            cancelMeeting(date,index,'close',userId,'close');
                                            print('$date,$index');
                                          },
                                          child: Container(child: Text('Cancel',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),),)),
                                      SizedBox(width: screenWidth*0.17,),
                                      InkWell(
                                          onTap: (){
                                            cancelMeeting(date,index,'pending',userId,'accept');
                                            print('$date,$index');
                                          },
                                          child: Container(child: Text('Accept',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),),)),
                                    ],
                                  ),
                                )
                                :(meetStatus=='accept')
                                ?Container(
                                  width: screenWidth*0.73,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                          onTap: (){
                                            cancelMeeting(date,index,'close',userId,'close');
                                            print('$date,$index');
                                          },
                                          child: Container(child: Text('Cancel',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),),)),
                                      SizedBox(width: screenWidth*0.08,),
                                      InkWell(
                                          onTap: (){
                                            print('Payment Successful');
                                            cancelMeeting(date,index,'schedule',userId,'schedule');
                                            print('$date,$index');
                                          },
                                          child: Container(child: Text('Unlock Calendar',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#0A8100')),),)),
                                    ],
                                  ),
                                )
                                :(meetStatus=='schedule')
                                ?InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ScheduledCalendar(date:date,userId:widget.userId,meetDetails:meetDetails,index:index),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: screenWidth*0.70,
                                    child: Center(child: Text('Go To Calendar',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                  ),
                                )
                                :(meetStatus=='close' && meetType=='receiver')
                                ?InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RateFeedBack(userPhoto:pingsDataStore.userPhotoPath,userName:pingsDataStore.userName,startTime:startTime,endTime:endTime,date:date,meetTitle:meetTitle,meetType:meetType,meetId:meetId),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: screenWidth*0.70,
                                    child: Center(child: Text('Rate & Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                  ),
                                )
                                : InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RateFeedBack(userPhoto: pingsDataStore.userPhotoPath,userName:pingsDataStore.userName,startTime:startTime,endTime:endTime,date:date,meetTitle:meetTitle),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: screenWidth*0.70,
                                    child: Center(child: Text('Give Us A Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                  ),
                                ),
                              ],
                            ),
                          ):SizedBox(height:0),
                          );
                       }),
                    ),
                  );
                }),
              )
              :SizedBox(height:0),
            ],
        ),
      ),
    ),
        )
        :Center(
    // Show a circular progress indicator while data is being fetched
    child: CircularProgressIndicator(),
    ),);
  }

}

class ScheduledCalendar extends StatefulWidget {
  String date,userId;
  dynamic meetDetails;
  int index;
  ScheduledCalendar({required this.date,required this.userId,required this.meetDetails,required this.index});
  @override
  _ScheduledCalendarState createState() =>  _ScheduledCalendarState();
}

class _ScheduledCalendarState extends State<ScheduledCalendar>{

  DateTime setDateTime(date,time){
    String parsedDateTime = ('$date $time');
    DateTime parsedDateTime2 = parseCustomDateTime(parsedDateTime);
    if (parsedDateTime2 != null) {
      print('Parsed DateTime: $parsedDateTime2');
    } else {
      print('Invalid date format...');
    }

    return parsedDateTime2;
  }

  DateTime parseCustomDateTime(String dateTimeString) {
    Map<String, int> monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };

    List<String> dateTimeParts = dateTimeString.split(' ');

    List<String> dateParts = dateTimeParts[0].split('/');
    int day = int.parse(dateParts[0]);
    int month = monthMap[dateParts[1]]!;
    int year = int.parse(dateParts[2]);

    List<String> timeParts = dateTimeParts[1].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    String amPm = dateTimeParts[2];

    if (amPm.toLowerCase() == 'pm' && hour < 12) {
      hour += 12;
    } else if (amPm.toLowerCase() == 'am' && hour == 12) {
      hour = 0;
    }

    DateTime parsedDateTime = DateTime(year, month, day, hour, minute);
    return parsedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    List<String> parts = widget.date.split('/'); // Split the string by '/'
    String useDate = '${parts[0]}/${parts[1]}'; // Concatenate the parts as needed
    String date=widget.date,userId=widget.userId;
    dynamic meetDetails=widget.meetDetails;
    String startTime= meetDetails['meetStartTime'][widget.index];
    String endTime= meetDetails['meetEndTime'][widget.index];
    String meetId = meetDetails['meetingId'][widget.index];
    String meetType = meetDetails['meetingType'][widget.index];
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 5),automaticallyImplyLeading: false,),
        body: SingleChildScrollView(
          child: Row(
            children: [
              SizedBox(width: 35,),
              Container(
                width: screenWidth*0.90,
                // decoration: BoxDecoration(border:Border.all(width: 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25,),
                    Text('Scheduled Calendar',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,fontFamily: 'Poppins'),),
                    SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,fontFamily: 'Poppins')),
                        Container(
                          width:120,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: HexColor('#FB8C00')
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 10,),
                              Image.asset('assets/images/calendar.png',color: HexColor('#FB8C00'),),
                              SizedBox(width: 10,),
                              Text('${useDate}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),)
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Column(
                      children: [
                        Text('Planned Call',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,fontFamily: 'Poppins')),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Column(
                        children:[
                          Container(
                              width: screenWidth<400?screenWidth*0.80:340,
                              child: Column(
                                children:[Container(
                                  height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white, // Container background color
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5), // Shadow color
                                      spreadRadius: 5, // Spread radius
                                      blurRadius: 7, // Blur radius
                                      offset: Offset(0, 3), // Changes the position of the shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: (){
                                    meetType=='sender'
                                        ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatApps(senderId:userId,receiverId:'',meetingId:meetId,date:date,index:widget.index,currentTime:setDateTime(date, startTime)),
                                      ),
                                    )
                                        :Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatApps(senderId:'',receiverId:userId,meetingId:meetId,date:date,index:widget.index,currentTime:setDateTime(date, startTime)),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width:screenWidth<400?screenWidth*0.75:320,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('${startTime} - ${endTime} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                                Container(
                                                  child: Image.asset('assets/images/arrow_fwd.png',width: 25,height: 25,),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text('Trip Planning call with customer',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),],
                              ),
                            ),
                          ],),
                      ],
                    ),
              ),
            ],
          ),
          ),
      ),
    );
  }
}

class RateFeedBack extends StatefulWidget{
  String?userPhoto,userName,startTime,endTime,date,meetTitle,meetType,meetId;
  RateFeedBack({this.meetId,this.meetType,this.meetTitle,this.endTime,this.startTime,this.userName,this.date,this.userPhoto});
  @override
  _RateFeedBackState createState() => _RateFeedBackState();
}

class _RateFeedBackState extends State<RateFeedBack>{
  String convertToDate(String dateStr) {
    final Map<String, String> months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };

    final List<String> parts = dateStr.split('/');
    final day = int.parse(parts[0]);
    final month = months[parts[1]]!;
    final year = parts[2];

    final formattedDate = DateTime(int.parse(year), int.parse(month), day);
    final dayName = formattedDate.weekday; // Get the day of the week (1 for Monday, 7 for Sunday)

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return days[dayName - 1]; // Adjust to index of days array (0 for Monday, 6 for Sunday)
  }
  int rating = 0;
  String textValue = '';
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 10,),
            Container(
              width: screenWidth<400?screenWidth*0.80:360,
              height:50,
              // decoration: BoxDecoration(border:Border.all(width: 1)),
              // padding: EdgeInsets.only(left:10,right:10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      height:50,child: Text('\nRate & Feedback.',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
                  Container(
                    height: 35,
                    child: IconButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, icon: Icon(Icons.close)),
                  ),
                ],
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth<400?screenWidth*0.85:360,
              height: 180,
              margin: EdgeInsets.only(top:75),
              decoration: BoxDecoration(border:Border.all(width: 1)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: screenWidth<400?screenWidth*0.80:370,
                    height: 40,
                    // decoration: BoxDecoration(
                    //   border:Border.all(
                    //     width: 1,
                    //     color: Colors.lightBlue
                    //   ),
                    // ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        widget.meetType=='sender'
                            ? CircleAvatar(
                          radius: 20.0,
                          backgroundImage: widget.userPhoto != null
                              ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                              : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                        )
                            :CircleAvatar(
                          radius: 20.0,
                          backgroundImage: (widget.userPhoto!) != null
                              ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                              : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                        ),
                        SizedBox(width: 10,),
                        Image.asset('assets/images/arrow_dir.png'),
                        SizedBox(width: 10,),
                        widget.meetType=='sender'
                            ? CircleAvatar(
                          radius: 20.0,
                          backgroundImage: (widget.userPhoto) != null
                              ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                              : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                        )
                            :CircleAvatar(
                          radius: 20.0,
                          backgroundImage: (widget.userPhoto) != null
                              ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                              : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                        ),
                      ],
                    ),
                  ),


                  Container(
                    height: 85,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.meetType=='sender'
                            ?Container(

                              child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text('Trip planning Call with',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
                              Text('${widget.userName!}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                          ],
                        ),
                            )
                            :Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Call requested by',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
                            Text('${widget.userName!}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                          ],
                        ),
                        Container(
                          height: 50,
                          // decoration: BoxDecoration(border:Border.all(width: 1)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: Image.asset('assets/images/time_icon.png',width: 20,height: 20,),
                                  ),
                                  SizedBox(width: 5,),
                                  Text('${widget.startTime!} - ${widget.endTime!} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                  Text('India',style: TextStyle(fontWeight: FontWeight.bold,fontSize:14,fontFamily: 'Poppins'),)
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    child: Image.asset('assets/images/calendar.png',width: 20,height: 20,),
                                  ),
                                  SizedBox(width: 5,),
                                  Text('Date ${widget.date!} "${convertToDate(widget.date!)}"',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth<400?screenWidth*0.80:370,
                    child: Text(widget.meetTitle==''?'Please Enter Tile Next Time':widget.meetTitle!,style: TextStyle(fontSize: 16,fontFamily: 'Poppins'),),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40,),
            Row(
              children: [
                SizedBox(width: 26,),
                Container(
                  // decoration: BoxDecoration(border:Border.all(width: 1)),
                  width: screenWidth<400?screenWidth*0.80:370,
                  height: 309,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height:64,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: screenWidth<400?screenWidth*0.80:370,
                              child: Text(
                                'Rate your Experience',
                                style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              // decoration: BoxDecoration(border:Border.all(width: 1)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        rating = index + 1;
                                      });
                                    },
                                    child: Icon(
                                      Icons.star,
                                      color: (index < rating) ? HexColor('#FB8C00') : Colors.grey,
                                      size: 32,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 185,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Container(
                                width: screenWidth<400?screenWidth*0.80:370,
                                child: Text('Additional Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
                            SizedBox(
                              width: screenWidth<400?screenWidth*0.80:370,
                              height: 152,
                              child: TextField(
                                style: TextStyle(fontSize: 16,),
                                onChanged: (value) {
                                textValue = value;
                              },
                              decoration: InputDecoration(
                              hintText: 'Type here........',
                              border: OutlineInputBorder(),
                              ),
                              maxLines: 5, // Increase the maxLines for a larger text area
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
            SizedBox(height:90),
            Container(
              width: screenWidth<400?screenWidth*0.80:370,
              height: 55,
              child: FiledButton(
                  backgroundColor: HexColor('#FB8C00'),
                  onPressed: () {
                  },
                  child: Center(
                      child: Text('SUBMIT',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16)))),
            ),
          ],
        ),
      ),
    );
  }
  
}