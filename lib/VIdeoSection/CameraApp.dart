import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewPage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: CameraApp(cameras: cameras, camera: firstCamera),
    ),
  );
}

class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraDescription camera;

  CameraApp({Key? key, required this.cameras, required this.camera})
      : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  bool isRecording = false;
  bool _isRecording = false;
  double _progressValue = 0.0;
  int _recordDurationInSeconds = 60;
  double _currentProgress = 0.0;
  List<String> recordedVideoPaths = [];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> saveVideo(File videoFile) async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoPath = '${appDirectory.path}/recorded_video.mp4';
    await videoFile.copy(videoPath);
  }

  void startRecording() async {
    await _controller.startVideoRecording();
    setState(() {
      _isRecording = true;
      _currentProgress = 0.0;
    });

    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentProgress += 0.00166666667;
      });

      if (_currentProgress >= 1.0) {
        stopRecording();
        timer.cancel();
      }
    });
  }

  void stopRecording() async {
    XFile? videoFile = await _controller.stopVideoRecording();
    setState(() {
      _isRecording = false;
      _currentProgress = 0.0;
    });

    if (videoFile != null) {
      String videoPath = videoFile.path;
      print("path of video file has to be printed" + videoPath);
      saveVideo(File(videoPath));

      recordedVideoPaths.add(videoPath);

      // Navigate to the Video Preview page using the navigatorKey
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => VideoPreviewPage(videoPaths: recordedVideoPaths),
        ),
      );
    }
  }

  void toggleCamera() async {
    CameraLensDirection newLensDirection;
    if (_controller.description.lensDirection == CameraLensDirection.front) {
      newLensDirection = CameraLensDirection.back;
    } else {
      newLensDirection = CameraLensDirection.front;
    }

    final newCamera = widget.cameras.firstWhere(
          (camera) => camera.lensDirection == newLensDirection,
    );

    if (_controller.value.isRecordingVideo) {
      await _controller.stopVideoRecording();
    }

    if (_controller.value.isStreamingImages) {
      await _controller.stopImageStream();
    }

    await _controller.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _controller.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_controller),
          Text(
            _isRecording ? 'Recording...' : '',
            style: TextStyle(
              color : Colors.white60,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 90,
                    height: 80,
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _isRecording ? stopRecording : startRecording,
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: _isRecording ? _currentProgress : 0.0,
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
                                child: Icon(
                                  _isRecording
                                      ? Icons.pause_circle
                                      : Icons.circle,
                                  size: 69,
                                  color: _isRecording
                                      ? Colors.white60
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'Start Filming',
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

                          child: IconButton(
                            icon: Image.asset("assets/images/flip_camera.png"),
                            onPressed: toggleCamera,

                          ),
                        ),
                      ),
                      Text(
                        'Flip',
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
          ),
        ],
      ),
    );
  }
}
