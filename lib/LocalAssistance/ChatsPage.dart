import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/All_Notifications/customizeNotification.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/CustomItems/RotatingSvgWidget.dart';
import 'package:learn_flutter/LocalAssistance/LocalAssist.dart';
import 'package:learn_flutter/ServiceSections/LocalAssistant/MapNavigator.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:learn_flutter/userLocation.dart';
import 'package:open_file/open_file.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:photo_view/photo_view.dart';

// import '../Notifications/NotificationManager.dart';
import '../Notifications/CustomNotificationMessages.dart';
import '../ServiceSections/TripCalling/Payments/RazorPay.dart';



import '../UserProfile/CoverPage.dart';
import '../UserProfile/ProfileHeader.dart';
import '../fetchDataFromMongodb.dart';
import '../widgets/Constant.dart';
import '../widgets/CustomButton.dart';
import '../widgets/CustomDialogBox.dart';
import '../widgets/hexColor.dart';
import 'package:http/http.dart'as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';

import '../ServiceSections/TripCalling/Payments/UpiPayments.dart';
import '../ServiceSections/VideoCalling/CallingScreen.dart';
import '../ServiceSections/VideoCalling/SignallingService.dart';
import '../ServiceSections/LocalAssistant/ChatSection/Uploader.dart';

// void main(){
//   runApp(ChatsPage(userId:'652a31f77ff9b6023a14838a',state:'user',meetId: '65844f69318c03e09ec1c5e0',));
// }

class ChatsPage extends StatefulWidget {
  String userId;
  String ? state,meetId,helperId,meetStatus,where,paymentStatus;

  ChatsPage({required this.userId,this.state,this.meetId,this.helperId,this.meetStatus,this.where,this.paymentStatus});
  @override
  State<ChatsPage> createState() => _ChatsPageState();

}

class _ChatsPageState extends State<ChatsPage> {


  List<String> userTokens = [

  ];



  String _isAccepted = 'no';
  bool _isMeetStatusFound = false;

  bool _userRefreshingPageOnFirstMessage = false;

  bool _chatBoxVisibility = false;

  String paymentStatus = '';



  List<String>userIds = [];
  List<String>distance = [];
  bool _isTyping = false;
  File? _userProfileImage;
  double bottomInset = 0;
  FocusNode _textFieldFocusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  String liveLocation = 'Fetching location...';
  List <String>userWith10km=[],userWith10kmDist=[],userWith15km=[],userWith15kmDist=[];
  bool isContentLoaded = false;
  List<String>suggestedTexts = [
    'Need Mechanical help for my car ',
    'My Vehicle get Puncture  ',
    'My vehicle is out of fuel ',
    'My car battery get discharge ',
    'I need medical assistance ',
  ];
  bool _isUiEnabled = true;
  bool rotateButton = false;
  final TextEditingController _controller = TextEditingController();
  bool pageVisitor = true; // true means saviour coming to this page is user while in else condition its helper
  bool messageTyping = false;// Default text
  bool isScrollingUp = false;
  String helpingHands = '';



