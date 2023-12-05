//customfooter
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/Settings.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:learn_flutter/VIdeoSection/Draft/SavedDraftsPage.dart';
import 'package:learn_flutter/Utils/location_utils.dart';
import 'package:learn_flutter/UserProfile/FinalUserProfile.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/Calendar.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/VideoPreviewPage.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/video_database_helper.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:learn_flutter/widgets/hexColor.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_flutter/BackendStore/BackendStore.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/video_info2.dart';

class CustomFooter extends StatefulWidget implements PreferredSizeWidget {
  final String? userId;
  final String? userName;

  CustomFooter({this.userId, this.userName});

  @override
  _CustomFooterState createState() => _CustomFooterState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _CustomFooterState extends State<CustomFooter> {
  Color homeIconColor = Color(0xFF001B33);
  Color searchIconColor = Color(0xFF001B33);
  Color airplaneIconColor = Color(0xFF001B33);
  Color settingsIconColor = Color(0xFF001B33);
  Color addIconColor = Color(0xFF001B33);

  late VideoDatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = VideoDatabaseHelper();
    checkVideos();

    // You can access userId and userName via widget.userId and widget.userName
  }



  void _changeIconColor(String iconName) {
    setState(() {
      homeIconColor = Color(0xFF001B33);
      searchIconColor = Color(0xFF001B33);
      airplaneIconColor = Color(0xFF001B33);
      settingsIconColor = Color(0xFF001B33);
      addIconColor = Color(0xFF001B33);

      switch (iconName) {
        case 'home':
          homeIconColor = Colors.orange;
          break;
        case 'search':
          searchIconColor = Colors.orange;
          break;
        case 'airplane':
          airplaneIconColor = Colors.orange;
          break;
        case 'settings':
          settingsIconColor = Colors.orange;
          break;
        case 'add':
          addIconColor = Colors.orange;
          break;
      }
    });
  }

  void _showVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF001B33),

          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                'Continue Previous Story?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Icon(
                Icons.video_call,
                color: Colors.orange,
                size: 60,
              ),


              SizedBox(height: 20),
              Text(
                'If you want to start a new story, you can save the current videos as a draft.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                'You can edit your drafts in the Settings section.',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    // Save draft logic
                    Navigator.pop(context);
                    _saveDraft();
                  },
                  child: Text(
                    'Save Draft',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Start a new story logic
                    Navigator.pop(context);

                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _saveDraft() {

    print('Draft saved!');
  }


  void checkVideos() async{
    bool hasVideoss = await VideoDatabaseHelper().hasVideos();
    if(hasVideoss){
      setState(() {
        addIconColor = Colors.orange;
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffF2F2F2),


      child: Padding(
        padding: const EdgeInsets.only(left:4.0,right:4.0),
        child: Column(

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width : 80,

                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );


                          _changeIconColor('home');
                        },
                        icon: SvgPicture.asset(
                          'assets/images/home_icon.svg', // Replace with the path to your SVG icon
                          color: homeIconColor,

                          height: 38,

                        ),
                      ),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: Color(0xFF001B33),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width : 80,

                  child: Column(
                    children: [
                      SizedBox(height : 2),
                      IconButton(
                        onPressed: () {
                          _changeIconColor('search');
                        },
                        icon: SvgPicture.asset(
                          'assets/images/search_icon.svg', // Replace with the path to your SVG icon
                          color: searchIconColor,


                          height: 25,



                        ),
                      ),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Color(0xFF001B33),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, -30.0),
                    child: SizedBox(

                      width: 80,
                      height: 80,
                      child: Container(


                        // decoration: BoxDecoration(
                        //   shape: BoxShape.circle,
                        //   border: Border.all(
                        //     color: Colors.orange,
                        //     width: 3.0, // Adjust the width of the border as needed
                        //   ),
                        // ),

                        child: ElevatedButton(
                          onPressed: () async{
                            bool hasVideos = await VideoDatabaseHelper().hasVideos();

                            if (hasVideos) {

                              // Navigate to VideoPreviewPage with data from the database
                              List<VideoInfo2> videos = await _databaseHelper.getAllVideos();
                              List<VideoInfo2> allVideos = await VideoDatabaseHelper().getAllVideos();

                              // Extract the required data from the list of videos
                              List<String> videoPaths = videos.map((video) => video.videoUrl).toList();
                              String userLocation = ''; // Replace with your logic to get user location
                              double latitude = allVideos[0].latitude;
                              double longitude = allVideos[0].longitude;

                              print('latitude : $latitude');
                              print('longitude : $longitude');

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPreviewPage(
                                    videoPaths: videoPaths,
                                    userLocation: userLocation,
                                    latitude: latitude,
                                    longitude: longitude,
                                  ),
                                ),
                              );

                              _showVideoDialog(context);
                            } else {
                              // Navigate to CameraApp
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CameraApp()));
                            }
                            _changeIconColor('add');
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shadowColor: Colors.grey,
                            shape: CircleBorder(),
                          ),
                          child: SvgPicture.asset(
                            'assets/images/addIcon.svg',
                            color: addIconColor,
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width : 80,


                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (context) => ProfileDataProvider(),
                                child: ProfileApp(userId: widget.userId, userName: widget.userName),
                              ),
                            ),
                          );
                          _changeIconColor('airplane');
                        },

                        icon: SvgPicture.asset(
                          'assets/images/tripassit.svg', // Replace with the path to your SVG icon
                          color: airplaneIconColor,

                          height: 34,



                        ),

                      ),
                      Text(
                        'Local Assist',
                        style: TextStyle(
                          color: Color(0xFF001B33),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width : 80,

                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          print('${widget.userId}');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(userId: widget.userId!),
                            ),
                          );
                          _changeIconColor('settings');
                        },

                        icon: SvgPicture.asset(
                          'assets/images/settings.svg', // Replace with the path to your SVG icon
                          color: airplaneIconColor,

                          height: 30,




                        ),
                      ),
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: Color(0xFF001B33),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 0,
            ),
          ],
        ),
      ),
    );
  }
}

