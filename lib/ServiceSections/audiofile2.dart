import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder and Merger',
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
  FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  FlutterFFprobe _flutterFFprobe = FlutterFFprobe();
  List<String> recordedFiles = [];
  String _mergedFilePath = '';
  FlutterSoundPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
    _initAudioPlayer();
    _requestPermissions();
  }

  Future<void> _playMergedAudio() async {
    if (_mergedFilePath.isNotEmpty) {
      await _audioPlayer!.startPlayer(fromURI: _mergedFilePath);
    } else {
      print('Merged audio file path is empty.');
    }
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
      String path = await _getFilePath();
      await _audioRecorder!.startRecorder(toFile: path, codec: Codec.aacADTS);
      setState(() {
        recordedFiles.add(path);
      });
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    await _audioRecorder!.stopRecorder();
  }

  // Future<String> _getFilePath() async {
  //   Directory appDir = await getApplicationDocumentsDirectory();
  //   String filePath;
  //   if (_mergedFilePath.isNotEmpty) {
  //     filePath = _mergedFilePath;
  //   } else {
  //     filePath = '${appDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
  //   }
  //   return filePath;
  // }

  Future<String> _getFilePath() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String appName = 'CulturTap'; // Replace 'YourAppName' with your actual app name
    String appFolderPath = '${appDir.path}/$appName';

    // Create the folder if it doesn't exist
    Directory(appFolderPath).createSync(recursive: true);

    String filePath;
    if (_mergedFilePath.isNotEmpty) {
      filePath = _mergedFilePath;
    } else {
      filePath = '$appFolderPath/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    }
    print('FilePath : $filePath');

    return filePath;
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.microphone,
      Permission.storage,
    ].request();

    if (status[Permission.microphone] == PermissionStatus.granted) {
      _initAudioRecorder();
      // Permission is granted. You can start recording here.
    } else {
      // Handle the case where the user denies microphone permission.
      // You can show an error message or ask the user to grant permission again.
      print('Microphone permission denied');
    }

    if (status[Permission.storage] == PermissionStatus.granted) {
      // Permission is granted. You can handle storage-related functionality here.
    } else {
      // Handle the case where the user denies storage permission.
      // You can show an error message or ask the user to grant permission again.
      print('Storage permission denied');
    }
  }

  // Future<void> _mergeAudioFiles() async {
  //   if (recordedFiles.length < 2) {
  //     print('Need at least 2 audio files to merge.');
  //     return;
  //   }
  //
  //   // Get the duration of each audio file
  //   List<String> durations = [];
  //   for (String file in recordedFiles) {
  //     String durationCommand = '-i $file -hide_banner';
  //     MediaInformation mediaInfo = await _flutterFFmpeg.getMediaInformation(durationCommand);
  //     String duration = mediaInfo.getMediaProperties()?['duration'];
  //     durations.add(duration);
  //   }
  //
  //   // Find the maximum duration among the audio files
  //   String maxDuration = durations.reduce((curr, next) => double.parse(curr) > double.parse(next) ? curr : next);
  //
  //   // Adjust audio files to match the maximum duration if needed
  //
  //   // Perform the merge operation
  //   String outputFilePath = await _getFilePath();
  //   List<String> inputFiles = recordedFiles.map((path) => '-i $path').toList();
  //   String inputs = inputFiles.join(' ');
  //   String command = '$inputs -filter_complex amix=inputs=${recordedFiles.length}:duration=longest $outputFilePath';
  //
  //   int rc = await _flutterFFmpeg.execute(command);
  //   if (rc == 0) {
  //     setState(() {
  //       _mergedFilePath = outputFilePath;
  //     });
  //     print('Audio files merged to: $outputFilePath');
  //   } else {
  //     print('Failed to merge audio files');
  //   }
  // }

  // Add a method to play the merged audio file

  // Future<void> _mergeAudioFiles() async {
  //   if (recordedFiles.length < 2) {
  //     print('Need at least 2 audio files to merge.');
  //     return;
  //   }
  //
  //   // Get the duration of each audio file
  //   List<String> durations = [];
  //   for (String file in recordedFiles) {
  //     final mediaInfo = await _flutterFFprobe.getMediaInformation(file);
  //     final duration = mediaInfo.getMediaProperties()?['duration'];
  //     durations.add(duration);
  //   }
  //
  //   // Find the maximum duration among the audio files
  //   String maxDuration = durations.reduce((curr, next) =>
  //   double.parse(curr) > double.parse(next) ? curr : next);
  //
  //   // Adjust audio files to match the maximum duration if needed
  //
  //   // Perform the merge operation
  //   String outputFilePath = await _getFilePath();
  //   List<String> inputFiles =
  //   recordedFiles.map((path) => '-i $path').toList();
  //   String inputs = inputFiles.join(' ');
  //   String command =
  //       '$inputs -filter_complex amix=inputs=${recordedFiles.length}:duration=longest $outputFilePath';
  //
  //   int rc = await _flutterFFmpeg.execute(command);
  //   if (rc == 0) {
  //     setState(() {
  //       _mergedFilePath = outputFilePath;
  //     });
  //     print('Audio files merged to: $outputFilePath');
  //   } else {
  //     print('Failed to merge audio files');
  //   }
  // }

  // Future<void> _mergeAudioFiles() async {
  //   if (recordedFiles.length < 2) {
  //     print('Need at least 2 audio files to merge.');
  //     return;
  //   }
  //
  //   // Get the duration of each audio file
  //   List<double> durations = [];
  //   for (String file in recordedFiles) {
  //     final mediaInfo = await _flutterFFprobe.getMediaInformation(file);
  //     final duration = double.tryParse(mediaInfo.getMediaProperties()?['duration'] ?? '0.0');
  //     durations.add(duration ?? 0.0);
  //   }
  //
  //   // Find the maximum duration among the audio files
  //   double maxDuration = durations.reduce((curr, next) => curr > next ? curr : next);
  //
  //   // Adjust audio files to match the maximum duration
  //   List<String> adjustedFiles = [];
  //   for (int i = 0; i < recordedFiles.length; i++) {
  //     final duration = durations[i];
  //     String inputFile = recordedFiles[i];
  //
  //     if (duration < maxDuration) {
  //       // If the duration is shorter, pad the audio with silence to match the max duration
  //       String outputFilePath = await _padAudioFile(inputFile, maxDuration);
  //       adjustedFiles.add(outputFilePath);
  //     } else if (duration > maxDuration) {
  //       // If the duration is longer, trim the audio to match the max duration
  //       String outputFilePath = await _trimAudioFile(inputFile, maxDuration);
  //       adjustedFiles.add(outputFilePath);
  //     } else {
  //       adjustedFiles.add(inputFile);
  //     }
  //   }
  //
  //   // Perform the merge operation with adjusted audio files
  //   String outputFilePath = await _getFilePath();
  //   List<String> inputFiles = adjustedFiles.map((path) => '-i $path').toList();
  //   String inputs = inputFiles.join(' ');
  //   String command =
  //       '$inputs -filter_complex amix=inputs=${recordedFiles.length}:duration=longest $outputFilePath';
  //
  //   int rc = await _flutterFFmpeg.execute(command);
  //   if (rc == 0) {
  //     setState(() {
  //       _mergedFilePath = outputFilePath;
  //     });
  //     print('Audio files merged to: $outputFilePath');
  //   } else {
  //     print('Failed to merge audio files');
  //   }
  // }

  Future<void> _playSequentially() async {
    for (String filePath in recordedFiles) {
      await _audioPlayer!.startPlayer(fromURI: filePath);
      await _audioPlayer!.isStopped;
    }
  }

  Future<void> _mergeAudioFiles() async {
    if (recordedFiles.length < 2) {
      print('Need at least 2 audio files to merge.');
      return;
    }

    // Calculate the maximum duration among the audio files
    double maxDuration = recordedFiles.map((file) => _getAudioDuration(file)).reduce((curr, next) => curr > next ? curr : next);

    // Adjust audio files to match the maximum duration
    List<String> adjustedFiles = [];
    for (String file in recordedFiles) {
      String outputFilePath;
      final duration = _getAudioDuration(file);

      if (duration < maxDuration) {
        // If the duration is shorter, pad the audio with silence to match the max duration
        outputFilePath = await _padAudioFile(file, maxDuration);
      } else if (duration > maxDuration) {
        // If the duration is longer, trim the audio to match the max duration
        outputFilePath = await _trimAudioFile(file, maxDuration);
      } else {
        outputFilePath = file;
      }
      adjustedFiles.add(outputFilePath);
    }

    // Perform the merge operation with adjusted audio files
    String outputFilePath = await _getFilePath();
    String inputs = adjustedFiles.map((path) => '-i $path').join(' ');
    String command = '$inputs -filter_complex amix=inputs=${recordedFiles.length}:duration=longest $outputFilePath';

    int rc = await _flutterFFmpeg.execute(command);
    if (rc == 0) {
      setState(() {
        _mergedFilePath = outputFilePath;
      });
      print('Audio files merged to: $outputFilePath');
    } else {
      print('Failed to merge audio files');
    }
  }

  double _getAudioDuration(String filePath) {
    // Get audio duration using FlutterFFprobe or other methods
    // Return the duration in seconds
    return 3.01; // Replace this with actual duration retrieval logic
  }

  Future<String> _padAudioFile(String inputFile, double maxDuration) async {
    String outputFilePath = await _getFilePath();

    // Use FFmpeg to pad the audio file with silence to match the max duration
    String command = '-i $inputFile -filter_complex "adelay=${(maxDuration * 1000).toInt()}:${(maxDuration * 1000).toInt()}" $outputFilePath';
    int rc = await _flutterFFmpeg.execute(command);

    return rc == 0 ? outputFilePath : '';
  }

  Future<String> _trimAudioFile(String inputFile, double maxDuration) async {
    String outputFilePath = await _getFilePath();

    // Use FFmpeg to trim the audio file to match the max duration
    String command = '-i $inputFile -t $maxDuration $outputFilePath';
    int rc = await _flutterFFmpeg.execute(command);

    return rc == 0 ? outputFilePath : '';
  }

  @override
  void dispose() {
    _audioPlayer?.closePlayer();
    _audioRecorder?.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder and Merger'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            onPressed: _mergeAudioFiles,
            child: Text('Merge Audio Files'),
          ),
          ElevatedButton(
            onPressed: _playMergedAudio,
            child: Text('Play Audio Files'),
          ),
          ElevatedButton(
            onPressed: _playSequentially,
            child: Text('Play Single'),
          ),
          // Add a button to play the merged audio file
        ],
      ),
    );
  }
}