  void scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 10),
        curve: Curves.easeInOut,
      );
    });
  }


  void handleImageUpdated(File image) {
    setState(() {
      _userProfileImage = image; // Update the parameter in the main class
    });
  }


  late IO.Socket socket;
  late RTCPeerConnection _peerConnection;


  String userName = '',userPhoto = '',helperId='',helperAddress='',helperName='',helperPhoto='',helperLongitude='',helperNumber='',meetStatus='',helperLatitude='', helperToken='';
  bool helperMessage=false;
  final String serverUrl = Constant().serverUrl;  // Replace with your server's URL

  bool messagesStarted = false;
  List<List<String>> messages = [];
  List<String>sender=[],receiver=[];
  dynamic incomingSDPOffer;
  bool callEnded = false;

  String requestSend = 'yes';
  bool _helperRefreshCompleted = true;


  // void startTimer(Function callback) {
  //   const duration = Duration(seconds: 10);
  //   int elapsedSeconds = 0;
  //
  //   Timer.periodic(duration, (Timer timer) {
  //     if (elapsedSeconds < 3000) { // 5 minutes = 30 intervals of 10 seconds
  //       callback(); // Call your function here
  //       elapsedSeconds += 10;
  //     } else {
  //       timer.cancel(); // Cancel the timer after 5 minutes
  //     }
  //   });
  // }


  Future<String> createMeetRequest() async {
    final url = Uri.parse('$serverUrl/updateLocalAssistantMeetDetails');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId": widget.userId,
      "helperIds": userWith10km,
      "helperIds2": userWith15km,
      "helperDist" : userWith10kmDist,
      "helperDist2":userWith15kmDist,
      "meetTitle": _controller.text,
      "paymentStatus":'initiated',
      "time":DateTime.now().toIso8601String()
    };
    print('New Meet Details :  ${requestData}');
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
        await updateMeetingChats(meetId,[_controller.text,'user']);
        await createUpdateLocalUserPings(meetId,'pending');
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

  Future<void> _refreshPage(String meetId,{String state='user'}) async {
    // Add your data fetching logic here
    // For example, you can fetch new data from an API

    print('inside refresh ');
    await Future.delayed(Duration(seconds: 0));
    // Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatsPage(userId: widget.userId!,state: state,meetId:meetId),
      ),
    );
  }

  Future<void> createUpdateLocalUserPings(String meetId,String meetStatus) async {
    final url = Uri.parse('$serverUrl/setUpdateUserPings');
    // Replace with your data
    DateTime now = DateTime.now();
    String formattedDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    Map<String, dynamic> requestData = {
      "userId": widget.userId,
      "time":setCurrentTime(),
      "date":formattedDate,
      "title": _controller.text,
      'meetId':meetId,
      'meetStatus':meetStatus,
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
        await createUpdateLocalHelperPings(meetId,'choose');
      } else {
        print("Failed to create/update meet. Status code: ${response.statusCode}");
        throw Exception("Failed to save meet");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during creating/updating meet");
    }
  }

  Future<void> createUpdateLocalHelperPings(String meetId,String meetStatus) async {
    final url = Uri.parse('$serverUrl/setLocalHelpersPings');
    // Replace with your data
    DateTime now = DateTime.now();
    String formattedDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    Map<String, dynamic> requestData = {
      "userId": widget.userId,
      "time":setCurrentTime(),
      "date":formattedDate,
      "title": _controller.text,
      "distances":userWith10kmDist,
      "helperIds":userWith10km,
      'meetId':meetId,
      'meetStatus':meetStatus,
      'userName':userName,
      'userPhoto':userPhoto,
    };

    print('Message Sent To Pings Of Helpers ::$requestData');
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
        _refreshPage(meetId);
      } else {
        print("Failed to send request message to helpers. Status code: ${response.statusCode}");
        throw Exception("Failed to send request message to helpers.");
      }
    } catch (e) {
      print("Failed to send request message to helpers.: $e");
      throw Exception("Failed to send request message to helpers.");
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
        print('Meeting Conversation Restored');
        print(responseData);

        final List<dynamic> conversationJson = responseData['conversation'];
        setState(() {
          if(widget.state=='helper'  && responseData['paymentStatus']=='initiated'){
            print('Helper Message');
            helperMessage=true;
            _controller.text = '';
          }
          messages = conversationJson.map<List<String>>((list) {
            return (list as List<dynamic>).map<String>((e) => e.toString()).toList();
          }).toList();
          if(widget.state=='helper'){
            helperId = responseData['userId'];
          }
          else if(responseData['helperId']!=null){
            helperId = responseData['helperId'];
          }
        });
        print('Helpers Id :  $helperId');
        print('Helpers Name : $helperName');
        // if(widget.state=='helper'  && responseData['helperIds'].length==0 && responseData['paymentStatus']=='initiated'){
        //   await updatePaymentStatus('pending',meetId);
        // }

        if(helperId!=''){
          if(widget.state=='user')
            await fetchHelperDataset(responseData['helperId']);
          else if(widget.state=='helper')
            await fetchHelperDataset(responseData['userId']);
        }
        seperateList(messages);
      } else {
        print('Failed to retrive meet date : ${response.statusCode}');
      }
    }catch(err){
      print("Error is aa2: $err");
    }
  }

  Future<void> updatePaymentStatus(String paymentStatus,String meetId) async {
    try {
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/updateLocalMeetingHelperIds/$meetId'),
        headers: {
          "Content-Type": "application/json",
        },
        body:jsonEncode({"paymentStatus":paymentStatus,"time":DateTime.now().toIso8601String()}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Meeting Conversation Restored');
        print(responseData);
      } else {
        print('Failed to save meeting data : ${response.statusCode}');
      }
    }catch(err){
      print("Error in updating meeting status: $err");
    }
  }



  Future<void> updateMeetingChats(String meetId,List<String>meetDetails)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'meetId':meetId,
        'conversation':meetDetails,
      };
      print('Meeting Chats Request Sent : $data');

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
        print('Failed to update meeting chats : ${response.statusCode}');
      }
    }catch(err){
      print("failed to update meeting chats : $err");
    }
  }

  Future<void> getMeetStatus() async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/getLocalUserPingsStatus/${widget.userId}/${widget.meetId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Data Of Meet $data');
      setState(() {

        // meetStatus == 'schedule' ? _refreshPage(widget.meetId!,) : '';

        meetStatus = data['meetStatus'] == null ? 'start' : data['meetStatus'];
        print('pring kra rhea');
        print(data['meetStatus']);
        print(widget.state);




        _isMeetStatusFound = true;
      });
      print('Current Meeting Status $meetStatus');
    } else {
      // Handle error
      print('Failed to fetch meet status : ${response.statusCode}');
    }
  }


  Future<void> checkMeetStatus(String thisMeetId) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/getLocalUserPingsStatus/${widget.userId}/${thisMeetId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Data Of Meet $data');
      setState(() {


        if(data['meetStatus'] == 'hold_accept'){
          print('kosis kr rha hai');



          // _refreshPage(thisMeetId,state:'user');

        }


        print(data['meetStatus']);
        print(data['meetId']);

        data['meetStatus'] == 'hold_accept' ? meetStatus == 'hold_accept' : meetStatus == meetStatus;





      });
      print('Current Meeting Status $meetStatus');
    } else {
      // Handle error
      print('Failed to fetch meet status : ${response.statusCode}');
    }
  }

  void updateBroadCastMessage(dynamic data)async{
    setState(() {
      _isUiEnabled = false;
      messages.add([data['message'],data['user']]);
      if(data['user']=='user')
        sender.add(data['message']);
      else if(data['user']=='helper')
        receiver.add(data['message']);
    });
    if(data['user'].contains('admin')){

      if(data['user']=='admin-user-1')
        {
          _refreshPage(widget.meetId!,state: pageVisitor?'user':'helper');
          await fetchHelperDataset(helperId);
        }
      else
        await fetchHelperDataset(helperId);
      await getMeetStatus();
    }
    if(widget.meetId!=null && pageVisitor && helperId!=''){
      await updatePaymentStatus('pending',widget.meetId!);
    }
    if(widget.meetId!=null && helperId==''){
      await updatePaymentStatus('initiated',widget.meetId!);
    }
    scrollToBottom();
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
      print('Users Name and Photo Taken');
      setState(() {
        userName = data['userName'];
        userPhoto = data['userPhoto']!=null?data['userPhoto']:'';
      });
    } else {
      // Handle error
      print('Failed to fetch users name & phone : ${response.statusCode}');
    }
  }

  Future<void> fetchHelperDataset(String userId) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Users Profile Data : $data');
      setState(() {
        helperId = userId;
        helperLatitude=data['latitude']==null?'25.4622095':data['latitude'];
        helperLongitude=data['longitude']==null?'78.6419707':data['longitude'];
        helperName = data['userName'];
        helperPhoto = data['userPhoto']!=null?data['userPhoto']:'';
        helperNumber = data['phoneNumber'].toString();
        helperToken = data['uniqueToken'];

      });
      await getAddress(helperLatitude, helperLongitude);
    } else {
      // Handle error
      print('Failed to fetch users profile data : ${response.statusCode}');
    }
  }

  Future<void> updateLocalUserPings(String userId,String meetId,String meetStatus) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/updateLocalUserPings');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId": userId,
      'meetId':meetId,
      'meetStatus':meetStatus,
    };
    print('Messa::$requestData');
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
        final responseData = jsonDecode(response.body);
        print("Response: $responseData");
      } else {
        print("Failed to update pings. Status code: ${response.statusCode}");
        throw Exception("Failed to update pings");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }


  @override
  void initState() {
    super.initState();
    checkMeetStatus('');

    getMeetStatus();
    scrollToBottom();
    getLocation();
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

    fetchData();
    if(widget.state!='user'){
      pageVisitor = false;
    }
    if(pageVisitor){
      userIds = userWith10km;
      distance = ['0.05','0.09'];
    }
    if(widget.meetId!=null) {
      startConnectionCards();
      // listen for incoming video call
      SignallingService.instance.init(
        websocketUrl: serverUrl,
        selfCallerID: widget.meetId!,
      );
      SignallingService.instance.socket!.on("newCall", (data) {
        if (mounted) {
          print('Remote User Tried To Call');
          // set SDP Offer of incoming call
          print('Incmoing SDP Offer :$incomingSDPOffer');
          setState(() => incomingSDPOffer = data);
        }
      });
      SignallingService.instance.socket!.on("leaveCall", (data) {
        setState(() => callEnded = true);
      });
    }
  }



  void scrollToBottomClick() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }


  Map<String, double> findUnique(Map<String, double> data1, Map<String, double> data2) {
    Map<String,double> uniqueData = {};

    data2.forEach((key, _) {
      if (!data1.containsKey(key)) {
        uniqueData[key] = data2[key]!;
      }
    });
    print('Help:${uniqueData}');
    return uniqueData;
  }

  Future<Map<String,double>> getUserIdsAndDistances(String providedLatitude, String providedLongitude, String userIdToRemove, int vardis) async {
    // setState(() {
    //   helpingHands = 0;
    // });

    print('inside this function ');


    final String serverUrl = Constant().serverUrl;
    final Uri uri = Uri.parse('$serverUrl/findUserIdsAndDistancesWithin10Km?providedLatitude=$providedLatitude&providedLongitude=$providedLongitude&vardis=${vardis}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['allUserIdsAndDistances'];

        print(data);
        print('printing users data and token here');

        final Map<String, double> userIdsAndDistances = {};






        data.forEach((item) {
          userIdsAndDistances[item['userId']] = item['distance'].toDouble();
        });




        print('helping hands');

        setState(() {
          userTokens = data.map((user) => user["uniqueToken"].toString()).toList();
          print('printing users tokens here $userTokens');

          if(vardis==10){
            helpingHands = '${userIdsAndDistances.length}';
          }

          // if(vardis==10){
          //   userWith10km = users;
          //   userWith10kmDist = dist;
          // }else{
          //   userWith15km = users;
          //   userWith15kmDist = dist;
          // }
        });

        print('printing users tokens here $userTokens');

        return userIdsAndDistances;
      } else {
        throw Exception('Failed to load data for helping hands');
      }
    } catch (error) {
      print('Error fetching user IDs and distances: $error');
      throw error; // Rethrow the error to propagate it to the calling code
    }
  }

  // join Call
  _joinCall({
    required String callerId,
    required String calleeId,
    required String section,imageOwn,imageOther,
    dynamic offer,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerId: callerId,
          calleeId: calleeId,
          section:section,
          offer: offer,
          imageOwn:userPhoto,
          imageOther:helperPhoto,
        ),
      ),
    );
  }

  Future<void> fetchData() async{
    await fetchDataset();
  }
  Future<void> startConnectionCards()async{
    await getMeetStatus();
    await retriveMeetingConversation(widget.meetId!);
    await socketConnection();
    // if(widget.state=='user'){}
    // else{
    //   if(meetStatus=='pending' && helperMessage){
    //     updateMeetingChats(widget.meetId!,[widget.userId,'admin-user-1']);
    //     // hey see this ther can be prblm as u are passing only userIf not helperId
    //     socket.emit('message', {'message':widget.userId,'user1':'admin-user-1','user2':''});
    //     _refreshPage(widget.meetId!,state:'helper');
    //   }else{}
    // }
  }

  Future<void> socketConnection()async{
    socket = IO.io(serverUrl+'/localAssistant', <String, dynamic>{
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
        updateBroadCastMessage(data);
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

  void _openFileWithDefaultApp(String message) {
    print('work');
    if (message != null) {
      OpenFile.open(message);
    }
  }

  //to get and print location name
  Future<void> getAndPrintLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark first = placemarks.first;
        String locationName = "${first.name}, ${first.locality}, ${first.administrativeArea}, ${first.country}";
        setState(() {
          liveLocation = locationName;
        });
      } else {
        // Return latitude and longitude if location not found
        setState(() {
          liveLocation = '$latitude, $longitude';
        });
      }
    } catch (e) {
      print("Error: $e");
      // Return latitude and longitude in case of an error fetching location
      setState(() {
        liveLocation = '$latitude, $longitude';
      });
    }
  }



  Future<void> getLocation() async{
    await _getUserLocation();
  }
  // Function to get user location
  Future<void> _getUserLocation() async {
    setState(() {
      liveLocation = 'fetching location';
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // Convert latitude and longitude to a string

      String providedLatitude = '${position.latitude}';
      String providedLongiude = '${position.longitude}';

      await getAndPrintLocationName(position.latitude, position.longitude);
      // Update the state with the user location

      if(widget.meetId==null){
        Map<String,double> tenKm = await getUserIdsAndDistances(providedLatitude, providedLongiude, userID,10);

        Map<String,double> fifteenKm = await getUserIdsAndDistances(providedLatitude, providedLongiude, userID,15);

        fifteenKm = findUnique(tenKm, fifteenKm);

        // Check if the userIdToRemove exists and remove it
        if (tenKm.containsKey(userID)) {
          tenKm.remove(userID);
        }

        tenKm.forEach((key, value) {
          userWith10km.add(key);
          userWith10kmDist.add(value.toString());
        });

        fifteenKm.forEach((key, value) {
          userWith15km.add(key);
          userWith15kmDist.add(value.toString());
        });

        print('Helppp');
        print(userWith10km);
        print(userWith15km);
      }


      setState(() {
        rotateButton = false;
      });



    } catch (e) {
      print("Error getting location: $e");
      setState(() {

      });
    }
  }


  void _handleSend()async {
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
        scrollToBottom();
        print('Message Is $message');
        await updatePaymentStatus('pending',widget.meetId!);
      } catch (e) {
        print('Error sending messagesss: $e');
        // Handle the error, e.g., display an error message to the user
      }
    } else {
      // Handle empty message, e.g., display a validation error to the user
      print('message is not valid');
    }
  }

  Future<void> getAddress(String latitude,String longitude)async{
    List<Placemark> placemarks = await placemarkFromCoordinates(
      double.parse(latitude),
      double.parse(longitude),
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      helperAddress = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      print('Address Of Users::$helperAddress');
    }
    else{
      print('Address Is Not Determined');
    }
  }

  String capitalize(String text) {
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }

  Future<bool> showConfirmationDialog(BuildContext context, String receiverName) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          message: 'Are You Sure To Cancel Meet With $receiverName',
          onCancel: () {
            Navigator.of(context).pop(false); // Return false when canceled
          },
          onConfirm: () {
            Navigator.of(context).pop(true); // Return true when confirmed
          },
        );
      },
    );
  }

  Future<void> updateLocalHelperPings(String meetId,String meetStatus) async {

    print('finding help here now');
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/updateLocalHelpersPings');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId": userID,
      'meetId':meetId,
      'meetStatus':meetStatus,
    };
    print('Messa::$requestData');
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
        final responseData = jsonDecode(response.body);
        print("Response: $responseData");
      } else {
        print("Failed to update pings. Status code: ${response.statusCode}");
        throw Exception("Failed to update pings");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }

  Future<void> createUpdateLocalUserPing(String userId,String meetId,String meetStatus,String userName,String userPhoto) async {
    final url = Uri.parse('${Constant().serverUrl}/setUpdateUserPings');
    Map<String, dynamic> requestData = {
      "userId": userID,
      'meetId':meetId,
      'meetStatus':meetStatus,
      "userName":userName,
      "userPhoto":userPhoto,
      "helperId":userID,
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
        _refreshPage(widget.meetId!,state:'helper');
      } else {
        print("Failed to create/update meet. Status code: ${response.statusCode}");
        throw Exception("Failed to save meet");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during creating/updating meet");
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_isUiEnabled){
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
    else{}
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(

      onWillPop: () async {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PingsSection(userId: userID,selectedService: 'Local Assistant', state : (meetStatus=='pending')?'Pending':(meetStatus=='schedule')?'Scheduled':'All')),
        );

        return false;
      },

      child: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 2,userId: widget.userId,assistMeetId: widget.meetId,tripHelperId: widget.helperId,meetStatus : widget.meetStatus,requestSend : requestSend),automaticallyImplyLeading: false,backgroundColor: Theme.of(context).backgroundColor, shadowColor: Colors.transparent,toolbarHeight: 90,),
        body: Container(
          color: Theme.of(context).backgroundColor,
          height : MediaQuery.of(context).size.height,
          width : double.infinity,
          child:
          Stack(

              children : [

                Container(


                  child: SingleChildScrollView(
                    reverse : false,

                    controller: widget.meetId!=null?_scrollController:null,

                    child: Container(
                      margin : EdgeInsets.only(bottom : 80),
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                padding: EdgeInsets.only(top:16,left:22,right:16,bottom:16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 0),
                                    Text('Immediate Local Assistance',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('Get help at your fingertip from locals',
                                        style: Theme.of(context).textTheme.subtitle2),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),

                              pageVisitor
                                  ? Container(
                                padding: EdgeInsets.only(left:16,right:16,),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: (){},
                                      child: Icon(Icons.location_on, color: Theme.of(context).primaryColor,size: 35,),
                                    ),
                                    Container(
                                      width: 250,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text('Location ',style: Theme.of(context).textTheme.subtitle1),
                                            ],
                                          ),
                                          Text(liveLocation,style: Theme.of(context).textTheme.subtitle2), // Display user location here
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                                  :SizedBox(height:0),


                              pageVisitor
                                  ? SizedBox(height: 10)
                                  : SizedBox(height: 0),

                              pageVisitor
                                  ? Container(
                                padding: EdgeInsets.only(left:16,right:16,),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap:(){

                                        getLocation();
                                        setState(() {
                                          rotateButton = true;
                                        });


                                      },
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap:(){},
                                            child: Transform.rotate(
                                              angle: rotateButton ? 3.14 : 0, // Rotate by 180 degrees if true, 0 degrees if false
                                              child: Icon(Icons.refresh, color: Colors.orange, size: 25),
                                            ),
                                          ),
                                          SizedBox(width : 5),
                                          Text('Refresh',style:TextStyle(fontSize:16,color :Colors.orange)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width : 20),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.share, color: Colors.orange,size: 25,),
                                          onPressed: () {},
                                        ),
                                        Text('Share Location',style:TextStyle(fontSize:16,color :Colors.orange)),
                                      ],
                                    )
                                  ],
                                ),
                              )
                                  : SizedBox(height: 0,),

                              pageVisitor
                                  ? SizedBox(height: 20)
                                  : SizedBox(height: 0),

                              (helpingHands=='' && pageVisitor && messages.length==0) || _userRefreshingPageOnFirstMessage || liveLocation  == 'fetching location'
                                  ? Container(
                                height : 300,
                                child: Center(
                                    child: Center(
                                      child: RotatingSvgWidget(imagePath: 'assets/images/tripassit.svg'),
                                    ),
                                ),
                              )
                                  : pageVisitor ?
                              Column(
                                children: [
                                  SizedBox(height : 10),
                                  Column(

                                    children: [
                                      widget.meetId==null
                                          ? Container(
                                        width : 286,
                                        height: 246,
                                        margin: EdgeInsets.only(left:16,right:16,),
                                        color : Theme.of(context).primaryColorLight,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(height : 10),
                                            Container(
                                                width: 236,
                                                child: Text('Hello ! How can Culturtap help you?',style: TextStyle(fontSize: 13,fontFamily: 'Poppins',fontWeight: FontWeight.w600),)),
                                            SizedBox(height : 10),
                                            Container(
                                              width: 236,
                                              child: Text.rich(
                                                TextSpan(
                                                  text: 'You can find here local assistance immediately, we have found ',
                                                  style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins', fontSize: 13),
                                                  children: [
                                                    TextSpan(
                                                      text: ' $helpingHands helping hands ',
                                                      style: TextStyle(fontWeight: FontWeight.bold, ),
                                                    ),
                                                    TextSpan(
                                                      text: ' near you. Please raise a request for help.',
                                                    ),
                                                  ],
                                                ),

                                              ),

                                            ),
                                            SizedBox(height : 10),

                                            Container(
                                              width: 236,
                                              child: Text('Type your request carefully before sending it to the local assistant .',
                                                style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 13,color: Colors.green),),
                                            ),
                                            SizedBox(height : 20),
                                          ],
                                        ),
                                      )
                                          :SizedBox(height: 0,),
                                      messages.length!=0
                                          ?SizedBox(height:0)
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
                                              width: 286,
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
                                  ),
                                ],
                              )
                                  :SizedBox(height:0),










                              ///----------------------------------------------------------------------------------------------------------






                              _userRefreshingPageOnFirstMessage ? Container():
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [


                                  messages.length > 0
                                      ? Column(

                                    children: messages.map((message) {
                                      return ListTile(
                                        title: message[1] == 'admin-helper-1'
                                            ? widget.state == 'user'
                                            ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [

                                              GestureDetector(
                                                onTap: () async {
                                                  String mapsUrl =
                                                      'https://www.google.com/maps/dir/?api=1&destination=$helperLatitude,$helperLongitude';
                                                  if (await canLaunch(
                                                      mapsUrl)) {
                                                    await launch(mapsUrl);
                                                  } else {
                                                    throw 'Could not launch $mapsUrl';
                                                  }
                                                },
                                                child: Container(

                                                  color: Theme.of(context).backgroundColor,
                                                  child: Row(
                                                    mainAxisAlignment : MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [

                                                      CircleAvatar(
                                                        backgroundColor : Colors.white,

                                                        radius: 15.0,
                                                        backgroundImage: Image.asset(
                                                          'assets/images/logo.png', // Replace with the actual path to your image in the 'assets' folder
                                                        ).image,

                                                      ),
                                                      SizedBox(width : 6),
                                                      Container(
                                                        width: 240,



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
                                                            topLeft: Radius.circular(-10.0),
                                                            topRight: Radius.circular(20.0),
                                                            bottomLeft: Radius.circular(20.0),
                                                            bottomRight: Radius.circular(20.0),
                                                          ),
                                                        ),
                                                        padding: EdgeInsets.only(left : 15, right : 10, top : 10, bottom :10),
                                                        child: Expanded(
                                                          child: Container(





                                                            child: Column(

                                                              children: [
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: [
                                                                    SvgPicture.asset('assets/images/success_logo.svg',width:18,height: 22,),
                                                                    SizedBox(width : 10),
                                                                    Text(
                                                                      'Payment Successful',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                          14,
                                                                          fontFamily:
                                                                          'Poppins',
                                                                          fontWeight: FontWeight.w600,
                                                                          color: Colors
                                                                              .green),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 21,
                                                                ),
                                                                Text(
                                                                  'We already share your location with your Savior.',
                                                                  style:Theme.of(context).textTheme.subtitle2,
                                                                ),
                                                                SizedBox(
                                                                  height: 21,
                                                                ),
                                                                Container(
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      SvgPicture.asset('assets/images/location_logo.svg',width:21,height: 24,),
                                                                      SizedBox(
                                                                        width: 10,
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                'Location',
                                                                                style: TextStyle(
                                                                                    fontSize:(12 * MediaQuery.of(context).textScaleFactor),
                                                                                    fontFamily: 'Poppins',
                                                                                    fontWeight:
                                                                                    FontWeight.w600,color:  Color(0xFF001B33)),
                                                                              ),
                                                                              SizedBox(width: 2,),
                                                                              Icon(Icons.keyboard_arrow_down,size: 14,color: Color(0xFF001B33),),
                                                                            ],
                                                                          ),
                                                                          Container(
                                                                              width : 100,

                                                                              child:
                                                                              Text(
                                                                                helperAddress,
                                                                                style:TextStyle(
                                                                                    fontSize:(12 * MediaQuery.of(context).textScaleFactor),
                                                                                    fontFamily: 'Poppins',
                                                                                    fontWeight:
                                                                                    FontWeight.w300,color:  Color(0xFF001B33)), )),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                height: 15,
                                              ),

                                              InkWell(
                                                onTap: () {
                                                  FlutterClipboard.copy(
                                                      helperNumber)
                                                      .then((value) {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                      'Copied to clipboard: $helperNumber',
                                                      toastLength:
                                                      Toast.LENGTH_SHORT,
                                                      gravity:
                                                      ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                      Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0,
                                                    );
                                                  });

                                                },
                                                child: Row(
                                                  mainAxisAlignment : MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,

                                                  children: [

                                                    CircleAvatar(
                                                      backgroundColor : Colors.white,

                                                      radius: 15.0,
                                                      backgroundImage: Image.asset(
                                                        'assets/images/logo.png', // Replace with the actual path to your image in the 'assets' folder
                                                      ).image,

                                                    ),
                                                    SizedBox(width: 6,),
                                                    Container(
                                                      width : 240,

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
                                                          topLeft: Radius.circular(-10.0),
                                                          topRight: Radius.circular(20.0),
                                                          bottomLeft: Radius.circular(20.0),
                                                          bottomRight: Radius.circular(20.0),
                                                        ),
                                                      ),
                                                      padding: EdgeInsets.only(left : 15, right : 0, top : 10, bottom :10),
                                                      child: Expanded(
                                                        child: Container(

                                                          // Adjust the padding as needed

                                                          padding: EdgeInsets.only(right: 4,left:4),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                'Call Your Saviour !',
                                                                style: Theme.of(context).textTheme.subtitle1,
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    helperName,
                                                                    style: Theme.of(context).textTheme.subtitle2,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        helperNumber,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            16,
                                                                            fontFamily:
                                                                            'Poppins',
                                                                            color: Colors
                                                                                .green),
                                                                      ),
                                                                      SizedBox(width : 6),
                                                                      Icon(
                                                                        Icons.copy, // Replace 'star' with the desired icon name
                                                                        color: Colors.green, // Set the color as needed
                                                                        size: 24, // Set the size as needed
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),

                                                              InkWell(
                                                                onTap : (){
                                                                  launch("tel:$helperNumber");
                                                                },
                                                                child: Text(
                                                                  'Make A Phone Call',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      16,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                      color: Colors
                                                                          .orange,
                                                                      fontFamily:
                                                                      'Poppins'),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),


                                            ],
                                          ),
                                        )
                                            : Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  FlutterClipboard.copy(
                                                      helperNumber)
                                                      .then((value) {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                      'Copied to clipboard: $helperNumber',
                                                      toastLength:
                                                      Toast.LENGTH_SHORT,
                                                      gravity:
                                                      ToastGravity.BOTTOM,
                                                      backgroundColor:
                                                      Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0,
                                                    );
                                                  });
                                                },
                                                child: Container(

                                                  color: Theme.of(context).backgroundColor,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [

                                                      CircleAvatar(
                                                        backgroundColor : Colors.white,

                                                        radius: 15.0,
                                                        backgroundImage: Image.asset(
                                                          'assets/images/logo.png', // Replace with the actual path to your image in the 'assets' folder
                                                        ).image,

                                                      ),
                                                      SizedBox(width : 10),
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
                                                            topLeft: Radius.circular(-10.0),
                                                            topRight: Radius.circular(20.0),
                                                            bottomLeft: Radius.circular(20.0),
                                                            bottomRight: Radius.circular(20.0),
                                                          ),
                                                        ),
                                                        padding: EdgeInsets.only(left : 15, right : 10, top : 10, bottom :10),
                                                        child: Container(
                                                          width: 200,
                                                          // Adjust the padding as needed
                                                          padding: EdgeInsets.only(left: 4),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                'Call Tourist Now',
                                                                style: Theme.of(context).textTheme.subtitle1,
                                                              ),
                                                              SizedBox(
                                                                height: 21,
                                                              ),
                                                              Text(
                                                                capitalizeWords('first, get connect with user and understand his issue , Plan accordingly to rescue or help them.'),
                                                                style: Theme.of(context).textTheme.subtitle2,
                                                              ),
                                                              SizedBox(
                                                                height: 21,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  Text(
                                                                    helperName,
                                                                    style:Theme.of(context).textTheme.subtitle2,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        helperNumber,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            16,
                                                                            fontFamily:
                                                                            'Poppins',
                                                                            color: Colors
                                                                                .green),
                                                                      ),
                                                                      SizedBox(width : 8),
                                                                      Icon(
                                                                        Icons.copy, // Replace 'star' with the desired icon name
                                                                        color: Colors.green, // Set the color as needed
                                                                        size: 24, // Set the size as needed
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 21,
                                                              ),

                                                              InkWell(
                                                                onTap : (){
                                                                  launch("tel:$helperNumber");
                                                                },
                                                                child: Text(
                                                                  'Make A Phone Call',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      16,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                      color: Colors
                                                                          .orange,
                                                                      fontFamily:
                                                                      'Poppins'),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              InkWell(
                                                //gafv
                                                onTap: () async {
                                                  // String mapsUrl =
                                                  //     'https://www.google.com/maps/dir/?api=1&destination=$helperLatitude,$helperLongitude';
                                                  // if (await canLaunch(
                                                  //     mapsUrl)) {
                                                  //   await launch(mapsUrl);
                                                  // } else {
                                                  //   throw 'Could not launch $mapsUrl';
                                                  // }
                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //     builder: (context) => MapNavigatorScreen(latitude:double.parse(helperLatitude),longitude:double.parse(helperLongitude)),
                                                  //   ),
                                                  // );
                                                },
                                                child: Row(
                                                  mainAxisAlignment : MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    CircleAvatar(
                                                      backgroundColor : Colors.white,

                                                      radius: 15.0,
                                                      backgroundImage: Image.asset(
                                                        'assets/images/logo.png', // Replace with the actual path to your image in the 'assets' folder
                                                      ).image,

                                                    ),
                                                    SizedBox(width:6),
                                                    Container(
                                                      width : 240,

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
                                                          topLeft: Radius.circular(-10.0),
                                                          topRight: Radius.circular(20.0),
                                                          bottomLeft: Radius.circular(20.0),
                                                          bottomRight: Radius.circular(20.0),
                                                        ),
                                                      ),
                                                      padding: EdgeInsets.only(left : 15, right : 0, top : 10, bottom :10),
                                                      child: Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.only(right: 4,left:4),
                                                          child: Column(
                                                            children: [
                                                              Row(

                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SizedBox(width: 8),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        'Tourist Location',
                                                                        style: Theme.of(context).textTheme.subtitle1,
                                                                      ),
                                                                      SizedBox(
                                                                        height: 11,
                                                                      ),
                                                                      Container(
                                                                        width : 200,
                                                                        child: Text(
                                                                          "Hurry up, it may be the concern of someone's life. ",
                                                                          style:Theme.of(context).textTheme.subtitle2,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 21,
                                                                      ),
                                                                      Row(
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                        children: [
                                                                          SvgPicture.asset('assets/images/location_logo.svg',width:21,height: 24,),
                                                                          SizedBox(
                                                                            width: 10,
                                                                          ),
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Location',
                                                                                    style: TextStyle(
                                                                                        fontSize:(12 * MediaQuery.of(context).textScaleFactor),
                                                                                        fontFamily: 'Poppins',
                                                                                        fontWeight:
                                                                                        FontWeight.w600,color:  Color(0xFF001B33)),
                                                                                  ),
                                                                                  SizedBox(width: 2,),
                                                                                  Icon(Icons.keyboard_arrow_down,size: 14,color: Color(0xFF001B33),),
                                                                                ],
                                                                              ),
                                                                              Container(
                                                                                  width: 150,
                                                                                  child:
                                                                                  Text(
                                                                                      helperAddress,
                                                                                      style:Theme.of(context).textTheme.bodyText2 )),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height: 21,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            'Go to The Map',
                                                                            style: TextStyle(
                                                                                fontSize:
                                                                                16,
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                                color: Colors
                                                                                    .orange,
                                                                                fontFamily:
                                                                                'Poppins'),
                                                                          ),
                                                                          Image.asset(
                                                                            'assets/images/arrow_fwd.png',
                                                                            width: 16,
                                                                            height: 16,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(
                                                height: 15,
                                              ),

                                              Container(
                                                width:360,
                                                color: Theme.of(context).backgroundColor,
                                                child:
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [

                                                    CircleAvatar(
                                                      backgroundColor : Colors.white,

                                                      radius: 15.0,
                                                      backgroundImage: Image.asset(
                                                        'assets/images/logo.png', // Replace with the actual path to your image in the 'assets' folder
                                                      ).image,

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
                                                          topLeft: Radius.circular(-10.0),
                                                          topRight: Radius.circular(20.0),
                                                          bottomLeft: Radius.circular(20.0),
                                                          bottomRight: Radius.circular(20.0),
                                                        ),
                                                      ),
                                                      padding: EdgeInsets.only(left : 15, right : 10, top : 10, bottom :10),
                                                      child: Container(

                                                        padding: EdgeInsets.only(left: 4,right: 4),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(height: 5,),


                                                                Text(
                                                                  'What you need to do ? ',
                                                                  style:Theme.of(context).textTheme.subtitle1,
                                                                ),
                                                                SizedBox(
                                                                  height: 11,
                                                                ),
                                                                Text(
                                                                  'You need to connect with the tourist and ask for the actual problem. You can connect with them through multiple channels as like message , call or video call, '
                                                                      '\n\nMotivate tell them for not to fear. Plan your rescue with the help of them'
                                                                      '\n\nArrange person whom you needed to rescue the tourist !As like, if tourist need to find a mechanic so arrange a relevant mechanic for them.'
                                                                      '\n\nat least be physically available for them and be their saviour. Saving other’s life is a work of God! ',
                                                                  style: Theme.of(context).textTheme.subtitle2,
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 30,
                                                            ),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  '*Terms & conditions\n',
                                                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w300,color:Colors.red),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  'You will recieve 400 Rs for your physical availability.'
                                                                      '\n\nCustomer will pay extra for further cost of goods or any other required service. '
                                                                  ,
                                                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,color:Colors.red, fontWeight: FontWeight.w300,),
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Text(
                                                                  'You can create payment link with attched bill for further goods or purchase.\n'

                                                                  ,
                                                                  style: Theme.of(context).textTheme.subtitle2,
                                                                ),

                                                                Container(
                                                                  height : 20,

                                                                  child: Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        'Just click on attachment   '

                                                                        ,
                                                                        style: Theme.of(context).textTheme.subtitle2,
                                                                      ),
                                                                      SvgPicture.asset('assets/images/attachment_icon.svg',color : Colors.grey[400],),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 30,
                                                                ),
                                                                Text(
                                                                  "Let's Connect !",
                                                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w300,color:Colors.green),
                                                                ),

                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                            : message[1] == 'admin-cancel'
                                            ? widget.state == 'user'
                                            ? Align(
                                          alignment:
                                          Alignment.centerRight,
                                          child: Container(
                                            width: screenWidth * 0.80,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(

                                            ),
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              '',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins'),
                                            ),
                                          ),
                                        )
                                            : Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            width: screenWidth * 0.80,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: HexColor('#E9EAEB')
                                                  .withOpacity(1),
                                            ),
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              'Meeting Is Cancelled By ${helperName}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins'),
                                            ),
                                          ),
                                        )
                                            : message[1] == 'user'
                                            ? widget.state == 'helper'
                                            ? Align(
                                          alignment:
                                          Alignment.centerLeft,
                                          child: Container(
                                            width: 360,
                                            color: Theme.of(context).backgroundColor,
                                            child: Row(
                                              mainAxisAlignment : MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.black,
                                                  radius: 15.0,
                                                  backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>, // Use a default asset image
                                                ),
                                                SizedBox(width: 6,),
                                                Container(
                                                  width:250,
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
                                                      topLeft: Radius.circular(-10.0),
                                                      topRight: Radius.circular(20.0),
                                                      bottomLeft: Radius.circular(20.0),
                                                      bottomRight: Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(left : 15, right : 10, top : 10, bottom :10),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 8,),
                                                      Container(
                                                        width: 200,
                                                        // Adjust the padding as needed
                                                        padding: EdgeInsets.only(left: 4),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              helperName,
                                                              style: Theme.of(context).textTheme.subtitle1,
                                                            ),
                                                            (message[0]).contains('.jpg') ||
                                                                (message[0]).contains(
                                                                    '.jpeg') ||
                                                                (message[0]).contains(
                                                                    '.png')
                                                                ? Image
                                                                .file(
                                                              File(message[
                                                              0]),
                                                              fit: BoxFit
                                                                  .cover,
                                                            )
                                                                : message[0]
                                                                .contains('.pdf')
                                                                ? GestureDetector(
                                                              onTap:
                                                                  () {
                                                                _openFileWithDefaultApp(message[0]);
                                                              },
                                                              child: Container(
                                                                  width: 200,
                                                                  height: 200,
                                                                  child: PDFView(
                                                                    filePath: message[0],
                                                                  )),
                                                            )
                                                                : Text(
                                                              message[0],
                                                              style:
                                                              Theme.of(context).textTheme.subtitle2,
                                                            ),
                                                          ],
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

                                            color: Theme.of(context).backgroundColor,
                                            child: Row(
                                              mainAxisAlignment : MainAxisAlignment.end,
                                              crossAxisAlignment : CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.orange,
                                                  radius: 15.0,
                                                  backgroundImage: FileImage(File(userPhoto)),
                                                ),
                                                SizedBox(width : 6),
                                                Container(
                                                  width: 240,
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
                                                      topLeft: Radius.circular(-10.0),
                                                      topRight: Radius.circular(20.0),
                                                      bottomLeft: Radius.circular(20.0),
                                                      bottomRight: Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(left : 15, top : 5, bottom :10),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Move the CircleAvatar outside of the Column

                                                      SizedBox(width: 3), // Add some space between CircleAvatar and message
                                                      Expanded(
                                                        child: Container(



                                                          // Adjust the padding as needed
                                                          padding: EdgeInsets.only(left: 4, right : 4),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'You',
                                                                style: Theme.of(context).textTheme.subtitle1,
                                                              ),
                                                              // The rest of your message content here
                                                              (message[0]).contains('.jpg') ||
                                                                  (message[0]).contains('.jpeg') ||
                                                                  (message[0]).contains('.png')
                                                                  ? Image.file(
                                                                File(message[0]),
                                                                fit: BoxFit.cover,
                                                              )
                                                                  : message[0].contains('.pdf')
                                                                  ? GestureDetector(
                                                                onTap: () {
                                                                  _openFileWithDefaultApp(message[0]);
                                                                },
                                                                child: Container(
                                                                  width: 200,
                                                                  height: 200,
                                                                  child: PDFView(
                                                                    filePath: message[0],
                                                                  ),
                                                                ),
                                                              )
                                                                  : Text(
                                                                message[0],
                                                                style: Theme.of(context).textTheme.subtitle2,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )

                                            : widget.state == 'user' &&
                                            message[1].contains(
                                                'admin') ==
                                                false
                                            ? Align(
                                          alignment:
                                          Alignment.centerLeft,
                                          child: Container(

                                            color: Theme.of(context).backgroundColor,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.black,
                                                  radius: 15.0,
                                                  backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>, // Use a default asset image
                                                ),
                                                SizedBox(width: 6,),
                                                Container(
                                                  width: 240,

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
                                                      topLeft: Radius.circular(-10.0),
                                                      topRight: Radius.circular(20.0),
                                                      bottomLeft: Radius.circular(20.0),
                                                      bottomRight: Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(left : 15, right : 10, top : 10, bottom :10),
                                                  child: Expanded(
                                                    child: Container(

                                                      padding: EdgeInsets.only(left: 4,right: 4),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            helperName,
                                                            style: Theme.of(context).textTheme.subtitle1,
                                                          ),
                                                          (message[0]).contains('.jpg') ||
                                                              (message[0]).contains(
                                                                  '.jpeg') ||
                                                              (message[0]).contains(
                                                                  '.png')
                                                              ? Image
                                                              .file(
                                                            File(message[
                                                            0]),
                                                            fit: BoxFit
                                                                .cover,
                                                          )
                                                              : message[0]
                                                              .contains('.pdf')
                                                              ? GestureDetector(
                                                            onTap:
                                                                () {
                                                              _openFileWithDefaultApp(message[0]);
                                                            },
                                                            child: Container(
                                                                width: 200,
                                                                height: 200,
                                                                child: PDFView(
                                                                  filePath: message[0],
                                                                )),
                                                          )
                                                              : Text(
                                                            message[0],
                                                            style: Theme.of(context).textTheme.subtitle2,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                            : message[1].contains(
                                            'admin') ==
                                            false
                                            ? Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .end,
                                          children: [
                                            Container(

                                              color: Theme.of(context).backgroundColor,

                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: Colors.black,
                                                    radius: 15.0,
                                                    backgroundImage:
                                                    AssetImage(
                                                        'assets/images/profile_iage.jpg'), // Use a default asset image
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
                                                        topRight: Radius.circular(20.0),
                                                        bottomLeft: Radius.circular(20.0),
                                                        bottomRight: Radius.circular(20.0),
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.only(left : 15, right : 10, top : 10, bottom :10),
                                                    child: Expanded(
                                                      child: Container(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [

                                                            Text(
                                                              'You',
                                                              style: Theme.of(context).textTheme.subtitle1,
                                                            ),


                                                            (message[0]).contains('.jpg') ||
                                                                (message[0]).contains(
                                                                    '.jpeg') ||
                                                                (message[0]).contains(
                                                                    '.png')
                                                                ? Image
                                                                .file(
                                                              File(message[0]),
                                                              fit:
                                                              BoxFit.cover,
                                                            )
                                                                : message[0].contains('.pdf')
                                                                ? GestureDetector(
                                                              onTap: () {
                                                                _openFileWithDefaultApp(message[0]);
                                                              },
                                                              child: Container(
                                                                  width: 200,
                                                                  height: 200,
                                                                  child: PDFView(
                                                                    filePath: message[0],
                                                                  )),
                                                            )
                                                                : Text(
                                                              message[0],
                                                              style: Theme.of(context).textTheme.subtitle2,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                            : widget.state == 'user'
                                            ? message[1] ==
                                            'admin-user-1'
                                            ? Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Container(

                                              color: Theme.of(context).backgroundColor,
                                              child:
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: Colors.black,

                                                    radius: 15.0,
                                                    backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>, // Use a default asset image
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
                                                        topRight: Radius.circular(20.0),
                                                        bottomLeft: Radius.circular(20.0),
                                                        bottomRight: Radius.circular(20.0),
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.only(left : 15, right : 10, top : 10, bottom :10),
                                                    child: Container(



                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          SizedBox(height: 5,),
                                                          Row(


                                                            children: [
                                                              Text(
                                                                'Saviour',
                                                                style: Theme.of(context).textTheme.subtitle1,
                                                              ),
                                                              SizedBox(width : 10),

                                                              Expanded(
                                                                child: Container(

                                                                  child: Text(
                                                                    'Allotment Successful',
                                                                    style: TextStyle(fontSize: 10, fontFamily: 'Poppins', color: Colors.green),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 15,),
                                                          Text(
                                                            message[0],
                                                            style: Theme.of(context).textTheme.subtitle2,
                                                          ),
                                                          SizedBox(height: 15,),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: 'This service will cost you ',
                                                                  style: TextStyle(
                                                                    fontFamily: 'Poppins',
                                                                    fontWeight: FontWeight.w300,
                                                                    fontSize: 14,
                                                                    color: Colors.black, // Set the color as needed
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: CountryName == 'India' ? 'Rs 500' : '\$10',
                                                                  style: TextStyle(
                                                                    fontFamily: 'Poppins',
                                                                    fontWeight: FontWeight.w300,
                                                                    fontSize: 14,
                                                                    color: Colors.green, // Set the color as needed
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: ' if you successfully get assistance!',
                                                                  style: TextStyle(
                                                                    fontFamily: 'Poppins',
                                                                    fontWeight: FontWeight.w300,
                                                                    fontSize: 14,
                                                                    color: Colors.black, // Set the color as needed
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          SizedBox(height: 10,),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                              15,
                                            ),
                                            Container(
                                              width:360,
                                              color: Theme.of(context).backgroundColor,
                                              child:
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [

                                                  CircleAvatar(
                                                    backgroundColor : Colors.white,

                                                    radius: 15.0,
                                                    backgroundImage: Image.asset(
                                                      'assets/images/logo.png', // Replace with the actual path to your image in the 'assets' folder
                                                    ).image,

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
                                                        topLeft: Radius.circular(-10.0),
                                                        topRight: Radius.circular(20.0),
                                                        bottomLeft: Radius.circular(20.0),
                                                        bottomRight: Radius.circular(20.0),
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.only(left : 15, right : 10, top : 10, bottom :10),
                                                    child: Container(

                                                      padding: EdgeInsets.only(left: 4,right: 4),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(height: 5,),


                                                              Text(
                                                                'What you will get ?',
                                                                style:Theme.of(context).textTheme.subtitle1,
                                                              ),
                                                              SizedBox(
                                                                height: 11,
                                                              ),
                                                              Text(
                                                                'You can connect with the saviour with multiple channel as like message , call even video call,and ask for the problem you facing, if needed than saviour will be available physically with the nature of help. ',
                                                                style: Theme.of(context).textTheme.subtitle2,
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 30,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                '*Terms & conditions',
                                                                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w300,color:Colors.red),
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                'This 500 Rs payment is for the saviour physical presence And Guidance only, other extra expenditure will cost you separately.\n\nYou can talk clearly with your savior ,may communication itself a solution of your problems.',
                                                                style: TextStyle(fontFamily: 'Poppins', fontSize: 13,color:Colors.red, fontWeight: FontWeight.w300,),
                                                              ),
                                                              SizedBox(
                                                                height: 30,
                                                              ),
                                                              Text(
                                                                "Let's Connect !",
                                                                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w300,color:Colors.green),
                                                              ),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                            : SizedBox(
                                          height: 0,
                                        )
                                            : message[1] ==
                                            'admin-user-1'
                                            ? Align(
                                          alignment: Alignment
                                              .centerRight,
                                          child: Container(
                                            width: 360,
                                            color: Theme.of(context).backgroundColor,
                                            child:
                                            Row(
                                              mainAxisAlignment : MainAxisAlignment.end,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.orange,
                                                  radius: 15.0,
                                                  backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>, // Use a default asset image
                                                ),
                                                SizedBox(
                                                  width:
                                                  10,
                                                ),
                                                Container(
                                                  width:250,
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
                                                      topLeft: Radius.circular(-10.0),
                                                      topRight: Radius.circular(20.0),
                                                      bottomLeft: Radius.circular(20.0),
                                                      bottomRight: Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(left : 15, right : 10, top : 10, bottom :10),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'You',
                                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        message[0],
                                                        style: Theme.of(context).textTheme.subtitle2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                            : SizedBox(
                                          height: 0,
                                        ),
                                      );
                                    }).toList(),
                                  )
                                      : SizedBox(
                                    height: 10,
                                  ),
                                  widget.userId==userID && meetStatus=='pending' && pageVisitor
                                      ? Container(

                                    padding : EdgeInsets.only(top : 20,left : 16),

                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                            meetStatus == 'hold_accept' ? 'Accepted' : 'Waiting for response',
                                            style : TextStyle(fontStyle: FontStyle.italic,fontSize : 14)),
                                        SizedBox(width : 9),
                                        LoadingDotAnimation(),
                                      ],
                                    ),
                                  )
                                      :SizedBox(height: 0,),






                                  ///-------------------------------------------------------------------------------------






                                  // Expanded(child: SizedBox(height: 10,)),
                                  if (incomingSDPOffer != null)
                                    Center(
                                      child: Container(
                                        width: screenWidth * 0.70,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30.0),
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Voice Call from $userName",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.call_end),
                                              color: Colors.redAccent,
                                              onPressed: () {
                                                setState(() => incomingSDPOffer = null);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.call),
                                              color: Colors.greenAccent,
                                              onPressed: () async {
                                                await _joinCall(
                                                  callerId: incomingSDPOffer["callerId"]!,
                                                  calleeId: widget.meetId!,
                                                  offer: incomingSDPOffer["sdpOffer"],
                                                  section: incomingSDPOffer["section"],
                                                  imageOwn: incomingSDPOffer["imageOther"],
                                                  imageOther: incomingSDPOffer["imageOwn"],
                                                );
                                                setState(() => incomingSDPOffer = null);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),


                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),






                ///----------------------------------------------------------------------------------------------------------------------------

                _userRefreshingPageOnFirstMessage || liveLocation=='fetching location' || (pageVisitor && helpingHands==''&& meetStatus == 'pending')  ? Container() :
                Positioned(
                  bottom : 0,
                  left : 0,
                  right : 0,
                  child: _isMeetStatusFound ? Container(
                    color : Theme.of(context).backgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [


                        if(meetStatus=='cancel' || meetStatus=='close')
                          Center(
                            child: Container(
                              height : 63,

                              padding:EdgeInsets.only(left:10,right:10),
                              decoration: BoxDecoration(
                                color : Colors.grey[200],
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Center(child:Text(meetStatus=='cancel'?'Cancelled':'Closed',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 18))),
                            ),
                          ),


                        if(widget.state=='user' && (meetStatus == 'accept' || meetStatus == 'hold_accept') )
                          Column(
                            children: [

                              GestureDetector(
                                onTap:()async{
                                  // Payment Gateway Open
                                  // payment success then true else false

                                  // bool res = await Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => RazorPayIntegration(),
                                  //   ),
                                  // );
                                  if(true){



                                    print(helperId);print('here we are ');
                                    print(widget.meetId!);
                                    await updateLocalUserPings(widget.userId, widget.meetId!, 'schedule');
                                    await updateLocalUserPings(helperId, widget.meetId!, 'schedule');
                                    await updateMeetingChats(widget.meetId!,[helperId,'admin-helper-1']);
                                    await updatePaymentStatus('pending',widget.meetId!);
                                    socket.emit('message', {'message':helperId,'user1':'admin-helper-1','user2':''});
                                    await getMeetStatus();
                                    // await updateLocalUserPings('65ad32bc43e1dc64172f3ef7', widget.meetId!, 'schedule');
                                    // sendCustomNotificationToUsers([helperId!], localAssistantHelperPay(userName,widget.meetId!));

                                    // sendCustomNotificationToUsers([helperId!], localAssistantHelperPay(userName,widget.meetId!));
                                    //

                                    sendCustomNotificationToOneUser(
                                      userToken,
                                      '',
                                      'payment Successful','Connect With Your Saviour Via Text, Voice Call, Video Call',
                                      '${widget.meetId}','trip_assistance_required',userID,'user',
                                    );


                                    sendCustomNotificationToOneUser(
                                      helperToken,
                                      'Payment Successful',
                                      'payment Successful','Connect With Tourist Via Text, Voice Call, Video Call',
                                      '${widget.meetId}','trip_assistance_required',userID,'user',
                                    );



                                    setState(() {});
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Payment UnSuccessful. Try Again!'),
                                      ),
                                    );
                                  }
                                },
                                child: Container(

                                  height: 63,

                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(

                                    color: Colors.orange,
                                  ),
                                  child: Center(child:Text('Continue To Pay',style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 18))),
                                ),
                              ),

                            ],
                          ) ,




                        if( widget.state=='helper' && meetStatus == 'accept' &&  meetStatus != 'scheduled' )
                          Center(
                            child: Container(
                              height : 63,



                              child:  Center(
                                child: Container(
                                  height : 63,



                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Waiting For Payment ',style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.orange,
                                            fontSize: 16)),
                                        SizedBox(width : 4),

                                        LoadingDotAnimation(),
                                      ],
                                    ),
                                  ),
                                ),
                              ) ,

                            ),
                          ) ,












                        ( (widget.state=='user' && meetStatus == 'hold_accept') ||  meetStatus == 'cancel' || meetStatus =='close' ||( widget.state=='user' && meetStatus=='accept' )|| (widget.state=='user' && meetStatus=='pending')
                            || (meetStatus=='accept' && widget.state=='user') || (meetStatus == 'pending' && widget.state=='user') || meetStatus == 'accept' && widget.state=='user'  ) ||  (meetStatus=='accept' && widget.state=='helper')
                            ? Container():
                        Container(
                          height: 75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 10,),
                              Flexible(
                                child: Container(



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
                                  padding: EdgeInsets.only(left: 25,right: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              scrollToBottom();
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(



                                              // Set your desired background color

                                            ),
                                            child: TextField(
                                              focusNode: _textFieldFocusNode,


                                              style : Theme.of(context).textTheme.subtitle2,
                                              cursorColor : Colors.orange,
                                              onChanged: (text) {
                                                setState(() {
                                                  scrollToBottom();
                                                });

                                                if (text.length > 0) {
                                                  setState(() {
                                                    messageTyping = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    messageTyping = false;
                                                  });
                                                }
                                              },
                                              maxLines: null,
                                              controller: _controller,
                                              decoration: InputDecoration(
                                                hintText: 'Start Typing Here...',
                                                hintStyle: Theme.of(context).textTheme.subtitle2,
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ), //chat box

                                      SizedBox(width: 25,),
                                      (meetStatus=='schedule' ||  sender.length<=1)?GestureDetector(
                                          onTap: ()async{
                                            String ?path = await showDialog(context: context, builder: (BuildContext context){
                                              return Container(child: UploadMethod());
                                            },);
                                            if(path!=null && path.length>0){
                                              if(widget.state=='helper'){
                                                updateMeetingChats(widget.meetId!,[path,'helper']);
                                                socket.emit('message', {'message':path,'user1':'','user2':'helper'});
                                              }
                                              else{
                                                updateMeetingChats(widget.meetId!,[path,'user']);
                                                socket.emit('message', {'message':path,'user1':'user','user2':''});
                                              }
                                              setState(() {});
                                            }
                                          },
                                          child: SvgPicture.asset('assets/images/attachment_icon.svg',color : Theme.of(context).primaryColor,)):SizedBox(width: 0,),
                                      SizedBox(width : 10),
                                      messageTyping==false?SizedBox(width: 10,):SizedBox(width: 5,),
                                      SizedBox(width : 10),
                                      // messageTyping==false?Image.asset('assets/images/send_icon.png'):SizedBox(width: 0,),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width: 5,),
                              widget.meetId!=null ?
                              messageTyping==false &&  (meetStatus=='schedule' ||  sender.length<=1)? Container(
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
                                    await _joinCall(
                                      callerId: widget.meetId!,
                                      calleeId: widget.meetId!,
                                      section: 'audio',
                                      imageOwn:userPhoto,
                                      imageOther:helperPhoto,
                                    );
                                  },
                                  // onPressed: !_isUiEnabled ? startCall : null,
                                  color : Theme.of(context).primaryColor,
                                ),
                              ):SizedBox(width: 0,) : Container(),


                              if (messageTyping==false  && (meetStatus=='schedule' ||  sender.length<=1))
                                SizedBox(width : 5),
                              if (messageTyping==false && (meetStatus=='schedule' ||  sender.length<=1))
                                Container(
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
                                      _joinCall(
                                        callerId: widget.meetId!,
                                        calleeId: widget.meetId!,
                                        section: 'video',
                                        imageOwn:userPhoto,
                                        imageOther:helperPhoto,
                                      );

                                    },
                                    color : Theme.of(context).primaryColor,
                                  ),
                                )
                              else if((meetStatus=='schedule' ||  sender.length<=1))
                                GestureDetector(
                                  onTap: ()async{
                                    if(receiver.length==0 && sender.length>1){
                                    }else{
                                      if(pageVisitor){
                                        if(widget.meetId==null){
                                          print('kya baat hia baya a');
                                          setState(() {
                                            _userRefreshingPageOnFirstMessage = true;
                                          });
                                          String meetingId = await createMeetRequest();

                                          List<Map<String,dynamic>> payloadData = localAssistantRequest(userName,meetingId,_controller.text);

                                          sendCustomNotificationToOneUser(
                                            userToken,
                                            'Request Sent',
                                            'Request Raised Successfully','Finding NearyBy Helping Hands For You 🔎',
                                            '$meetingId','trip_assistance_required',userID,'user',
                                          );

                                          sendCustomNotificationToUserss(
                                              userTokens,
                                              'Local Assistance Request By \n${userName}',
                                              '${_controller.text}','Local Assistance Request By \n${userName}',
                                              '$meetingId',widget.state!,userID
                                          );
                                          //
                                          // startTimer(() {
                                          //   getMeetStatus(); // Replace this with your function call
                                          // });

                                          _controller.clear();

                                          // startTimer(() {
                                          //
                                          //   checkMeetStatus(meetingId);
                                          //
                                          //   print("Function called!"); // Replace this with your function call
                                          // });
                                          // _refreshPage(meetingId,state:'user');
                                          setState(() {
                                            _userRefreshingPageOnFirstMessage = false;
                                          });
                                          // startConnectionCards();

                                        }else{
                                          print('kya baat hai');
                                          // sendCustomNotificationToUsers([helperId],localAssistantMessage(helperName,widget.meetId!,_controller.text,'helper'));
                                          //
                                          _handleSend();

                                        }
                                        setState(() {});
                                      }else{
                                        if(helperMessage){

                                          print('kese ho');

                                            setState(() {
                                              _userRefreshingPageOnFirstMessage = true;
                                            });



                                          print('kese ho');
                                          print(helperId);

                                          print('Controller : ${_controller.text},$helperId');
                                          await updateLocalHelperPings(widget.meetId!, 'accept');
                                          await createUpdateLocalUserPing(helperId ,widget.meetId!, 'accept',userName,userPhoto);
                                          await updatePaymentStatus('pending',widget.meetId!);
                                          // await updateLocalUserPings(widget.userId, widget.meetId!, 'pending');
                                          // await updateLocalUserPings(helperId, widget.meetId!, 'accept');
                                          await updateMeetingChats(widget.meetId!,[_controller.text,'admin-user-1']);

                                          socket.emit('message', {'message':_controller.text,'user1':'admin-user-1','user2':''});
                                          sendCustomNotificationToUsers([helperId!],localAssistantHelperAccepted(userName!, widget.meetId!));
                                          // setState(() {
                                          //   helperMessage=false;
                                          // });

                                          startConnectionCards();

                                          setState(() {
                                            _userRefreshingPageOnFirstMessage = false;
                                          });

                                        }else{
                                          // sendCustomNotificationToUsers([helperId],localAssistantMessage(helperName,widget.meetId!,_controller.text,'user'));
                                          print('kya baat hai yee');
                                          _handleSend();
                                          setState(() {});
                                        }
                                      }
                                      setState(() {
                                        messageTyping = false;
                                      });
                                    }
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(15),

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
                                      child: SvgPicture.asset('assets/images/send_msg.svg',color : Theme.of(context).primaryColor,)), //send message container
                                )
                              else SizedBox(width: 0,),
                              messageTyping==false?SizedBox(width: 10,):SizedBox(width: 10,),
                            ],
                          ),
                        ) ,


                      ],
                    ),
                  ): Container(),
                ),



                ////---------------------------------------------------------------------------------------------------------------------------------------------


              ]

          ),
        ),
      ),
    );
  }





  ///--------------------------------------------------------------------------------------------------------------------------------------------------------





  @override
  void dispose() {

    _textFieldFocusNode.dispose();
    setState(() {
      _isTyping = false;
    });

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

class MapNavigatorScreen {
}

class LoadingDotAnimation extends StatefulWidget {
  @override
  _LoadingDotAnimationState createState() => _LoadingDotAnimationState();
}

class _LoadingDotAnimationState extends State<LoadingDotAnimation> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();







    _controller1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _controller3 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    Future.delayed(Duration(milliseconds: 300), () {
      _controller2.repeat(reverse: true);
    });

    Future.delayed(Duration(milliseconds: 600), () {
      _controller3.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedDot(_controller1),
        SizedBox(width: 10),
        _buildAnimatedDot(_controller2),
        SizedBox(width: 10),
        _buildAnimatedDot(_controller3),
      ],
    );
  }

  Widget _buildAnimatedDot(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: ColorTween(begin: Colors.orange, end:Theme.of(context).primaryColorLight).animate(controller).value,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }
}