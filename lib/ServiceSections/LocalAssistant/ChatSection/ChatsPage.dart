import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../UserProfile/ProfileHeader.dart';
import '../../../widgets/Constant.dart';
import '../../../widgets/hexColor.dart';
import 'package:http/http.dart'as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;


void main(){
  runApp(ChatsPage(userId:'652a31f77ff9b6023a14838a',state:'user',meetId: '65844f69318c03e09ec1c5e0',));
}

class ChatsPage extends StatefulWidget {
  String userId;
  String ? state,meetId;
  ChatsPage({required this.userId,this.state,this.meetId});
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<String>userIds = [];
  List<String>distance = [];
  List<String>suggestedTexts = [
    'Need Mechanical help for my car ',
    'My Vehicle get Puncture  ',
    'My vehicle is out of fuel ',
    'My car battery get discharge ',
    'I need medical assistance ',
  ];
  late IO.Socket socket;
  late RTCPeerConnection _peerConnection;

  bool _isUiEnabled = true;
  String userName = '',userPhoto = '';
  final String serverUrl = Constant().serverUrl;  // Replace with your server's URL
  final TextEditingController _controller = TextEditingController();
  bool pageVisitor = true; // true means person coming to this page is user while in else condition its helper
  bool messageTyping = false;
  bool messagesStarted = false;
  List<List<String>> messages = [];
  List<String>sender=[],receiver=[];

