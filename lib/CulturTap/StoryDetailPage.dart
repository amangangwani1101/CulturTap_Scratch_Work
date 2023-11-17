import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class StoryDetailPage extends StatefulWidget {
  final List<String> storyUrls;
  final List<Map<String, dynamic>> storyDetailsList;
  final int initialIndex;

  StoryDetailPage({
    required this.storyUrls,
    required this.storyDetailsList,
    required this.initialIndex,
  });

  @override
  _StoryDetailPageState createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;

    _initializeVideoPlayer();

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isPlaying &&
          _videoPlayerController.value.position ==
              _videoPlayerController.value.duration) {
        _playNextVideo();
      }
    });
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.network(
      widget.storyUrls[_currentIndex],
    );

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowMuting: false,
      allowedScreenSleep: false,
      showControls: true,
    );
  }

  void _playNextVideo() {
    if (_currentIndex < widget.storyUrls.length - 1) {
      setState(() {
        _currentIndex++;
      });

      _videoPlayerController.dispose();
      _initializeVideoPlayer();
    }
  }

  void _playPreviousVideo() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });

      _videoPlayerController.dispose();
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          // Get the width of the screen
          double screenWidth = MediaQuery.of(context).size.width;

          // Calculate the tap position relative to the screen width
          double tapPosition = details.globalPosition.dx / screenWidth;

          // If tapped on the right side, play the next video; if tapped on the left side, play the previous video
          if (tapPosition > 0.5) {
            print('Tapped on the right side');
            _playNextVideo();
          } else {
            print('Tapped on the left side');
            _playPreviousVideo();
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.storyUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return buildStoryPage(
              widget.storyUrls[index],
              widget.storyDetailsList[index],
            );
          },
        ),
      ),
    );
  }



  Widget buildStoryPage(String videoUrl, Map<String, dynamic> storyDetails) {
    return ListView(
      children: [
        GestureDetector(
          onTap: () {
            // Toggle play/pause on video tap
            if (_videoPlayerController.value.isPlaying) {
              _videoPlayerController.pause();
            } else {
              _videoPlayerController.play();
            }
          },
          child: Chewie(
            controller: _chewieController,
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
      ],
    );
  }
}
