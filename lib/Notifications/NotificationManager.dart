// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:learn_flutter/Notifications/NotificationHandler.dart';
// import 'package:learn_flutter/widgets/Constant.dart';
//
// class NotificationManager{
//   Future<void> localAssistantNotification(List<String> userIds,String title,String body,String meetId,String userId) async {
//     String userToken = 'dLeYBckGTpyId7-kFZfx9S:APA91bFuAN-cIRar51f0eG7nkluef2_nC8ybu_xnDlCKHDusgQTJgz5iZ00FM9NTnYJQZH7qRF7HJC05SKWDiXckmbbnsIatx7a39o3y2Ts3zl-yN2QVJO__TZ6vBTkewvurt6VRIWUK';
//     await sendCustomNotificationToUser(userToken, title, body, body, meetId, 'helper', 'local_assistant_service',userId);
//     // final url = Uri.parse('${Constant().serverUrl}/notificationHandler');
//       // Replace with your data
//       // for(var helper in userIds){
//       //   Map<String, dynamic> requestData =  {
//       //     "userId": helper,
//       //     "title" : title,
//       //     "body" : body,
//       //     "type": "local_assistant_service",
//       //     "meetId" : meetId,
//       //     "state" : "helper"
//       //   };
//       //   print('Notification Details :  ${requestData}');
//       //   try {
//       //     fin  al response = await http.post(
//       //       url,
//       //       headers: {
//       //         "Content-Type": "application/json",
//       //       },
//       //       body: jsonEncode(requestData),
//       //     );
//       //
//       //     if (response.statusCode == 200) {
//       //       print("Notification Sent To $helper");
//       //
//       //     } else {
//       //       print("Failed to send notifcatipn ${helper}: ${response.statusCode}");
//       //       throw Exception("Failed to save meet");
//       //     }
//       //   } catch (e) {
//       //     print("Error: $e");
//       //     throw Exception("Error during API call");
//       //   }
//       // }
//     }
// }