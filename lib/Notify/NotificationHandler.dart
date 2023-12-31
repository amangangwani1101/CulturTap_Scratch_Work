import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendCustomNotificationToUser(
    String userToken,
    String title,
    String body,
    String innerBody,
    ) async {
  var data = {
    'to': userToken,
    'priority': 'high',
    'notification': {
      'title': title,
      'body': body,
    },
    'data': {
      'type': 'chat',
      'message':'aman gangeamo',
      'chatId':'12345',
      'navigationData':'amsn',
      'innerBody': innerBody,
    }
  };

  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'key=AAAAPpVuKrI:APA91bF7BA61C5dlBD65HIs4KY1Ljw5rHZ1FyNxuqjEpQUjfnQJMkhxf71XKlk2dK3fkjRVYG7gErT4lZj2lluhZVsdaHPeyjWKGQ6AcUZlNeXLTiuKxnnVgO21EowO0ATcxKSBd2EK7',
      },
    );
  } catch (e) {
    print('Failed to send notification: $e');
    // Handle errors or exceptions here
  }
}
