import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/Pings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_common/src/util/event_emitter.dart';
import 'package:http/http.dart' as http;
import '../../../UserProfile/ProfileHeader.dart';
import '../../../widgets/Constant.dart';
import '../../../widgets/hexColor.dart';
// import 'package:shared_prefrences/shared_prefrences.dart';
import 'CallScreen.dart';

// void main() => runApp(ChatApp());

class ChatApps extends StatefulWidget {
  final String meetingId,senderId,receiverId;
  String ?date;
  DateTime?currentTime;
  int ?index;
  ChatApps({required this.senderId,required this.receiverId,required this.meetingId,this.date,this.index,this.currentTime});
  @override
  _ChatAppsState createState() => _ChatAppsState();
}

class _ChatAppsState extends State<ChatApps> {
  final TextEditingController _controller = TextEditingController();
  List<RTCIceCandidate> rtcIceCadidates = [];
  RTCPeerConnection? _rtcPeerConnection;
  late IO.Socket socket;
  List<List<String>> messages = [];
  List<String>sender=[],receiver=[];
  final String serverUrl = Constant().serverUrl;  // Replace with your server's URL
  late Timer meetingTimer;
  String senderNavigatorId = 'sender';
  String receiverNavigatorId = 'receiver';
  int meetingTime =3;
  late Duration meetingDuration = Duration(minutes: meetingTime); // Set your meeting duration
  Duration remainingTime = Duration();
  late Timer countdownTimer;
  late Timer alertTimer;
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;

  // late Timer _timer;
  // int _start = 180;   // 2 minutes in seconds
  bool dispalyHi = true;
  @override
  void initState() {
    super.initState();
    print('inti');
    // Connect to your server
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    startMeetingTimer();
    // startTimer();
    if(widget.senderId!='')
      fetchDataFromSharedPreferences(senderNavigatorId);
    else
      fetchDataFromSharedPreferences(receiverNavigatorId);
    try {
      socket.connect();
      print('Hello 1');
    } catch (e) {
      print('Error connecting to the server: $e');
      // Handle the error, e.g., display an error message to the user
    }

    // Listen for incoming messages
    socket.on('message', (data) {
      // Handle 'data' based on your requirements
      print('Received: ${data}');
      // Extract sender or other relevant information from 'data'
      setState(() {
        messages.add([data['message'],data['user']]);
        if(data['user']=='sender')
            sender.add(data['message']);
        else
          receiver.add(data['message']);
        print(messages);
      });
    });

    // Emit 'join' event with uniqueIdentifier, senderId, receiverId, and meetingId
    socket.emit('join', {widget.meetingId, widget.senderId, widget.receiverId});

    // Listen for 'roomNotFound' event to handle cases where the user is not allowed
    socket.on('roomNotFound', (message) {
      print('Room not found: $message');
      // Handle the case where the user is not allowed to enter the room
      // You can display an error message and navigate the user out of this screen.
    });

    // callng functionality
    // Listen for signaling messages
    socket.on('offer', (data) {
      print('Step2');
      // final se = data['offer'];
      print('sss:$data');
      // Handle incoming offer
      handleOffer(data['offer'], data['callerId']);
    });

    socket.on('answer', (data) {
      // Handle incoming answer
      print('Data:$data');
      handleAnswer(data['answer']);
    });

    socket.on('iceCandidate', (data) {
      // Handle incoming ICE candidates
      handleIceCandidate(data['candidate']);
    });
  }

  void storeDataLocally(userNavigatorId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dataJson = json.encode(messages);
    await prefs.setString(userNavigatorId, dataJson);
    print('Data saved to SharedPreferences');
  }

  void fetchDataFromSharedPreferences(userNavigatorId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dataJson = prefs.getString(userNavigatorId);
    if (dataJson != null) {
      setState(() {
        messages = List<List<String>>.from(json.decode(dataJson)
            .map((item) => List<String>.from(item)));
      });
      print('Data retrieved from SharedPreferences');
    } else {
      print('No data found in SharedPreferences');
    }
  }

