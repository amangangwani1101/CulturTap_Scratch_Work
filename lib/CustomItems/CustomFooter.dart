import 'package:flutter/material.dart';
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
  Color homeIconColor = Color(0xFF263238);
  Color searchIconColor = Color(0xFF263238);
  Color airplaneIconColor = Color(0xFF263238);
  Color settingsIconColor = Color(0xFF263238);
  Color addIconColor = Color(0xFF263238);

  late VideoDatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = VideoDatabaseHelper();
    // You can access userId and userName via widget.userId and widget.userName
  }

  void _changeIconColor(String iconName) {
    setState(() {
      homeIconColor = Color(0xFF263238);
      searchIconColor = Color(0xFF263238);
      airplaneIconColor = Color(0xFF263238);
      settingsIconColor = Color(0xFF263238);
      addIconColor = Color(0xFF263238);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (context) => ProfileDataProvider(),
                              child: FinalProfile(userId: widget.userId!, clickedId: widget.userId!),
                            ),
                          ),
                        );

                        _changeIconColor('home');
                      },
                      icon: Icon(Icons.home, color: homeIconColor, size: 30),
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Color(0xFF263238),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _changeIconColor('search');
                      },
                      icon: Icon(Icons.search, color: searchIconColor, size: 30),
                    ),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: Color(0xFF263238),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(5, -30.0),
                    child: SizedBox(
                      width: 80,
                      height: 80,
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
                          } else {
                            // Navigate to CameraApp
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CameraApp()));
                          }
                          _changeIconColor('add');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: CircleBorder(),
                        ),
                        child: Icon(Icons.add, color: addIconColor, size: 42),
                      ),
                    ),
                  ),
                ),
                Column(
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
                      icon: Icon(Icons.airplanemode_active, color: airplaneIconColor, size: 30),
                    ),
                    Text(
                      'Airplane',
                      style: TextStyle(
                        color: Color(0xFF263238),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SavedDraftsPage(),
                          ),
                        );
                        _changeIconColor('settings');
                      },
                      icon: Icon(Icons.settings, color: settingsIconColor, size: 30),
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Color(0xFF263238),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 0,
          ),
        ],
      ),
    );
  }
}
