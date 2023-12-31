import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SenderScreen extends StatefulWidget {
  @override
  _SenderScreenState createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String serverUrl = 'YOUR_BACKEND_URL'; // Replace with your server's URL
  String meetingId; // Pass the meeting ID to this screen

  Future<void> _sendMessage() async {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      final url = Uri.parse('$serverUrl/sendMessage');
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        'meetingId': meetingId, // Use the provided meeting ID
        'sender': 'SENDER_USER_ID', // Replace with the sender's user ID
        'message': message,
      });

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          print('Message sent successfully');
        } else {
          // Handle errors
          print('Failed to send the message. Status code: ${response.statusCode}');
        }
      } catch (error) {
        // Handle connection or other errors
        print('Error sending the message: $error');
      }
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sender Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Type a message...'),
            ),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat Room


// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class ChatRoomScreen extends StatefulWidget {
//   @override
//   _ChatRoomScreenState createState() => _ChatRoomScreenState();
// }
//
// class _ChatRoomScreenState extends State<ChatRoomScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final List<String> chatHistory = [];
//   late Socket socket;
//   final String serverUrl = 'YOUR_BACKEND_URL'; // Replace with your server's URL
//   String meetingId; // Pass the meeting ID to this screen
//
//   void initState() {
//     super.initState();
//
//     // Initialize the Socket.IO connection.
//     socket = io(serverUrl);
//     socket.on('connect', (_) {
//       print('Connected to server');
//     });
//
//     socket.on('message', (data) {
//       // Handle incoming messages
//       final sender = data['sender'];
//       final message = data['message'];
//       setState(() {
//         chatHistory.add('$sender: $message');
//       });
//     });
//   }
//
//   void _sendMessage() {
//     final message = _messageController.text;
//     if (message.isNotEmpty) {
//       // Implement message sending logic.
//       socket.emit('sendMessage', {
//         'meetingId': meetingId, // Use the provided meeting ID
//         'sender': 'SENDER_USER_ID', // Replace with the sender's user ID
//         'message': message,
//       });
//       _messageController.clear();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat Room'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: chatHistory.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(chatHistory[index]),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(hintText: 'Type a message...'),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
