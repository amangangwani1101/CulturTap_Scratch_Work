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
      home: SchedulerScreen(),
    );
  }
}

class SchedulerScreen extends StatefulWidget {
  @override
  _SchedulerScreenState createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  final String serverUrl = 'http://192.168.53.54:8080'; // Replace with your server's URL
  late Socket socket;
  String meetingID = '';

  Future<dynamic> createMeeting() async {
    final scheduledDate = '13/09/2023'; // Replace with the scheduled date
    final scheduledTime = '6:00PM'; // Replace with the scheduled time
    final sendersId = 'SENDER_USER_ID'; // Replace with the sender's user ID
    final receiversId = 'RECEIVER_USER_ID'; // Replace with the receiver's user ID

    final url = Uri.parse('$serverUrl/createMeeting');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'sendersId': sendersId,
      'receiversId': receiversId,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final meetingId = responseData['meetingId']; // Extract the meeting ID
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

  @override
  void initState() {
    super.initState();

    socket = io(serverUrl);
    socket.on('connect', (_) {
      print('Connected to server');
    });

    // Handle the scheduled meeting and navigation to Sender/Receiver screens
    socket.on('scheduledMeeting', (meetingData) {
      print('Scheduled Meeting: $meetingData');
      final scheduledTime = DateTime.parse(meetingData['scheduledTime']);
      final currentTime = DateTime.now();
      final timeDifference = scheduledTime.difference(currentTime);

      Timer(timeDifference, () {
        // Timer completed, navigate to Sender or Receiver
        final meetingType = meetingData['meetingType'];
        final meetingId = meetingData['meetingId'];
        setState(() {
          meetingID = meetingId;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => meetingType == 'sender'
                ? SenderScreen(meetingId: meetingId)
                : ReceiverScreen(meetingId: meetingId),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting Scheduler'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            createMeeting().then((meetingId) {
              if (meetingId != null) {
                // Meeting created, do something if needed
                print('Meeting ID: $meetingId');
              } else {
                // Handle the case where creating the meeting failed
                print('Failed to create a meeting');
              }
            });
          },
          child: Text('Schedule Meeting'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}

class SenderScreen extends StatefulWidget {
  final String meetingId;

  SenderScreen({required this.meetingId});

  @override
  _SenderScreenState createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> chatHistory = [];
  late Socket socket;
  bool isMeetingStarted = false;
  final String serverUrl = 'http://192.168.53.54:8080'; // Replace with your server's URL
  @override
  void initState() {
    super.initState();

    socket = io(serverUrl);
    socket.on('connect', (_) {
      print('Connected to server');
    });

    // Handle meeting started event
    socket.on('meetingStarted', (message) {
      setState(() {
        isMeetingStarted = true;
      });
    });

    // Handle incoming messages
    socket.on('message', (data) {
      final sender = data['sender'];
      final message = data['message'];
      setState(() {
        chatHistory.add('$sender: $message');
      });
    });
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      socket.emit('sendMessage', {
        'meetingId': widget.meetingId,
        'sender': 'Sender',
        'message': message,
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sender Chat'),
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
              'Waiting for the meeting to start...',
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

class ReceiverScreen extends StatefulWidget {
  final String meetingId;

  ReceiverScreen({required this.meetingId});

  @override
  _ReceiverScreenState createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> chatHistory = [];
  late Socket socket;
  bool isMeetingStarted = false;
  final String serverUrl = 'http://192.168.53.54:8080'; // Replace with your server's URL
  @override
  void initState() {
    super.initState();

    socket = io(serverUrl);
    socket.on('connect', (_) {
      print('Connected to server');
    });

    // Handle meeting started event
    socket.on('meetingStarted', (message) {
      setState(() {
        isMeetingStarted = true;
      });
    });

    // Handle incoming messages
    socket.on('message', (data) {
      final sender = data['sender'];
      final message = data['message'];
      setState(() {
        chatHistory.add('$sender: $message');
      });
    });
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      socket.emit('sendMessage', {
        'meetingId': widget.meetingId,
        'sender': 'Receiver',
        'message': message,
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receiver Chat'),
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
              'Waiting for the meeting to start...',
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
