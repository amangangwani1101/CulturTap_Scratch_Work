List<Map<String, dynamic>> localAssistantRequest(String userName,  String meetId, String message) {
  return [
    {
      "notification": {
        "title": 'CulturTap',
        "body": 'Call requested by | ${userName}',
      },
      "data": {
        "type": 'local_assistant_request',
        "meetId": meetId,
        "state": 'helper',
        "innerBody": message,
      },
    },
    {
      "notification": {
        "title": 'CulturTap',
        "body": 'Outgoing Service...',
      },
      "data": {
        "type": 'local_assistant_request',
        "meetId": meetId,
        "state": 'user',
        "innerBody": 'Waiting For Opponent...',
      },
    }
  ];
}

Map<String, dynamic> localAssistantHelperAccepted(String userName,  String meetId) {
  return {
    "notification": {
      "title": 'CulturTap',
      "body": 'Trip assistant need from | ${userName}',
    },
    "data": {
      "type": 'local_assistant_accept',
      "meetId": meetId,
      "state": 'user',
      "innerBody": '<b> Hey ${userName},  <u> I get your problem</u> </b>, <br> lets connect first on call, be calm',
    },
  };
}

Map<String, dynamic> localAssistantHelperPay(String userName,  String meetId) {
  return {
    "notification": {
      "title": 'CulturTap',
      "body": 'Call requested by | ${userName}',
    },
    "data": {
      "type": 'local_assistant_payment',
      "meetId": meetId,
      "state": 'helper',
      "innerBody": 'Payment done by ${userName} ',
    },
  };
}

Map<String, dynamic> localAssistantMessage(String userName,  String meetId, String message,String state) {
  return {
    "notification": {
      "title": 'CulturTap',
      "body": state=='helper'?'Call requested by | ${userName}' :'Trip assistant need from | ${userName}',
    },
    "data": {
      "type": 'local_assistant_message',
      "meetId": meetId,
      "state": state,
      "innerBody": message,
    },
  };
}

Map<String, dynamic> localAssistantMeetCancel(String userName) {
  return {
    "notification": {
      "title": 'CulturTap',
      "body": 'Call requested by | ${userName}',
    },
    "data": {
      "type": 'local_assistant_cancel',
      "state": 'Cancelled',
      'service' : 'Local Assistant',
      "innerBody": '<b> Meeting is Cancelled By ${userName}</b>',
    },
  };
}

Map<String, dynamic> localAssistantMeetClose(String userName) {
  return {
    "notification": {
      "title": 'CulturTap',
      "body": 'Call requested by | ${userName}',
    },
    "data": {
      "type": 'local_assistant_cancel',
      "state": 'Closed',
      'service' : 'Local Assistant',
      "innerBody": '<b> Meeting is Closed</b> <br/> Thank You For Your Service',
    },
  };
}
