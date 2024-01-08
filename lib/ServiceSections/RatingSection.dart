import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';

import '../widgets/Constant.dart';
import '../widgets/CustomButton.dart';
import '../widgets/hexColor.dart';

class RateFeed extends StatefulWidget{
  String?userPhoto,userName,startTime,endTime,date,meetTitle,meetType,meetId,userId,service;
  final VoidCallback? pingsCallback;
  RateFeed({this.meetId,this.meetType,this.meetTitle,this.endTime,this.startTime,this.service,this.userName,this.date,this.userPhoto,this.userId,this.pingsCallback});
  @override
  _RateFeedState createState() => _RateFeedState();
}

class _RateFeedState extends State<RateFeed>{


  @override
  void initState() {
    if(widget.service=='Local Assistant')
      meeting(widget.meetId!);
    super.initState();
  }

  Future<void> meeting(String meetId) async{
    await  fetchMeetingData(meetId);
  }

  Future<void> fetchMeetingData(String meetId) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/closedMeetingFeedback/${'6598cf50e7474fb150c40cdd'}?meeting=${meetId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Meeting Data Received $data');
      setState(() {
        widget.startTime = data['time'];
        widget.date = data['date'];
        widget.meetType = data['userId']==userID?'sender':'receiver';
        widget.meetTitle = data['title'];
        widget.meetId = data['meetId'];
        widget.userName = data['userName'];
        widget.userPhoto = data['userPhoto'];
        widget.userId = userID;
      });
    } else {
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }


