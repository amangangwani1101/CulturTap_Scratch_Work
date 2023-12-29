import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/BackendStore/BackendStore.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/categoryData.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/category_section_builder.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/data_service.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/process_fetched_stories.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/SearchEngine/searchPage.dart';
import 'package:learn_flutter/UserProfile/FinalUserProfile.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';


class StoryDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> storyDetailsList;
  final int initialIndex;
  final List<String> storyUrls;
  final String where;


  StoryDetailPage({
    required this.storyUrls,
    required this.storyDetailsList,
    required this.initialIndex,
    required this.where,
  });

  @override
  _StoryDetailPageState createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  late List<Map<String, dynamic>> categoryData;
  ScrollController _scrollController = ScrollController();
  bool _isScrollingDown = false;



  bool isPlaying = true;
  late PageController _pageController;
  int _currentIndex = 0;
  List<List<VideoPlayerController>> _videoControllersList = [];

  ChewieController? _chewieController;
  bool _isVideoLoading = true;
  bool showPlayPauseIcon = true;
  bool showPauseIcon = false;
  int currentVideoIndex = 0;
  bool showNextVideoIcon = false;
  bool showPreviousVideoIcon = false;
  bool _isFullScreen = false;
  String storyUserID = '';
  bool _isVisible = true;





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






  @override
  void initState() {
    super.initState();



    print('printing videcontroller list');
    print(_videoControllersList);

    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _videoControllersList = List.generate(
      widget.storyDetailsList.length,
          (index) => _initializeVideoControllers(widget.storyDetailsList[index]["videoPaths"]),
    );


    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        setState(() {
          if (_chewieController != null) {
            _chewieController?.pause();
          }
        });
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        setState(() {
          if (_chewieController != null) {
            _chewieController?.pause();
          }
        });
      }
    });
    storyUserID = widget.storyDetailsList[_currentIndex]['userID'];


    // _toggleFullScreen();
    _initializeChewieController(_currentIndex, currentVideoIndex);
    _chewieController?.play();

    _chewieController?.enterFullScreen();

    print('printing videcontroller list again');
    print(_videoControllersList);

    fetchUserLocationAndData();
    fetchingStoriesUserID(storyUserID);



  }

  void fetchingStoriesUserID(String storyUserID){
    print('printitng story user ID');
    print(storyUserID);
    categoryData = [
      ...generateCategoryData(name: 'Other Related Story', apiEndpoint: '/main/api/trending-nearby-places'),
      ...generateCategoryData(name: 'Other Stories By ', apiEndpoint: 'api/stories/user/$storyUserID/genres/Street Foods,Restaurants,Fashion,Festival'),
    ];

  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Assuming the video has a 9:16 aspect ratio
    double videoAspectRatio = 9 / 16;

    _chewieController = ChewieController(
      videoPlayerController: _videoControllersList[_currentIndex][currentVideoIndex],
      placeholder: Container(
        color: Colors.black,
      ),
      autoPlay: true,
      looping: true,
      allowMuting: true,
      showControls: false,
      aspectRatio: videoAspectRatio,
    );
  }

  List<VideoPlayerController> _initializeVideoControllers(List<String> videoPaths) {
    return videoPaths.map((path) {
      String fullVideoUrl = 'http://173.212.193.109:8080/videos/$path';
      return VideoPlayerController.network(fullVideoUrl)..initialize();
    }).toList();
  }

  // void _toggleFullScreen() {
  //   setState(() {
  //     _isFullScreen = !_isFullScreen;
  //
  //     if (_isFullScreen) {
  //       SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  //     } else {
  //       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  //     }
  //   });
  // }


  void _initializeChewieController(int index, int videoIndex) {

    _chewieController = ChewieController(
      videoPlayerController: _videoControllersList[_currentIndex][currentVideoIndex],
      placeholder: Container(
        color: Colors.black,
      ),
      autoPlay: true,
      looping: true,
      allowMuting:true,
      allowedScreenSleep: false,
      showControls: false,
      aspectRatio: _videoControllersList[index][0].value.aspectRatio,

    );

    // _videoControllersList[_currentIndex][currentVideoIndex].addListener(() {
    //   if (_videoControllersList[_currentIndex][currentVideoIndex].value.position ==
    //       _videoControllersList[_currentIndex][currentVideoIndex].value.duration) {
    //     // Video has ended
    //     _playNextVideo();
    //   }
    // });


  }



  void _playNextVideo() {
    print('currentVideoIndex $currentVideoIndex');
    print('this thing ${_videoControllersList[_currentIndex].length - 1}');
    if (currentVideoIndex < _videoControllersList[_currentIndex].length - 1) {
      // Move to the next video in the current story

      currentVideoIndex++;

      _initializeChewieController(_currentIndex, currentVideoIndex);

      setState(() {
        showPlayPauseIcon = true;
        showNextVideoIcon = true;
        showPreviousVideoIcon = false;
      });

      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          showNextVideoIcon = false;

        });
      });
    } else {

      print('No more videos in the current story');
    }
  }

  void _playPreviousVideo() {
    print('currentVideoIndex $currentVideoIndex');
    print('this thing ${_videoControllersList[_currentIndex].length - 1}');
    if (currentVideoIndex > 0) {
      // Move to the previous video in the current story
      currentVideoIndex--;

      _initializeChewieController(_currentIndex, currentVideoIndex);

      setState(() {
        showPlayPauseIcon = true;
        showPreviousVideoIcon = true;
        showNextVideoIcon = false;
      });
    // } else if (_currentIndex > 0) {
    //   // Move to the previous story and play the last video of the previous story
    //   _currentIndex--;
    //
    //   // Set the currentVideoIndex to the last index of the new story
    //   currentVideoIndex = _videoControllersList[_currentIndex].length - 1;
    //
    //   _initializeChewieController(_currentIndex, currentVideoIndex);
    //
    //   setState(() {
    //     showPlayPauseIcon = true;
    //   });


      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          showPreviousVideoIcon = false;

        });
      });
    } else {
      print('Already at the first video in the current story');
    }
  }





  @override
  void dispose() {
    _scrollController.dispose();
    for (var controllers in _videoControllersList) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    _chewieController?.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        if (_chewieController != null) {
          _chewieController?.pause();
        }

        if(widget.where == 'home'){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
        if(widget.where == 'search'){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        }



        return false; // Returning true will allow the user to pop the page
      },
      child: WillPopScope(
        onWillPop: () async {
          // If you want to prevent the user from going back, return false
          // return false;

          // If you want to navigate directly to the homepage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );

          return false; // Returning true will allow the user to pop the page
        },
        child: Scaffold(
          body: PageView.builder(
            controller: _pageController,
            itemCount: widget.storyDetailsList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                showPlayPauseIcon = true;
                currentVideoIndex = 0;
                storyUserID = widget.storyDetailsList[_currentIndex]['userID'];
                fetchUserLocationAndData();
                fetchingStoriesUserID(storyUserID);
                if (_chewieController != null) {
                  _chewieController?.pause();
                }

              });
              _chewieController?.dispose();
              _initializeChewieController(_currentIndex, currentVideoIndex);

            },
            itemBuilder: (context, index) {
              return buildStoryPage(
                widget.storyDetailsList[index],
              );
            },
          ),

          bottomNavigationBar: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            height: _isVisible ? 70 : 0.0,
            child: CustomFooter(userName: userName, userId: userID, lode : 'dark'),
          ),
        ),
      ),
    );
  }

  Widget buildStoryPage(Map<String, dynamic> storyDetails) {



    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        // Handle scroll update here
        if (_chewieController != null && _chewieController!.isPlaying) {
          _chewieController?.pause();
          setState(() {
            showPlayPauseIcon = false;
          });
        }
        return false; // Return false to allow the notification to continue to be dispatched to further ancestors
      },
      child: ListView(
        children: [
          GestureDetector(
            onTapUp: (details) {
              double screenWidth = MediaQuery.of(context).size.width;

              double tapPosition = details.globalPosition.dx / screenWidth;

              if (tapPosition > 0.7) {
                print('right side tapped');
                _playNextVideo();
              } else if (tapPosition < 0.3) {
                print('left side tapped');
                _playPreviousVideo();
              } else {
                print('center tapped');
                // Toggle play/pause here
                if (_chewieController?.isPlaying == true) {
                  _chewieController?.pause();
                  showPlayPauseIcon = false;
                } else {
                  _chewieController?.play();
                  showPlayPauseIcon = true;
                }
                // Update the play/pause state
                setState(() {
                  isPlaying = !_chewieController!.isPlaying;

                });

                // Ensure that controls remain visible
                Future.delayed(Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _isVideoLoading = false; // Assume video is loaded after 2 seconds
                    });
                  }
                });
              }
            },
            child: Stack(
              children: [
                Container(

                  height: MediaQuery.of(context).size.height-101,
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                    // onDoubleTap: _toggleFullScreen,
                    child: Chewie(
                      controller: _chewieController ?? ChewieController(
                        videoPlayerController: _videoControllersList[_currentIndex][0],
                        aspectRatio: _videoControllersList[_currentIndex][0].value.aspectRatio,
                        autoInitialize: true,
                        showControls: false,
                        autoPlay: true,


                        placeholder: Container(
                          color: Theme.of(context).backgroundColor, // Change color to match your background
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),

                    ),
                  ),
                ),

                Visibility(
                  visible: showNextVideoIcon,
                  child: Positioned(
                    top: MediaQuery.of(context).size.height / 2 - 29,
                    right: 16,

                    child: Icon(
                      Icons.keyboard_double_arrow_right_outlined,
                      size: 58.0,
                      color: Colors.white70,
                    ),
                  ),
                ),

                Visibility(
                  visible: showPreviousVideoIcon,
                  child: Positioned(
                    top: MediaQuery.of(context).size.height / 2 - 29,
                    left: 16,

                    child: Icon(
                      Icons.keyboard_double_arrow_left_outlined,
                      size: 58.0,
                      color: Colors.white70,
                    ),
                  ),
                ),


                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: showPlayPauseIcon ? 0.0 : 1.0, // 1.0 for visible, 0.0 for invisible
                    duration: Duration(milliseconds: 200), // Adjust the duration as needed
                    child: Center(
                      child: Icon(
                        Icons.play_circle,
                        size: 58.0,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),



                Positioned(
                  top: 60,
                  right: 15,
                  child: Container(
                    height : 30,

                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0), // Adjust the value as needed
                        bottomRight: Radius.circular(15.0),

                        topRight: Radius.circular(15.0), // Adjust the value as needed
                        bottomLeft: Radius.circular(0.0),// Adjust the value as needed
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.turn_right,
                          color: Colors.white,
                          size: 24,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            '${storyDetails["storyDistance"]} km',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                Positioned(
                  top: 0,
                  left: 5,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                          _isFullScreen = false;
                        }, child: Text('< back',style: Theme.of(context).textTheme.headline5,))
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text('Location',style: Theme.of(context).textTheme.headline5,
                        ),

                        Container(
                          width: 100,
                          child: Text(
                            '${storyDetails["storyLocation"]}',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).backgroundColor,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          child: SvgPicture.asset(
                            'assets/images/heart.svg', // Replace with the path to your SVG file
                            // color: Color(0xFF001B33),
                            height :20,
                            width : 20,
                            color:Theme.of(context).primaryColor
                          ),
                        ),
                        Text(
                          ' 21',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                        Text(
                          ' 21',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 30,
                        ),
                        Text(
                          '${storyDetails["starRating"]}',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.share,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                        Text(
                          ' Share ',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 35),
                Row(
                  children: [
                    Text(
                      'Location : ',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      '${storyDetails["storyLocation"]}',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Category : ',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      '${storyDetails["storyCategory"]}',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Genre : ',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      '${storyDetails["genre"]}',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Uploader : ',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      '${storyDetails["userName"]}',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Container(height : 0.2,color : Color(0xFF001B33), width : double.infinity),

                SizedBox(height: 18),
                Text(
                  'Story Title',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  '${storyDetails["storyTitle"]}',
                  style: Theme.of(context).textTheme.subtitle2,
                ),

                SizedBox(height: 28),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  '${storyDetails["storyDescription"]}',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                SizedBox(height: 18),
                Text(
                  'What ${storyDetails["userName"]} Love About This Place ?',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  '${storyDetails["placeLoveDesc"]}',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                SizedBox(height: 18),
                Text(
                  'What ${storyDetails["userName"]} don`t like about About This Place ?',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  '${storyDetails["dontLikeDesc"]}',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                SizedBox(height: 18),
                Text(
                  'Connect with ${storyDetails["userName"]} for trip planning advice & guidance for your upcoming ${storyDetails["storyCityLocation"]} visits.',
                  style: Theme.of(context).textTheme.subtitle1,
                ),

                SizedBox(height: 18),
                Text(
                  'Cost of trip planning interaction call',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  '${storyDetails["dontLikeDesc"]}',
                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color : Colors.green,),
                ),

                SizedBox(height: 18),
                Text(
                  'Cost of Trip Assistance In ${storyDetails["storyCityLocation"]} .',
                  style: Theme.of(context).textTheme.subtitle1,
                ),

                Text(
                  '${storyDetails["dontLikeDesc"]}',
                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color : Colors.green,),
                ),

                SizedBox(height : 30),
                Container(height : 0.2,color : Color(0xFF001B33), width : double.infinity),
                SizedBox(height : 30),
                Center(
                  child: Container(
                    width : 250,
                    height: 63,
                    child: ElevatedButton(
                      onPressed: () async{

                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange, // Change background color
                        elevation: 0, // No shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(color: Colors.orange, width: 2.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.location_on_outlined),
                            color : Colors.white,
                            onPressed: () {
                              FinalProfile(userId:userID,clickedId: storyUserID,);
                            },

                          ),
                          Text(
                            'Follow Location',
                            style: TextStyle(
                              // Change text color
                              fontWeight: FontWeight.bold , // Change font weight
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height : 30),
                Container(height : 0.2,color : Color(0xFF001B33), width : double.infinity),

                SizedBox(height : 40),
                Container(
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height : 32,
                          width : 32,


                          child: Visibility(

                            // visible: widget.imagePath != null,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 20.0,

                            ),
                            replacement: SvgPicture.asset(
                              'assets/images/profile_icon.svg',
                              width: 50.0,
                              height: 50.0,
                            ),
                          ),




                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Check Visitor Profile', style:TextStyle(color : Colors.orange,fontWeight:FontWeight.bold,fontSize: 16)),
                            Text('${storyDetails["userName"]}',style:TextStyle(fontSize: 14)),
                          ],
                        ),

                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios_outlined),
                          color : Colors.orange,
                          onPressed: () {
                            print('userID');
                            print(userID);
                            print('storyuserID');
                            print(storyUserID);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                                create:(context) => ProfileDataProvider(),
                                child: FinalProfile(userId: userID,clickedId: storyUserID,),
                              ),),
                            );

                          },

                        ),


                      ],
                    )

                ),
                SizedBox(height : 30),

                Container(height : 0.2,color : Color(0xFF001B33), width : double.infinity),






              ],
            ),
          ),  Column(

            children: categoryData.asMap().entries.map((entry) {
              final int categoryIndex = entry.key;
              final Map<String, dynamic> category = entry.value;


              final String specificCategoryName = category['specificName'];
              final String categoryName = category['name'];
              final String whereTo = '';
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
                whereTo,
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
          ), // Show loader when video is loading
        ],
      ),
    )
    ;
  }
}




