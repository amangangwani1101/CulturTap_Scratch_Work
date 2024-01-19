//customfooter
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/LocalAssistance/LocalAssist.dart';
import 'package:learn_flutter/SearchEngine/searchPage.dart';
import 'package:learn_flutter/Settings.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:learn_flutter/VIdeoSection/ComposePage.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/video_database_helper.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
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

  bool addButtonClicked = false;



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
        return Center(
          child: Container(
            margin : EdgeInsets.only(left : 20, right : 20),
            color :  Theme.of(context).primaryColorDark,
            height : 380,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue Previous Story ?',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          SizedBox(height: 20),
                          Icon(
                            Icons.video_call,
                            color: Colors.orange,
                            size: 60,
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              'If you want to start a new story, you can save the current videos as a draft.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              'You can edit your drafts in the \n Settings section.',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height : 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () async {
                              // Start a new story logic
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      },
    );
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
    }else{
      setState((){
        orange = '';

      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height :  80,

      decoration: BoxDecoration(
          color : mode == 'dark' ? Colors.black : Theme.of(context).backgroundColor,
          border: Border.all(color :mode == 'dark' ?  Colors.black : Theme.of(context).backgroundColor,width : 0.00)),




      child: Padding(
        padding: const EdgeInsets.only(left:6.0,right:6.0,),
        child:
            Column(
              children: [
                // Container(
                //     color: Colors.transparent,
                //     height : addButtonClicked ? MediaQuery.of(context).size.height - 241 : 0,
                // ),
                //
                // Visibility(
                //   visible: addButtonClicked == true,
                //   child : Column(children: [
                //   InkWell(
                //     onTap: ()async{
                //
                //
                //
                //       bool hasVideos = await VideoDatabaseHelper().hasVideos();
                //
                //       if (hasVideos) {
                //
                //         // Navigate to VideoPreviewPage with data from the database
                //         List<VideoInfo2> videos = await _databaseHelper.getAllVideos();
                //         List<VideoInfo2> allVideos = await VideoDatabaseHelper().getAllVideos();
                //
                //         // Extract the required data from the list of videos
                //         List<String> videoPaths = videos.map((video) => video.videoUrl).toList();
                //         String userLocation = ''; // Replace with your logic to get user location
                //         double latitude = allVideos[0].latitude;
                //         double longitude = allVideos[0].longitude;
                //
                //         print('latitude : $latitude');
                //         print('longitude : $longitude');
                //
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => VideoPreviewPage(
                //               videoPaths: videoPaths,
                //               userLocation: userLocation,
                //               latitude: latitude,
                //               longitude: longitude,
                //             ),
                //           ),
                //         );
                //
                //         _showVideoDialog(context);
                //       } else {
                //         // Navigate to CameraApp
                //         Navigator.push(context, MaterialPageRoute(builder: (context) => CameraApp()));
                //       }
                //       // _changeIconColor('add');
                //
                //
                //     },
                //     child: Container(
                //
                //       height : 80,
                //
                //       decoration: BoxDecoration(
                //         color : Colors.white,
                //
                //         borderRadius: BorderRadius.all(Radius.circular(0)),
                //         border: Border.all(color: Colors.white70), // Optional: Add border for visual clarity
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.all(10.0),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Row(
                //               children: [
                //                 IconButton(
                //                   icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                //                   onPressed: () {
                //                     // Handle bottom icon press
                //                   },
                //                 ),
                //                 Text(
                //                   'Shoot Regular Story',
                //                   style: TextStyle(fontSize: 16,),
                //                 ),
                //               ],
                //             ),
                //
                //             IconButton(
                //               icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                //               onPressed: () {
                //                 // Handle bottom icon press
                //               },
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                //   Container(height : 1, color : Colors.grey),
                //   InkWell(
                //     onTap: (){
                //
                //     },
                //     child: Container(
                //
                //       height : 80,
                //
                //       decoration: BoxDecoration(
                //         color : Colors.white,
                //
                //         borderRadius: BorderRadius.all(Radius.circular(0)),
                //         border: Border.all(color: Colors.white70), // Optional: Add border for visual clarity
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.all(10.0),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Row(
                //               children: [
                //                 IconButton(
                //                   icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                //                   onPressed: () {
                //                     // Handle bottom icon press
                //                   },
                //                 ),
                //                 Text(
                //                   'Shoot Long Trips',
                //                   style: TextStyle(fontSize: 16,),
                //                 ),
                //               ],
                //             ),
                //
                //             IconButton(
                //               icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                //               onPressed: () {
                //                 // Handle bottom icon press
                //               },
                //             ),
                //
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                //   SizedBox(height : 10),
                // ],),
                // ),
                //
                //



                Container(
                  height : 70,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            _changeIcon('home');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );
                          },
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
                                iconSize: 30,
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
                        child: InkWell(
                          onTap: (){
                            _changeIcon('search');
                  
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SearchPage()),
                            );
                          },
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
                      ),
                  
                  
                  
                      addButtonadd == 'add' ? Container(): Expanded(
                        child: Align(
                          alignment: Alignment(0.0, 0.0),
                          child: Transform.translate(
                            offset: Offset(0, -30.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).backgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 0.2,
                                    blurRadius: 0.4,
                                    offset: Offset(1, 2),
                                  ),
                                ],
                                //

                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 3.0, // Adjust the width of the border as needed
                                ),
                              ),
                              child: Container(
                                child: InkWell(
                                  onTap: ()async{



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
                                          builder: (context) => ComposePage(
                                            videoPaths: videoPaths,

                                            latitude: latitude,
                                            longitude: longitude,
                                            videoData: videoData,
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(22.0), // Adjust the padding as needed
                                    child: SvgPicture.asset(
                                      'assets/images/addIcon.svg',

                                      color: orange == 'yes' ? Colors.orange : mode == 'dark' ? Colors.white : Theme.of(context).primaryColor,
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  
                      Expanded(
                        child: InkWell(
                          onTap: (){
                  
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LocalAssist(),
                              ),
                            );
                  
                  
                          },
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
                      ),
                  
                  
                      Expanded(
                        child: InkWell(
                  
                          onTap: (){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(userId: userID),
                              ),
                            );
                          },
                  
                  
                  
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
                      ),
                    ],
                  ),
                ),
              ],
            ),

      ),
    );
  }
}

