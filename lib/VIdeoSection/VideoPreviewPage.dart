import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/VIdeoSection/ComposePage.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';




Map<String, List<VideoInfo>> videoData = {};

class VideoInfo {
  final String videoUrl;
  final double latitude;
  final double longitude;

  VideoInfo({
    required this.videoUrl,
    required this.latitude,
    required this.longitude,
  });
}

class VideoPreviewPage extends StatefulWidget {
  final List<String> videoPaths;
  final String userLocation;
  final double latitude;
  final double longitude;


  VideoPreviewPage({
    required this.videoPaths,
    required this.userLocation,
    required this.latitude,
    required this.longitude,
  });

  @override
  _VideoPreviewPageState createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  double? firstVideoLatitude;
  double? firstVideoLongitude;
  @override
  void initState() {
    super.initState();

    // Add videos to videoData when the page loads

    for (int i = 0; i < widget.videoPaths.length; i++) {
      addVideo(widget.userLocation, widget.videoPaths[i], widget.latitude, widget.longitude);

      // Save the latitude and longitude of the first video
      if (i == 0) {
        firstVideoLatitude = widget.latitude;
        firstVideoLongitude = widget.longitude;
      }




    }


  }

  void addVideo(String location, String videoUrl, double latitude, double longitude) {
    final videoInfo = VideoInfo(
      videoUrl: videoUrl,
      latitude: latitude,
      longitude: longitude,
    );

    videoData[location] = [videoInfo];


  }

  void removeVideo(String videoPath) {
    setState(() {
      // Find the location associated with the videoPath
      String location = widget.userLocation;

      if (videoData.containsKey(location)) {
        // Find the index of the video with the given path within the location
        int index = videoData[location]!.indexWhere((videoInfo) => videoInfo.videoUrl == videoPath);

        if (index != -1) {
          // Remove the video info from videoData
          videoData[location]!.removeAt(index);

          // If there are no videos left for that location, remove the location key
          if (videoData[location]!.isEmpty) {
            videoData.remove(location);
          }
        }
      }

      // Remove the video path from widget.videoPaths
      int pathIndex = widget.videoPaths.indexOf(videoPath);
      if (pathIndex != -1) {
        widget.videoPaths.removeAt(pathIndex);
      }
    });

    if (widget.videoPaths.isEmpty) {
      Navigator.pop(context);
    }



  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VideoAppBar(),
      body: Container(
        color: Color(0xFF263238),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: widget.videoPaths.length,
                itemBuilder: (context, index) {
                  return VideoItem(
                    videoPath: widget.videoPaths[index],
                    videoNumber: index + 1,
                    onClosePressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          Color myHexColor = Color(0xFF263238);
                          return AlertDialog(
                            backgroundColor: myHexColor,
                            icon: Center(child: Image.asset('assets/images/remove.png')),
                            title: Text('Are You Sure ?', style: TextStyle(color: Colors.white)),
                            content: Container(
                              height: 15,
                              child: Center(child: Text('you are removing a film shoot.', style: TextStyle(color: Colors.white))),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel', style: TextStyle(color: Colors.orange)),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Remove video logic here
                                  removeVideo(widget.videoPaths[index]);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Remove', style: TextStyle(color: Colors.orange)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 90,
                    height: 50,
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  value: 1,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange,
                                  ),
                                  strokeWidth: 10.0,
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: IconButton(
                                  icon: Image.asset("assets/images/addNewButton.png"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'Add New Film',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        child: Container(
                          height: 100,
                          width: 80,
                          child: IconButton(
                            icon: Image.asset("assets/images/next_button.png"),
                            onPressed: () {
                              // Navigate to the next page
                              if (firstVideoLatitude != null && firstVideoLongitude != null) {
                                // Navigate to the custom page with latitude and longitude
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ComposePage(
                                      latitude: firstVideoLatitude!,
                                      longitude: firstVideoLongitude!,
                                      videoPaths: widget.videoPaths,
                                      videoData: videoData,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Text(
                        'Next',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
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
  }
}

class VideoItem extends StatefulWidget {
  final String videoPath;
  final int videoNumber;
  final VoidCallback? onClosePressed;

  VideoItem({required this.videoPath, required this.videoNumber, this.onClosePressed});

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      _controller.setVolume(1.0);
      _controller.play();
    } else {
      _controller.setVolume(0.0);
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _togglePlayPause();
      },
      onLongPress: () {
        _toggleFullScreen();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 4.0),
          ),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 2 / 3.15,
                child: VideoPlayer(_controller),
              ),
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 8.0,
                left: 8.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Text(
                      widget.videoNumber.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8.0,
                right: 8.0,
                child: IconButton(
                  onPressed: widget.onClosePressed,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
