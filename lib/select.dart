// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Multi-Select Dropdown Text Field'),
//         ),
//         body: MyForm(),
//       ),
//     );
//   }
// }
//
// class MyForm extends StatefulWidget {
//   @override
//   _MyFormState createState() => _MyFormState();
// }
//
// class _MyFormState extends State<MyForm> {
//   List<String> selectedOptions = [];
//   List<String> options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Text('Selected Items: ${selectedOptions.join(', ')}'),
//               SizedBox(width: 8),
//             ],
//           ),
//           GestureDetector(
//             onTap: () {
//               showOptionsDialog(context);
//             },
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 selectedOptions.isEmpty
//                     ? 'Select options'
//                     : selectedOptions.join(', '),
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: selectedOptions.isEmpty ? Colors.grey : Colors.black,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void showOptionsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Select Options'),
//           content: Container(
//             width: double.maxFinite,
//             child: ListView(
//               shrinkWrap: true,
//               children: options.map((String option) {
//                 return CheckboxListTile(
//                   title: Text(option),
//                   value: selectedOptions.contains(option),
//                   onChanged: (bool? checked) {
//                     setState(() {
//                       if (checked != null) {
//                         if (checked) {
//                           selectedOptions.add(option);
//                         } else {
//                           selectedOptions.remove(option);
//                         }
//                       }
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


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
