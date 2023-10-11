import 'dart:io';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:learn_flutter/SignUp/FourthPage.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:video_player/video_player.dart';
=======
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/VIdeoSection/ComposePage.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';

void main() {
  runApp(MaterialApp(
    home: VideoPreviewPage(
      videoPaths: [],
      userLocation: '',
      latitude: 0.0,
      longitude: 0.0,
    ),
  ));
}
>>>>>>> protectedfile1

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
  @override
  void initState() {
    super.initState();

    // Add videos to videoData when the page loads

    for (int i = 0; i < widget.videoPaths.length; i++) {
      addVideo(widget.userLocation, widget.videoPaths[i], widget.latitude, widget.longitude);
      print("this is the given data");

    }
  }

  void addVideo(String location, String videoUrl, double latitude, double longitude) {
    final videoInfo = VideoInfo(
      videoUrl: videoUrl,
      latitude: latitude,
      longitude: longitude,
    );

    // Check if the location already exists in the map
    if (videoData.containsKey(location)) {
      // If the location exists, add the video info to the existing list
      videoData[location]!.add(videoInfo);
    } else {
      // If the location doesn't exist, create a new list with the video info
      videoData[location] = [videoInfo];
    }
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

    // Force an immediate update of the UI by pushing and popping a new instance of the current page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => VideoPreviewPage(
          videoPaths: widget.videoPaths,
          userLocation: widget.userLocation,
          latitude: widget.latitude,
          longitude: widget.longitude,
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD

      appBar:VideoAppBar(),


=======
      appBar: VideoAppBar(),
>>>>>>> protectedfile1
      body: Container(
        color: Color(0xFF263238),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns
                  childAspectRatio: 2 / 4, // Width / Height ratio for videos
                ),
                itemCount: widget.videoPaths.length,
                itemBuilder: (context, index) {
                  return VideoItem(
                    videoPath: widget.videoPaths[index],
<<<<<<< HEAD
=======
                    videoNumber: index + 1,
>>>>>>> protectedfile1
                    onClosePressed: () {
                      // Display a confirmation dialog before removing the video.
                      showDialog(
                        context: context,
                        builder: (context) {
<<<<<<< HEAD
=======
                          Color myHexColor = Color(0xFF263238);
>>>>>>> protectedfile1
                          return AlertDialog(
                            title: Text('Confirm Video Removal'),
                            content: Text('Are you sure you want to remove this video?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
<<<<<<< HEAD
                                  // Remove the video and update the UI.
                                  removeVideo(index);
                                  Navigator.of(context).pop(); // Close the dialog
=======
                                  // Remove video logic here
                                  removeVideo(widget.videoPaths[index]);
                                  Navigator.of(context).pop();
>>>>>>> protectedfile1
                                },
                                child: Text('Remove'),
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
                                  value :1,

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
                                  onPressed: (){
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
                          height : 100,
                          width : 80,

                          child:IconButton(
                            icon: Image.asset("assets/images/next_button.png"),
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FourthPage()),
                              );
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
<<<<<<< HEAD
=======
  final int videoNumber;
>>>>>>> protectedfile1
  final VoidCallback? onClosePressed;

  VideoItem({required this.videoPath, this.onClosePressed});

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Toggle play/pause when tapping on the video.
        _togglePlayPause();
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
<<<<<<< HEAD
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(), // Empty space to maintain spacing
                if (widget.onClosePressed != null)
                  IconButton(
                    onPressed: widget.onClosePressed,
                    icon: Icon(Icons.close),

=======
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
>>>>>>> protectedfile1
                  ),
              ],
            ),
          ],
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
