import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
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

  Geolocator _geolocator = Geolocator();
  Position? _startPosition;
  bool hasRecordedVideos = false; // Add this variable

  late CameraController _controller;
  bool _isRecording = false;
  int _remainingRecordingTime = 60;
  bool _showRecordingMessage = false;
  late Timer? _countdownTimer;

  double _progressValue = 0.0;
  int _recordDurationInSeconds = 60;
  double _currentProgress = 0.0;
  List<String> recordedVideoPaths = [];
  String liveLocation = '';
  double liveLatitude = 0.0;
  double liveLongitude = 0.0;

  @override
  void initState() {
    super.initState();

    // Check if at least one video has been recorded


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

  void updateCloseButtonVisibility() {
    setState(() {
      if (recordedVideoPaths.isNotEmpty) {
        hasRecordedVideos = true;
      } else {
        hasRecordedVideos = false;
      }
    });
  }

  Future<void> fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // Format the user's location into a string
      String location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      double latitude = position.latitude; // Get the latitude from the user's location
      double longitude = position.longitude; // Get the longitude from the user's location



      setState(() {
        liveLocation = location;
        liveLatitude = latitude;
        liveLongitude = longitude;
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> saveVideo(File videoFile) async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoPath = '${appDirectory.path}/recorded_video.mp4';
    await videoFile.copy(videoPath);
  }

  void startRecording() async {
    fetchUserLocation();
    await _controller.startVideoRecording();

    setState(() {
      _isRecording = true;
      _currentProgress = 0.0;
    });




    _showRecordingMessage = true;
    Timer(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showRecordingMessage = false;
        });
      }
    });

    _remainingRecordingTime = 60;
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingRecordingTime > 0) {
        setState(() {
          _remainingRecordingTime--;
        });
      } else {
        timer.cancel();
      }
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

  // Function to navigate to the video preview page
  void navigateToPreviewPage() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => VideoPreviewPage(
          videoPaths: recordedVideoPaths,
          userLocation: liveLocation,
          latitude: liveLatitude,
          longitude: liveLongitude,
        ),
      ),
    );
  }



  void stopRecording() async {
    XFile? videoFile = await _controller.stopVideoRecording();
    setState(() {
      _isRecording = false;
      _currentProgress = 0.0;
    });

    if (videoFile != null) {
      updateCloseButtonVisibility();
      String videoPath = videoFile.path;
      print("path of video file has to be printed" + videoPath);
      saveVideo(File(videoPath));

      recordedVideoPaths.add(videoPath);

      // Navigate to the Video Preview page using the navigatorKey
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => VideoPreviewPage(
            videoPaths: recordedVideoPaths,
            userLocation: liveLocation,
            latitude : liveLatitude,
            longitude : liveLongitude ,

          ),
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

          if (hasRecordedVideos)
            Positioned(
              top: 50,
              right: 30,
              child: GestureDetector(
                onTap: navigateToPreviewPage,
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),


          Positioned(
            bottom : 190,
            left: 10,
            right: 0,
            child: Column(
              children: <Widget>[
                Text(
                  _showRecordingMessage ? 'Recording Started' : '',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isRecording ? 'Time Remaining: $_remainingRecordingTime' : '',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Container(
              // ... rest of your code for the "Start Filming" button and flip camera button
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
