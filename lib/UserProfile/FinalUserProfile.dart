import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/Calendar.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/CalendarHelper.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:provider/provider.dart';

import '../BackendStore/BackendStore.dart';
import '../widgets/01_helpIconCustomWidget.dart';
import '../widgets/CustomButton.dart';
import '../widgets/hexColor.dart';
import 'CoverPage.dart';
import 'ExpertCard.dart';
import 'ProfileHeader.dart';
import 'ReviewPage.dart';
import 'UserInfo.dart';


// Set Profile Fetching Data From DataBase
class FinalProfile extends StatefulWidget{
  final String userId,clickedId;
  FinalProfile({required this.userId,required this.clickedId});
  @override
  _FinalProfileState createState() => _FinalProfileState();
}
class _FinalProfileState extends State<FinalProfile> {
  Map<String, dynamic>? dataset;
  @override
  void initState() {
    super.initState();
    fetchDataset();
  }
  Future<void> fetchDataset() async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${widget.clickedId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched Data ${widget.clickedId}');
      print(data);
      print('Path ${dataset?['userQuote']}');
      setState(() {
        dataset = data;
      });
    } else {
      // Handle error
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }

  ServiceTripCallingData? parseServiceTripCallingData(Map<String, dynamic> data) {
    return ServiceTripCallingData(
      setStartTime: data['startTimeFrom'] as String?,
      setEndTime: data['endTimeTo'] as String?,
      slots: data['slotsChossen'] as String?,
    );
  }

  List<RatingEntry> parseRatings(List<dynamic> data) {
    return data.map((item) {
      return RatingEntry(
        name: item['ratersName'] as String?,
        count: item['ratersStar'] as int?,
        comment: item['ratersComment'] as String?,
      );
    }).toList();
  }

  Future<void> _refreshPage() async {
    // Add your data fetching logic here
    // For example, you can fetch new data from an API
    await Future.delayed(Duration(seconds: 2));
    // Update the UI with new data if needed
    setState(() {
      // Update your data
      // otherUserId= '652a578b7ff9b6023a1483ba';
      fetchDataset();
    });
  }