  String convertToDate(String dateStr)  {
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


  // void updateMeetingFeedback(String meetingId,int rating,String info,String type,String userId,int index,String date,String info2)async{
  //   try {
  //     final String serverUrl = Constant().serverUrl; // Replace with your server's URL
  //     final Map<String,dynamic> data = {
  //       'meetId': meetingId,
  //       'rating':rating,
  //       'info':info,
  //       'companyInfo':info2,
  //       'type':type,
  //     };
  //     print('PPPPP::$data');
  //     final http.Response response = await http.patch(
  //       Uri.parse('$serverUrl/updateMeetingFeedback'), // Adjust the endpoint as needed
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode(data),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       print(responseData);
  //       widget.pingsCallback!();
  //     } else {
  //       print('Failed to save data: ${response.statusCode}');
  //     }
  //   }catch(err){
  //     print("Error: $err");
  //   }
  //
  //   try {
  //     final String serverUrl = Constant().serverUrl; // Replace with your server's URL
  //     final Map<String,dynamic> data = {
  //       'userId': userId,
  //       'date':date,
  //       'index':index,
  //     };
  //     print('PPPPP::$data');
  //     final http.Response response = await http.patch(
  //       Uri.parse('$serverUrl/closeMeeting'), // Adjust the endpoint as needed
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode(data),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       print(responseData);
  //     } else {
  //       print('Failed to save data: ${response.statusCode}');
  //     }
  //   }catch(err){
  //     print("Error: $err");
  //   }
  // }

  Future<void> updateLocalAssistFeedback(String meetingId,int rating,String info,String type,String info2)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'meetId': meetingId,
        'rating':rating,
        'info':info,
        'companyInfo':info2,
        'type':type,
      };
      print('Feedback Form ::$data');
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/updateLocalAssistFeedback'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        Fluttertoast.showToast(
          msg:
          'Feedback Updated Successfully !',
          toastLength:
          Toast.LENGTH_SHORT,
          gravity:
          ToastGravity.BOTTOM,
          backgroundColor:
          Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print('Failed to save data: ${response.statusCode}');
        Fluttertoast.showToast(
          msg:
          'Try Again :( !',
          toastLength:
          Toast.LENGTH_SHORT,
          gravity:
          ToastGravity.BOTTOM,
          backgroundColor:
          Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }catch(err){
      print("Error: $err");
    }
  }

  int rating = 0;
  String textValue = '',textValue2='';
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: widget.userName==null ?SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            children: [
             SizedBox(height: 30,),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('Rate & Feedback',style: Theme.of(context).textTheme.headline2,),
                  Icon(Icons.close,size: 26,color: Theme.of(context).primaryColor,),
               ],
             ),
              SizedBox(height: 71,),
              Row(
                children: [
                  Container(
                    // decoration: BoxDecoration(border:Border.all(width: 1)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.meetType=='user'
                                ? CircleAvatar(
                              radius: 20.0,
                              backgroundImage: AssetImage('assets/images/profile_image.svg'),// Use a default asset image
                            )
                                :CircleAvatar(
                              radius: 20.0,
                              backgroundImage: AssetImage('assets/images/profile_image.svg'),// Use a default asset image
                            ),
                            SizedBox(width: 10,),
                            SvgPicture.asset(
                              'assets/images/local_assist_logo.svg', // Replace with the path to your SVG file
                              width: 25, // Specify the width
                              height: 25, // Specify the height
                              color: Colors.black, // Change the color if needed
                            ),
                            SizedBox(width: 10,),
                            // widget.meetType=='sender'
                            //     ? CircleAvatar(
                            //   radius: 20.0,
                            //   backgroundImage: (widget.userPhoto) != null && widget.userPhoto != ''
                            //       ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                            //       : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                            // )
                            //     :CircleAvatar(
                            //   radius: 20.0,
                            //   backgroundImage: (widget.userPhoto) != null && widget.userPhoto != ''
                            //       ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                            //       : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                            // ),
                          ],
                        ),


                        // Container(
                        //   height: 85,
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       widget.meetType=='sender'
                        //           ?Container(
                        //
                        //         child: Row(
                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Text('Trip planning Call with',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
                        //             Text('${widget.userName!}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                        //           ],
                        //         ),
                        //       )
                        //           :Row(
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           Text('Call requested by',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
                        //           Text('${widget.userName!}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                        //         ],
                        //       ),
                        //       Container(
                        //         height: 50,
                        //         // decoration: BoxDecoration(border:Border.all(width: 1)),
                        //         child: Column(
                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Row(
                        //               children: [
                        //                 Container(
                        //                   child: Image.asset('assets/images/time_icon.png',width: 20,height: 20,),
                        //                 ),
                        //                 SizedBox(width: 5,),
                        //                 // Text('${widget.startTime!} - ${widget.endTime!} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                        //                 // Text('India',style: TextStyle(fontWeight: FontWeight.bold,fontSize:14,fontFamily: 'Poppins'),)
                        //               ],
                        //             ),
                        //             Row(
                        //               children: [
                        //                 Container(
                        //                   child: Image.asset('assets/images/calendar.png',width: 20,height: 20,),
                        //                 ),
                        //                 SizedBox(width: 5,),
                        //                 // Text('Date ${widget.date!} "${convertToDate(widget.date!)}"',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                        //               ],
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Container(
                        //   width: screenWidth<400?screenWidth*0.80:370,
                        //   child: Text(widget.meetTitle==''?'Please Enter Tile Next Time':widget.meetTitle!,style: TextStyle(fontSize: 16,fontFamily: 'Poppins'),),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40,),
              Row(
                children: [
                  SizedBox(width: 26,),
                  Container(
                    // decoration: BoxDecoration(border:Border.all(width: 1)),
                    width: screenWidth<400?screenWidth*0.80:370,
                    height: 333,
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
                                          print('Rating is$rating');
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
                          height: widget.meetType=='sender'?156:185,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding:EdgeInsets.only(top: widget.meetType=='sender'?23:0),
                                  width: screenWidth<400?screenWidth*0.80:370,
                                  child: Text('Additional Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
                              Container(
                                color: HexColor('#E9EAEB'),
                                width: screenWidth<400?screenWidth*0.80:370,
                                height: widget.meetType=='sender'?104:152,
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
                        widget.meetType=='sender'?SizedBox(height: 5,):SizedBox(height: 0,),
                        widget.meetType=='sender'
                            ?Container(
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black
                            ),
                          ),
                        )
                            :SizedBox(height: 0,),
                        widget.meetType=='sender'?SizedBox(height: 5,):SizedBox(height: 0,),
                        widget.meetType=='sender'
                            ?Container(
                          height: 102,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: screenWidth<400?screenWidth*0.80:370,
                                  height: 21,
                                  child: Text('Wanna say something to Culturtap ?',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
                              SizedBox(height: 10,),
                              Container(
                                color: HexColor('#E9EAEB'),
                                width: screenWidth<400?screenWidth*0.80:370,
                                height: 70,
                                child: TextField(
                                  style: TextStyle(fontSize: 16,),
                                  onChanged: (value) {
                                    textValue2 = value;
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
                        )
                            :SizedBox(height: 0,),
                      ],
                    ),
                  ),
                ],
              ),
              widget.meetType=='sender'?SizedBox(height: 30,):SizedBox(height: 90,),
              Container(
                width: screenWidth<400?screenWidth*0.80:370,
                height: 55,
                child: FiledButton(
                    backgroundColor: HexColor('#FB8C00'),
                    onPressed: () async{
                      print('${widget.meetId},${widget.meetType}');
                      if(widget.service=='Local Assistant'){
                        await updateLocalAssistFeedback(widget.meetId!,rating,textValue,widget.meetType!,textValue2);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => HomePage(userId: widget.userId,userName: widget.userName,),
                      //   ),
                      // );

                      // Navigator.of(context).pop();
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
      ):CircularProgressIndicator(),
    );
  }
}
