import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';

import '../widgets/Constant.dart';
import '../widgets/CustomButton.dart';
import '../widgets/hexColor.dart';

class RateFeed extends StatefulWidget{
  String?meetId,service;
  RateFeed({this.meetId,this.service});
  @override
  _RateFeedState createState() => _RateFeedState();
}

class _RateFeedState extends State<RateFeed>{

  String startTime='',date='',meetType='',meetTitle='',userName='',userPhoto='',userId='',helperId='',helperName='',helperPhoto='';
  bool dataGot = false,ratingUnfilled=false;
  String liveLocation = 'Fetching location...';
  @override
  void initState() {
    if(widget.service=='Local Assistant')
      meeting(widget.meetId!);
    getLocation();
    super.initState();
  }

  Future<void> getAndPrintLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark first = placemarks.first;
        String locationName = "${first.name}, ${first.locality}, ${first.administrativeArea}, ${first.country}";
        setState(() {
          liveLocation = locationName;
        });
      } else {
        // Return latitude and longitude if location not found
        setState(() {
          liveLocation = '$latitude, $longitude';
        });
      }
    } catch (e) {
      print("Error: $e");
      // Return latitude and longitude in case of an error fetching location
      setState(() {
        liveLocation = '$latitude, $longitude';
      });
    }
  }

  Future<void> fetchDataset(String userId) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Users Name and Photo Taken');
      setState(() {
        if(meetType=='sender'){
          userName = data['userName'];
          userPhoto = data['userPhoto']!=null?data['userPhoto']:'';
        }else{
          helperName = data['userName'];
          helperPhoto = data['userPhoto']!=null?data['userPhoto']:'';
        }
        print('UserName:${userName}');
        print('HelperName:${helperName}');
      });
    } else {
      // Handle error
      print('Failed to fetch users name & phone : ${response.statusCode}');
    }
  }

  Future<void> fetchDataset2(String userId) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Users Name and Photo Taken');
      setState(() {
        if(meetType=='sender'){
          helperName = data['userName'];
          helperPhoto = data['userPhoto']!=null?data['userPhoto']:'';
        }else{
          userName = data['userName'];
          userPhoto = data['userPhoto']!=null?data['userPhoto']:'';
        }
        print('UserName:${userName}');
        print('HelperName:${helperName}');
      });
    } else {
      // Handle error
      print('Failed to fetch users name & phone : ${response.statusCode}');
    }
  }


  Future<void> getLocation() async{
    await _getUserLocation();
  }
  // Function to get user location
  Future<void> _getUserLocation() async {
    setState(() {
      liveLocation = 'fetching location';
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // Convert latitude and longitude to a string

      String providedLatitude = '${position.latitude}';
      String providedLongiude = '${position.longitude}';

      getAndPrintLocationName(position.latitude, position.longitude);
      // Update the state with the user locatio
    } catch (e) {
      print("Error getting location: $e");
      setState(() {

      });
    }
  }

  Future<void> meeting(String meetId) async{
    setState(() {
      dataGot = false;
    });
    await  fetchMeetingData(meetId);
    setState(() {
      dataGot= true;
    });
  }

  Future<void> fetchMeetingData(String meetId) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/closedMeetingFeedback/${userID}?meeting=${meetId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['dataset'];
      print('Meeting Data Received ${data}');
      setState(() {
        startTime = data['time'];
        date = data['date'];
        meetType = data['userId']==userID?'sender':'receiver';
        meetTitle = data['title'];
        userId = data['userId'];
        helperId = data['helperId'];
      });
      await fetchDataset(userId);
      await fetchDataset2(helperId);
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
    final month = parts[1]!;
    final year = parts[2];

    final formattedDate = DateTime(int.parse(year), int.parse(month), day);
    final dayName = formattedDate.weekday; // Get the day of the week (1 for Monday, 7 for Sunday)

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return days[dayName - 1]; // Adjust to index of days array (0 for Monday, 6 for Sunday)
  }


  Future<void> updateLocalAssistFeedback(String meetingId,int rating,String info,String type,String info2)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'meetId': meetingId,
        'rating':rating,
        'info':info,
        'companyInfo':info2,
        'type':type,
        'userId':userID,
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
        await Fluttertoast.showToast(
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PingsSection(userId: userID,selectedService: 'Local Assistant',state:'Closed')),
        );
      } else {
        print('Failed to save data: ${response.statusCode}');
        Fluttertoast.showToast(
          msg:
          'Unable To Submit Feedback.!',
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

  int rating = -1;
  String textValue = '',textValue2='';
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: dataGot?SingleChildScrollView(
        child:  Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                 SizedBox(height: 50,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text('Rate & Feedback',style:TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color:Theme.of(context).primaryColorDark,fontFamily: 'Poppins'),),
                     InkWell(
                         onTap: (){
                           Navigator.of(context).pop();
                         },
                         child: Container(
                             padding: EdgeInsets.all(10),
                             child: Icon(Icons.close,size: 25,color: Theme.of(context).primaryColor,))),
                   ],
                 ),
                  SizedBox(height: 30,),
                  Container(
                    padding: EdgeInsets.only(right: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            meetType=='sender'
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
                            meetType=='sender'
                                ? CircleAvatar(
                              radius: 20.0,
                              backgroundImage: AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                            )
                                :CircleAvatar(
                              radius: 20.0,
                              backgroundImage:  AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              meetType=='sender'
                                  ?Container(
                                child:   Text('Local Assistant Request With ${Constant().extractFirstName(helperName)}',style: Theme.of(context).textTheme.subtitle2,),
                              )
                                  :Container(
                                child: Text('Local Assitant Request By ${Constant().extractFirstName(helperName)}',style: Theme.of(context).textTheme.subtitle2,),
                              ),
                              SizedBox(height: 20,),
                              Container(
                                // decoration: BoxDecoration(border:Border.all(width: 1)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          child: Icon(Icons.access_time_filled,size: 20,)
                                        ),
                                        SizedBox(width: 10,),
                                        Text('${startTime!} \t',style: Theme.of(context).textTheme.headline6),
                                        Text('India',style: Theme.of(context).textTheme.headline6,)
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Container(
                                          child:Icon(Icons.date_range_sharp,size: 20,),
                                        ),
                                        SizedBox(width: 10,),
                                        Text('Date ${date!} "${convertToDate(date!)}"',style: Theme.of(context).textTheme.headline6),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12,),
                  Container(
                    // decoration: BoxDecoration(border:Border.all(color: Colors.red)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: (){},
                          child: Icon(Icons.location_on,size: 24,),
                        ),
                        SizedBox(width:10,),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Location ',style: TextStyle(fontSize: 12,fontFamily: 'Poppins',fontWeight: FontWeight.w600,color:Theme.of(context).primaryColorDark),),
                                  Icon(Icons.keyboard_arrow_down,size: 17,),
                                ],
                              ),
                              Text(liveLocation,style: Theme.of(context).textTheme.subtitle2,), // Display user location here
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 25,),
                  Container(
                    // decoration: BoxDecoration(border:Border.all(width: 1)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                'Rate your Experience',
                                style: ratingUnfilled?TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color:Colors.red,fontFamily: 'Poppins') : Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      rating = index + 1;
                                      print('Rating is$rating');
                                      if(ratingUnfilled)
                                        ratingUnfilled = false;
                                    });
                                  },
                                  child: index<rating
                                      ?SvgPicture.asset('assets/images/star-color.svg',width: 40,height: 40,)
                                      :SvgPicture.asset('assets/images/star-no-color.svg',width: 30,height: 30,color: ratingUnfilled?Colors.red:Colors.black,),
                                 );
                              }),
                            ),
                            ratingUnfilled
                                ?Container(
                                  padding: EdgeInsets.only(top:5),
                                  child:Text('Please Rate Your Experience',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color:Colors.red,fontFamily: 'Poppins'),),
                                )
                                : SizedBox(height: 0,),
                          ],
                        ),
                        SizedBox(height: 25,),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text('Additional Feedback',style: Theme.of(context).textTheme.subtitle1)),
                              SizedBox(height: 10,),
                              Container(
                                color: Theme.of(context).primaryColorLight,
                                height: 104,
                                child: TextField(
                                  cursorColor: Colors.orange,
                                  style: Theme.of(context).textTheme.headline6,
                                  onChanged: (value) {
                                    textValue = value;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Type here........',
                                    hintStyle: Theme.of(context).textTheme.subtitle1,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.orange,
                                        )
                                    ),
                                  ),
                                  maxLines: 7, // Increase the maxLines for a larger text area
                                ),
                              ),

                            ],
                          ),
                        ),
                        SizedBox(height: 25,),
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black
                            ),
                          ),
                        ),
                        SizedBox(height: 15,),
                        Container(
                          // color: Colors.red,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text('Wanna say something to Culturtap ?',style: Theme.of(context).textTheme.subtitle1,)),
                              SizedBox(height: 10,),
                              Container(
                                color:  Theme.of(context).primaryColorLight,
                                height: 75,
                                child: TextField(
                                  style:Theme.of(context).textTheme.headline6,
                                  onChanged: (value) {
                                    textValue2 = value;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Type here........',
                                    hintStyle: Theme.of(context).textTheme.subtitle1,
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.orange,
                                        )
                                    ),
                                  ),
                                  maxLines: 7, // Increase the maxLines for a larger text area
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,)
                ],
              ),
            ),
            Container(
              width:MediaQuery.of(context).size.width,
              height: 63,
              child: FiledButton(
                  backgroundColor: HexColor('#FB8C00'),
                  onPressed: () async{
                    print('Ratting ${rating}');
                    if(rating==-1){
                      setState(() {
                        ratingUnfilled = true;
                      });
                    }
                    else{
                      print('${widget.meetId},${meetType}');
                      if(widget.service=='Local Assistant'){
                        await updateLocalAssistFeedback(widget.meetId!,rating,textValue,meetType!,textValue2);
                      }
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
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 18)))),
            ),
          ],
        ),
      ):Center(child: CircularProgressIndicator(),),
    );
  }
}
