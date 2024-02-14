import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:socket_io_common/src/util/event_emitter.dart';
import 'package:http/http.dart' as http;
import '../../../All_Notifications/customizeNotification.dart';
import '../../../CustomItems/ImagePopUpWithTwoOption.dart';
import '../../../UserProfile/ProfileHeader.dart';
import '../../../fetchDataFromMongodb.dart';
import '../../../widgets/Constant.dart';
import '../../../widgets/hexColor.dart';
import '../../LocalAssistant/ChatSection/Uploader.dart';

class ChatApps extends StatefulWidget {
  String senderId='',receiverId='';
  String ?date,meetingId,startTime;
  DateTime?currentTime;
  VoidCallback? callbacker;
  int ?index;
  ChatApps({required this.senderId,required this.receiverId, this.meetingId,this.date,this.index,this.currentTime,this.callbacker,this.startTime});
  @override
  _ChatAppsState createState() => _ChatAppsState();
}

class _ChatAppsState extends State<ChatApps> {
  final TextEditingController _controller = TextEditingController();
  List<RTCIceCandidate> rtcIceCadidates = [];
  RTCPeerConnection? _rtcPeerConnection;
  late IO.Socket socket;
  FocusNode _textFieldFocusNode = FocusNode();
  List<List<String>> messages = [];
  List<String>sender=[],receiver=[];
  final String serverUrl = Constant().serverUrl;  // Replace with your server's URL
  late Timer meetingTimer;
  String senderNavigatorId = 'sender';
  String receiverNavigatorId = 'receiver';
  int meetingTime =20;
  Duration meetingDuration = Duration(); // Set your meeting duration
  Duration remainingTime = Duration();
  Timer countdownTimer = Timer(Duration(seconds: 0), () { });
  Timer alertTimer = Timer(Duration(seconds: 0), () { });
  ScrollController _scrollController = ScrollController();
  late RTCPeerConnection _peerConnection ;
  late MediaStream _localStream;
  // late Timer _timer;
  Duration _remainingTime = Duration();
  bool _isUiEnabled = true;
  late Timer _timer;
  bool dispalyHi = true;
  VoidCallback? onButtonPressed;
  bool dataFetched = false;
  String userId='',plannerId='',meetId='',date='',index='',meetStatus='',userName='',userPhoto='',plannerName='',plannerPhoto='',startTime='',endTime='',meetType='',plannerToken='',userToken='';
  DateTime? time;
  bool meetClosed = false,_isTyping=false;
  bool meetScheduled = false;


  @override
  void initState() {
    super.initState();
    meetingDuration = Duration(minutes: meetingTime);
    initalSetup();
  }

  Future<void> initalSetup()async{
    setState(() {
      dataFetched = false;
    });

    await fetchMeetStatus();
    await fetchTripPlanningMeetDetais();
    if(meetStatus=='close' || meetStatus=='closed'){
      setState(() {
        meetClosed = true;
      });
    }
    else{
      if (time != null && time!.isAfter(DateTime.now())) {
        // DateTime is greater than current time, start the countdown
        setState(() {
          meetScheduled = true;
        });
        startCountdown();

      }
      else{
        _isUiEnabled = false;
        startMeetingTimer();
        await startSocketConnection();
      }
    }
    await fetchDataset();
    await retriveMeetingConversation(meetId);
    if(messages.length>0){
      scrollToBottom();
    }
    _textFieldFocusNode.addListener(() {
      scrollToBottom();
      setState(() {
        scrollToBottom();
        _isTyping = _textFieldFocusNode.hasFocus;
        if (_isTyping) {
          print("Keyboard opened");
          scrollToBottom();
        } else {
          _isTyping = false;
          print("Keyboard closed");
          scrollToBottom();
        }
      });
    });
    setState(() {
      dataFetched = true;
    });
  }

  DateTime parseCustomDateTime(String dateTimeString) {
    Map<String, int> monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };

    List<String> dateTimeParts = dateTimeString.split(' ');

    List<String> dateParts = dateTimeParts[0].split('/');
    int day = int.parse(dateParts[0]);
    int month = monthMap[dateParts[1]]!;
    int year = int.parse(dateParts[2]);

    List<String> timeParts = dateTimeParts[1].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    String amPm = dateTimeParts[2];

    if (amPm.toLowerCase() == 'pm' && hour < 12) {
      hour += 12;
    } else if (amPm.toLowerCase() == 'am' && hour == 12) {
      hour = 0;
    }

