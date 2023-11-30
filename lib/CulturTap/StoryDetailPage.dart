import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:learn_flutter/CulturTap/custom_control.dart';
import 'package:video_player/video_player.dart';

class StoryDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> storyDetailsList;
  final int initialIndex;
  final List<String> storyUrls;


  StoryDetailPage({
    required this.storyUrls,
    required this.storyDetailsList,
    required this.initialIndex,
  });

  @override
  _StoryDetailPageState createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  bool isPlaying = true;
  late PageController _pageController;
  int _currentIndex = 0;
  List<List<VideoPlayerController>> _videoControllersList = [];

  ChewieController? _chewieController;
  bool _isVideoLoading = true;
  bool showPlayPauseIcon = true;
  bool showPauseIcon = false;
  int currentVideoIndex = 0;



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

    _initializeChewieController(_currentIndex, currentVideoIndex);

    print('printing videcontroller list again');
    print(_videoControllersList);

  }

  List<VideoPlayerController> _initializeVideoControllers(List<String> videoPaths) {
    return videoPaths.map((path) {
      String fullVideoUrl = 'http://173.212.193.109:8080/videos/$path';
      return VideoPlayerController.network(fullVideoUrl)..initialize();
    }).toList();
  }



  void _initializeChewieController(int index, int videoIndex) {

    _chewieController = ChewieController(
      videoPlayerController: _videoControllersList[_currentIndex][currentVideoIndex],
      placeholder: Container(
        color: Colors.black,
      ),
      autoPlay: true,
      looping: false,
      allowMuting: false,
      allowedScreenSleep: false,
      showControls: false,
      aspectRatio: _videoControllersList[index][0].value.aspectRatio,
    );
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
    } else {
      print('Already at the first video in the current story');
    }
  }


  // void _playPreviousVideo() {
  //   // Check if there are more videos in the current story
  //   if (_videoControllersList[_currentIndex].length > 1) {
  //     // Move to the previous video in the current story
  //     if (_currentIndex > 0) {
  //
  //       _currentIndex--;
  //
  //       _initializeChewieController(_currentIndex,);
  //
  //       setState(() {});
  //     }
  //   } else if (_currentIndex > 0) {
  //     // Move to the previous story and play the last video of the previous story
  //
  //     _currentIndex--;
  //
  //     _initializeChewieController(_currentIndex);
  //
  //     setState(() {});
  //   }
  // }


  @override
  void dispose() {
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
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          double screenWidth = MediaQuery.of(context).size.width;
          double tapPosition = details.globalPosition.dx / screenWidth;

          if (tapPosition > 0.7) {
            print('right side tapped');
            _playNextVideo();
          } else if (tapPosition < 0.3) {
            print('left side tapped');
            // _playPreviousVideo();
          } else {
            print('center tapped');
            // Toggle play/pause here
            // showPlayPauseIcon = true;

            if (_chewieController?.isPlaying == true) {

              showPlayPauseIcon = true;
              _chewieController?.pause();
            } else {
              _chewieController?.play();
              showPlayPauseIcon = false;
            }
            // Update the play/pause state
            setState(() {
              isPlaying = !_chewieController!.isPlaying;
            });
          }
        },

        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.storyDetailsList.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
              showPlayPauseIcon = true;
              currentVideoIndex = 0;
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
      ),
    );
  }

  Widget buildStoryPage(Map<String, dynamic> storyDetails) {
    return ListView(
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
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Chewie(
                  controller: _chewieController ?? ChewieController(
                    videoPlayerController: _videoControllersList[_currentIndex][0],
                    aspectRatio: _videoControllersList[_currentIndex][0].value.aspectRatio,
                    autoInitialize: true,
                    showControls: false,

                    placeholder: Container(
                      color: Colors.black, // Change color to match your background
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
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
                top: 105,
                right: 35,
                child: Container(
                  height : 30,

                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0), // Adjust the value as needed
                      bottomRight: Radius.circular(10.0),

                      topRight: Radius.circular(10.0), // Adjust the value as needed
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
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                      TextButton(onPressed: () {}, child: Text('< back', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 95,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Local Visits', style: TextStyle(color: Colors.white, fontSize: 17)),
                      Container(
                        width: 100,
                        child: Text(
                          '${storyDetails["storyLocation"]}',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
                      Icon(
                        Icons.heart_broken,
                        color: Colors.grey,
                        size: 30,
                      ),
                      Text(
                        ' 21',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        color: Colors.grey,
                        size: 30,
                      ),
                      Text(
                        ' 21',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF263238),
                        ),
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
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.grey,
                        size: 30,
                      ),
                      Text(
                        ' Share ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF263238),
                        ),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                  Text(
                    '${storyDetails["storyLocation"]}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Category : ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                  Text(
                    '${storyDetails["storyCategory"]}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Genre : ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                  Text(
                    '${storyDetails["genre"]}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Uploader : ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                  Text(
                    '${storyDetails["uploader"]}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Text(
                'Story Title',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              Text(
                '${storyDetails["storyTitle"]}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              Text(
                '${storyDetails["storyDescription"]}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 18),
              Text(
                'What ${storyDetails["user"]} Love About This Place',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              Text(
                '${storyDetails["placeLoveDesc"]}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 18),
              Text(
                'What ${storyDetails["user"]} don`t like about About This Place',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              Text(
                '${storyDetails["dontLikeDesc"]}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 18),
              Text(
                'Connect with ${storyDetails["user"]} for trip planning advice & guidance for your upcoming Bengaluru visits.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              Text(
                '${storyDetails["connectDesc"]}',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        _isVideoLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : SizedBox(), // Show loader when video is loading
      ],
    );
  }
}
