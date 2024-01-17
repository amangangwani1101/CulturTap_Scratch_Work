import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendCustomNotificationToUsers(
    List<String>userIds,
    Map<String,dynamic> payload
    ) async {
  var data = payload;
  data['priority'] = 'high';
  // data['to']
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
