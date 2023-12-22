//customfooter
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/LocalAssistance/LocalAssist.dart';
import 'package:learn_flutter/SearchEngine/searchPage.dart';
import 'package:learn_flutter/UserProfile/Settings.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:learn_flutter/VIdeoSection/Draft/SavedDraftsPage.dart';
import 'package:learn_flutter/Utils/location_utils.dart';
import 'package:learn_flutter/UserProfile/FinalUserProfile.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/Calendar.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/VideoPreviewPage.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/video_database_helper.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:learn_flutter/widgets/hexColor.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_flutter/BackendStore/BackendStore.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/video_info2.dart';


String? mode = '';
String? orange = '';
String? page = '';
String? addButtonadd = '';

class CustomFooter extends StatefulWidget implements PreferredSizeWidget {
  final String? userId;
  final String? userName;
  final String? lode;
  final String? addButtonAdd;


  CustomFooter({this.userId, this.userName, this.lode, this.addButtonAdd});

  @override
  _CustomFooterState createState() => _CustomFooterState();





  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _CustomFooterState extends State<CustomFooter> {



  Color homeIconColor = mode == 'dark' ? Colors.black : Colors.white;
  Color searchIconColor = mode == 'dark' ? Colors.black : Colors.white;
  Color airplaneIconColor = mode == 'dark' ? Colors.black : Colors.white;
  Color settingsIconColor = mode == 'dark' ? Colors.black : Colors.white;
  Color addIconColor = mode == 'dark' ? Colors.black : Colors.white;

  late VideoDatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = VideoDatabaseHelper();
    checkVideos();

    print('mode : $mode');


setState(() {
  addButtonadd = widget.addButtonAdd;
});


    // You can access userId and userName via widget.userId and widget.userName
  }



  void _changeIcon(String iconName) {
    setState(() {


      switch (iconName) {
        case 'home':
          page = 'home';
          break;
        case 'search':
          page = 'search';
          break;
        case 'trip':
          page = 'trip';
          break;
        case 'settings':
          page = 'settings';
          break;
        case 'add':
          page = 'add';
          break;
      }
    });
  }

  void _showVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E2529),

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

    setState(() {
      mode = widget.lode;
    });
    bool hasVideoss = await VideoDatabaseHelper().hasVideos();
    if(hasVideoss){
      setState(() {
        orange = 'yes';
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height : 50,


      color: mode == 'dark' ? Colors.black : Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(left:6.0,right:6.0,),
        child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    

                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );


                             _changeIcon('home');
                          },
                          icon: SvgPicture.asset(
                            page=='home' ? 'assets/images/home_oicon.svg'  : 'assets/images/home_icon.svg', // Replace with the path to your SVG icon
                            color: page == 'home' ? Colors.orange :mode == 'dark' ? Colors.white : Theme.of(context).primaryColor,



                          ),
                        ),
                        Text(
                          'Home',
                          style: mode == 'dark' ? Theme.of(context).textTheme.button : Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                ),


                Expanded(
                  child: Container(


                    child: Column(
                      children: [

                        IconButton(
                          onPressed: () {

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SearchPage()),
                            );

                            _changeIcon('search');
                          },
                          icon: SvgPicture.asset(
                              page=='search' ? 'assets/images/search_oicon.svg'  : 'assets/images/search_icon.svg', // Replace with the path to your SVG icon
                            color: page == 'search' ? Colors.orange : mode == 'dark' ? Colors.white : Theme.of(context).primaryColor,


                            height: 24,





                          ),
                        ),
                        Text(
                          'Search',
                          style: mode == 'dark' ? Theme.of(context).textTheme.button : Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                ),

                addButtonadd == 'add' ? Container(): Expanded(
                  child: Align(
                    alignment: Alignment(0.0, 0.0),
                    child: Transform.translate(
                      offset: Offset(0, -30.0),
                      child: SizedBox(
                        width : 100,
                        height : 100,


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
                              // _changeIconColor('add');
                            },
                            style: ElevatedButton.styleFrom(
                              primary: mode == 'dark' ? Colors.black : Theme.of(context).backgroundColor,

                              shape: CircleBorder(),
                            ),
                            child: SvgPicture.asset(
                              'assets/images/addIcon.svg',
                              color: orange == 'yes' ? Colors.orange : mode == 'dark' ? Colors.white : Theme.of(context).primaryColor ,
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(



                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LocalAssist(),
                              ),
                            );

                            _changeIcon('trip');
                          },

                          icon: SvgPicture.asset(
                            page=='trip' ? 'assets/images/trip_oicon.svg'  : 'assets/images/tripassit.svg',  // Replace with the path to your SVG icon
                            color: page=='trip' ? Colors.orange : mode == 'dark' ? Colors.white : Theme.of(context).primaryColor,

                            height: 24,

                          ),

                        ),
                        Text(
                          'Local Assist',
                          style:  mode == 'dark' ? Theme.of(context).textTheme.button : Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                ),


                Expanded(
                  child: Container(
                    

                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            print('${userID}');
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(userId: userID),
                              ),
                            );
                            _changeIcon('settings');
                          },

                          icon: SvgPicture.asset(
                            page=='settings' ? 'assets/images/setting_oicon.svg'  : 'assets/images/settings.svg',  // Replace with the path to your SVG icon
                            color: page=='settings' ? Colors.orange : mode == 'dark' ? Colors.white : Theme.of(context).primaryColor,

                            height: 24,




                          ),
                        ),
                        Text(
                          'Settings',
                          style: mode == 'dark' ? Theme.of(context).textTheme.button : Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

      ),
    );
  }
}

