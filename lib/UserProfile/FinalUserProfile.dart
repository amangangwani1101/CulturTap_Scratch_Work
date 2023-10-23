import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../BackendStore/BackendStore.dart';
import '../widgets/CustomButton.dart';
import '../widgets/hexColor.dart';
import 'CoverPage.dart';
import 'ExpertCard.dart';
import 'ProfileHeader.dart';
import 'ReviewPage.dart';
import 'UserInfo.dart';


// Set Profile Fetching Data From DataBase
class FinalProfile extends StatefulWidget{
  final String userId;
  FinalProfile({required this.userId});
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
  String otherUserId = '652a31f77ff9b6023a14838a';
  Future<void> fetchDataset() async {
    final String serverUrl = 'http://192.168.53.54:8080'; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${widget.userId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched Data ${otherUserId}');
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
      // otherUserId= '652d671b59966d1623532468';
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
          onWillPop: () async{
            return false;
          },
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(top: 0.0,left: 16.0,right: 16.0 , bottom: 16.00),
              child: Center(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(reqPage: 0,imagePath:dataset != null ? dataset!['userPhoto'] : null),
                    SizedBox(height: 20,),
                    CoverPage(reqPage: 0,profileDataProvider: profileDataProvider,imagePath:dataset != null ? dataset!['userPhoto'] : null,name:dataset != null ? dataset!['userName'] : null),
                    SizedBox(height: 20,),
                    MotivationalQuote(profileDataProvider: profileDataProvider,quote:dataset != null ? dataset!['userQuote'] : null,),
                    SizedBox(height: 30,),
                    ReachAndLocation(profileDataProvider: profileDataProvider,followers:dataset != null ? dataset!['userFollowers'] : null,following:dataset != null ? dataset!['userFollowing'] : null,locations:dataset != null ? dataset!['userExploredLocations'] : null),
                    SizedBox(height: 40,),
                    Container(
                      width: 360,
                      child: Center(
                        child: UserDetailsTable(place:dataset != null ? dataset!['userPlace'] : null,
                          profession:dataset != null ? dataset!['userProfession'] : null,
                          age:dataset != null ? dataset!['userAge'] : null,
                          gender:dataset != null ? dataset!['userGender'] : null,
                          languageList:dataset != null ? dataset!['userLanguages'] : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 40,),
                    ExpertCardDetails(),
                    SizedBox(height: 40,),
                    dataset?['userServiceTripCallingData'] != null?TripCalling(data:parseServiceTripCallingData(dataset?['userServiceTripCallingData']), actualUserId : otherUserId,currentUserId : otherUserId):SizedBox(height: 0,),
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
  final String? currentUserId , actualUserId;
  TripCalling({this.data,this.actualUserId,this.currentUserId});
  @override
  _TripCallingState createState() => _TripCallingState();
}
class _TripCallingState extends State<TripCalling>{
  final costCall = 1000;
  @override
  Widget build(BuildContext context) {
    return Container(
      width:380,
      height:290,
      // decoration: BoxDecoration(
      //   border:Border.all(
      //     color: Colors.red,
      //     width:1,
      //   ),
      // ),
      child: Column(
        children: [
          Text('Hemant’s provided avilable time for trip planning interaction calls -',
            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
          SizedBox(height: 15,),
          Column(
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/time_icon.png',width: 22,height: 22,),
                      Text('${widget.data?.setStartTime} - ${widget.data?.setEndTime} India',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                    ],
                  ),
                  widget.currentUserId == widget.actualUserId
                      ? InkWell(
                    onTap: (){
                    },
                    child: Row(
                      children:[
                        Image.asset('assets/images/edit_icon.png',width: 11,height: 11,),
                        Text('EDIT',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),),
                      ],
                    ),
                  )
                      :SizedBox(width: 0,),
                ],
              ),
              Row(
                children: [
                  Image.asset('assets/images/notification_icon.png',width: 22,height: 22,),
                  Text('5 already pending requests for interaction \n with Hemant',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                ],
              ),
            ],
          ),
          SizedBox(height: 15,),
          Column(
            children: [
              Text('Cost of trip planning interaction call',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
              Text('$costCall INR',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w900,color: Colors.green),)
            ],
          ),
          widget.currentUserId == widget.actualUserId
              ? Container(
              width: 163,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: HexColor('#FB8C00'),
                ),
              ),
              child: Center(child: Text('Schedual Requests',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: HexColor('#FB8C00'),fontFamily: 'Poppins'),))
          )
              : Container(
            width: 250,
            height: 35,
            child: FiledButton(
                backgroundColor: HexColor('#FB8C00'),
                onPressed: () {
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
    );
  }
}