    DateTime parsedDateTime = DateTime(year, month, day, hour, minute);
    return parsedDateTime;
  }
  DateTime setDateTime(date,time){
    String parsedDateTime = ('$date $time');
    DateTime parsedDateTime2 = parseCustomDateTime(parsedDateTime);
    if (parsedDateTime2 != null) {
      print('Parsed DateTime: $parsedDateTime2');
    } else {
      print('Invalid date format...');
    }

    return parsedDateTime2;
  }

  Future<void> fetchDataset() async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userID}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Users Name and Photo Taken');
      setState(() {
        if(widget.senderId!=''){
          userName = data['userName'];
          userPhoto = data['userPhoto']!=null?data['userPhoto']:'';
        }else{
          userName = data['userName'];
          userPhoto = data['userPhoto']!=null?data['userPhoto']:'';
        }
      });
    } else {
      // Handle error
      print('Failed to fetch users name & phone : ${response.statusCode}');
    }
  }

  Future<void> startSocketConnection()async{
    socket = IO.io(serverUrl+'/tripPlanning', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    try {
      socket.connect();
      print('Hello Local Assistant Service Started :) ');
    } catch (err) {
      print('Error connecting to the local assistant: $err');
    }

    try {
      socket.on('message', (data) {
        // Handle 'data' based on your requirements
        print('BroadCast Message Received : ${data}');
        updateBroadCast(data);
        print('Message is :${data['message']}');
      });
    }
    catch (err) {
      print('Error in Message : $err');
    }

    // Emit 'join' event with uniqueIdentifier, senderId, receiverId, and meetingId
    try {
      print('Meetig ${widget.meetingId}');
      socket.emit('join', {widget.meetingId});
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
  Future<void> fetchTripPlanningMeetDetais()async{
    final url = Uri.parse('$serverUrl/fetchMeetDetails');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId" : userID,
      "date" : widget.date,
      "meetStartTime":widget.startTime,
    };
    print('data is ');
    print(requestData);
    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final data = jsonDecode(response.body)['details'][0];
        // userWith10km = List<String>.from(data);
        print('Data fethced $data');
        setState(() {
          userId = userID;
          plannerId = data['plannerId'];
          meetId = data['meetId'];
          meetStatus = data['meetStatus'];
          startTime = data['start'];
          endTime = data['end'];
          meetType = data['meetType'];
          plannerToken = data['plannerToken'];
          userName = data['plannerName'];
          userPhoto = data['plannerPhoto'];
          plannerName = data['plannerName'];
          plannerPhoto = data['plannerPhoto'];
          time= setDateTime(widget.date, data['start']);
          if(data['meetType']=='sender'){
            widget.senderId = userID;
            // widget.receiverId = data['plannerId'];
          }else{
            // widget.senderId = ;
            widget.receiverId = userID;
          }
          widget.meetingId = meetId;
          widget.currentTime = time;
          if(widget.senderId!=''){
          }else{

          }
        });
        print('Meeting is ${widget.meetingId}');
        return ; // Return the ID
      } else {
        print("Failed to save meet. Status code: ${response}");
        throw Exception("Failed to save meet");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }

  Future<void> fetchMeetStatus()async{
    final url = Uri.parse('$serverUrl/fetchMeetDetails');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId" : userID,
      "date" : widget.date,
      'meetStartTime':widget.startTime,
    };

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final data = jsonDecode(response.body)['details'][0];
        // userWith10km = List<String>.from(data);
        print('Data fethced $data');
        setState(() {
          meetStatus = data['meetStatus'];
        });
        if(meetStatus=='closed' || meetStatus=='close'){
          meetClosed=true;
        }
        // print(data['start']);
        return ; // Return the ID
      } else {
        print("Failed to save meet. Status code: ${response}");
        throw Exception("Failed to save meet");
      }
      setState(() {});
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }
  Future<void> retriveMeetingConversation(String meetId) async {
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final http.Response response = await http.get(
        Uri.parse('$serverUrl/fetchMeetingConversation/$meetId'),);

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
      } else {
        print('Failed to retrive data: ${response.statusCode}');
      }
    }catch(err){
      print("Error is 2: $err");
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void updateBroadCast(dynamic data)async{
    setState(() {
      messages.add([data['message'],data['user']]);
      if(data['user']=='sender')
        sender.add(data['message']);
      else if(data['user']=='receiver')
        receiver.add(data['message']);
      scrollToBottom();
    });
  }

  Future<void> cancelMeeting(String date,String startTime,String status,String plannerId,String otherStatus)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId':userID,
        'date':date,
        'startTime':startTime,
        'setStatus':status,
        'user2Id':plannerId,
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
      print("Error Is 1: $err");
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
      print("Error is 2: $err");
    }
  }

  void updateRemainingTime() {
    if(mounted){
      setState(() {
        DateTime currentTime = DateTime.now();
        Duration elapsed = currentTime.difference(widget.currentTime!);
        remainingTime = meetingDuration - elapsed;
        print(remainingTime);
        if (remainingTime.inSeconds <= 0) {
          // timer.cancel();
          // Perform necessary actions when the meeting ends
          navigateToEndScreen();
        }
        else if(remainingTime.inMinutes==1 && remainingTime.inSeconds==0){
          showOneMinuteAlert();
        }
      });
    }
  }

  Future<void> _refreshPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatApps(senderId:widget.senderId,receiverId:widget.receiverId,date:widget.date,index:widget.index),
      ),
    );
  }

  void startCountdown() {
    _remainingTime = widget.currentTime!.difference(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(mounted){
        setState(() {
          _remainingTime = widget.currentTime!.difference(DateTime.now());
          if (_remainingTime.inSeconds <= 0) {
            _timer.cancel();
            // _refreshPage();
            meetScheduled = false;
            initalSetup();
          }
        });
      }
    });
  }

  void startMeetingTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateRemainingTime();
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

  void navigateToEndScreen() async{
    // Navigate to the end screen after the meeting ends
    await cancelMeeting(widget.date!,startTime,'close',plannerId,'close');
    await fetchMeetStatus();
    if(meetType=='sender'){
      sendCustomNotificationToOneUser(
          userToken,
          'Trip Planning Meeting Updates',
          'Trip Planning Request Updates','Meeting is closed successfully',
          'Closed','trip_planning_close',userID,'user'
      );
    }
    else{
      sendCustomNotificationToOneUser(
          plannerToken,
          'Message From ${userName}',
          'Messages From ${userName}' ,'Meeting  with ${date} , ${startTime} is cancelled by ${userName}',
          'Closed','trip_planning_close',userId,'helper'
      );
    }
    setState(() {
      meetClosed = true;
    });
    // showMeetingEndedAlert();

    // Navigator.of(context).pop();
    // widget.callbacker!();
    // Navigator.of(context).pop();
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => PingsSection(userId: widget.senderId==''?widget.receiverId:widget.senderId,)),
    // );
  }

  String twoDigits(int n,int idx) {
    String add = idx==0?'D : ':idx==1?'H  : ':idx==2?'M  : ':'S';
    if (n >= 10) {
      return "$n$add";
    } else if(n>0 && idx!=3) {
      return "0$n$add";
    }else{
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // int minutes = remainingTime.inMinutes;
    return Scaffold(
      appBar: AppBar( automaticallyImplyLeading: false,title: ProfileHeader(reqPage: 2,text:'chats',userId:userID,onButtonPressed:(){
        if(meetStatus=='schedule'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PingsSection(userId:userID,state:'Scheduled',selectedService: 'Trip Planning',fromWhichPage: 'trip_planning',),
            ),
          );
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PingsSection(userId:userID,state:'Closed',selectedService: 'Trip Planning',fromWhichPage: 'trip_planning',),
            ),
          );
        }
          // if(widget.senderId!='')
          //   storeDataLocally(senderNavigatorId);
          // else
          //   storeDataLocally(receiverNavigatorId);
      },service:'trip_planning',fromWhichPage: 'trip_planning_chat',meetStatus:_isUiEnabled==false?'started':meetStatus,state: meetType=='sender'?'user':'helper',cancelCloseClick: ()async{
        String currentMeetStatus = meetStatus;
        await fetchMeetStatus();
        if(currentMeetStatus!=meetStatus){
          Fluttertoast.showToast(
            msg:
            'Meeting Is Closed By ${plannerName}.Update Page!!',
            toastLength:
            Toast.LENGTH_SHORT,
            gravity:
            ToastGravity.BOTTOM,
            backgroundColor:
            Theme.of(context).primaryColorDark,
            textColor: Colors.orange,
            fontSize: 16.0,
          );
          setState(() {
            meetClosed = true;
          });
        }
        else{
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ImagePopUpWithTwoOption(imagePath: 'assets/images/logo.png',textField:'You are closing this request ?',extraText: 'Thank you for using our services !', what: 'a',
                option2Callback:()async{

                  await cancelMeeting(widget.date!,startTime,'close',plannerId,'close');
                  socket.emit('message', {'message':'','user1':'admin-close','user2':''});
                  if(meetType=='sender'){
                    sendCustomNotificationToOneUser(
                        userToken,
                        'Trip Planning Meeting Updates',
                        'Meeting is closed successfully <br/> Thank You For Using Service','Meeting is closed successfully',
                        'Closed','trip_planning_close',userID,'user'
                    );
                  }
                  else{
                    sendCustomNotificationToOneUser(
                        plannerToken,
                        'Message From ${userName}',
                        'Messages From ${userName} <br/> Meeting  with ${date} , ${startTime} is closed by ${userName}' ,'Meeting  with ${date} , ${startTime} is closed by ${plannerName}',
                        'Closed','trip_planning_close',plannerId,'helper'
                    );
                  }
                  setState(() {
                    meetClosed = true;
                  });
                },);
            },
          );
        }
      },),),
      body: WillPopScope(
        onWillPop: ()async{
          // if(_isUiEnabled!=true){
          //   if(widget.senderId!='')
          //     storeDataLocally(senderNavigatorId);
          //   else
          //     storeDataLocally(receiverNavigatorId);
          // }
          if(meetStatus=='schedule'){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PingsSection(userId:userID,state:'Scheduled',selectedService: 'Trip Planning',fromWhichPage: 'trip_planning',),
              ),
            );
          }else{
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PingsSection(userId:userID,state:'Closed',selectedService: 'Trip Planning',fromWhichPage: 'trip_planning',),
              ),
            );
          }
          return true;
        },
        child: Container(
          color: Theme.of(context).backgroundColor,
          height : MediaQuery.of(context).size.height,
          width : double.infinity,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20,right:20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15,),
                        dataFetched
                            ? Container(
                            width: 200,
                            margin: EdgeInsets.only(bottom: 10),
                            child: meetType=='sender'
                                ? Text('Get Connected With Trip Planner',style:Theme.of(context).textTheme.headline2,)
                                : Text('Get Connected With Your Customer',style:Theme.of(context).textTheme.headline2,)
                        )
                            : SizedBox(height: 0,),
                        dataFetched
                            ? Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text('You can chat, talk or do the Video call',style: Theme.of(context).textTheme.subtitle2,))
                            : SizedBox(height: 0,),
                        dataFetched
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/clock.png',width: 22,height: 22,color: meetClosed?Colors.orange : _isUiEnabled?Colors.red:Colors.green,),
                            SizedBox(width: 10,),
                            meetClosed
                                ?Text('00M:00S',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w800,color: Colors.orange,fontFamily: 'Poppins'),)
                                : _isUiEnabled
                                ?Text(
                              "Time Left - ${twoDigits(_remainingTime.inDays,0)}${twoDigits((_remainingTime.inHours)%24,1)}${twoDigits((_remainingTime.inMinutes % 60),2)}${twoDigits((_remainingTime.inSeconds % 60),3)}",
                              style: TextStyle(fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.red),
                            )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('${remainingTime.inMinutes}Min : ${(remainingTime.inSeconds)%60}Sec ',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: Colors.green),),
                                    Text(' left ',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.green.withOpacity(0.5),fontSize: 13,fontFamily: 'Poppins',fontStyle: FontStyle.normal),),
                                  ],
                                ),
                          ],
                        )
                            :SizedBox(height: 0,),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  // !dataFetched
                  //     ? Center(
                  //   // Show a circular progress indicator while data is being fetched
                  //   child: CircularProgressIndicator(
                  //     color: Theme.of(context).primaryColorDark,
                  //   ),
                  // )
                  // :SizedBox(height: 0,),
                  meetScheduled
                      ? Expanded(child: SizedBox(height: 0,))
                      :messages.length==0 && !_isUiEnabled && dataFetched
                      ?Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: (){
                            if(meetType=='sender'){
                              _controller.text = 'Hi ${Constant().extractFirstName(plannerName)},i want to have discussion about my next trip to....';
                            }else{
                              _controller.text = 'Hi ${Constant().extractFirstName(plannerName)},how can i help u with your next trip....';
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20,left:25,right:25),
                            padding: EdgeInsets.only(left: 30,right: 30),
                            height: 150,
                            decoration: BoxDecoration(
                              // color: Colors.white,
                              // color: Colors.red,// Container background color
                              color: Theme.of(context).primaryColorLight,

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.6),
                                  spreadRadius: 0.4,
                                  blurRadius: 0.6,
                                  offset: Offset(0.5, 0.8),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Say Hi!',style: Theme.of(context).textTheme.headline1,),
                                Text('You have 20 min, to discuss and plan your next trip',style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      :(!_isUiEnabled || meetClosed) && dataFetched
                      ? Expanded(
                     child: Container(
                      margin: EdgeInsets.only(bottom: 70),
                      padding:EdgeInsets.only(right:5,left:5),
                      // color: Colors.red,
                      // decoration: BoxDecoration(border:Border.all(width: 1)),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            minVerticalPadding: 7.0,
                            title:messages[index][1]=='sender'
                                ?widget.senderId!=''
                                ?Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.black,

                                      radius: 15.0,
                                      backgroundImage: FileImage(File(userPhoto)) as ImageProvider<Object>, // Use a default asset image
                                    ),
                                    SizedBox(width: 6,),
                                    Container(
                                        width:240,
                                        decoration: BoxDecoration(

                                          boxShadow: [

                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2), // Set your desired shadow color
                                              spreadRadius: 0.3,
                                              blurRadius: 0.4,
                                              offset: Offset(0.7, 0.8), // Adjust the shadow offset
                                            ),
                                          ],

                                          color: Theme.of(context).primaryColorLight,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0.0),
                                            topRight: Radius.circular(10.0),
                                            bottomLeft: Radius.circular(10.0),
                                            bottomRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.only( right : 5, top : 3, bottom :10),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 8,),
                                            Container(
                                                width: 200,
                                                padding: EdgeInsets.only(left: 4),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      Constant().extractFirstName('You'),
                                                      style: Theme.of(context).textTheme.subtitle1,
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(messages[index][0],style: Theme.of(context).textTheme.subtitle2,),
                                                  ],
                                                )),
                                          ],
                                        )
                                    ),
                                  ],
                                )
                                :Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.black,
                                       radius: 15.0,
                                      backgroundImage: FileImage(File(plannerPhoto)) as ImageProvider<Object>, // Use a default asset image
                                    ),
                                    SizedBox(width: 6,),
                                    Container(
                                        width:240,
                                        decoration: BoxDecoration(

                                          boxShadow: [

                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2), // Set your desired shadow color
                                              spreadRadius: 0.3,
                                              blurRadius: 0.4,
                                              offset: Offset(0.7, 0.8), // Adjust the shadow offset
                                            ),
                                          ],

                                          color: Theme.of(context).primaryColorLight,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0.0),
                                            topRight: Radius.circular(10.0),
                                            bottomLeft: Radius.circular(10.0),
                                            bottomRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.only( right : 5, top : 3, bottom :10),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 8,),
                                            Container(
                                                width: 200,
                                                padding: EdgeInsets.only(left: 4),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      Constant().extractFirstName(plannerName),
                                                      style: Theme.of(context).textTheme.subtitle1,
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(messages[index][0],style: Theme.of(context).textTheme.subtitle2,),
                                                  ],
                                                )),
                                          ],
                                        )),
                                  ],
                                )
                                :messages[index][1]=='receiver'
                                ?widget.senderId==''
                                ?Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.black,

                                      radius: 15.0,
                                      backgroundImage: FileImage(File(userPhoto)) as ImageProvider<Object>, // Use a default asset image
                                    ),
                                    SizedBox(width: 6,),
                                    Container(
                                        width:240,
                                        decoration: BoxDecoration(

                                          boxShadow: [

                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2), // Set your desired shadow color
                                              spreadRadius: 0.3,
                                              blurRadius: 0.4,
                                              offset: Offset(0.7, 0.8), // Adjust the shadow offset
                                            ),
                                          ],

                                          color: Theme.of(context).primaryColorLight,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0.0),
                                            topRight: Radius.circular(10.0),
                                            bottomLeft: Radius.circular(10.0),
                                            bottomRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.only( right : 5, top : 3, bottom :10),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 8,),
                                            Container(
                                                width: 200,
                                                padding: EdgeInsets.only(left: 4),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'You',
                                                      style: Theme.of(context).textTheme.subtitle1,
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(messages[index][0],style: Theme.of(context).textTheme.subtitle2,),
                                                  ],
                                                )),
                                          ],
                                        )),
                                  ],
                                )
                                :Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.black,

                                      radius: 15.0,
                                      backgroundImage: FileImage(File(plannerPhoto)) as ImageProvider<Object>, // Use a default asset image
                                    ),
                                    SizedBox(width: 6,),
                                    Container(
                                        width:240,
                                        decoration: BoxDecoration(

                                          boxShadow: [

                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2), // Set your desired shadow color
                                              spreadRadius: 0.3,
                                              blurRadius: 0.4,
                                              offset: Offset(0.7, 0.8), // Adjust the shadow offset
                                            ),
                                          ],

                                          color: Theme.of(context).primaryColorLight,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0.0),
                                            topRight: Radius.circular(10.0),
                                            bottomLeft: Radius.circular(10.0),
                                            bottomRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.only( right : 5, top : 3, bottom :10),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 8,),
                                            Container(
                                                width: 200,
                                                padding: EdgeInsets.only(left: 4),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      Constant().extractFirstName(plannerName),
                                                      style: Theme.of(context).textTheme.subtitle1,
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(messages[index][0],style: Theme.of(context).textTheme.subtitle2,),
                                                  ],
                                                )),
                                          ],
                                        )),
                                  ],
                                )
                                :SizedBox(height: 0,),
                          );
                        },
                      ),
                    ),
                  )
                      :Expanded(child: SizedBox(height: 0, child: Center(
                        child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColorDark,
                  ),
                      ),)),
                ],
              ),

              dataFetched
                  ? Positioned(
                bottom : 0,
                left : 0,
                right : 0,
                child: meetClosed
                    ? InkWell(
                  onTap: (){
                    if(meetStatus=='close'){
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => RateFeedBack(userId:userID,startTime: widget.startTime!,date:widget.date,fromWhichPage:'trip_planning_chat'),
                      //   ),
                      // );
                    }
                  },
                  child: Container(
                    height : 63,
                    padding:EdgeInsets.only(left:10,right:10),
                    decoration: BoxDecoration(
                      color : Colors.grey[200],
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Center(child:Text('Closed',style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18))),
                  ),
                )
                    :  Container(
                  margin: EdgeInsets.only(left:5,right:5,bottom: 10),

                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                      Flexible(
                        child: Container(
                          // width: 300,
                          height: 60,
                          decoration: BoxDecoration(
                            color : Theme.of(context).primaryColorLight,

                            boxShadow: [

                              BoxShadow(
                                color: Colors.black.withOpacity(0.2), // Set your desired shadow color
                                spreadRadius: 0.5,
                                blurRadius: 0.2,
                                offset: Offset(0, 2), // Adjust the shadow offset
                              ),
                            ],

                            borderRadius: BorderRadius.circular(50),
                          ),
                          // padding: EdgeInsets.only(left: 25,right: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 30,),
                              Expanded(
                                child: Container(
                                  child: TextField(
                                    style : Theme.of(context).textTheme.subtitle2,
                                    onChanged: (text){
                                      setState(() {
                                        scrollToBottom();
                                      });
                                      // if (text.length > 0) {
                                      //   setState(() {
                                      //     messageTyping = true;
                                      //   });
                                      // } else {
                                      //   setState(() {
                                      //     messageTyping = false;
                                      //   });
                                      // }
                                    },
                                    onTap: (){
                                      if(_isUiEnabled){
                                        _textFieldFocusNode.unfocus();
                                      }
                                    },
                                    onTapOutside: (value){
                                      _textFieldFocusNode.unfocus();
                                    },
                                    onSubmitted: (value){
                                      _textFieldFocusNode.unfocus();
                                    },
                                    onEditingComplete: (){
                                      _textFieldFocusNode.unfocus();
                                    },
                                    maxLines: null,
                                    focusNode: _textFieldFocusNode,
                                    controller: _controller,
                                    decoration: InputDecoration(hintText: 'Type your Message here....',hintStyle: Theme.of(context).textTheme.subtitle2,border: InputBorder.none, ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                  onTap: ()async{
                                    String ?path = await showDialog(context: context, builder: (BuildContext context){
                                      return Container(child: UploadMethod());
                                    },);
                                    if(path!=null && path.length>0){
                                      if(meetType=='receiver'){
                                        await updateMeetingChats(meetId,[path,'helper']);
                                        socket.emit('message', {'message':path,'user1':'','user2':'helper'});
                                      }
                                      else{
                                        await updateMeetingChats(meetId,[path,'user']);
                                        socket.emit('message', {'message':path,'user1':'user','user2':''});
                                      }
                                      setState(() {});
                                    }
                                  },
                                  child: SvgPicture.asset('assets/images/attachment_icon.svg',color : Theme.of(context).primaryColor,)),
                              SizedBox(width: 20,),
                            ],
                          ),
                        ),
                      ),
                      // SizedBox(width: 5,),
                      // Container(
                      //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
                      //   child: IconButton(
                      //     icon: Icon(Icons.call),
                      //     // onPressed:initiateVideoCall,
                      //     onPressed: !_isUiEnabled ? startCall : null,
                      //   ),
                      // ),
                      // SizedBox(width: 5,),
                      // Container(
                      //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
                      //   child: IconButton(
                      //     icon: Icon(Icons.videocam),
                      //     // onPressed:initiateVideoCall,
                      //     onPressed: (){},
                      //   ),
                      // ),
                      _controller.text.length>0
                        ? Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),

                          boxShadow: [


                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Set your desired shadow color
                              spreadRadius: 0.5,
                              blurRadius: 0.2,
                              offset: Offset(0, 2), // Adjust the shadow offset
                            ),
                          ],
                          color : Theme.of(context).primaryColorLight,
                        ),
                          child: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: !_isUiEnabled ? _handleSend : null,
                      ),
                        ):SizedBox(width: 0,),
                      _controller.text.length==0
                      ? Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),

                          boxShadow: [


                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Set your desired shadow color
                              spreadRadius: 0.5,
                              blurRadius: 0.2,
                              offset: Offset(0, 2), // Adjust the shadow offset
                            ),
                          ],
                          color : Theme.of(context).primaryColorLight,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.call),
                          onPressed:()async{
                            // await _joinCall(
                            //   callerId: widget.meetId!,
                            //   calleeId: widget.meetId!,
                            //   section: 'audio',
                            //   imageOwn:userPhoto,
                            //   imageOther:helperPhoto,
                            // );
                          },
                          // onPressed: !_isUiEnabled ? startCall : null,
                          color : Theme.of(context).primaryColor,
                        ),
                      )
                      :SizedBox(width: 0,),
                      _controller.text.length==0
                      ? Container(
                        // margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),
                          boxShadow: [


                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Set your desired shadow color
                              spreadRadius: 0.5,
                              blurRadius: 0.2,
                              offset: Offset(0, 2), // Adjust the shadow offset
                            ),
                          ],
                          color : Theme.of(context).primaryColorLight,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.videocam),
                          // onPressed:initiateVideoCall,
                          onPressed: (){
                            // _joinCall(
                            //   callerId: widget.meetId!,
                            //   calleeId: widget.meetId!,
                            //   section: 'video',
                            //   imageOwn:userPhoto,
                            //   imageOther:helperPhoto,
                            // );

                          },
                          color : Theme.of(context).primaryColor,
                        ),
                      )
                      :SizedBox(width: 0,),
                  ],
                ),
                    ),
              )
                  : SizedBox(height: 0,),
            ],
          ),
        )
      ),
      // bottomNavigationBar:
      // meetClosed
      //     ? InkWell(
      //       onTap: (){},
      //       child: Container(
      //   height : 63,
      //   padding:EdgeInsets.only(left:10,right:10),
      //   decoration: BoxDecoration(
      //       color : Colors.grey[200],
      //       borderRadius: BorderRadius.circular(0),
      //       border: Border.all(color: Colors.orange),
      //   ),
      //   child: Center(child:Text(meetStatus=='cancel'?'Cancelled': meetStatus=='close'?'Rate & Feedback' :'Closed',style: TextStyle(
      //         fontWeight: FontWeight.bold,
      //         color: Colors.orange,
      //         fontSize: 18))),
      // ),
      //     )
      //     :  Row(
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   children: [
      //     Container(
      //       width: MediaQuery.of(context).size.width,
      //       height: 60,
      //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2'),
      //       ),
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         children: <Widget>[
      //           SizedBox(width: 30,),
      //           Expanded(
      //             child: TextField(
      //               onChanged: (text){
      //                 setState(() {
      //                   scrollToBottom();
      //                 });
      //               },
      //               onTapOutside: (value){
      //                 _textFieldFocusNode.unfocus();
      //               },
      //               onSubmitted: (value){
      //                 _textFieldFocusNode.unfocus();
      //               },
      //               onEditingComplete: (){
      //                 _textFieldFocusNode.unfocus();
      //               },
      //               focusNode: _textFieldFocusNode,
      //               controller: _controller,
      //               decoration: InputDecoration(hintText: 'Type your Message here',border: InputBorder.none, ),
      //             ),
      //           ),
      //           IconButton(
      //             icon: Icon(Icons.send),
      //             onPressed: !_isUiEnabled ? _handleSend : null,
      //           ),
      //         ],
      //       ),
      //     ),
      //     // SizedBox(width: 5,),
      //     // Container(
      //     //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
      //     //   child: IconButton(
      //     //     icon: Icon(Icons.call),
      //     //     // onPressed:initiateVideoCall,
      //     //     onPressed: !_isUiEnabled ? startCall : null,
      //     //   ),
      //     // ),
      //     // SizedBox(width: 5,),
      //     // Container(
      //     //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
      //     //   child: IconButton(
      //     //     icon: Icon(Icons.videocam),
      //     //     // onPressed:initiateVideoCall,
      //     //     onPressed: (){},
      //     //   ),
      //     // ),
      //   ],
      // ),
    );
  }

  void _handleSend() async{
    String message = _controller.text;
    if (message.isNotEmpty) {
      try {
        // Send the message to the server
        print('Meet Type ${meetType} ${userName} ${widget.startTime} ${widget.date}');
        if(meetType=='sender') {
          await updateMeetingChats(meetId,[message,'sender']);
          socket.emit('message', {'message':message,'user1':'sender','user2':''});
          sendCustomNotificationToOneUser(
              plannerToken,
              'Message From ${userName}',
              'Message From ${userName}',_controller.text,
              '${widget.date}','trip_planning_chat_message','sender','${widget.startTime}'
          );
        } else{
          await updateMeetingChats(meetId,[message,'receiver']);
          socket.emit('message', {'message':message,'user1':'','user2':'receiver'});
          sendCustomNotificationToOneUser(
              plannerToken,
              'Message From ${userName}',
              'Message From ${userName}',_controller.text,
              '${widget.date}','trip_planning_chat_message','receiver','${widget.startTime}}'
          );
        }
        print(message);
        _controller.clear();
      } catch (e) {
        print('Error sending messagesss: $e');
        // Handle the error, e.g., display an error message to the user
      }
    } else {
      // Handle empty message, e.g., display a validation error to the user
      print('message is not valid');
    }
  }


  // Voice Call Need some Debugging
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

  void initiateVideoCall() {
    // Signal the backend to join the video call room
    socket.emit("joinVideoCallRoom", widget.meetingId); // Replace roomId with the unique ID

    // When both users are in the same room, start the video call
    socket.on("videoCallStarted", (data) {
      // Logic to initiate the video call using WebRTC
      // Start streaming video between the users
      // Navigate to the video call screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => CallScreen(callerId:widget.senderId,calleeId:widget.receiverId,offer:widget.meetingId), // Adjust as per your widget structure
      //   ),
      // );
    });

    // Handle ICE candidates
    socket.on("newICECandidate", (data) {
      // data format should include candidate, sdpMid, sdpMLineIndex
      RTCIceCandidate candidate = RTCIceCandidate(
        data["candidate"],
        data["sdpMid"],
        data["sdpMLineIndex"],
      );
      _rtcPeerConnection?.addCandidate(candidate);
    });

    // Handle call responses
    socket.on("callAnswered", (data) async {
      await _rtcPeerConnection?.setRemoteDescription(
        RTCSessionDescription(
          data["sdpAnswer"]["sdp"],
          data["sdpAnswer"]["type"],
        ),
      );

      rtcIceCadidates.forEach((candidate) {
        socket.emit("newICECandidate", {
          "calleeId": widget.receiverId,
          "iceCandidate": {
            "id": candidate.sdpMid,
            "label": candidate.sdpMLineIndex,
            "candidate": candidate.candidate,
          },
        });
      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    print('Destroy');
    // _timer.cancel();
    countdownTimer.cancel();
    _textFieldFocusNode.dispose();
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
