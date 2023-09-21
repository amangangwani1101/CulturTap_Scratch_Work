import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learn_flutter/SignUp/FourthPage.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:video_player/video_player.dart';

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

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                    onClosePressed: () {
                      // Display a confirmation dialog before removing the video.
                      showDialog(
                        context: context,
                        builder: (context) {
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
                                  // Remove the video and update the UI.
                                  removeVideo(index);
                                  Navigator.of(context).pop(); // Close the dialog
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

  void removeVideo(int index) {
    setState(() {
      widget.videoPaths.removeAt(index);
    });
  }
}

class VideoItem extends StatefulWidget {
  final String videoPath;
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
