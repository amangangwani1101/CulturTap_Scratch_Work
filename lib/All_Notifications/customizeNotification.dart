import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/Constant.dart';

Future<void> sendCustomNotificationToUsers(
    List<String>userIds,
    Map<String,dynamic> payload
    ) async {
  final url = Uri.parse('${Constant().serverUrl}/notificationHandler');
  // Replace with your data
  for(var helper in userIds){
    Map<String, dynamic> requestData =  {
      "userIds" : userIds,
      "payload":payload,
    };
    print('Notification Details :  ${requestData}');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print("Notification Sent To all users");

      } else {
        print("Failed to send notifcatipn ${helper}: ${response.statusCode}");
        throw Exception("Failed to save meet");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }

  // try {
  //   await http.post(
  //     Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //     body: jsonEncode(data),
  //     headers: {
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Authorization': 'key=AAAAPpVuKrI:APA91bF7BA61C5dlBD65HIs4KY1Ljw5rHZ1FyNxuqjEpQUjfnQJMkhxf71XKlk2dK3fkjRVYG7gErT4lZj2lluhZVsdaHPeyjWKGQ6AcUZlNeXLTiuKxnnVgO21EowO0ATcxKSBd2EK7',
  //     },
  //   );
  // } catch (e) {
  //   print('Failed to send notification: $e');
  //   // Handle errors or exceptions here
  // }
}

Future<void> sendCustomNotificationToOneUser(
    String userToken,
    String title,
    String body,
    String innerBody,
    String meetId,
    String type,
    String userId,
    String state,
    ) async {
  var data = {
    'to': userToken, // 'to' is used for sending to a specific device
    'priority': 'high',
    'notification': {
      'title': title,
      'type' : type,
      'body': body,
      'innerBody': innerBody,
      'ongoing' : true,
    },
    'data': {
      "type": type,
      "meetId": meetId,
      "userId": userId,
      "state": state,
      'innerBody': innerBody,
    }
  };

  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
        'key=AAAAPpVuKrI:APA91bF7BA61C5dlBD65HIs4KY1Ljw5rHZ1FyNxuqjEpQUjfnQJMkhxf71XKlk2dK3fkjRVYG7gErT4lZj2lluhZVsdaHPeyjWKGQ6AcUZlNeXLTiuKxnnVgO21EowO0ATcxKSBd2EK7',
      },
    );
  } catch (e) {
    print('Failed to send notification: $e');
    // Handle errors or exceptions here
  }
}


Future<void> sendCustomNotificationToUserss(
    List<String> userTokens,
    String title,
    String body,
    String innerBody,
    String meetId,

    String type,
    String userId,
    ) async {
  var data = {
    'registration_ids': userTokens,
    'priority': 'high',
    'notification': {
      'title': title,
      'body': body,
      'innerBody': innerBody,
      'ongoing' : true,

    },
    'data': {
      "type": "local_assistant_service",
      "meetId": meetId,
      "userId": userId,
      "state": "helper",
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