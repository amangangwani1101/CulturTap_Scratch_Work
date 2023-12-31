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
  bool isMeetingStarted = true;
  int meetingDuration = 20 * 60; // 20 minutes in seconds
  int remainingTimeInSeconds = 0;
  final String serverUrl = 'http://192.168.53.54:8080'; // Replace with your server's URL
  String sendersId = '652a578b7ff9b6023a1483ba' , receiversId = '652b2cfe59629378c2c7dacb';
  late String meetingID ;

  @override


  Future<dynamic> createMeeting() async {
    final url = Uri.parse('${serverUrl}/createMeeting');
    final headers = {'Content-Type': 'application/json'};
    final scheduledDate = '13/09/2023'; // Replace with the scheduled date
    final scheduledTime = '6:00PM'; // Replace with the scheduled time
    final body = json.encode({
      'sendersId': sendersId, // Replace with sender's ID
      'receiversId': receiversId, // Replace with receiver's ID
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final meetingId = responseData['meetingId']; // Extract the meeting ID
        print('Meeting created with ID: $meetingId');
        return meetingId; // Return the meeting ID
        print('Meeting created: $responseData');
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

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      // Implement message sending logic.
      socket.emit('sendMessage', {
        'meetingId': meetingID, // Replace with the actual meeting ID.
        'sender': 'SENDER_USER_ID', // Replace with the actual user ID.
        'message': message,
      });
      _messageController.clear();
    }
  }

  void _endMeeting() {
    // Implement meeting ending logic.
    socket.emit('endMeeting', 'MEETING_ID'); // Replace with the actual meeting ID.
  }

  void _endMeetingEarly() {
    // Implement early meeting termination logic.
    socket.emit('endMeetingEarly', 'MEETING_ID'); // Replace with the actual meeting ID.
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
