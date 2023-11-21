import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

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
   ChewieController? _chewieController;
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
  Future<void> _initializeVideoPlayer() async {
    List<String> videoPaths = widget.storyDetailsList[_currentIndex]["videoPaths"];
    print('videoPaths in storyDetailsPage $videoPaths');
    String initialVideoPath = videoPaths.first;

    // Construct the full video URL based on your server URL and video path
    String fullVideoUrl = 'http://173.212.193.109:8080/videos$initialVideoPath';

    _videoPlayerController = VideoPlayerController.network(fullVideoUrl);

    // Fetch the first video in the list initially
    await _fetchAndPlayVideo(initialVideoPath);

    // Wait for the video to initialize
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      placeholder: Container(
        color: Colors.grey,
      ),
      autoPlay: true,
      looping: false,
      allowMuting: false,
      allowedScreenSleep: false,
      showControls: true,
    );

    setState(() {});
  }

  Future<void> _fetchAndPlayVideo(String videoPath) async {
    String fullVideoUrl = 'http://173.212.193.109:8080/videos/$videoPath';
    print('this is the video url $fullVideoUrl');

    var response = await http.get(Uri.parse(fullVideoUrl));

    if (response.statusCode == 200) {
      // Dispose the old controllers before creating new ones
      _videoPlayerController.dispose();
      _chewieController?.dispose();

      // Create new controllers
      _videoPlayerController = VideoPlayerController.network(fullVideoUrl);
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        placeholder: Container(
          color: Colors.grey,
        ),
        autoPlay: true,
        looping: false,
        allowMuting: false,
        allowedScreenSleep: false,
        showControls: true,
      );

      // Update the state to reflect the new video
      setState(() {});
    } else {
      // Handle errors, e.g., video not found, server error, etc.
      print('Failed to fetch video: ${response.statusCode}');
    }
  }


  void _playNextVideo() {
    if (_currentIndex < widget.storyUrls.length - 1) {
      _videoPlayerController.dispose();
      _chewieController?.dispose();
      _initializeVideoPlayer();
      setState(() {
        _currentIndex++;
      });


    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    // Check if _chewieController is initialized before disposing
    if (_chewieController != null) {
      _chewieController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          double screenWidth = MediaQuery.of(context).size.width;
          double tapPosition = details.globalPosition.dx / screenWidth;

          if (tapPosition > 0.5) {
            print('Tapped on the right side');
            _playNextVideo();
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.storyUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            _videoPlayerController.dispose();
            _initializeVideoPlayer();
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
          onTapUp: (details) {
            double screenWidth = MediaQuery.of(context).size.width;
            double tapPosition = details.globalPosition.dx / screenWidth;

            if (tapPosition > 0.5) {
              print('right side tapped');
              _playNextVideo();
            }
          },
          child: Chewie(
            controller: _chewieController ?? ChewieController(
              videoPlayerController: _videoPlayerController,
            ),
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
