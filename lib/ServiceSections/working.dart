import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_archive/flutter_archive.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AudioRecorder(),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  bool _downloading = false;
  int _count = 1;
  List<String> _savedFilePaths = [];

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
    _initAudioPlayer();
    _requestPermissions();
  }

  Future<void> _initAudioRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();
  }

  Future<void> _startRecording() async {
    try {
      await _audioRecorder!.startRecorder(
        toFile: await _getFilePath(),
        codec: Codec.aacADTS,
      );
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    await _audioRecorder!.stopRecorder();
    setState(() {
      _count++;
      _savedFilePaths.add(_getCurrentFilePath()); // Add the saved file path to the list
    });
  }

  String _getCurrentFilePath() {
    Directory appDir = Directory(path.join(
        (Platform.isIOS ? '' : Directory.systemTemp.path), 'YourAppName'));
    String subFolderPath = path.join(appDir.path, 'SubFolder');
    Directory(subFolderPath).createSync(recursive: true);
    print("Path :${subFolderPath}/audio-uniqueid-${_count}.aac");
    return '$subFolderPath/audio-uniqueid-$_count.aac';
  }

  Future<void> _playSequentially() async {
    for (String filePath in _savedFilePaths) {
      await _audioPlayer!.startPlayer(fromURI: filePath,
      whenFinished: (){
        print('Its Played ${filePath}');
      });
    }
  }

  // Future<void> _downloadFiles(BuildContext context) async {
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   String zipPath = '${appDocDir.path}/audio_files.zip';
  //
  //   List<File> filesToZip = _savedFilePaths.map((filePath) => File(filePath)).toList();
  //
  //   try {
  //     File zipFile = File(zipPath);
  //
  //     final progress = Fluttertoast.showToast(
  //       msg: 'Downloading...',
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //     );
  //
  //     await ZipFile.createFromFiles(
  //       sourceDir: appDocDir,
  //       files: filesToZip,
  //       zipFile: zipFile,
  //       includeBaseDirectory: true,
  //     );
  //     Fluttertoast.cancel(); // Cancel the toast once download completes
  //
  //     Fluttertoast.showToast(
  //       msg: 'Download complete!',
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //     );
  //
  //     OpenFile.open(appDocDir.path);
  //     print('Files zipped successfully to: $zipPath');
  //   } catch (e) {
  //     print('Error zipping files: $e');
  //     Fluttertoast.showToast(
  //       msg: 'Error downloading files',
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //     );
  //     print('Error zipping files: $e');
  //   }
  // }

  Future<void> _downloadFiles(BuildContext context) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String downloadFolderPath = appDocDir.path + '/DownloadedAudios';
    Directory downloadFolder = Directory(downloadFolderPath);
    if (!(await downloadFolder.exists())) {
      await downloadFolder.create(recursive: true);
    }

    // Convert and copy audio files to the download folder
    FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
    for (String filePath in _savedFilePaths) {
      String fileName = path.basename(filePath);
      String destinationPath = '$downloadFolderPath/$fileName.mp3';
      await flutterFFmpeg.execute(
        '-i $filePath -codec:a libmp3lame -qscale:a 2 $destinationPath',
      );
    }

    Fluttertoast.showToast(
      msg: 'Download complete!',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );

    // Open the download folder
    OpenFile.open(downloadFolderPath);
  }
  Future<String> _getFilePath() async {
    Directory appDir = Directory(path.join(
        (Platform.isIOS ? '' : Directory.systemTemp.path), 'YourAppName'));
    String subFolderPath = path.join(appDir.path, 'SubFolder');
    Directory(subFolderPath).createSync(recursive: true);
    return '$subFolderPath/audio-uniqueid-$_count.aac';
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.microphone,
      Permission.storage,
    ].request();

    if (status[Permission.microphone] != PermissionStatus.granted) {
      print('Microphone permission denied');
    }

    if (status[Permission.storage] != PermissionStatus.granted) {
      print('Storage permission denied');
    }
  }

  @override
  void dispose() {
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Stop Recording'),
            ),
            ElevatedButton(
              onPressed: _playSequentially,
              child: Text('Play All'),
            ),
            _downloading
                ? LinearProgressIndicator() // Show progress bar if downloading
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  _downloading = true;
                });
                _downloadFiles(context); // Initiates download
              },
              child: Text('Download All'),
            ),
          ],
        ),
      ),
    );
  }
}
