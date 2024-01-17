Map<String, dynamic> localAssistantRequest(String userName,  String meetId, String userId, String type, String message) {
  return {
    "notification": {
      "title": 'CulturTap',
      "body": 'Call requested by | ${userName}',
    },
    "data": {
      "type": type,
      "meetId": meetId,
      "userId": userId,
      "state": 'helper',
      "innerBody": message,
    },
  };
}