import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learn_flutter/CustomItems/CostumAppbar.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/SignUp/FourthPage.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/VIdeoSection/ComposePage.dart';

void main() {
  runApp(MaterialApp(
    home: VideoPreviewPage(
      videoPaths: ['video1.mp4', 'video2.mp4', 'video3.mp4'], // Example video paths
    ),
  ));
}

class VideoPreviewPage extends StatefulWidget {
  final List<String> videoPaths;

  VideoPreviewPage({required this.videoPaths});

  @override
  _VideoPreviewPageState createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:VideoAppBar(),

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
                    videoNumber: index + 1, // Add the video number
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
                                  removeVideo(index);
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ComposePage(videoPaths: widget.videoPaths)),
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

  void removeVideo(int index) {
    setState(() {
      widget.videoPaths.removeAt(index);
    });
  }
}
class VideoItem extends StatefulWidget {
  final String videoPath;
  final int videoNumber; // Add a video number property
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
              // Add the video number on the left side
              Positioned(
                top: 8.0,
                left: 8.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // This makes the container circular
                    border: Border.all(
                      color: Colors.white, // Border color
                      width: 2.0, // Border width
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent, // Background color of the CircleAvatar
                    child: Text(
                      widget.videoNumber.toString(),
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )

              ),
              // Add the remove button (position unchanged)
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


class FourthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fourth Page'),
      ),
      body: Center(
        child: Text('This is the Fourth Page.'),
      ),
    );
  }
}
