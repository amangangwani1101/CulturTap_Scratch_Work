import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import "package:learn_flutter/Utils/BackButtonHandler.dart";
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/VideoPreviewPage.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/video_database_helper.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/video_info2.dart';
import 'package:permission_handler/permission_handler.dart';
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
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Colors.orange, // Set your primary color

      ),
      home: CameraApp(),
    ),
  );
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {

  late VideoDatabaseHelper _databaseHelper;

  List<CameraDescription> cameras = [];
  Geolocator _geolocator = Geolocator();
  Position? _startPosition;
  bool hasRecordedVideos = false;

  CameraController? _controller;
  bool _isRecording = false;
  int _remainingRecordingTime = 60;
  bool _showRecordingMessage = false;
  late Timer? _countdownTimer;

  double _currentProgress = 0.0;
  List<String> recordedVideoPaths = [];
  String liveLocation = '';
  double liveLatitude = 0.0;
  double liveLongitude = 0.0;
  bool locationgranted = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    _databaseHelper = VideoDatabaseHelper();
    requestLocationPermission();


    // Check if at least one video has been recorded
    updateCloseButtonVisibility();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void updateCloseButtonVisibility() {
    setState(() {
      hasRecordedVideos = recordedVideoPaths.isNotEmpty;
    });
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      fetchUserLocation();
      locationgranted=true;
    } else {

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomePage()),
      // );


      stopRecording;
      // Handle denied location permission

    }
  }

  Future<void> saveVideoToDatabase(String videoPath, double latitude, double longitude) async {
    try {
      // Create a VideoInfo object
      VideoInfo2 videoInfo = VideoInfo2(
        videoUrl: videoPath,
        latitude: latitude,
        longitude: longitude,
      );


      await _databaseHelper.insertVideo(videoInfo);

      print('Video added to the local database.');
    } catch (e) {
      print('Error adding video to the local database: $e');
    }
  }


  Future<void> fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      String location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      double latitude = position.latitude;
      double longitude = position.longitude;

      setState(() {
        liveLocation = location;
        liveLatitude = latitude;
        liveLongitude = longitude;
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }
  //
  // Future<void> saveVideo(File videoFile) async {
  //   final Directory appDirectory = await getApplicationDocumentsDirectory();
  //   final String videoPath = '${appDirectory.path}/recorded_video.mp4';
  //   await videoFile.copy(videoPath);
  // }
  //

  void startRecording() async {


    requestLocationPermission();

      await _controller!.startVideoRecording();

      setState(() {
        _isRecording = true;
        _currentProgress = 0.0;
        _remainingRecordingTime = 60;
      });

      _showRecordingMessage = true;
      Timer(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showRecordingMessage = false;
          });
        }
      });


      _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingRecordingTime > 0) {
          setState(() {
            _remainingRecordingTime--;
            _currentProgress = (60 - _remainingRecordingTime) / 60;
          });
        } else {
          stopRecording();
          timer.cancel();
        }
      });




    //for smooth timing
    // Timer.periodic(Duration(milliseconds: 100), (timer) {
    //   setState(() {
    //     _currentProgress += 0.00166666667;
    //   });
    //
    //   if (_currentProgress >= 1.0) {
    //     stopRecording();
    //     timer.cancel();
    //   }
    // });
  }

  void navigateToPreviewPage(BuildContext context) async{
    bool hasVideos = await VideoDatabaseHelper().hasVideos();
    if (hasVideos) {
      // Navigate to VideoPreviewPage with data from the database
      List<VideoInfo2> videos = await _databaseHelper.getAllVideos();
      List<VideoInfo2> allVideos = await VideoDatabaseHelper().getAllVideos();

      // Extract the required data from the list of videos
      List<String> videoPaths = videos.map((video) => video.videoUrl).toList();
      String userLocation = ''; // Replace with your logic to get user location
      double latitude = allVideos[0].latitude;
      double longitude = allVideos[0].longitude;

      print('latitude : $latitude');
      print('longitude : $longitude');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPreviewPage(
            videoPaths: videoPaths,
            userLocation: userLocation,
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      );
    } else {
      // Navigate to CameraApp
      Navigator.push(context, MaterialPageRoute(builder: (context) => CameraApp()));
    }
  }


  void stopRecording() async {
    _countdownTimer?.cancel();
    XFile? videoFile = await _controller!.stopVideoRecording();



    setState(() {

      _isRecording = false;
      _currentProgress = 0.0;
      _remainingRecordingTime = 60;




    });

    if (videoFile != null) {
      updateCloseButtonVisibility();
      String videoPath = videoFile.path;

      saveVideoToDatabase(videoPath, liveLatitude, liveLongitude);


      recordedVideoPaths.add(videoPath);

      // Save video information to the database



      print('navigating to preview page');
      navigateToPreviewPage(context);
      print('navigated to preview page');
    }
  }

  void toggleCamera() async {
    if (_controller != null && _controller!.value.isRecordingVideo) {
      // If recording, stop recording before flipping the camera
      stopRecording();
      return;
    }

    final cameras = await availableCameras();
    final newCameraDescription = _controller!.description == cameras.first
        ? cameras.last
        : cameras.first;

    if (_controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }

    await _controller!.dispose();

    _controller = CameraController(
      newCameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    setState(() {});
  }


  void initializeAndSwitchCamera() async {
    CameraDescription newCamera;

    if (_controller!.description.lensDirection == CameraLensDirection.back) {
      newCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } else {
      newCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    }

    await _controller!.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  BackButtonHandler backButtonHandler = BackButtonHandler(
    imagePath: 'assets/images/exit.svg',
    textField: 'homepage,',
    what: 'back',
  );


  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
          body: Container(
            color: Color(0xFF263238),
            child: Center(
              child: CircularProgressIndicator(

                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.orange,

                ),
              ),
            ),
          ),
        );
    } else {
      return WillPopScope(
        onWillPop: () => backButtonHandler.onWillPop(context, true),
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CameraPreview(_controller!),
              if (hasRecordedVideos)
                Positioned(
                  top: 50,
                  right: 30,
                  child: GestureDetector(
                    onTap: (){
                      navigateToPreviewPage(context);
                    } ,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              Positioned(
                bottom: 190,
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
                      _isRecording ? ' $_remainingRecordingTime sec' : ' ',
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
                            height: 100,
                            width: 80,
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
            ],
          ),
        ),
      );
    }
  }
}