  Widget build(BuildContext context) {
    final profileDataProvider = Provider.of<ProfileDataProvider>(context);
    return RefreshIndicator(
      onRefresh: _refreshPage,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0), // Set the preferred height to 0
          child: AppBar(
            elevation: 0, // Remove the shadow
            backgroundColor: Colors.transparent, // Make the background transparent
          ),
        ),
        body: WillPopScope(
          onWillPop: ()async{
            Navigator.of(context).pop();
            return true;
          },
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(top: 0.0,left: 18.0,right: 18.0 , bottom: 18.00),
              child: Center(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(reqPage: 0,imagePath:dataset != null ? dataset!['userPhoto'] : null,userId: widget.userId,),
                    SizedBox(height: 20,),
                    CoverPage(reqPage: 0,profileDataProvider: profileDataProvider,imagePath:dataset != null ? dataset!['userPhoto'] : null,name:dataset != null ? dataset!['userName'] : null),
                    SizedBox(height: 20,),
                    MotivationalQuote(profileDataProvider: profileDataProvider,quote:dataset != null ? dataset!['userQuote'] : null,state:'final'),
                    SizedBox(height: 30,),
                    ReachAndLocation(profileDataProvider: profileDataProvider,followers:dataset != null ? dataset!['userFollowers'] : null,following:dataset != null ? dataset!['userFollowing'] : null,locations:dataset != null ? dataset!['userExploredLocations'] : null),
                    SizedBox(height: 40,),
                    // Container(
                    //   width: 360,
                    //   child: Center(
                    //     child: UserDetailsTable(place:dataset != null ? dataset!['userPlace'] : null,
                    //       profession:dataset != null ? dataset!['userProfession'] : null,
                    //       age:dataset != null ? dataset!['userAge'] : null,
                    //       gender:dataset != null ? dataset!['userGender'] : null,
                    //       languageList:dataset != null ? dataset!['userLanguages'] : null,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 40,),
                    ExpertCardDetails(),
                    SizedBox(height: 40,),
                    dataset?['userServiceTripCallingData'] != null?TripCalling(name:dataset != null ? dataset!['userName'] : null,data:parseServiceTripCallingData(dataset?['userServiceTripCallingData']), actualUserId : widget.clickedId,currentUserId : widget.userId,plans:dataset?['userServiceTripCallingData']['dayPlans']):SizedBox(height: 0,),
                    SizedBox(height: 50,),
                    RatingSection(ratings: dataset?['userReviewsData']!=null ?parseRatings(dataset?['userReviewsData']):[], reviewCnt: dataset?['userReviewsData']!=null? (dataset?['userReviewsData'].length):0,name:dataset?['userName'])
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// Services Selected By User -> Its Data || Currently Trip Calling Is Available
class TripCalling extends StatefulWidget{
  final  ServiceTripCallingData? data;
  final String? currentUserId , actualUserId,name;
  Map<String, dynamic>? plans;
  TripCalling({this.data,this.actualUserId,this.currentUserId,this.plans,this.name});
  @override
  _TripCallingState createState() => _TripCallingState();
}
class _TripCallingState extends State<TripCalling>{
  final costCall = Constant().tripPlaningCost;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width:331,
        height:250,
        // decoration: BoxDecoration(
        //   border:Border.all(
        //     color: Colors.red,
        //     width:1,
        //   ),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.name}’s provided avilable time for trip planning interaction calls -',
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Color(0xFF263238),),),
            Container(
              width: 331,
              height: 76,
              // decoration: BoxDecoration(
              //   border:Border.all(
              //     color: Colors.red,
              //     width:1,
              //   ),
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/time_icon.png',width: 22,height: 22,),
                          SizedBox(width: 10,),
                          Text('${widget.data?.setStartTime} - ${widget.data?.setEndTime} India',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',color: Color(0xFF263238),),),
                        ],
                      ),
                      widget.currentUserId == widget.actualUserId
                          ? InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> ServicePage(userId: widget.actualUserId,data:widget.data)));
                        },
                        child: Row(
                          children:[
                            Image.asset('assets/images/edit_icon.png',width: 15,height: 15,),
                            SizedBox(width: 3,),
                            Text('EDIT',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),),
                          ],
                        ),
                      )
                          :SizedBox(width: 0,),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/notification_icon.png',width: 22,height: 22,),
                      SizedBox(width: 10,),
                      Text('5 already pending requests for \ninteraction with Hemant',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',color: Color(0xFF263238),),),
                    ],
                  ),
                ],
              ),
            ),
            widget.currentUserId != widget.actualUserId
            ? Container(
              width: 331,
              height: 47,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cost of trip planning interaction call',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                  Text('$costCall INR',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w900,color: HexColor('#0A8100')),)
                ],
              ),
            )
            :SizedBox(height: 0,),
            widget.currentUserId == widget.actualUserId
                ? Container( 
                width: 183,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: HexColor('#FB8C00'),
                  ),
                ),
                child: InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarHelper(userName:widget.name,plans:widget.plans,startTime:widget.data?.setStartTime ,endTime: widget.data?.setEndTime,slotChossen: widget.data?.slots,),
                        ),
                      );
                    },
                    child: Center(child: Text('Schedual Requests',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: HexColor('#FB8C00'),fontFamily: 'Poppins'),)))
                )
                : Row(
                  children: [
                    Container(
              width: 250,
              height: 35,
              child: FiledButton(
                      backgroundColor: HexColor('#FB8C00'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> CalendarPage(clickedUser: widget.actualUserId!,currentUser: widget.currentUserId!,)));
                      },
                      child: Container(
                        width: 212,
                        height: 21,
                        child: Center(
                          child: Text('Schedual a  Trip Planning Call',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 13)),
                        ),
                      )),
            ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

