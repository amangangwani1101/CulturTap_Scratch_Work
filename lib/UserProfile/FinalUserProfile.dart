import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/CulturTap/VideoFunc/categoryData.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/category_section_builder.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/data_service.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/process_fetched_stories.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/Calendar.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/CalendarHelper.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
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

  late List<Map<String, dynamic>> categoryData;
  Map<String, dynamic>? dataset;
  bool isLoading = true;
  bool isDataLoading = true;

  @override
  void initState() {
    super.initState();

    fetchDataset();
    // print('userid is');
    // print(widget.userId);
    // print('clickedid is');
    fetchingStoriesUserID(widget.clickedId);
    fetchUserLocationAndData();
    print("clicked ID");
    print(widget.clickedId);
  }


  Future<void> fetchDataForCategory(double latitude, double longitude, int categoryIndex) async {
    try {

      final Map<String, dynamic> category = categoryData[categoryIndex];
      String apiEndpoint = category['apiEndpoint'];

      final fetchedStoryList = await fetchDataForStories(latitude, longitude, apiEndpoint);

      Map<String, dynamic> processedData = processFetchedStories(fetchedStoryList, latitude, longitude);

      categoryData[categoryIndex]['storyUrls'] = processedData['totalVideoPaths'];
      categoryData[categoryIndex]['videoCounts'] = processedData['totalVideoCounts'];
      categoryData[categoryIndex]['storyDistance'] = processedData['storyDistances'];
      categoryData[categoryIndex]['storyLocation'] = processedData['storyLocations'];
      categoryData[categoryIndex]['storyTitle'] = processedData['storyTitles'];
      categoryData[categoryIndex]['storyCategory'] = processedData['storyCategories'];
      categoryData[categoryIndex]['thumbnail_url'] = processedData['thumbnail_urls'];
      categoryData[categoryIndex]['storyDetailsList'] = processedData['storyDetailsList'];

      setState(() {

          isLoading = false;


      });


      print('Video counts per story in category $categoryIndex: ${processedData['totalVideoCounts']}');
      print('All video paths in category $categoryIndex: ${processedData['totalVideoPaths']}');
      print('storyurls');
      print(categoryData[categoryIndex]['storyUrls']);
    } catch (error) {
      print('Error fetching stories for category $categoryIndex: $error');
      setState(() {

      });
    }
  }


  Future<void> fetchUserLocationAndData() async {
    print('I called');

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;


      print('Latitude is: $latitude');

      // Fetch stories for each category



      for (int i = 0; i < categoryData.length; i++) {
        await fetchDataForCategory(latitude, longitude, i);

      }



    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> fetchDataset() async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${widget.clickedId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {

        isDataLoading = true;
      });
      final data = json.decode(response.body);
      print('Fetched Data ${widget.clickedId}');
      print(data);
      setState(() {
        dataset = data;
        isDataLoading = false;
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

  void fetchingStoriesUserID(String storyUserID){
    print('printitng story user ID hahahaha');
    print(storyUserID);
    categoryData = [
      ...generateCategoryData(name: 'Most Recent Visits', apiEndpoint: 'api/stories/user/$storyUserID'),
      ...generateCategoryData(name: 'Solo Trips', apiEndpoint: 'api/stories/user/$storyUserID/category/Solo trip'),
      ...generateCategoryData(name: 'Trip With Friends', apiEndpoint: 'api/stories/user/$storyUserID/category/Trip With Friends'),
      ...generateCategoryData(name: 'Trip With Family', apiEndpoint: 'api/stories/user/$storyUserID/category/Trip With Family'),
      ...generateCategoryData(name: 'Food And Restaurants', apiEndpoint: 'api/stories/user/$storyUserID/genres/Street Foods,Restaurants'),
      ...generateCategoryData(name: 'Fashion', apiEndpoint: 'api/stories/user/$storyUserID/genres/Fashion'),

    ];

  }

  Widget build(BuildContext context) {
    final profileDataProvider = Provider.of<ProfileDataProvider>(context);

    return RefreshIndicator(
      onRefresh: _refreshPage,

      child: Scaffold(
        appBar:AppBar(title: ProfileHeader(reqPage: 0,imagePath:dataset != null ? dataset!['userPhoto'] : null,userId: widget.userId,), shadowColor: Colors.transparent,automaticallyImplyLeading:false,toolbarHeight: 90,),
        body: WillPopScope(
          onWillPop: ()async{
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );

            return false;
          },
          child: isDataLoading ?

          Center(
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
          )

              : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).backgroundColor,
                  padding: EdgeInsets.only(top: 0.0,left: 16.0,right: 16.0 , bottom: 16.00),
                  child: Center(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SizedBox(height: 20,),
                        CoverPage(reqPage: 0,profileDataProvider: profileDataProvider,imagePath:dataset != null ? dataset!['userPhoto'] : null,name:dataset != null ? dataset!['userName'] : null),
                        dataset?['userQuote']!=null ?SizedBox(height: 30,):SizedBox(height: 0,),
                        MotivationalQuote(profileDataProvider: profileDataProvider,quote:dataset != null ? dataset!['userQuote'] : null,state:'final'),
                        ReachAndLocation(profileDataProvider: profileDataProvider,followers:dataset != null ? dataset!['userFollowers'] : null,following:dataset != null ? dataset!['userFollowing'] : null,locations:dataset != null ? dataset!['userExploredLocations'] : null),
                        SizedBox(height: 40,),
                        Container(
                          width: 360,
                          child: Center(
                            child: UserDetailsTable(place:dataset != null && dataset?['userPlace']!=null? dataset!['userPlace'] : null,
                              profession:dataset != null && dataset?['userProfession']!=null? dataset!['userProfession'] : null,
                              age:dataset != null && dataset?['userAge']!=null? dataset!['userAge'] : null,
                              gender:dataset != null && dataset?['userGender']!=null? dataset!['userGender'] : null,
                              languageList:dataset != null && dataset?['userLanguages']!=null? dataset!['userLanguages'] : [],
                            ),
                          ),
                        ),
                        SizedBox(height: 40,),
                        ExpertCardDetails(),
                        SizedBox(height: 40,),
                        dataset?['userServiceTripCallingData'] != null && dataset?['userServiceTripCallingData']['startTimeFrom']!=null?TripCalling(name:dataset != null ? dataset!['userName'] : null,data:parseServiceTripCallingData(dataset?['userServiceTripCallingData']), actualUserId : widget.clickedId,currentUserId : widget.userId,plans:dataset?['userServiceTripCallingData']['dayPlans']):SizedBox(height: 0,),
                        SizedBox(height: 50,),
                        RatingSection(ratings: dataset?['userReviewsData']!=null ?parseRatings(dataset?['userReviewsData']):[], reviewCnt: dataset?['userReviewsData']!=null? (dataset?['userReviewsData'].length):0,name:dataset?['userName']),

                        SizedBox(height : 40),
                      ],
                    ),
                  ),
                ),

                isLoading ? Center(
                  child: Container( height : 40,
                      child: CircularProgressIndicator(color: Colors.orange, )),
                ):

                Column(
                  children: [

                    Column(
                      children: [
                        SizedBox(height : 40),
                        Padding(
                          padding: const EdgeInsets.only(left:16.0),
                          child: Row(

                            children: [
                              Container(
                                width : 240,
                                child: Text(
                                  widget.userId == widget.clickedId ? "Your Story Tree" :  "Other Stories By ${dataset?['userName']?.split(' ')[0] } ?"
                                 ,
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),


                            ],
                          ),
                        ),
                        SizedBox(height : 40),
                      ],
                    ),
                    Column(


                      children: categoryData.asMap().entries.map((entry) {
                        final int categoryIndex = entry.key;
                        final Map<String, dynamic> category = entry.value;


                        final String specificCategoryName = category['specificName'];
                        final String categoryName = category['name'];
                        final List<String> storyUrls = category['storyUrls'];
                        final List<String> videoCounts = category['videoCounts'];
                        final List<String> storyDistance = category['storyDistance'];
                        final List<String> storyLocation = category['storyLocation'];
                        final List<String> storyCategory = category['storyCategory'];
                        final List<String> storyTitle = category['storyTitle'];
                        List<Map<String, dynamic>> storyDetailsList = category['storyDetailsList'];

                        return buildCategorySection(
                          specificCategoryName,
                          categoryName,
                          storyUrls,
                          videoCounts,
                          storyDistance,
                          storyLocation,
                          storyTitle,
                          storyCategory,
                          storyDetailsList,
                          true,

                        );
                      }).toList(),
                    ),
                  ],
                )
              ],
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
              style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
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
                          Text('${widget.data?.setStartTime} - ${widget.data?.setEndTime} India',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
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
                            Text('EDIT',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),),
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
                      Text('5 already pending requests for \ninteraction with Hemant',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
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
                width: 163,
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
                          builder: (context) => PingsSection(userId:widget.currentUserId!,state:'pending'),
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

