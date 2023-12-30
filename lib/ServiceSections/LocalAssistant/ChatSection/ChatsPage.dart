import 'dart:convert';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:photo_view/photo_view.dart';

import '../../../UserProfile/CoverPage.dart';
import '../../../UserProfile/ProfileHeader.dart';
import '../../../widgets/Constant.dart';
import '../../../widgets/CustomButton.dart';
import '../../../widgets/CustomDialogBox.dart';
import '../../../widgets/hexColor.dart';
import 'package:http/http.dart'as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';

import '../../TripCalling/Payments/UpiPayments.dart';
import '../../VideoCalling/CallingScreen.dart';
import '../../VideoCalling/SignallingService.dart';
import 'Uploader.dart';

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

  File? _userProfileImage;

  void handleImageUpdated(File image) {
    setState(() {
      _userProfileImage = image; // Update the parameter in the main class
    });
  }
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
  String userName = '',userPhoto = '',helperId='',helperAddress='',helperName='',helperPhoto='',helperLongitude='',helperNumber='',meetStatus='',helperLatitude='';
  bool helperMessage=false;
  final String serverUrl = Constant().serverUrl;  // Replace with your server's URL
  final TextEditingController _controller = TextEditingController();
  bool pageVisitor = true; // true means person coming to this page is user while in else condition its helper
  bool messageTyping = false;
  bool messagesStarted = false;
  List<List<String>> messages = [];
  List<String>sender=[],receiver=[];
  dynamic incomingSDPOffer;

  Future<String> createMeetRequest() async {
    final url = Uri.parse('$serverUrl/updateLocalAssistantMeetDetails');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId": widget.userId,
      "helperIds": userIds,
      "meetTitle": _controller.text,
      "paymentStatus":'initiated',
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
    DateTime now = DateTime.now();
    String formattedDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    Map<String, dynamic> requestData = {
      "userId": widget.userId,
      "time":setCurrentTime(),
      "date":formattedDate,
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
      "distances":distance,
      "helperIds":userIds,
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
        _controller.clear();
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
          if(widget.state=='helper' && responseData['paymentStatus']=='initiated'){
            print('Helper Message');
            helperMessage=true;
          }
          messages = conversationJson.map<List<String>>((list) {
            return (list as List<dynamic>).map<String>((e) => e.toString()).toList();
          }).toList();
          if(responseData['helperId']!=null){
            helperId = responseData['helperId'];
          }
        });
        print('Helpers Id :  $helperId');
        print('Helpers Name : $helperName');
        if(widget.state=='helper' && responseData['paymentStatus']=='initiated'){
          await updatePaymentStatus('pending',meetId);
        }

        if(helperId!='' && helperName==''){
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
        body:jsonEncode({"paymentStatus":paymentStatus}),
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
          meetStatus = data['meetStatus'];
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
      await fetchHelperDataset(data['message']);
      await getMeetStatus();
    }
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
    fetchDataset();
    if(widget.state!='user'){
      pageVisitor = false;
    }
    if(pageVisitor){
      userIds = ['6587944352bea38528b313d7','656050b3030772278b8b54cd'];
      distance = ['0.05','0.09'];
    }
    if(widget.meetId!=null) {
      startConnectionCards();
      SignallingService.instance.init(
        websocketUrl: serverUrl,
        selfCallerID: widget.meetId!,
      );
      SignallingService.instance.socket!.on("newCall", (data) {
        if (mounted) {
          print('comingdddd');
          // set SDP Offer of incoming call
          setState(() => incomingSDPOffer = data);
        }
      });
      // listen for incoming video call

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

  Future<void> startConnectionCards()async{
    await retriveMeetingConversation(widget.meetId!);
    await socketConnection();
    await getMeetStatus();
    if(widget.state=='user'){}
    else{
      if(meetStatus=='pending' && helperMessage){
        updateMeetingChats(widget.meetId!,[widget.userId,'admin-user-1']);
        // hey see this ther can be prblm as u are passing only userIf not helperId
        socket.emit('message', {'message':widget.userId,'user1':'admin-user-1','user2':''});
        setState(() {});
      }else{}
    }
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
        setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 2,userId: widget.userId,),automaticallyImplyLeading: false,),
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
                            if (incomingSDPOffer != null)
                              Column(
                                children: [
                                  Text(
                                    "Incoming Call from $userName",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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
                                        onPressed: () {
                                          _joinCall(
                                            callerId: incomingSDPOffer["callerId"]!,
                                            calleeId: widget.meetId!,
                                            offer: incomingSDPOffer["sdpOffer"],
                                            section: incomingSDPOffer["section"],
                                            imageOwn:incomingSDPOffer["imageOther"],
                                            imageOther:incomingSDPOffer["imageOwn"],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),

                    messages.length>0
                    ?Container(
                      child: Column(
                        crossAxisAlignment:CrossAxisAlignment.center,
                        children: messages.map((message) {
                          return ListTile(
                            title: message[1]=='admin-helper-1'
                                ?widget.state=='user'
                                  ? Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap:()async{
                                        String mapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$helperLatitude,$helperLongitude';
                                        if (await canLaunch(mapsUrl)) {
                                        await launch(mapsUrl);
                                        } else {
                                        throw 'Could not launch $mapsUrl';
                                        }
                                      },
                                      child: Container(
                                        width:screenWidth*0.80,
                                        decoration: BoxDecoration(
                                          color: HexColor('#E9EAEB').withOpacity(1),
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: CircleAvatar(
                                                radius: 20.0,
                                                backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>,// Use a default asset image
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  SizedBox(height: 10,),
                                                  Row(
                                                    children: [
                                                      Image.asset('assets/images/heart.png',width: 18,height: 22,),
                                                      Text('( Payment Successful )',style:TextStyle(fontSize: 13,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.green),),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Text(
                                                    'We already share your location with your Savior.',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:[
                                                      Image.asset('assets/images/heart.png',width: 20,height: 20,) ,
                                                      SizedBox(width: 10,),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('Location',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                                                          Container(width: screenWidth*0.50, child: Text(helperAddress,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),))
                                                        ],
                                                      ),
                                                    ],

                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    GestureDetector(
                                      onTap: (){
                                        FlutterClipboard.copy('jhkas').then((value) {
                                          Fluttertoast.showToast(
                                            msg: 'Copied to clipboard: $helperNumber',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        });
                                      },
                                      child: Container(
                                        width: screenWidth*0.80,
                                        decoration: BoxDecoration(
                                          color: HexColor('#E9EAEB').withOpacity(1),
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: CircleAvatar(
                                                radius: 20.0,
                                                backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>,// Use a default asset image
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Call Your Saviour',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                                                  SizedBox(height: 20,),
                                                  Column(
                                                    children: [
                                                      Text(helperName,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                                      Text(helperNumber,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,fontFamily: 'Poppins',color: Colors.green),)
                                                    ],
                                                  ),
                                                  SizedBox(height: 20,),
                                                  Row(
                                                    children: [
                                                      Image.asset('assets/images/heart.png',width: 20,height: 22,),
                                                      Text('Copy Contact',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.orange,fontFamily: 'Poppins'),)
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  :Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      FlutterClipboard.copy('vakfvba').then((value) {
                                        Fluttertoast.showToast(
                                          msg: 'Copied to clipboard: $helperNumber',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      });
                                    },
                                    child: Container(
                                      width: screenWidth*0.80,
                                      decoration: BoxDecoration(
                                        color: HexColor('#E9EAEB').withOpacity(1),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: CircleAvatar(
                                              radius: 20.0,
                                              backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>,// Use a default asset image
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Call Tourist Now',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                                                SizedBox(height: 10,),
                                                Text('first, get connect with user and understand his issue , Plan accordingly to rescue or help them.',
                                                  style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                                SizedBox(height: 20,),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(helperName,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                                    Text(helperNumber,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,fontFamily: 'Poppins',color: Colors.green),)
                                                  ],
                                                ),
                                                SizedBox(height: 20,),
                                                Row(
                                                  children: [
                                                    Image.asset('assets/images/heart.png',width: 20,height: 22,),
                                                    Text('Copy Contact',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.orange,fontFamily: 'Poppins'),)
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15,),
                                  GestureDetector(
                                    onTap:()async{
                                      String mapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$helperLatitude,$helperLongitude';
                                      if (await canLaunch(mapsUrl)) {
                                        await launch(mapsUrl);
                                      } else {
                                        throw 'Could not launch $mapsUrl';
                                      }
                                    },
                                    child: Container(
                                      width:screenWidth*0.80,
                                      decoration: BoxDecoration(
                                        color: HexColor('#E9EAEB').withOpacity(1),
                                      ),
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: CircleAvatar(
                                              radius: 20.0,
                                              backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>,// Use a default asset image
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                SizedBox(height: 10,),
                                                Text('Tourist Location',style:TextStyle(fontSize: 13,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.green),),
                                                SizedBox(height: 10,),
                                                Text(
                                                  "Hurry up, it may be the concern of someone's life. ",
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children:[
                                                    Image.asset('assets/images/heart.png',width: 20,height: 20,) ,
                                                    SizedBox(width: 10,),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('Location',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                                                        Container(width:screenWidth*0.50,child: Text(helperAddress,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),))
                                                      ],
                                                    ),
                                                  ],

                                                ),
                                                SizedBox(height: 20,),
                                                Row(
                                                  children: [
                                                    Text('Go to The Map',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.orange,fontFamily: 'Poppins'),),
                                                    Image.asset('assets/images/arrow_fwd.png',width: 16,height: 16,)
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : message[1]=='admin-cancel'
                                ?widget.state=='user'
                                ? Align(alignment: Alignment.centerRight,
                                  child: Container(
                                    width: screenWidth*0.80,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: HexColor('#E9EAEB').withOpacity(1),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Text('Meeting Is Cancelled By You',
                                      style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                  ),)
                                :Align(alignment: Alignment.centerLeft,
                              child: Container(
                                width: screenWidth*0.80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: HexColor('#E9EAEB').withOpacity(1),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text('Meeting Is Cancelled By ${helperName}',
                                  style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                              ),)
                                :message[1] == 'user'
                                ? widget.state == 'helper'
                                  ? Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: screenWidth*0.80,
                                  decoration: BoxDecoration(
                                    color: HexColor('#E9EAEB').withOpacity(1),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                            Text(helperName,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                                            (message[0]).contains('.jpg') || (message[0]).contains('.jpeg') || (message[0]).contains('.png')
                                              ?Image.file(
                                              File(message[0]),
                                              fit: BoxFit.cover,
                                              )
                                              :message[0].contains('.pdf')
                                                ?GestureDetector(
                                                  onTap: (){
                                                    _openFileWithDefaultApp(message[0]);
                                                  },
                                                  child: Container(
                                                  width: 200,
                                                  height: 200,
                                                  child: PDFView(filePath: message[0],)),
                                                )
                                                :Text(
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
                                width: screenWidth*0.80,
                                decoration: BoxDecoration(
                                  color: HexColor('#E9EAEB').withOpacity(1),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          Text('You',style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.bold,fontSize: 14),),
                                          (message[0]).contains('.jpg') || (message[0]).contains('.jpeg') || (message[0]).contains('.png')
                                              ?Image.file(
                                            File(message[0]),
                                            fit: BoxFit.cover,
                                          )
                                              :message[0].contains('.pdf')
                                              ?GestureDetector(
                                            onTap: (){
                                              _openFileWithDefaultApp(message[0]);
                                            },
                                            child: Container(
                                                width: 200,
                                                height: 200,
                                                child: PDFView(filePath: message[0],)),
                                          )
                                              :Text(
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
                                : widget.state == 'user' && message[1].contains('admin')==false
                                  ? Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: screenWidth*0.80,
                                  decoration: BoxDecoration(
                                    color: HexColor('#E9EAEB').withOpacity(1),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                            Text(helperName,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                                            (message[0]).contains('.jpg') || (message[0]).contains('.jpeg') || (message[0]).contains('.png')
                                                ?Image.file(
                                              File(message[0]),
                                              fit: BoxFit.cover,
                                            )
                                                :message[0].contains('.pdf')
                                                ?GestureDetector(
                                              onTap: (){
                                                _openFileWithDefaultApp(message[0]);
                                              },
                                              child: Container(
                                                  width: 200,
                                                  height: 200,
                                                  child: PDFView(filePath: message[0],)),
                                            )
                                                :Text(
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
                                  : message[1].contains('admin')==false
                                      ?Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: screenWidth*0.80,
                                decoration: BoxDecoration(
                                  color: HexColor('#E9EAEB').withOpacity(1),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          Text('You',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                                          (message[0]).contains('.jpg') || (message[0]).contains('.jpeg') || (message[0]).contains('.png')
                                              ?Image.file(
                                            File(message[0]),
                                            fit: BoxFit.cover,
                                          )
                                              :message[0].contains('.pdf')
                                              ?GestureDetector(
                                            onTap: (){
                                              _openFileWithDefaultApp(message[0]);
                                            },
                                            child: Container(
                                                width: 200,
                                                height: 200,
                                                child: PDFView(filePath: message[0],)),
                                          )
                                              :Text(
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
                                      :widget.state=='user'
                                        ?message[1]=='admin-user-1'
                                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:screenWidth*0.80,
                                    decoration: BoxDecoration(
                                      color: HexColor('#E9EAEB').withOpacity(1),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: CircleAvatar(
                                            radius: 20.0,
                                            backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>,// Use a default asset image
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Text(helperName,style: TextStyle(fontSize: 13,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
                                                  Text('( Allotment Successful )',style:TextStyle(fontSize: 12,fontStyle: FontStyle.italic,fontFamily: 'Poppins',color: Colors.green),),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Text(
                                                'Hey ${userName},I get your problem, let’s connect first on call. be calm down.',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Text('This service will cost you 500 Rs, you successfully get assistant !',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  color: Colors.green,
                                                ),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15,),
                                  Container(
                                    width: screenWidth*0.80,
                                    decoration: BoxDecoration(
                                      color: HexColor('#E9EAEB').withOpacity(1),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: CircleAvatar(
                                            radius: 20.0,
                                            backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>,// Use a default asset image
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('What you will get ?',style: TextStyle(fontFamily: 'Poppins',fontSize: 13,fontWeight: FontWeight.bold),),
                                                  SizedBox(height: 10,),
                                                  Text('You can connect with the person with multiple channel as like message , call even video call,and ask for the problem you facing, if needed than person will be available physically with the nature of help. ',
                                                    style: TextStyle(fontFamily: 'Poppins',fontSize: 13),)
                                                ],
                                              ),
                                              SizedBox(height: 20,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('*Terms & conditions',style: TextStyle(fontFamily: 'Poppins',fontSize: 13,fontWeight: FontWeight.bold),),
                                                  SizedBox(height: 10,),
                                                  Text('This 500 Rs payment is for the person allotment only, other extra expenditure will cost you separately.\n\nYou can talk clearly with your savior ,may communication itself a solution of your problems.',
                                                    style: TextStyle(fontFamily: 'Poppins',fontSize: 13),),
                                                  SizedBox(height: 20,),
                                                  Text("Let's Connect",style: TextStyle(fontFamily: 'Poppins',fontSize: 13,fontWeight: FontWeight.bold),),
                                                  SizedBox(height: 20,),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                                          : SizedBox(height: 0,)
                                        : message[1]=='admin-user-1'
                                      ?Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                    Container(
                      width:screenWidth*0.80,
                      decoration: BoxDecoration(
                        color: HexColor('#E9EAEB').withOpacity(1),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: CircleAvatar(
                              radius: 20.0,
                              backgroundImage: FileImage(File(helperPhoto)) as ImageProvider<Object>,// Use a default asset image
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('You',style: TextStyle(fontSize: 13,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
                                  ],
                                ),
                                Text(
                                  'Hey ${helperName},I get your problem, let’s connect first on call. be calm down.',
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
                    ],
                  ),
                )
                                      :SizedBox(height: 0,),
                          );
                        }).toList(),
                      ),
                    )
                    :SizedBox(height: 10,),

                    // Expanded(child: SizedBox(height: 10,)),

                    (widget.state=='user' && meetStatus=='accept')
                    ?Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: ()async{
                              bool userConfirmed = await showConfirmationDialog(context, userName!);
                              if (userConfirmed) {
                                // User confirmed, do something
                                print('User confirmed');
                                await updateLocalUserPings(widget.userId, widget.meetId!, 'cancel');
                                await updateLocalUserPings(helperId, widget.meetId!, 'cancel');
                                updateMeetingChats(widget.meetId!,['','admin-cancel']);
                                socket.emit('message', {'message':'','user1':'admin-cancel','user2':''});
                                setState(() {});
                              } else {
                                // User canceled, do something else
                                print('User canceled');
                              }
                            },
                            child: Container(
                              width: 325,
                              height: 63,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.orange)
                              ),
                              child: Center(child:Text('Cancel Request',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 18))),
                            ),
                          ),
                          SizedBox(height: 20,),
                          GestureDetector(
                            onTap:()async{
                              // Payment Gateway Open
                              // payment success then true else false

                              bool res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpiPayments(name:userName,merchant:helperName,amount:500,phoneNo:helperNumber),
                                ),
                              );
                              if(res){
                                await updateLocalUserPings(widget.userId, widget.meetId!, 'schedule');
                                await updateLocalUserPings(helperId, widget.meetId!, 'schedule');
                                updateMeetingChats(widget.meetId!,['','admin-helper-1']);
                                socket.emit('message', {'message':helperId,'user1':'admin-helper-1','user2':''});
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
                              width: 325,
                              height: 63,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                color: Colors.orange,
                              ),
                              child: Center(child:Text('Continue to pay',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18))),
                            ),
                          ),
                        ],
                      ),
                    )
                    :(meetStatus=='cancel' || meetStatus=='close')
                    ?Center(
                      child: Container(
                        width: 325,
                        height: 63,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange)
                        ),
                        child: Center(child:Text(meetStatus=='cancel'?'Cancelled':'Closed',style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 18))),
                      ),
                    )
                    :(widget.state=='helper' && meetStatus=='choose')
                    ? Center(
                      child: GestureDetector(
                      onTap: ()async{
                        bool userConfirmed = await showConfirmationDialog(context, userName!);
                        if (userConfirmed) {
                          // User confirmed, do something
                          print('User confirmed');
                          await updateLocalUserPings(widget.userId, widget.meetId!, 'cancel');
                          await updateLocalUserPings(helperId, widget.meetId!, 'cancel');
                          updateMeetingChats(widget.meetId!,['','admin-cancel']);
                          socket.emit('message', {'message':'','user1':'admin-cancel','user2':''});
                          setState(() {});
                        } else {
                          // User canceled, do something else
                          print('User canceled');
                        }
                      },
                      child: Container(
                        width: 325,
                        height: 63,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.orange,
                        ),
                        child: Center(child:Text('Accept & Reply',style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18))),
                      ),
                  ),
                    )
                    : Container(
                      height: 60,
                        child: Row(
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
                                      child: Image.asset('assets/images/attach_icon.png')):SizedBox(width: 0,),
                                  messageTyping==false?SizedBox(width: 10,):SizedBox(width: 5,),
                                  // messageTyping==false?Image.asset('assets/images/send_icon.png'):SizedBox(width: 0,),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          messageTyping==false && (meetStatus=='schedule' ||  sender.length<=1)? Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
                            child: IconButton(
                              icon: Icon(Icons.call),
                              onPressed:(){
                                _joinCall(
                                  callerId: widget.meetId!,
                                  calleeId: widget.meetId!,
                                  section: 'audio',
                                  imageOwn:userPhoto,
                                  imageOther:helperPhoto,
                                );
                              },
                              // onPressed: !_isUiEnabled ? startCall : null,
                            ),
                          ):SizedBox(width: 0,),
                          messageTyping==false? SizedBox(width: 0,):SizedBox(width: 5,),
                          if (messageTyping==false && (meetStatus=='schedule' ||  sender.length<=1)) Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
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
                            ),
                          ) else if((meetStatus=='schedule' ||  sender.length<=1)) GestureDetector(
                            onTap: ()async{
                              if(receiver.length==0 && sender.length>1){

                              }else{
                                if(pageVisitor){
                                  if(widget.meetId==null){
                                    String meetingId = await createMeetRequest();
                                    setState(() {});
                                  }else{
                                    _handleSend();
                                  }
                                }else{
                                  _handleSend();
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