  Future<String> createMeetRequest() async {
    final url = Uri.parse('$serverUrl/updateLocalAssistantMeetDetails');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId": widget.userId,
      "helperIds": userIds,
      "meetTitle": _controller.text,
    };
    print('Data is :${requestData}');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final responseData = jsonDecode(response.body);
        final String meetId = responseData['id'];
        print("Meet saved successfully with ID: $meetId");
        updateMeetingChats(meetId,[_controller.text,'user']);
        createUpdateLocalUserPings(meetId,'pending');
        return meetId; // Return the ID
      } else {
        print("Failed to save meet. Status code: ${response.statusCode}");
        throw Exception("Failed to save meet");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }

  String setCurrentTime() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    String period = (hour < 12) ? 'AM' : 'PM';

    // Convert to 12-hour clock
    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    // Ensure two-digit formatting
    String formattedHour = (hour < 10) ? '0$hour' : '$hour';
    String formattedMinute = (minute < 10) ? '0$minute' : '$minute';

    return '$formattedHour:$formattedMinute $period';
  }

  Future<void> _refreshPage(String meetId) async {
    // Add your data fetching logic here
    // For example, you can fetch new data from an API
    await Future.delayed(Duration(seconds: 0));
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatsPage(userId: widget.userId!,state: 'user',meetId:meetId),
      ),
    );
  }
  Future<void> createUpdateLocalUserPings(String meetId,String meetStatus) async {
    final url = Uri.parse('$serverUrl/setUpdateUserPings');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId": widget.userId,
      "time":setCurrentTime(),
      "title": _controller.text,
      'meetId':meetId,
      'meetStatus':meetStatus
    };
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final responseData = jsonDecode(response.body);
        print("Response: $responseData");
        createUpdateLocalHelperPings(meetId,'choose');
      } else {
        print("Failed to save meet. Status code: ${response.statusCode}");
        throw Exception("Failed to save meet");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }

  Future<void> createUpdateLocalHelperPings(String meetId,String meetStatus) async {
    final url = Uri.parse('$serverUrl/setLocalHelpersPings');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId": widget.userId,
      "time":setCurrentTime(),
      "title": _controller.text,
      "distances":distance,
      "helperIds":userIds,
      'meetId':meetId,
      'meetStatus':meetStatus,
      'userName':userName,
      'userPhoto':userPhoto,
    };
    print('Messa::$requestData');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final responseData = jsonDecode(response.body);
        print("Response: $responseData");
        _controller.clear();
        _refreshPage(meetId);
      } else {
        print("Failed to save meet. Status code: ${response.statusCode}");
        throw Exception("Failed to save meet");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }

  void seperateList(List<List<String>> msg){
      List<String>user=[],helper=[];
      for (List<String> item in msg) {
        if (item[1] == 'user') {
          user.add(item[0]);
        }else{
          helper.add(item[0]);
        }
      }
      setState(() {
        sender = user;
        receiver = helper;
      });
    }
  Future<void> retriveMeetingConversation(String meetId) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$serverUrl/fetchLocalMeetingConversation/$meetId'),);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Red:::');
        print(responseData);
        final List<dynamic> conversationJson = responseData['conversation'];
        setState(() {
          messages = conversationJson.map<List<String>>((list) {
            return (list as List<dynamic>).map<String>((e) => e.toString()).toList();
          }).toList();
        });
        seperateList(messages);
      } else {
        print('Failed to retrive data: ${response.statusCode}');
      }
    }catch(err){
      print("Error is 2: $err");
    }
  }

  Future<void> updateMeetingChats(String meetId,List<String>meetDetails)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'meetId':meetId,
        'conversation':meetDetails,
      };
      print('PPPPP::$data');
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/storeLocalMeetingConversation'), // Adjust the endpoint as needed
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
      print("Error is 2: $err");
    }
  }

  void func(dynamic data)async{

    setState(() {
      _isUiEnabled = false;
      messages.add([data['message'],data['user']]);
      if(data['user']=='user')
        sender.add(data['message']);
      else
        receiver.add(data['message']);
    });
  }
  // Function to handle the incoming offer
  Future<void> handleOffer(String offerSdp, String callerId) async {
    await _peerConnection.setRemoteDescription(
      RTCSessionDescription(offerSdp, 'offer'),
    );
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

  Future<void> fetchDataset() async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${widget.userId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userName = data['userName'];
        userPhoto = data['userPhoto'];
      });
    } else {
      // Handle error
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataset();
    if(widget.state!='user'){
      pageVisitor = false;
    }
    if(pageVisitor){
      userIds = ['656754b3bf6b875d1ef7e879','656050b3030772278b8b54cd'];
      distance = ['0.05','0.09'];
    }
    if(widget.meetId!=null) {
      retriveMeetingConversation(widget.meetId!);
      socketConnection();
    }

  }

  void socketConnection(){
    socket = IO.io(serverUrl+'/localAssistant', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    try {
      socket.connect();
      print('Hello Local Assistant Service Started :) ');
    } catch (e) {
      print('Error connecting to the server: $e');
      // Handle the error, e.g., display an error message to the user
    }

    try {
      socket.on('message', (data) {
        // Handle 'data' based on your requirements
        print('Received: ${data}');
        // Extract sender or other relevant information from 'data'
        func(data);
        print('Message is :${data['message']}');
      });
    }
    catch (err) {
      print('Error in Message : $err');
    }

    // Emit 'join' event with uniqueIdentifier, senderId, receiverId, and meetingId
    try {
      socket.emit('join', {widget.meetId});
    } catch (err) {
      print('Error in Joining :$err');
    }

    // Listen for 'roomNotFound' event to handle cases where the user is not allowed
    socket.on('roomNotFound', (message) {
      print('Room not found: $message');
      // Handle the case where the user is not allowed to enter the room
      // You can display an error message and navigate the user out of this screen.
    });

    // callng functionality
    // Listen for signaling messages
    try {
      socket.on('offer', (data) {
        print('Step2');
        // final se = data['offer'];
        print('sss:$data');
        // Handle incoming offer
        handleOffer(data['offer'], data['callerId']);
      });
    } catch (err) {
      print('Error in offer:$err');
    }


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

  void _handleSend() {
    String message = _controller.text;
    if (message.isNotEmpty) {
      try {
        // Send the message to the server
        if(pageVisitor) {
          updateMeetingChats(widget.meetId!,[message,'user']);
          socket.emit('message', {'message':message,'user1':'user','user2':''});
        } else{
          updateMeetingChats(widget.meetId!,[message,'helper']);
          socket.emit('message', {'message':message,'user1':'','user2':'helper'});
        }
        _controller.clear();
        print('Message Is $message');
      } catch (e) {
        print('Error sending messagesss: $e');
        // Handle the error, e.g., display an error message to the user
      }
    } else {
      // Handle empty message, e.g., display a validation error to the user
      print('message is not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 5,userId: '',),),
        body: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 25,),
                        Column(
                          children: [
                            pageVisitor?
                            Column(
                              children: [
                                Container(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 286,
                                  height: 246,
                                  padding: EdgeInsets.all(13),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                          width: 236,
                                          child: Text('Hello ! How can Culturtap help you?',textAlign: TextAlign.justify,style: TextStyle(fontSize: 13,fontFamily: 'Poppins',fontWeight: FontWeight.w600),)),
                                      Container(
                                          width: 236,
                                          child: Text('You can find here local assistance immediately, we have found ' + '${userIds.length} helping hands' + ' near you.Please raise request for help'
                                          ,textAlign: TextAlign.justify,style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 13),)),
                                      Container(
                                        width: 236,
                                        child: Text('Type your request carefully before sending it to the local assistant .',textAlign: TextAlign.justify,
                                            style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 13,color: Colors.green),),
                                      ),
                                    ],
                                  ),
                                ),
                                messages.length!=0
                                ? SizedBox(height: 0,)
                                : Column(
                                  children:List.generate(suggestedTexts.length, (index) {
                                      return GestureDetector(
                                        onTap: (){
                                          print('Text: ${suggestedTexts[index]}');
                                          setState(() {
                                            messageTyping = true;
                                            _controller.text = suggestedTexts[index];
                                          });
                                        },
                                        child: Container(
                                          width: 276,
                                          height: 69,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(25),
                                          margin: EdgeInsets.only(bottom: 0.2),
                                          child: Text(suggestedTexts[index],
                                            style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 13),),
                                        ),
                                      );
                                  }),
                                ),
                              ],
                            ):SizedBox(height: 0,),
                          ],
                        ),
                      ],
                    ),

                    messages.length>0
                    ?Container(
                      // width: screenWidth < 450 ? screenWidth * 0.92 : 400,
                      // decoration: BoxDecoration(border:Border.all(width: 1)),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment:CrossAxisAlignment.center,
                          children: messages.map((message) {
                            return ListTile(
                              title: message[1] == 'user'
                                  ? widget.state != 'user'
                                  ? Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: screenWidth*0.70,
                                  decoration: BoxDecoration(
                                    color: HexColor('#E9EAEB').withOpacity(1),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: CircleAvatar(
                                          radius: 20.0,
                                          backgroundImage: AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text('Name Of User'),
                                            Text(
                                              message[0],
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: screenWidth*0.70,
                                  decoration: BoxDecoration(
                                    color: HexColor('#E9EAEB').withOpacity(1),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: CircleAvatar(
                                          radius: 20.0,
                                          backgroundImage: AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('You'),
                                            Text(
                                              message[0],
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : widget.state == 'user'
                                  ? Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: screenWidth*0.70,
                                  decoration: BoxDecoration(
                                    color: HexColor('#E9EAEB').withOpacity(1),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: CircleAvatar(
                                          radius: 20.0,
                                          backgroundImage: AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Name Of Helper'),
                                            Text(
                                              message[0],
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: HexColor('#E9EAEB').withOpacity(1),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: CircleAvatar(
                                          radius: 20.0,
                                          backgroundImage: AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('You'),
                                            Text(
                                              message[0],
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                    :SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20,),
                        Flexible(
                          child: Container(
                            width: messageTyping?screenWidth:screenWidth*0.70,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: !_isUiEnabled?Colors.grey.withOpacity(0.2):Colors.grey.withOpacity(0.01),
                            ),
                            padding: EdgeInsets.only(left: 10,right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    onChanged: (text){
                                      if(text.length>0){
                                        setState(() {
                                          messageTyping = true;
                                        });
                                      }
                                      else{
                                        setState(() {
                                          messageTyping = false;
                                        });
                                      }
                                    },
                                    maxLines: null,
                                    controller: _controller,
                                    decoration:  InputDecoration(hintText: 'Start Typing Here...',border: InputBorder.none,),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                GestureDetector(
                                    onTap: (){
                                    },
                                    child: !(receiver.length==0 && sender.length>1)?Image.asset('assets/images/attach_icon.png'):SizedBox(width: 0,)),
                                messageTyping==false?SizedBox(width: 10,):SizedBox(width: 5,),
                                // messageTyping==false?Image.asset('assets/images/send_icon.png'):SizedBox(width: 0,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        messageTyping==false && !(receiver.length==0 && sender.length>1)? Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
                          child: IconButton(
                            icon: Icon(Icons.call),
                            onPressed:(){},
                            // onPressed: !_isUiEnabled ? startCall : null,
                          ),
                        ):SizedBox(width: 0,),
                        messageTyping==false? SizedBox(width: 0,):SizedBox(width: 5,),
                        if (messageTyping==false && !(receiver.length==0 && sender.length>1)) Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
                          child: IconButton(
                            icon: Icon(Icons.videocam),
                            // onPressed:initiateVideoCall,
                            onPressed: (){},
                          ),
                        ) else if(!(receiver.length==0 && sender.length>1)) GestureDetector(
                          onTap: ()async{
                            if(receiver.length==0 && sender.length>1){

                            }else{
                              if(pageVisitor){
                                if(widget.meetId==null){
                                  setState(() {});
                                  String meetingId = await createMeetRequest();
                                }else{
                                  _handleSend();
                                }
                              }else{

                              }
                              setState(() {
                                messageTyping = false;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: Colors.green),
                              child: Image.asset('assets/images/send_icon.png')),
                        )
                        else SizedBox(width: 0,),
                        messageTyping==false?SizedBox(width: 0,):SizedBox(width: 10,),
                      ],
                    ),
                    SizedBox(height: 6,),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  void dispose() {
    super.dispose();
    print('Destroy');
    // _timer.cancel();
    // alertTimer.cancel();
    // if (_rtcPeerConnection != null) {
    //   _rtcPeerConnection!.dispose();
    // }
    // widget.senderId!=''?eraseDataAfterTimer(senderNavigatorId):eraseDataAfterTimer(receiverNavigatorId);
    // _localStream.dispose();
    // meetingTimer.cancel(); // Cancel the timer when the screen is disposed
    socket.dispose();
    socket.disconnect();
    socket.dispose();
  }
}
