import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoSelectionScreen(),
    );
  }
}

class VideoSelectionScreen extends StatefulWidget {
  @override
  _VideoSelectionScreenState createState() => _VideoSelectionScreenState();
}

class _VideoSelectionScreenState extends State<VideoSelectionScreen> {
  VideoPlayerController? _videoController;
  late String _selectedVideoPath;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedVideoPath = pickedFile.path;
        _videoController = VideoPlayerController.file(File(_selectedVideoPath))
          ..initialize().then((_) {
            // Ensure the first frame is shown
            setState(() {});
          });
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_videoController != null && _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            else
              Icon(
                Icons.video_library,
                size: 100.0,
                color: Colors.grey,
              ),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text('Pick a Video'),
            ),
          ],
        ),
      ),
    );
  }
}