  void eraseDataAfterTimer(userNavigatorId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(userNavigatorId);
    print('Data Removed Successfully');
  }
  // void startTimer() {
  //   int oneSec = Duration(seconds: meetDuration) as int;
  //   _timer = Timer.periodic(
  //     oneSec as Duration,
  //         (timer) {
  //       if (_start == 0) {
  //         setState(() {
  //           timer.cancel();
  //         });
  //       } else {
  //         setState(() {
  //           _start--;
  //         });
  //       }
  //     },
  //   );
  // }

  void cancelMeeting(String date,int index,String status,String otherId,String otherStatus)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': widget.senderId==''?widget.receiverId:widget.senderId,
        'date':date,
        'index':index,
        'setStatus':status,
        'user2Id':otherId,
        'set2Status':otherStatus,
      };
      print('PPPPP::$data');
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/cancelMeeting'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }
  }

  void updateMeetingChats(String meetId)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'meetId':meetId,
        'conversation':messages,
      };
      print('PPPPP::$data');
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/storeMeetingConversation'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }
  }

  // void startMeetingTimer() {
  //   const meetingDuration = Duration(minutes: 3);
  //   const alertDuration = Duration(minutes: 1); // Duration for showing alert before the meeting ends
  //
  //   meetingTimer = Timer(meetingDuration, () {
  //     // This will be called when the timer expires (i.e., after 2 minutes)
  //     widget.senderId!=''?eraseDataAfterTimer(senderNavigatorId):eraseDataAfterTimer(receiverNavigatorId);
  //     socket.disconnect();
  //     showMeetingEndedAlert(); // Show an alert as the meeting ends
  //     navigateToEndScreen(); // Navigate after the meeting ends
  //   });
  //
  //   Timer(alertDuration, () {
  //     // This will be called when 1 minute is left
  //     showOneMinuteAlert(); // Show an alert when 1 minute is left
  //   });
  // }

  void updateRemainingTime() {
    setState(() {
      DateTime currentTime = DateTime.now();
      Duration elapsed = currentTime.difference(widget.currentTime!);
      remainingTime = meetingDuration - elapsed;
    });
  }

  void startMeetingTimer() {

    // alertTimer = Timer(Duration(minutes: meetingTime-1), () {
    //   showOneMinuteAlert();
    // });

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateRemainingTime();
      print(remainingTime);
      if (remainingTime.inSeconds <= 0) {
        timer.cancel();
        widget.senderId!=''?eraseDataAfterTimer(senderNavigatorId):eraseDataAfterTimer(receiverNavigatorId);
        socket.disconnect();
        // Perform necessary actions when the meeting ends
        navigateToEndScreen();
      }
      if(remainingTime.inMinutes==1 && remainingTime.inSeconds==0){
        showOneMinuteAlert();
      }
    });
  }


  void showOneMinuteAlert() {
    // Show an alert when 1 minute is left
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("1 Minute Remaining"),
          content: Text("The meeting will end in 1 minute."),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showMeetingEndedAlert() {
    // Show an alert when the meeting ends
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Meeting Ended"),
          content: Text("The meeting has ended."),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                navigateToEndScreen();
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToEndScreen() {
    // Navigate to the end screen after the meeting ends
    updateMeetingChats(widget.meetingId);
    cancelMeeting(widget.date!,widget.index!,'close',widget.receiverId==''?widget.senderId:widget.receiverId,'close');
    showMeetingEndedAlert();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PingsSection(userId: widget.senderId==''?widget.receiverId:widget.senderId,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int minutes = remainingTime.inMinutes;
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 5,userId:widget.senderId!=''?widget.senderId:widget.receiverId),),
        body: Column(
            children: <Widget>[
              InkWell(onTap:(){
                if(widget.senderId!='')
                  storeDataLocally(senderNavigatorId);
                else
                  storeDataLocally(receiverNavigatorId);
                Navigator.of(context).pop();
              },child: Text('Back')),
              SizedBox(height: 20,),
              Container(
                height: 120,
                child: Row(
                  children: [
                    SizedBox(width: 35,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Get Connected With \nCustomer',style: TextStyle(fontSize: 18,fontFamily: 'Poppins',fontWeight: FontWeight.bold,),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('You Can Chat or Talk',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/clock.png',width: 22,height: 22,color: Colors.green,),
                            SizedBox(width: 10,),
                            Text('$minutes min',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: Colors.green),),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20,),
            messages.length==0
            ?Container(
              width: screenWidth<400?screenWidth*0.85:336,
              height: 134,
              decoration: BoxDecoration(
                color: Colors.white, // Container background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Shadow color
                    spreadRadius: 5, // Spread radius
                    blurRadius: 7, // Blur radius
                    offset: Offset(0, 3), // Changes the position of the shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Say Hi!',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,fontFamily: 'Poppins'),),
                  Text('You have 20 min, to discuss and \nplan your next trip',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                ],
              ),
            )
            : Expanded(
              child: Row(
                children: [
                  SizedBox(width: 20,),
                  Container(
                    width: screenWidth<400?screenWidth*0.92:400,
                    // decoration: BoxDecoration(border:Border.all(width: 1)),
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title:messages[index][1]=='sender'
                                  ?widget.senderId!=''
                                  ?Align(alignment: Alignment.centerRight, child: Container(decoration:BoxDecoration(borderRadius: BorderRadius.circular(10),color: HexColor('#FB8C00').withOpacity(0.8)),  padding:EdgeInsets.all(10),  child: Text(messages[index][0],style: TextStyle(fontFamily: 'Poppins',fontSize: 14,color: Colors.white),)))
                                  :Align(alignment: Alignment.centerLeft, child: Container(decoration:BoxDecoration(borderRadius: BorderRadius.circular(10),color: HexColor('#FB8C00').withOpacity(0.8)),  padding:EdgeInsets.all(10),  child: Text(messages[index][0],style: TextStyle(fontFamily: 'Poppins',fontSize: 14,color: Colors.white),)))
                                  :widget.senderId==''
                               ?Align(alignment: Alignment.centerRight, child: Container(decoration:BoxDecoration(borderRadius: BorderRadius.circular(10),color: HexColor('#FB8C00').withOpacity(0.8)),  padding:EdgeInsets.all(10),  child: Text(messages[index][0],style: TextStyle(fontFamily: 'Poppins',fontSize: 14,color: Colors.white),)))
                               :Align(alignment: Alignment.centerLeft, child: Container(decoration:BoxDecoration(borderRadius: BorderRadius.circular(10),color: HexColor('#FB8C00').withOpacity(0.8)),  padding:EdgeInsets.all(10),  child: Text(messages[index][0],style: TextStyle(fontFamily: 'Poppins',fontSize: 14,color: Colors.white),))),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth<400?screenWidth*0.70:320,
                  height: 58,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: HexColor('#F2F2F2'),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 30,),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(hintText: 'Type your Message here',border: InputBorder.none, ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _handleSend,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5,),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: HexColor('#F2F2F2')),
                  child: IconButton(
                    icon: Icon(Icons.call),
                    // onPressed:initiateVideoCall,
                    onPressed: startCall,
                  ),
                ),
                SizedBox(width: 5,),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: HexColor('#F2F2F2')),
                  child: IconButton(
                    icon: Icon(Icons.videocam),
                    // onPressed:initiateVideoCall,
                    onPressed: (){},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    String message = _controller.text;
    if (message.isNotEmpty) {
      try {
        // Send the message to the server
        if(widget.senderId!='') {
          socket.emit('message', {'message':message,'user1':'sender','user2':''});
        } else
          socket.emit('message', {'message':message,'user1':'','user2':'receiver'});
        print(message);
        _controller.clear();
      } catch (e) {
        print('Error sending message: $e');
        // Handle the error, e.g., display an error message to the user
      }
    } else {
      // Handle empty message, e.g., display a validation error to the user
      print('message is not valid');
    }
  }

  void startCall() async {
    // Get local audio stream
    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});

    print('Step');
    // Create RTCPeerConnection
    _peerConnection = await createPeerConnection({
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ]
    }, {});
    print('Step');
    // Add the local stream to the peer connection
    await _peerConnection.addStream(_localStream);

    print('Step');
    // Create and send offer
    RTCSessionDescription offer = await _peerConnection.createOffer({});
    await _peerConnection.setLocalDescription(offer);


    print('Step');
    print('OFFER:${offer.sdp}');
    socket.emit('offer', {'offer': offer.sdp, 'callerId': widget.senderId,'room':widget.meetingId});
  }

  // Function to handle the incoming offer
  Future<void> handleOffer(String offerSdp, String callerId) async {
    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(offerSdp, 'offer'),
    );

    RTCSessionDescription answer = await _peerConnection.createAnswer({});
    await _peerConnection.setLocalDescription(answer);
    print('Answer${answer}');
    socket.emit('answer', {'answer': answer.sdp, 'room': widget.meetingId, 'callerId': callerId});
  }

  // Function to handle the incoming answer
  Future<void> handleAnswer(String answerSdp) async {
    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(answerSdp, 'answer'),
    );
  }

  // Function to handle the incoming ICE candidate
  Future<void> handleIceCandidate(Map<String, dynamic> iceCandidate) async {
    final candidate = RTCIceCandidate(
      iceCandidate['candidate'],
      iceCandidate['sdpMid'],
      iceCandidate['sdpMLineIndex'],
    );
    await _peerConnection.addCandidate(candidate);
  }

  // void initiateVideoCall() {
  //   // Signal the backend to join the video call room
  //   socket.emit("joinVideoCallRoom", widget.meetingId); // Replace roomId with the unique ID
  //
  //   // When both users are in the same room, start the video call
  //   socket.on("videoCallStarted", (data) {
  //     // Logic to initiate the video call using WebRTC
  //     // Start streaming video between the users
  //     // Navigate to the video call screen
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => CallScreen(callerId:widget.senderId,calleeId:widget.receiverId,offer:widget.meetingId), // Adjust as per your widget structure
  //       ),
  //     );
  //   });
  //
    // // Handle ICE candidates
    // socket.on("newICECandidate", (data) {
    //   // data format should include candidate, sdpMid, sdpMLineIndex
    //   RTCIceCandidate candidate = RTCIceCandidate(
    //     data["candidate"],
    //     data["sdpMid"],
    //     data["sdpMLineIndex"],
    //   );
    //   _rtcPeerConnection?.addCandidate(candidate);
    // });
    //
    // // Handle call responses
    // socket.on("callAnswered", (data) async {
    //   await _rtcPeerConnection?.setRemoteDescription(
    //     RTCSessionDescription(
    //       data["sdpAnswer"]["sdp"],
    //       data["sdpAnswer"]["type"],
    //     ),
    //   );

      // rtcIceCadidates.forEach((candidate) {
      //   socket.emit("newICECandidate", {
      //     "calleeId": widget.receiverId,
      //     "iceCandidate": {
      //       "id": candidate.sdpMid,
      //       "label": candidate.sdpMLineIndex,
      //       "candidate": candidate.candidate,
      //     },
      //   });
      // });
    // });
  //
  // }

  @override
  void dispose() {
    // _timer.cancel();
    countdownTimer.cancel();
    alertTimer.cancel();
    meetingTimer.cancel(); // Cancel the timer when the screen is disposed
    socket.dispose();
    super.dispose();
  }
}
