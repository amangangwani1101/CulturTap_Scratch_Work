class NotificationSchema {
  final String to;
  final String priority;
  final Notification notification;
  final Data data;

  NotificationSchema({
    required this.to,
    required this.priority,
    required this.notification,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'priority': priority,
      'notification': notification.toJson(),
      'data': data.toJson(),
    };
  }


}

class Notification {
  final String title;
  final String body;

  Notification({
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
    };
  }
}

class Data {
  final String type;
  final String meetId;
  final String userId;
  final String state;
  final String innerBody;

  Data({
    required this.type,
    required this.meetId,
    required this.userId,
    required this.state,
    required this.innerBody,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'meetId': meetId,
      'userId': userId,
      'state': state,
      'innerBody': innerBody,
    };
  }

}

NotificationSchema createNotificationSchema({
  required String to,
  required String priority,
  required String title,
  required String body,
  required String type,
  required String meetId,
  required String userId,
  required String state,
  required String innerBody,
}) {
  return NotificationSchema(
    to: to,
    priority: priority,
    notification: Notification(
      title: title,
      body: body,
    ),
    data: Data(
      type: type,
      meetId: meetId,
      userId: userId,
      state: state,
      innerBody: innerBody,
    ),
  );
}

// from , data, category , collapseKey,contentid,
// messageType,mutableContent,notification,senderId,
// sentTime,threatId,ttl
