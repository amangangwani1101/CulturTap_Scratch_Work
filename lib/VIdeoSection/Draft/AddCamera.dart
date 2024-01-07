import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_flutter/HomePage.dart';
import "package:learn_flutter/Utils/BackButtonHandler.dart";
import 'package:learn_flutter/VIdeoSection/Draft/EditDraftPage.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/database_helper.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';







import 'package:torch_light/torch_light.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   final firstCamera = cameras.first;
//   runApp(
//     MaterialApp(
//       navigatorKey: navigatorKey,
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'Poppins',
//         primaryColor: Colors.orange, // Set your primary color
//
//       ),
//       home: AddCamera(),
//     ),
//   );
// }

class AddCamera extends StatefulWidget {
  final Draft draft;



  AddCamera({required this.draft});

  @override
  _AddCameraState createState() => _AddCameraState();
}

class _AddCameraState extends State<AddCamera> {
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 2.0;



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
  final player = AudioPlayer();

  bool isFlipped = false;

  bool locationFetched = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();


    // if(){
    //   hasRecordedVideos = true;
    // }
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

  void updateCloseButtonVisibility() async{

    bool hasVideos = true;
    setState(() {
      if(hasVideos){
        hasRecordedVideos = true;
      }


    });
  }


  void onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _currentZoom *= details.scale;

      // Ensure zoom stays within valid range
      if (_currentZoom < 1.0) {
        _currentZoom = 1.0;
      } else if (_currentZoom > _maxZoom) {
        _currentZoom = _maxZoom;
      }

      // Apply zoom to the camera controller
      _controller!.setZoomLevel(_currentZoom);
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



  Future<void> fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      String location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      double latitude = position.latitude;
      double longitude = position.longitude;

      if(latitude != 0.0 && longitude != 0.0 ){
        setState(() {
          liveLocation = location;
          liveLatitude = latitude;
          liveLongitude = longitude;
          locationFetched = true;
        });
      } else(){
        print('finding users lcoation when user start recording');
        fetchUserLocation();
      };


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



  void playSound() async{
    // AudioPlayer player = AudioPlayer();

    final player = AudioPlayer();
    await player.play(UrlSource('https://example.com/my-audio.wav'));
  }


  void startRecording() async {



    requestLocationPermission();

    if(locationFetched == true){
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
    }




  }




  bool _isFlashlightOn = false;

  void toggleFlashlight() async {
    try {
      bool hasTorch = await TorchLight.isTorchAvailable();

      if (hasTorch) {
        if (_isFlashlightOn) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }

        setState(() {
          _isFlashlightOn = !_isFlashlightOn;
        });
      } else {
        print('Flashlight is not available on this device.');
      }
    } on EnableTorchExistentUserException catch (e) {
      print('The camera is in use.');
    } on EnableTorchNotAvailableException catch (e) {
      print('Torch was not detected.');
    } on EnableTorchException catch (e) {
      print('Torch could not be enabled due to another error.');
    } on DisableTorchExistentUserException catch (e) {
      print('The camera is in use.');
    } on DisableTorchNotAvailableException catch (e) {
      print('Torch was not detected.');
    } on DisableTorchException catch (e) {
      print('Torch could not be disabled due to another error.');
    }
  }



  Future<void> updateDraftWithNewVideo(String newVideoPath) async {
    var updatedVideoPaths = widget.draft.videoPaths.split(',');
    updatedVideoPaths.add(newVideoPath);
    widget.draft.videoPaths = updatedVideoPaths.join(',');

    // Update the database
    DatabaseHelper.instance.updateDraft(widget.draft);
  }


  void stopRecording() async {

    _countdownTimer?.cancel();
    XFile? videoFile = await _controller!.stopVideoRecording();

    if (videoFile.path != null) {
      // Update the draft with the new video information
      print('yha print kr rhe hain ${videoFile.path}');
      updateDraftWithNewVideo(videoFile.path);

    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditDraftPage(draft : widget.draft),
      ),
    );



    setState(() {

      _isRecording = false;
      _currentProgress = 0.0;
      _remainingRecordingTime = 60;




    });

    if (videoFile != null) {
      updateCloseButtonVisibility();
      String videoPath = videoFile.path;







      // Save video information to the database



      print('navigating to preview page');

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

  void homepage(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  BackButtonHandler backButtonHandler = BackButtonHandler(
    imagePath: 'assets/images/exit.svg',
    textField: 'homepage,',
    what: 'Home',
    button1: 'NO',
    button2: 'YES',
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
      return GestureDetector(
        onScaleUpdate: onScaleUpdate,
        child: WillPopScope(
          onWillPop: () async {
            // If you want to prevent the user from going back, return false
            // return false;

            // If you want to navigate directly to the homepage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );

            return false; // Returning true will allow the user to pop the page
          },
          child: Scaffold(

            body: Column(

              children: [

                Expanded(
                  child: Container(
                    // Add your widgets for the row content here
                    color: Theme.of(context).primaryColorLight, // Replace with your desired background color
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top:14.0),
                          child: Row(

                            children: [
                              TextButton(onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                              }, child: Text('< back',style:TextStyle(color : Colors.white,fontWeight: FontWeight.bold,fontSize: 20)))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:19.0),
                          child: IconButton(
                            icon: Icon(
                              _isFlashlightOn ? Icons.flash_on : Icons.flash_off,
                              size: 25.0,
                              color: Colors.white,
                            ),
                            onPressed: toggleFlashlight,
                          ),
                        ),

                        if(hasRecordedVideos)
                          Padding(
                            padding: const EdgeInsets.only(top:14.0),
                            child: IconButton(
                              onPressed: () {




                              },
                              icon: Icon(
                                Icons.close_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        if(hasRecordedVideos == false)
                          Padding(
                            padding: const EdgeInsets.only(top:14.0),
                            child: IconButton(
                              onPressed: () {


                                print('has videos ');



                              },
                              icon: Icon(
                                Icons.close_rounded,
                                size: 25.0,
                                color: Theme.of(context).primaryColorLight,
                              ),
                            ),
                          ),

                      ],
                    ),
                  ),
                ),

                Stack(

                  children: <Widget>[



                    AspectRatio(
                      aspectRatio: 9/16, // Set the aspect ratio to 9:16
                      child: CameraPreview(_controller!),
                    ),




                    // //
                    // CameraPreview(_controller!),


                    Positioned(
                      bottom: 190,
                      left: 10,
                      right: 0,
                      child: Column(
                        children: <Widget>[
                          Text(
                            _showRecordingMessage ? 'Shooting Started' : '',
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
                              if(!_isRecording)
                                Text(
                                  'Start Shooting',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              if(_isRecording)
                                Text(
                                  'Shooting ..',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                          Column(

                            children: [
                              SizedBox(
                                height : 100,

                                child: Container(
                                  height : 80, width : 80,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RotationTransition(
                                        turns: isFlipped ? AlwaysStoppedAnimation(0.3) : AlwaysStoppedAnimation(0),
                                        child: IconButton(
                                          icon: SvgPicture.asset('assets/images/camera_flip.svg'),
                                          onPressed: () {
                                            // Your custom onPressed logic here
                                            // ...

                                            toggleCamera();
                                            setState(() {
                                              isFlipped = !isFlipped;
                                            });
                                          },
                                        ),

                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                'Flip',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
