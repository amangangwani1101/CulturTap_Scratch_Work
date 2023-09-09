import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(CameraApp(cameras: cameras, camera: firstCamera));
}

class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraDescription camera;

  CameraApp({Key? key, required this.cameras, required this.camera}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  bool isRecording = false;
  bool _isRecording = false;
  double _progressValue = 0.0;
  int _recordDurationInSeconds = 60; // Set the record duration to 60 seconds
  double _currentProgress = 0.0;

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

  void startRecording() async {
    await _controller.startVideoRecording();
    setState(() {
      _isRecording = true;
      _currentProgress = 0.0;
    });

    // Start a timer for 60 seconds
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentProgress += 0.00166666667; // 1/60 to complete in 60 seconds
      });

      if (_currentProgress >= 1.0) {
        stopRecording(); // Stop recording when the timer expires
        timer.cancel();
      }
    });
  }

  void stopRecording() async {
    await _controller.stopVideoRecording();
    setState(() {
      _isRecording = false;
      _currentProgress = 0.0; // Reset progress
    });
  }

  void toggleCamera() {
    CameraLensDirection newLensDirection;
    if (_controller.description.lensDirection == CameraLensDirection.front) {
      newLensDirection = CameraLensDirection.back;
    } else {
      newLensDirection = CameraLensDirection.front;
    }

    final newCamera = widget.cameras.firstWhere(
          (camera) => camera.lensDirection == newLensDirection,
    );

    _controller.dispose(); // Dispose of the old controller
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    CameraPreview(_controller),
                    if (_isRecording)
                      Align(
                        alignment: Alignment.center,

                      ),
                  ],
                ),
              ),
              // Existing code...

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 80,
                      height : 80,

                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _isRecording ? stopRecording : startRecording,
                          child: Container(
                            margin: EdgeInsets.all(20.0), // Add margin around the button
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: _isRecording ? _currentProgress : 10.0,
                                    backgroundColor: Colors.transparent, // Make background transparent
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                    strokeWidth: 12.0, // Adjust the thickness of the progress bar
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Icon(
                                    _isRecording ? Icons.pause_circle : Icons.circle,
                                    size: 69,
                                    color : _isRecording ? Colors.white60 : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text('Start Filming',style: TextStyle(fontWeight: FontWeight.bold,color : Colors.white,fontSize: 18),),

                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          child: IconButton(
                            // icon: Icon(Icons.flip_camera_ios_rounded),
                            icon : Image.asset('assets/images/flip_camera.png'),
                            onPressed: toggleCamera,
                          ),
                        ),
                        Text('Flip',style: TextStyle(fontWeight: FontWeight.bold,color : Colors.white,fontSize: 18),),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
