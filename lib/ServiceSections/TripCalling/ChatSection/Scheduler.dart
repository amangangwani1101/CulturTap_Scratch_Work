//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class ScheduleMeetingScreen extends StatefulWidget {
//   @override
//   _ScheduleMeetingScreenState createState() => _ScheduleMeetingScreenState();
// }
//
// class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
//   final TextEditingController _dateController = TextEditingController();
//   final TextEditingController _timeController = TextEditingController();
//   final String serverUrl = 'YOUR_BACKEND_URL'; // Replace with your server's URL
//
//   Future<void> _scheduleMeeting() async {
//     final url = Uri.parse('$serverUrl/createMeeting');
//     final headers = {'Content-Type': 'application/json'};
//     final scheduledDate = _dateController.text;
//     final scheduledTime = _timeController.text;
//     final body = json.encode({
//       'sendersId': 'SENDER_USER_ID', // Replace with the sender's ID
//       'receiversId': 'RECEIVER_USER_ID', // Replace with the receiver's ID
//       'scheduledDate': scheduledDate,
//       'scheduledTime': scheduledTime,
//     });
//
//     try {
//       final response = await http.post(url, headers: headers, body: body);
//
//       if (response.statusCode == 201) {
//         final responseData = json.decode(response.body);
//         final meetingId = responseData['meetingId']; // Extract the meeting ID
//         print('Meeting created with ID: $meetingId');
//       } else {
//         // Handle errors
//         print('Failed to create a meeting. Status code: ${response.statusCode}');
//       }
//     } catch (error) {
//       // Handle connection or other errors
//       print('Error creating a meeting: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Schedule Meeting'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _dateController,
//               decoration: InputDecoration(labelText: 'Date (dd/mm/yyyy)'),
//             ),
//             TextField(
//               controller: _timeController,
//               decoration: InputDecoration(labelText: 'Time (hh:mm AM/PM)'),
//             ),
//             ElevatedButton(
//               onPressed: _scheduleMeeting,
//               child: Text('Schedule Meeting'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// all in one no use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatApp(),
    );
  }
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> chatHistory = [];
  late Socket socket;
  bool isMeetingStarted = false;
  int meetingDuration = 20 * 60; // 20 minutes in seconds
  int remainingTimeInSeconds = 0;
  final String serverUrl = 'YOUR_BACKEND_URL';
  String senderId = 'SENDER_MONGODB_ID'; // Replace with the actual sender's ID
  String receiverId = 'RECEIVER_MONGODB_ID'; // Replace with the actual receiver's ID
  late String meetingID;

  @override
  void initState() {
    super.initState();

    // Initialize the Socket.IO connection.
    socket = io(serverUrl);
    socket.on('connect', (_) {
      print('Connected to server');
    });

    // Call the createMeeting function to test it when the ChatScreen initializes.
    createMeeting().then((meetingId) {
      if (meetingId != null) {
        // Use the meeting ID as needed
        meetingID = meetingId;
        print('Meeting ID: $meetingId');
      } else {
        // Handle the case where creating the meeting failed
        print('Failed to create a meeting');
      }
    });

    // Handle scheduled meetings, real-time chat, and meeting ending
    socket.on('scheduledMeeting', (meetingData) {
      // Handle the scheduled meeting here.
      print('Scheduled Meeting: $meetingData');
      final scheduledTime = DateTime.parse(meetingData['scheduledTime']);
      final currentTime = DateTime.now();
      final timeDifference = scheduledTime.difference(currentTime);
      remainingTimeInSeconds = timeDifference.inSeconds;

      if (remainingTimeInSeconds > 0) {
        Timer.periodic(Duration(seconds: 1), (timer) {
          if (remainingTimeInSeconds <= 0) {
            timer.cancel();
            setState(() {
              isMeetingStarted = true;
            });
          } else {
            setState(() {
              remainingTimeInSeconds--;
            });
          }
        });
      } else {
        setState(() {
          isMeetingStarted = true;
        });
      }
    });

    // Handle meeting ending and early meeting ending
    socket.on('meetingEnded', (message) {
      // Handle the meeting ending.
      print('Meeting Ended: $message');
      // Implement any necessary logic here.
    });

    socket.on('meetingEndedEarly', (message) {
      // Handle early meeting ending.
      print('Meeting Ended Early: $message');
      // Implement any necessary logic here.
    });

    // Rest of your Socket.IO event handling code
    // ...
  }

  Future<String?> createMeeting() async {
    final url = Uri.parse('$serverUrl/createMeeting');
    final headers = {'Content-Type': 'application/json'};
    final scheduledDate = '13/09/2023'; // Replace with the scheduled date
    final scheduledTime = '6:00PM'; // Replace with the scheduled time
    final body = json.encode({
      'sendersId': senderId, // Replace with sender's ID
      'receiversId': receiverId, // Replace with receiver's ID
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final meetingId = responseData['meetingId'];
        print('Meeting created with ID: $meetingId');
        return meetingId;
      } else {
        // Handle errors
        print('Failed to create a meeting. Status code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      // Handle connection or other errors
      print('Error creating a meeting: $error');
      return null;
    }
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      // Implement message sending logic.
      socket.emit('sendMessage', {
        'meetingId': meetingID,
        'sender': senderId,
        'message': message,
      });
      _messageController.clear();
    }
  }

  void _endMeeting() {
    // Implement meeting ending logic.
    socket.emit('endMeeting', meetingID);
  }

  void _endMeetingEarly() {
    // Implement early meeting termination logic.
    socket.emit('endMeetingEarly', meetingID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('20-Minute Meeting Chat'),
      ),
      body: Column(
        children: [
          isMeetingStarted
              ? Expanded(
            child: ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(chatHistory[index]),
                );
              },
            ),
          )
              : Center(
            child: Text(
              'Meeting starts in: ${remainingTimeInSeconds ~/ 60}:${remainingTimeInSeconds % 60}',
              style: TextStyle(fontSize: 20),
            ),
          ),
          if (isMeetingStarted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(hintText: 'Type a message...'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          if (isMeetingStarted)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _endMeeting,
                  child: Text('End Meeting'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _endMeetingEarly,
                  child: Text('End Meeting Early'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
