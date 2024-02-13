import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/Notifications/CustomNotificationMessages.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/Payments/RazorPay.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/Payments/UpiPayments.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:provider/provider.dart';

import '../../All_Notifications/customizeNotification.dart';
import '../../BackendStore/BackendStore.dart';
import '../../CustomItems/ImagePopUpWithTwoOption.dart';
import '../../LocalAssistance/LocalAssist.dart';
import '../../UserProfile/FinalUserProfile.dart';
import '../../UserProfile/ProfileHeader.dart';
// import '../../rating.dart';
import '../../fetchDataFromMongodb.dart';
import '../../widgets/CustomButton.dart';
import '../../widgets/CustomDialogBox.dart';
import '../../widgets/hexColor.dart';
import '../../LocalAssistance/ChatsPage.dart';
import '../RatingSection.dart';
import '../TripCalling/ChatSection/ChatSection.dart';
import 'package:upi_india/upi_india.dart';
// void main(){

//   runApp(Pings());
// }


class PingsDataStore{
  String userPhotoPath='';
  String userName='';

  Map<String,dynamic> meetData = {};
  List<dynamic> localHelpMeetData = [];
  PingsDataStore.fromJson(Map<String,dynamic> data){
    userPhotoPath = data['userPhoto']!=null?data['userPhoto']:'';
    userName = data['userName']!=null?data['userName']:'';
    meetData = data['userServiceTripCallingData']!=null?
    data['userServiceTripCallingData']['dayPlans']!=null?
    data['userServiceTripCallingData']['dayPlans']:{}:{};
    localHelpMeetData = data['userServiceTripAssistantData']!=null
        ? data['userServiceTripAssistantData']
        : [];
  }
}



class PingsSection extends StatefulWidget{
  String userId;
  String?text,userName,state,selectedService,fromWhichPage;
  PingsSection({required this.userId,this.selectedService,this.text,this.userName,this.state,this.fromWhichPage});
  @override
  _PingSectionState createState() => _PingSectionState();
}

class _PingSectionState extends State<PingsSection>{
  late PingsDataStore pingsDataStore;
  VoidCallback? callbacker;
  bool isLoading = true; // Add a boolean flag to indicate loading state
  bool dataLoading = false;
  @override
  void initState() {
    super.initState();
    print('Usss:${widget.userId}');
    fetchDatasets(widget.userId);
    _selectedService = widget.selectedService??'Trip Planning';
    // initialHandler();
  }





  void callback() async{
    print('I am !!');
    await fetchDatasets(userID);
  }


  // Future<void> initialHandler() async{
  //   WidgetsFlutterBinding.ensureInitialized();
  //   Stripe.publishableKey = Constant().publishableKey;
  //   Stripe.instance.applySettings();
  // }

  Future<void> fetchDatasets(userId) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userId}'); // Replace with your backend URL
    print('URL : $url');
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('DataSet :::  ${data}');
      setState(() {
        pingsDataStore = PingsDataStore.fromJson(data);
        isLoading = false;
      });
      print('1::${pingsDataStore.meetData}');
      print('1::${pingsDataStore.userName}');
      print('1::${pingsDataStore.userPhotoPath}');

    } else {
      // Handle error
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }
  Future<void> _refreshPage({int time = 2,String state = 'All Pings'}) async {
    // Add your data fetching logic here
    // For example, you can fetch new data from an API
    setState(() {
      isLoading=true;
    });
    await Future.delayed(Duration(seconds: time));
    await fetchDatasets(widget.userId);
    // Update the UI with new data if needed
    setState(() {
      isLoading = false;
      widget.state = state;
    });
  }


  Future<void> cancelMeeting(String date,String startTime,String status,String otherId,String otherStatus)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': widget.userId,
        'date':date,
        'startTime':startTime,
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
        callback();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to Update.Try Again!'),
          ),
        );
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }

  }

  String convertToDate(String dateStr) {
    final Map<String, String> months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };

    final List<String> parts = dateStr.split('/');
    final day = int.parse(parts[0]);
    final month = months[parts[1]]!;
    final year = parts[2];

    final formattedDate = DateTime(int.parse(year), int.parse(month), day);
    final dayName = formattedDate.weekday; // Get the day of the week (1 for Monday, 7 for Sunday)

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return days[dayName - 1]; // Adjust to index of days array (0 for Monday, 6 for Sunday)
  }

  String convertToDate2(String dateStr) {
    final Map<String, String> months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };

    final List<String> parts = dateStr.split('/');
    final day = int.parse(parts[0]);
    final month = parts[1];
    final year = parts[2];

    final formattedDate = DateTime(int.parse(year), int.parse(month), day);
    final dayName = formattedDate.weekday; // Get the day of the week (1 for Monday, 7 for Sunday)

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return days[dayName - 1]; // Adjust to index of days array (0 for Monday, 6 for Sunday)
  }

  String? _selectedValue;
  // String _selectedService='Trip Planning';
  String ?_selectedService;
  void _updateSelectedValue(String newValue) {
    setState(() {
      widget.state = newValue;
    });
  }
  void _updateSelectedService(String newValue) {
    setState(() {
      _selectedService = newValue;
    });
  }
  bool toggle = true;
  bool rotateButton = false;

  Future<void> paymentHandler(String name,String merchantName,double amount,String phone) async {
    try {
      // 1. Create a payment intent on the server
      final response = await http.post(Uri.parse('${Constant().serverUrl}/customerPayment'),
          body: {
            'phone':'6971833439',
            'amount': amount.toString(),
            'name':name
          });

      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            merchantDisplayName: merchantName,
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
          ));
      final res = await Stripe.instance.presentPaymentSheet();
      print('wlhfaui $res');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment is successful'),
        ),
      );
    } catch (errorr) {
      print(errorr);
      if (errorr is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured ${errorr.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured $errorr'),
          ),
        );
      }
    }
  }

  String generateRandomPhoneNumber() {
    // Generate 10 random digits for the phone number
    String randomDigits = '';
    for (int i = 0; i < 10; i++) {
      randomDigits += Random().nextInt(10).toString();
    }

    // Combine country code and random digits
    String phoneNumber =  randomDigits;

    return phoneNumber;
  }

  Future<bool> checkStatus(String date,String startTime,String receiver,String sender,String receiverName,String status) async{
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': sender,
        'date':date,
        'startTime':startTime,
      };
      print(data);
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/checkStatus'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        String currentStatus = responseData['status'];
        String userPosition = responseData['type'];
        if(userPosition=='sender'){
          if((currentStatus=='pending' && status=='cancel') || (currentStatus=='accept' && (status=='cancel'|| status=='schedule'))){
            return true;
          }
          else{
            Fluttertoast.showToast(
              msg:
              'Meeting Is Already Cancelled By ${userName}',
              toastLength:
              Toast.LENGTH_SHORT,
              gravity:
              ToastGravity.BOTTOM,
              backgroundColor:Theme.of(context).primaryColorDark,
              textColor: Colors.orange,
              fontSize: 16.0,
            );
            return false;
          }
        }
        else if(userPosition=='receiver'){
          if(currentStatus=='choose' && (status=='cancel'|| status=='pending')){
            return true;
          }
          else{
            Fluttertoast.showToast(
              msg:
              'Meeting Is Already Cancelled By ${userName}',
              toastLength:
              Toast.LENGTH_SHORT,
              gravity:
              ToastGravity.BOTTOM,
              backgroundColor:Theme.of(context).primaryColorDark,
              textColor: Colors.orange,
              fontSize: 16.0,
            );
            return false;
          }
        }else{
          Fluttertoast.showToast(
            msg:
            'Somethng Gone Wrong. Try Again After few moments',
            toastLength:
            Toast.LENGTH_SHORT,
            gravity:
            ToastGravity.BOTTOM,
            backgroundColor:Theme.of(context).primaryColorDark,
            textColor: Colors.orange,
            fontSize: 16.0,
          );
          return false;
        }
        // print('Current Staus is ${responseData['status']}');
        // if(responseData['status']!=status){
        //   bool res = await showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return ConfirmationDialog(
        //           message:'Are You Sure To Cancel Meet With ${receiverName} Scheduled At ${date}',
        //           onCancel: () {
        //             // Perform action on confirmation
        //             Navigator.pop(context,false); // Close the dialog
        //             // Add your action here
        //             print('Action cancelled');
        //           },
        //           onConfirm: () async{
        //             await cancelMeeting(date, index, 'cancel', receiver, 'cancel');
        //             // Perform action on cancellation
        //             // Add your action here
        //             Navigator.pop(context,true);
        //             print('Action confirmed');
        //           },
        //         );});
        //       return res;
        //
        // }else{
        //   if(status=='choose' && responseData['status']=='choose'){
        //     await cancelMeeting(date, index, 'pending', receiver, 'accept');
        //     return true;
        //   }
        //   else{
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(
        //         content: Text('Meeting Is Cancelled! Refresh Page'),
        //       ),
        //     );
        //     return false;
        //   }
        // }
        // print('$date,$index');
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to Update.Try Again!'),
          ),
        );
        print('Failed to save data: ${response.statusCode}');
        return false;
      }
    }catch(err){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to Update.Try Again!'),
        ),
      );
      print('Error:$err');
      return false;
    }
  }



  Future<void> removePingsHelper(String meetId) async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/removeHelperPings');
    // Replace with your data
    Map<String, dynamic> requestData = {
      'meetId':meetId,
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
        _refreshPage();
      } else {
        print("Failed to update pings. Status code: ${response.statusCode}");
        throw Exception("Failed to update pings");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
    }
  }


  Future<void> updateLocalHelperPings(String meetId,String meetStatus) async {
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
        _refreshPage();
      } else {
        print("Failed to update pings. Status code: ${response.statusCode}");
        throw Exception("Failed to update pings");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during API call");
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

  Future<void> createUpdateLocalUserPings(String userId,String meetId,String meetStatus,String userName,String userPhoto) async {
    final url = Uri.parse('${Constant().serverUrl}/setUpdateUserPings');
    Map<String, dynamic> requestData = {
      "userId": userId,
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
      } else {
        print("Failed to create/update meet. Status code: ${response.statusCode}");
        throw Exception("Failed to save meet");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error during creating/updating meet");
    }
  }

  Future<void> updatePaymentStatus(String paymentStatus,String meetId) async {
    try {
      final http.Response response = await http.patch(
        Uri.parse('${Constant().serverUrl}/updateLocalMeetingHelperIds/$meetId'),
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


  @override
  Widget build(BuildContext context) {
    _selectedValue = widget.state!=null?widget.state:'All Pings';
    final screenWidth = MediaQuery.of(context).size.width;
    // callback();
    return WillPopScope(
      onWillPop: () async {
        // If you want to prevent the user from going back, return false
        // return false;
        if(widget.text=='meetingPings'){
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => HomePage(userId: widget.userId!,userName: widget.userName,),
          //   ),
          // );
        }
        else if(widget.text=='edit'){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
        else if(widget.fromWhichPage=='trip_planning_schedule_profile'){
          Navigator.of(context).pop();
        }
        else if(widget.fromWhichPage=='local_assist'){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LocalAssist(),
            ),
          );
        }
        else{
          // If you want to navigate directly to the homepage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
        return false; // Returning true will allow the user to pop the page
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorLight,
        appBar: AppBar(title: ProfileHeader(reqPage: 1 ,text: widget.text,userName:widget.userName,fromWhichPage: widget.fromWhichPage,onButtonPressed: (){
          Navigator.of(context).pop();
        },),automaticallyImplyLeading: false,backgroundColor: Theme.of(context).backgroundColor, shadowColor: Colors.transparent, toolbarHeight: 90,),
        body: !isLoading
            ? RefreshIndicator(
              onRefresh: _refreshPage,
              child: Stack(
               children: [
                 dataLoading ==false
                     ? Container(
                   color : Theme.of(context).backgroundColor,
                   height : MediaQuery.of(context).size.height,

                   child: SingleChildScrollView(
                     child: Column(
                       children: [

                         SizedBox(height : 120),


                         toggle
                             ? Container(
                           padding: EdgeInsets.only(left:20,right:20),
                           // width: screenWidth*0.85,
                           // height: 50,
                           child: Row(

                             children: [





                             ],
                           ),
                         )
                             : SizedBox(height: 0,),
                         SizedBox(height: 10,),
                         toggle
                             ? _selectedService=='Trip Planning'
                             ? Column(
                           children: List.generate(pingsDataStore.meetData.length, (index)  {
                             final date = pingsDataStore.meetData.keys.elementAt(index);
                             final meetDetails = pingsDataStore.meetData[date];
                             print('2::${date}');
                             print('2::${meetDetails}');
                             return Column(
                               children:
                               List.generate(meetDetails['meetStartTime'].length, (index) {
                                 String startTime= meetDetails['meetStartTime'][index];
                                 String endTime= meetDetails['meetEndTime'][index];
                                 String meetId = meetDetails['meetingId'][index];
                                 String meetStatus = meetDetails['meetingStatus'][index];
                                 String meetTitle = meetDetails['meetingTitle'][index];
                                 String userId = meetDetails['userId'][index];
                                 String meetType = meetDetails['meetingType'][index];
                                 String userName = meetDetails['userName'][index];
                                 String userPhoto = meetDetails['userPhoto'][index];
                                 String plannerToken = meetDetails['userToken'][index];
                                 // String token =
                                 return Container(
                                   child:
                                   ((_selectedValue == 'Scheduled' && meetStatus =='schedule') ||
                                       (_selectedValue == 'Accepted' && meetStatus =='accept')||
                                       (_selectedValue == 'Pending' && meetStatus =='pending')||
                                       (_selectedValue == 'Closed' && (meetStatus =='close' || meetStatus =='closed'))||
                                       (_selectedValue == 'Cancelled' && meetStatus =='cancel')||
                                       _selectedValue =='All Pings' && meetStatus!='cancel' && meetStatus!='closed')
                                       ? InkWell(
                                         onTap: (){
                                           if((meetType=='sender' && (meetStatus=='schedule'  || meetStatus=='close' || meetStatus=='closed')) || (meetType=='receiver' &&( meetStatus=='schedule' || meetStatus=='close' || meetStatus=='closed'))){
                                             Navigator.push(
                                               context,
                                               MaterialPageRoute(
                                                 builder: (context) => ScheduledCalendar(date:date,userId:userID,meetStartTime: startTime,),
                                               ),
                                             );
                                           }
                                         },
                                         child: Stack(
                                           children: [
                                             Container(
                                     padding: EdgeInsets.all(18),
                                     margin: EdgeInsets.only(left:12,right:15,top:10,bottom:20),
                                     decoration: BoxDecoration(
                                             color: Theme.of(context).backgroundColor, // Container background color
                                             borderRadius: BorderRadius.circular(3),
                                             boxShadow: [
                                               BoxShadow(
                                                 color: Colors.grey.withOpacity(0.6),
                                                 spreadRadius: 0.4,
                                                 blurRadius: 0.6,
                                                 offset: Offset(0.5, 0.8),
                                               ),
                                             ],
                                     ),
                                     child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Container(
                                                 padding:EdgeInsets.only(top:10,bottom:20),
                                                 child: Text('Trip Planning',style:Theme.of(context).textTheme.subtitle1),
                                               ),
                                               Row(
                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                                                 crossAxisAlignment: CrossAxisAlignment.center,
                                                 children: [
                                                   Row(
                                                     children: [
                                                       meetType=='sender'
                                                           ? InkWell(
                                                             onTap:(){
                                                               Navigator.push(
                                                                 context,
                                                                 MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                                                                   create:(context) => ProfileDataProvider(),
                                                                   child: FinalProfile(userId: userID,clickedId: userID,fromWhichPage: 'pings',),
                                                                 ),),
                                                               );
                                                             },
                                                             child: CircleAvatar(
                                                         radius: 20.0,
                                                         backgroundImage: pingsDataStore.userPhotoPath != null && pingsDataStore.userPhotoPath != ''
                                                               ? FileImage(File(pingsDataStore.userPhotoPath)) as ImageProvider<Object>?
                                                               : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                                       ),
                                                           )
                                                           :InkWell(
                                                             onTap:(){
                                                               Navigator.push(
                                                                 context,
                                                                 MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                                                                   create:(context) => ProfileDataProvider(),
                                                                   child: FinalProfile(userId: userID,clickedId: userId,fromWhichPage: 'pings',),
                                                                 ),),
                                                               );
                                                             },
                                                             child: CircleAvatar(
                                                         radius: 20.0,
                                                         backgroundImage: userPhoto!= null && userPhoto!= ''
                                                               ? FileImage(File(userPhoto)) as ImageProvider<Object>?
                                                               : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                                       ),
                                                           ),
                                                       SizedBox(width: 6,),
                                                       SvgPicture.asset(
                                                         'assets/images/arrow_dir.svg', // Replace with the path to your SVG file
                                                         width: 25, // Specify the width
                                                         height: 25, // Specify the height
                                                         color: Colors.black, // Change the color if needed
                                                       ),
                                                       SizedBox(width: 6,),
                                                       meetType=='sender'
                                                           ? InkWell(
                                                             onTap:(){
                                                               Navigator.push(
                                                                 context,
                                                                 MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                                                                   create:(context) => ProfileDataProvider(),
                                                                   child: FinalProfile(userId: userID,clickedId: userId,fromWhichPage: 'pings',),
                                                                 ),),
                                                               );
                                                             },
                                                             child: CircleAvatar(
                                                         radius: 20.0,
                                                         backgroundImage: userPhoto!= null && userPhoto!= ''
                                                               ? FileImage(File(userPhoto)) as ImageProvider<Object>?
                                                               : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                                       ),
                                                           )
                                                           :InkWell(
                                                               onTap:(){
                                                                 Navigator.push(
                                                                   context,
                                                                   MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                                                                     create:(context) => ProfileDataProvider(),
                                                                     child: FinalProfile(userId: userID,clickedId: userID,fromWhichPage: 'pings', ),
                                                                   ),),
                                                                 );
                                                               },
                                                             child: CircleAvatar(
                                                         radius: 20.0,
                                                         backgroundImage: pingsDataStore.userPhotoPath != null && pingsDataStore.userPhotoPath != ''
                                                               ? FileImage(File(pingsDataStore.userPhotoPath)) as ImageProvider<Object>?
                                                               : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                                       ),
                                                           ),
                                                     ],
                                                   ),
                                                   SizedBox(width: 20,),
                                                   meetStatus=='pending' || meetStatus=='cancel'?
                                                   Container(
                                                     color: Colors.red, // Background color red
                                                     padding: EdgeInsets.only(left:9,right:9,bottom: 2,top:2),// Background color red
                                                     constraints: BoxConstraints(
                                                       minWidth: 0,
                                                       maxWidth: double.infinity, // Adjust width according to text
                                                     ),
                                                     child: Text(
                                                         (meetStatus=='pending'?'Pending':'Cancelled'),
                                                       style: TextStyle(color: Theme.of(context).backgroundColor,fontSize: 12,fontWeight: FontWeight.w300,fontFamily: 'Poppins'), // Text color white
                                                     ),
                                                   )
                                                       : meetStatus=='accept'
                                                       ? Container(
                                                     color: HexColor('FB8C00'), // Background color red
                                                     padding: EdgeInsets.only(left:9,right:9,bottom: 2,top:2),// Background color red
                                                     constraints: BoxConstraints(
                                                       minWidth: 0,
                                                       maxWidth: double.infinity, // Adjust width according to text
                                                     ),
                                                     child: Text(
                                                         'Accepted',
                                                       style: TextStyle(color: Theme.of(context).backgroundColor,fontSize: 12,fontWeight: FontWeight.w300,fontFamily: 'Poppins'), // Text color white
                                                     ),
                                                   )
                                                       : meetStatus=='schedule'
                                                       ? Container(
                                                     color: HexColor('0A8100'), // Background color red
                                                     height: 16  , // Height set to 16
                                                     constraints: BoxConstraints(
                                                       minWidth: 0,
                                                       maxWidth: double.infinity, // Adjust width according to text
                                                     ),
                                                     child: Text('   '+
                                                         'Scheduled'+'   ',
                                                       style: TextStyle(color: Theme.of(context).backgroundColor,fontSize: 10), // Text color white
                                                     ),
                                                   )
                                                       :meetStatus=='choose'
                                                       ?SizedBox(height: 0,)
                                                       : Container(
                                                     color: Colors.orange,
                                                     padding: EdgeInsets.only(left:5,right:5,bottom: 2,top:2),// Background color red
                                                     // Height set to 16
                                                     constraints: BoxConstraints(
                                                       minWidth: 0,
                                                       maxWidth: double.infinity, // Adjust width according to text
                                                     ),
                                                     child: Text('Closed',
                                                       style: TextStyle(color: Theme.of(context).primaryColorLight,fontSize: 12,fontFamily: 'Poppins',fontWeight: FontWeight.w300), // Text color white
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                               SizedBox(height: 18,),
                                               meetType=='sender'
                                                   ?Container(
                                                     child: Row(
                                                       mainAxisAlignment: MainAxisAlignment.start,
                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                       children: [
                                                         Text('Trip planning Call with ',style: Theme.of(context).textTheme.subtitle2,),
                                                         Container(
                                                             // width: 150,
                                                             child: Text('${Constant().extractFirstName(userName)}',style: Theme.of(context).textTheme.subtitle2,))
                                                       ],
                                                     ),
                                                   )
                                                   :Container(
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: [
                                                     Text('Trip Planning Call by',style: Theme.of(context).textTheme.subtitle2,),
                                                     Container(
                                                         // width: 150,
                                                         child: Text('${Constant().extractFirstName(userName)}',style: Theme.of(context).textTheme.subtitle2,))
                                                   ],
                                                 ),
                                               ),
                                               SizedBox(height: 7,),
                                               Container(
                                                 height: 20,
                                                 child: Row(
                                                   // mainAxisAlignment: MainAxisAlignment.start,
                                                   children: [
                                                     Container(
                                                       child: Image.asset('assets/images/time_icon.png',width: 22,height: 20,),
                                                     ),
                                                     Text(' ${startTime} - ${endTime} \t',style: Theme.of(context).textTheme.subtitle2),
                                                     Text('India',style: Theme.of(context).textTheme.subtitle2,)
                                                   ],
                                                 ),
                                               ),
                                               SizedBox(height: 7,),
                                               Container(
                                                 // decoration: BoxDecoration(border:Border.all(width: 1)),
                                                 child: Row(
                                                   children: [
                                                     Container(
                                                       child: Image.asset('assets/images/calendar.png',width: 22,height: 22,),
                                                     ),
                                                     Text(' Date ${date} "${convertToDate(date)}"',style: Theme.of(context).textTheme.subtitle2),
                                                   ],
                                                 ),
                                               ),
                                               SizedBox(height: 7,),
                                               Container(
                                                 // decoration: BoxDecoration(border:Border.all(width: 1)),
                                                 padding:EdgeInsets.only(left:3),
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   children: [
                                                     Container(
                                                       width:260,
                                                       child: Text(meetTitle==''?'Please Enter Tile Next Time':meetTitle,style: Theme.of(context).textTheme.subtitle2,),
                                                     ),
                                                     // InkWell(
                                                     //   onTap:(){
                                                     //     setState(() {
                                                     //
                                                     //   });},
                                                     //   child: Container(
                                                     //     child: Image.asset('assets/images/arrow_down.png',width: 35,height: 35,),
                                                     //   ),
                                                     // ),
                                                   ],
                                                 ),
                                               ),
                                               (meetStatus=='pending' && meetType=='sender')
                                                   ?InkWell(
                                                   onTap: ()  async{
                                                     bool res = await checkStatus(date,startTime,userId,widget.userId,userName,'cancel',);
                                                     if(res){
                                                       bool finalRes = await showDialog(
                                                           context: context,
                                                           builder: (BuildContext context) {
                                                             return ConfirmationDialog(
                                                               message:'Are You Sure To Cancel Meet With ${userName} Scheduled At ${date}',
                                                               onCancel: () {
                                                                 // Perform action on confirmation
                                                                 Navigator.pop(context,false);
                                                                 // Add your action here
                                                                 print('Action cancelled');
                                                               },
                                                               onConfirm: () async{
                                                                 Navigator.pop(context,true);
                                                                 print('Action confirmed');
                                                               },
                                                             );});
                                                       if(finalRes){
                                                         setState(() {
                                                           dataLoading=true;
                                                         });
                                                         await cancelMeeting(date, startTime, 'cancel', userId, 'cancel');
                                                         setState(() {
                                                           dataLoading = false;
                                                           widget.state='Cancelled';
                                                         });
                                                         Fluttertoast.showToast(
                                                           msg:
                                                           'Updated Meeting Status Successfully!!',
                                                           toastLength:
                                                           Toast.LENGTH_SHORT,
                                                           gravity:
                                                           ToastGravity.BOTTOM,
                                                           backgroundColor:
                                                           Theme.of(context).primaryColorDark,
                                                           textColor: Colors.orange,
                                                           fontSize: 16.0,
                                                         );
                                                         sendCustomNotificationToOneUser(
                                                             plannerToken,
                                                             'Messages From ${userName}',
                                                             'Messages From ${userName}','Meeting request for ${date} is cancelled ',
                                                             'Cancelled','trip_planning_cancel',userId,'helper'
                                                         );
                                                         // _refreshPage(time: 0,state: 'Cancelled');
                                                       }
                                                     }
                                                     else{
                                                       setState(() {
                                                         widget.state='Cancelled';
                                                       });
                                                     }
                                                     print('$date,$index');
                                                   },
                                                   child: Container(
                                                     padding: EdgeInsets.only(top:10,bottom:10),
                                                     child: Center(child: Text('Cancel',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),)),))
                                                   :(meetStatus=='pending' && meetType=='receiver')
                                                   ?Container(
                                                     padding: EdgeInsets.only(top:10,bottom:10),
                                                     child: Text('*User need to unlock calendar before complete call scheduled.Please wait for event. ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,fontFamily: 'Poppins',color: HexColor('#FF0000')),),)
                                                   :(meetStatus=='choose')
                                                   ? Container(
                                                 // color: Colors.red,
                                                 // decoration: BoxDecoration(border:Border.all(width:1)),
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                   children: [
                                                     InkWell(
                                                         onTap: ()async{

                                                           bool res = await checkStatus(date,startTime,userId,widget.userId,userName,'cancel',);
                                                           if(res){
                                                             bool finalRes = await showDialog(
                                                                 context: context,
                                                                 builder: (BuildContext context) {
                                                                   return ConfirmationDialog(
                                                                     message:'Are You Sure To Cancel Meet With ${userName} Scheduled At ${date}',
                                                                     onCancel: () {
                                                                       // Perform action on confirmation
                                                                       Navigator.pop(context,false);
                                                                       // Add your action here
                                                                       print('Action cancelled');
                                                                     },
                                                                     onConfirm: () async{
                                                                       Navigator.pop(context,true);
                                                                       print('Action confirmed');
                                                                     },
                                                                   );});
                                                             if(finalRes){
                                                               setState(() {
                                                                 dataLoading=true;
                                                               });
                                                               await cancelMeeting(date, startTime, 'cancel', userId, 'cancel');
                                                               setState(() {
                                                                 dataLoading = false;
                                                                 widget.state='Cancelled';
                                                               });
                                                               Fluttertoast.showToast(
                                                                 msg:
                                                                 'Updated Meeting Status Successfully!!',
                                                                 toastLength:
                                                                 Toast.LENGTH_SHORT,
                                                                 gravity:
                                                                 ToastGravity.BOTTOM,
                                                                 backgroundColor:
                                                                 Theme.of(context).primaryColorDark,
                                                                 textColor: Colors.orange,
                                                                 fontSize: 16.0,
                                                               );
                                                               sendCustomNotificationToOneUser(
                                                                   plannerToken,
                                                                   'Messages From ${userName}',
                                                                   'Messages From ${userName} <br/> Your trip planning request for ${date} is cancelled by ${userName}','Your trip planning request for ${date} is cancelled by ${userName}',
                                                                   'Cancelled','trip_planning_cancel',userId,'user'
                                                               );
                                                               // _refreshPage(time: 0,state: 'Cancelled');
                                                             }
                                                           }
                                                           else{
                                                             setState(() {
                                                               widget.state='Cancelled';
                                                             });
                                                           }
                                                         },
                                                         child: Container(padding: EdgeInsets.only(top: 10,bottom: 10), child: Text('Decline',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.red.withOpacity(0.6)),),)),
                                                     InkWell(
                                                         onTap: ()async{
                                                           bool res = await checkStatus(date,startTime,userId,widget.userId,userName,'cancel',);
                                                           if(res){
                                                             setState(() {
                                                               dataLoading=true;
                                                             });
                                                             await cancelMeeting(date, startTime, 'pending', userId, 'accept');
                                                             setState(() {
                                                               dataLoading = false;
                                                               widget.state='Pending';
                                                             });
                                                             Fluttertoast.showToast(
                                                               msg:
                                                               'Updated Meeting Status Successfully!!',
                                                               toastLength:
                                                               Toast.LENGTH_SHORT,
                                                               gravity:
                                                               ToastGravity.BOTTOM,
                                                               backgroundColor:
                                                               Theme.of(context).primaryColorDark,
                                                               textColor: Colors.orange,
                                                               fontSize: 16.0,
                                                             );
                                                             sendCustomNotificationToOneUser(
                                                                 userToken,
                                                                 'Request Sent!',
                                                                 'Payment Request Sent Successfully!','Payment Request Sent Successfully!',
                                                                 'Pending','trip_planning_accept',userID,'helper'
                                                             );
                                                             sendCustomNotificationToOneUser(
                                                                 plannerToken,
                                                                 'Messages From ${userName}',
                                                                 'Messages From ${userName} <br/> Trip Planning Request Accepted <br/> Meeting Details : ${date},${startTime}-${endTime} <br/> <b>Please Complete Payment</b>','Trip Planning Request Accepted <br/> Meeting Details : ${date},${startTime}-${endTime} <br/> <b>Please Complete Payment</b>',
                                                                 'Accepted','trip_planning_accept',userId,'user'
                                                             );
                                                           }
                                                         },
                                                         child: Container(padding: EdgeInsets.only(top: 10,bottom: 10), child: Text('Accept',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.orange),),)),
                                                   ],
                                                 ),
                                               )
                                                   :(meetStatus=='accept')//accept
                                                   ?Row(
                                                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                     children: [
                                                       InkWell(
                                                           onTap: ()async{
                                                             bool res = await checkStatus(date,startTime,userId,widget.userId,userName,'cancel',);
                                                             if(res){
                                                               bool finalRes = await showDialog(
                                                                   context: context,
                                                                   builder: (BuildContext context) {
                                                                     return ConfirmationDialog(
                                                                       message:'Are You Sure To Cancel Meet With ${userName} Scheduled At ${date}',
                                                                       onCancel: () {
                                                                         // Perform action on confirmation
                                                                         Navigator.pop(context,false);
                                                                         // Add your action here
                                                                         print('Action cancelled');
                                                                       },
                                                                       onConfirm: () async{
                                                                         Navigator.pop(context,true);
                                                                         print('Action confirmed');
                                                                       },
                                                                     );});
                                                               if(finalRes){
                                                                 setState(() {
                                                                   dataLoading=true;
                                                                 });
                                                                 await cancelMeeting(date, startTime, 'cancel', userId, 'cancel');
                                                                 setState(() {
                                                                   dataLoading = false;
                                                                   widget.state='Cancelled';
                                                                 });
                                                                 Fluttertoast.showToast(
                                                                   msg:
                                                                   'Updated Meeting Status Successfully!!',
                                                                   toastLength:
                                                                   Toast.LENGTH_SHORT,
                                                                   gravity:
                                                                   ToastGravity.BOTTOM,
                                                                   backgroundColor:
                                                                   Theme.of(context).primaryColorDark,
                                                                   textColor: Colors.orange,
                                                                   fontSize: 16.0,
                                                                 );
                                                                 sendCustomNotificationToOneUser(
                                                                     plannerToken,
                                                                     'Messages From ${userName}',
                                                                     'Messages From ${userName}<br/> Meeting request for ${date} is cancelled','Meeting request for ${date} is cancelled ',
                                                                     'Cancelled','trip_planning_cancel',userId,'helper'
                                                                 );
                                                                 // _refreshPage(time: 0,state: 'Cancelled');
                                                               }
                                                             }
                                                             else{
                                                               setState(() {
                                                                 widget.state='Cancelled';
                                                               });
                                                             }
                                                           },
                                                           child: Container(padding:EdgeInsets.only(top:10,bottom:10), child: Text('Cancel',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),),)),
                                                       InkWell(
                                                           onTap: ()async{
                                                             // bool res = await Navigator.push(
                                                             //   context,
                                                             //   MaterialPageRoute(
                                                             //     builder: (context) => UpiPayments(name:pingsDataStore.userName,merchant:userName,amount:100000.0,phoneNo:generateRandomPhoneNumber()),
                                                             //   ),
                                                             // );
                                                             if(true){
                                                               // await paymentHandler(pingsDataStore.userName,userName,100000.0,generateRandomPhoneNumber());
                                                               setState(() {
                                                                 dataLoading = true;
                                                               });
                                                               await cancelMeeting(date,startTime,'schedule',userId,'schedule');
                                                               setState(() {
                                                                 dataLoading = false;
                                                                 widget.state = 'Scheduled';
                                                               });
                                                               sendCustomNotificationToOneUser(
                                                                   userToken,
                                                                   'Payment Successful',
                                                                   'Payment Successful \n Trip Planning Request Scheduled \n Meeting is On ${date} , ${startTime} - ${endTime}','Trip Planning Request Scheduled <br/> Meeting is On <a href="https://google.com">${date}</a> , ${startTime} - ${endTime} ',
                                                                   'Scheduled','trip_planning_schedule',userID,'user'
                                                               );
                                                               sendCustomNotificationToOneUser(
                                                                   plannerToken,
                                                                   'Message From ${userName}',
                                                                   'Message From ${userName} <br/> Trip Planning Request Scheduled <br/> Meeting Details : ${date},${startTime}-${endTime} <br/> <b>Be On Time .</b> <br/> Notifications will be sent before meeting','Trip Planning Request Scheduled <br/> Meeting Details : ${date},${startTime}-${endTime} <br/> <b>Be On Time .</b> <br/> Notifications will be sent before meeting',
                                                                   'Scheduled','trip_planning_schedule',userId,'helper'
                                                               );
                                                               print('$date,$index');
                                                             }else{
                                                               ScaffoldMessenger.of(context).showSnackBar(
                                                                 const SnackBar(
                                                                   content: Text('Try Again!'),
                                                                 ),
                                                               );
                                                             }
                                                           },
                                                           child: Container(padding: EdgeInsets.only(top: 10,bottom:10),child: Text('Unlock Calendar',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#0A8100')),),)),
                                                     ],
                                                   )
                                                   :(meetStatus=='schedule')
                                                   ?InkWell(
                                                 onTap: (){
                                                    DateTime time= setDateTime(date, startTime);
                                                    print('Time is ${time}');
                                                    if(time != null && time!.isBefore(DateTime.now())){
                                                      meetType=='sender'
                                                          ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => ChatApps(senderId:userID,receiverId:'',date:date,startTime:startTime),
                                                        ),
                                                      )
                                                          :Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => ChatApps(senderId:'',receiverId:userID,date:date,startTime:startTime),
                                                        ),
                                                      );
                                                    }else{
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => ScheduledCalendar(date:date,userId:userID,meetStartTime:startTime),
                                                        ),
                                                      );
                                                    }
                                                 },
                                                 child: Container(
                                                   padding: EdgeInsets.only(top:10,bottom: 10),
                                                   child: Center(child: Text('Go To Calendar',style: TextStyle(fontSize: 18,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                                 ),
                                               )
                                                   :(meetStatus=='close' && meetType=='receiver')
                                                   ?InkWell(
                                                 onTap: (){
                                                   Navigator.push(
                                                     context,
                                                     MaterialPageRoute(
                                                       builder: (context) => RateFeedBack(pingsCallback:callback,userId:widget.userId,index:index,userPhoto:pingsDataStore.userPhotoPath,userName:userName,startTime:startTime,endTime:endTime,date:date,meetTitle:meetTitle,meetType:meetType,meetId:meetId),
                                                     ),
                                                   );
                                                 },
                                                 child: Container(
                                                   padding: EdgeInsets.only(top:10,bottom: 10),
                                                   child: Center(child: Text('Rate & Feedback',style: TextStyle(fontSize: 18,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                                 ),
                                               )
                                                   :(meetStatus=='close')
                                                   ? InkWell(
                                                 onTap: (){
                                                   Navigator.push(
                                                     context,
                                                     MaterialPageRoute(
                                                       builder: (context) => RateFeedBack(pingsCallback:callback,index:index,userPhoto: pingsDataStore.userPhotoPath,userName:userName,startTime:startTime,endTime:endTime,date:date,meetTitle:meetTitle,meetType:meetType,meetId:meetId,userId:widget.userId),
                                                     ),
                                                   );
                                                 },
                                                 child: Container(
                                                   padding: EdgeInsets.only(top:10,bottom: 10),
                                                   child: Center(child: Text('Give Us A Feedback',style: TextStyle(fontSize: 18,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                                 ),
                                               )
                                                   :SizedBox(height:0),
                                             ],
                                     ),
                                   ),
                                             (meetType=='sender' && (meetStatus=='schedule')) || (meetType=='receiver' && (meetStatus=='pending' || meetStatus=='schedule'))
                                                 ? Positioned(
                                               bottom:30,
                                               right:30,
                                               child:InkWell(
                                                   onTap: ()async{
                                                     setState(() {
                                                       rotateButton = !rotateButton;
                                                     });
                                                     await fetchDatasets(widget.userId);
                                                    widget.state='All Pings';
                                                   },
                                                   child: Container(
                                                       padding: EdgeInsets.all(10),
                                                       decoration: BoxDecoration(
                                                         borderRadius: BorderRadius.circular(50),
                                                         color:Theme.of(context).primaryColorLight.withOpacity(0.8),
                                                       ),
                                                       child: Transform.rotate(
                                                           angle: rotateButton ? 3.14 : 0,
                                                           child: Icon(Icons.refresh,color: (meetType=='receiver' && meetStatus=='pending') ? Colors.red:Theme.of(context).primaryColorDark,size: 20,)))
                                               ),
                                             )
                                                 : SizedBox(width:0),
                                           ],
                                         ),
                                       ):SizedBox(height:0),
                                 );
                               }),
                             );
                           }),
                         )
                             : Column(
                           children:
                           List.generate(pingsDataStore.localHelpMeetData.length, (index) {
                             dynamic meetDetails = pingsDataStore.localHelpMeetData[index];
                             print(meetDetails);

                             String startTime= meetDetails['time'];
                             String meetId = meetDetails['meetId'];
                             String meetStatus = meetDetails['meetStatus'];
                             String meetTitle = meetDetails['title'];
                             String userId = meetDetails['userId'];
                             String ?helperId = meetDetails['helperId'];
                             String ?distance = meetDetails['distance']==null?'':meetDetails['distance'];
                             String ?userName = meetDetails['userName']==null?'':meetDetails['userName'];
                             String ?userPhoto = meetDetails['userPhoto'];
                             String ?date = meetDetails['date']!=null?meetDetails['date']:'';
                             return Container(
                               child:
                               ((_selectedValue == 'Scheduled' && meetStatus =='schedule') ||
                                   (_selectedValue == 'Accepted' && (meetStatus =='accept'||meetStatus=='hold_accept'))||
                                   (_selectedValue == 'Pending' && meetStatus =='pending')||
                                   (_selectedValue == 'Closed' && (meetStatus =='close' || meetStatus=='closed') )||
                                   (_selectedValue == 'Cancelled' && meetStatus =='cancel')||
                                   _selectedValue =='All Pings')
                                   ? GestureDetector(
                                 onTap: ()async{
                                   if(widget.userId!=userId && meetStatus=='choose'){}
                                   else{
                                     await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: widget.userId,
                                       state: widget.userId==userId?'user':'helper',
                                       meetId: meetId,

                                     ),));
                                     _refreshPage();

                                   }
                                 },
                                 child: Container(

                                   padding: EdgeInsets.all(18),
                                   margin: EdgeInsets.only(left:12,right:15,top:10,bottom:20),
                                   decoration: BoxDecoration(
                                     color: Theme.of(context).backgroundColor, // Container background color
                                     borderRadius: BorderRadius.circular(3),
                                     boxShadow: [
                                       BoxShadow(
                                         color: Colors.grey.withOpacity(0.6),
                                         spreadRadius: 0.4,
                                         blurRadius: 0.6,
                                         offset: Offset(0.5, 0.8),
                                       ),
                                     ],
                                   ),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Container(
                                         padding:EdgeInsets.only(top:10,bottom:20),
                                         child: Text('Immediate Local Assistance',style:Theme.of(context).textTheme.subtitle1),
                                       ),
                                       Container(
                                         // width:screenWidth*0.73,
                                         // height: 36,
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                                           crossAxisAlignment: CrossAxisAlignment.center,
                                           children: [
                                             Row(
                                               children: [
                                                 userId==widget.userId
                                                     ? CircleAvatar(
                                                   radius: 20.0,
                                                   backgroundImage: pingsDataStore.userPhotoPath != null && pingsDataStore.userPhotoPath != ''
                                                       ? FileImage(File(pingsDataStore.userPhotoPath)) as ImageProvider<Object>?
                                                       : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                                 )
                                                     : CircleAvatar(
                                                   radius: 20.0,
                                                   backgroundImage: userPhoto!= null
                                                       ? FileImage(File(userPhoto)) as ImageProvider<Object>?
                                                       : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                                 ),
                                                 SizedBox(width: 6,),
                                                 SvgPicture.asset(
                                                   'assets/images/local_assist_logo.svg', // Replace with the path to your SVG file
                                                   width: 25, // Specify the width
                                                   height: 25, // Specify the height
                                                   color: Colors.black, // Change the color if needed
                                                 ),// IconButton(
                                                 //   onPressed: () {},
                                                 //   icon: SvgPicture.asset(
                                                 //     'assets/images/tripassit.svg', // Replace with the path to your SVG icon
                                                 //     height: 24,
                                                 //   ),
                                                 // ),
                                                 SizedBox(width: 6,),
                                                 userId==widget.userId
                                                     ? CircleAvatar(
                                                   radius: 20.0,
                                                   backgroundColor: Theme.of(context).backgroundColor,
                                                   backgroundImage: userPhoto!= null
                                                       ? FileImage(File(userPhoto)) as ImageProvider<Object>?
                                                       : AssetImage('assets/images/profile_image.png'),// Use a default asset image
                                                 )
                                                     :CircleAvatar(
                                                   radius: 20.0,
                                                   backgroundColor: Theme.of(context).backgroundColor,
                                                   backgroundImage: pingsDataStore.userPhotoPath != null && pingsDataStore.userPhotoPath != ''
                                                       ? FileImage(File(pingsDataStore.userPhotoPath)) as ImageProvider<Object>?
                                                       : AssetImage('assets/images/profile_image.png'),// Use a default asset image
                                                 ),
                                               ],
                                             ),
                                             SizedBox(width: 20,),
                                             meetStatus=='pending' || meetStatus=='cancel'?
                                             Container(
                                               color: Colors.red, // Background color red
                                               height: 16  , // Height set to 16
                                               constraints: BoxConstraints(
                                                 minWidth: 0,
                                                 maxWidth: double.infinity, // Adjust width according to text
                                               ),
                                               child: Text('   '+
                                                   (meetStatus=='pending'?'Request Pending':'Cancelled')+'   ',
                                                 style: TextStyle(color: Theme.of(context).backgroundColor,fontSize: 10), // Text color white
                                               ),
                                             )
                                                 : meetStatus=='accept' || meetStatus=='hold_accept'
                                                 ? Container(
                                               color: HexColor('FB8C00'), // Background color red
                                               height: 16  , // Height set to 16
                                               constraints: BoxConstraints(
                                                 minWidth: 0,
                                                 maxWidth: double.infinity, // Adjust width according to text
                                               ),
                                               child: Text('   '+
                                                   'Accepted'+'   ',
                                                 style: TextStyle(color: Theme.of(context).backgroundColor,fontSize: 10), // Text color white
                                               ),
                                             )
                                                 : meetStatus=='schedule'
                                                 ? Container(
                                               color: HexColor('0A8100'), // Background color red
                                               height: 16  , // Height set to 16
                                               constraints: BoxConstraints(
                                                 minWidth: 0,
                                                 maxWidth: double.infinity, // Adjust width according to text
                                               ),
                                               child: Text('   '+
                                                   'Scheduled'+'   ',
                                                 style: TextStyle(color: Theme.of(context).backgroundColor,fontSize: 10), // Text color white
                                               ),
                                             )
                                                 :meetStatus=='choose'
                                                 ?SizedBox(height: 0,)
                                                 : Container(
                                               color: HexColor('FB8C00'), // Background color red
                                               height: 16  , // Height set to 16
                                               constraints: BoxConstraints(
                                                 minWidth: 0,
                                                 maxWidth: double.infinity, // Adjust width according to text
                                               ),
                                               child: Text('   '+
                                                   'Closed'+'   ',
                                                 style: TextStyle(color: Theme.of(context).backgroundColor,fontSize: 10), // Text color white
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                       SizedBox(height: 18,),
                                       userName!=''
                                           ? userId==widget.userId
                                           ?Container(
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             Text('Meesage With',style: Theme.of(context).textTheme.subtitle2,),
                                             Container(
                                                 width: 150,
                                                 child: Text('${userName}',style: Theme.of(context).textTheme.subtitle2,)),
                                           ],
                                         ),
                                       )
                                           :Container(
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           children: [
                                             Text('Meesage From',style: Theme.of(context).textTheme.subtitle2,),
                                             Container(
                                                 width: 150,
                                                 child: Text('${userName}',style: Theme.of(context).textTheme.subtitle2,)),
                                           ],
                                         ),
                                       )
                                           :SizedBox(height: 0,),
                                       SizedBox(height: 7,),
                                       Container(
                                         height: 20,
                                         child: Row(
                                           // mainAxisAlignment: MainAxisAlignment.start,
                                           children: [
                                             Container(
                                               child: Image.asset('assets/images/time_icon.png',width: 20,height: 20,  ),
                                             ),
                                             Text(' ${startTime} \t',style: Theme.of(context).textTheme.subtitle2),
                                             Text('India',style: Theme.of(context).textTheme.subtitle2,)
                                           ],
                                         ),
                                       ),
                                       SizedBox(height: 7,),
                                       Container(
                                         // decoration: BoxDecoration(border:Border.all(width: 1)),
                                         child: Row(
                                           children: [
                                             Container(
                                               child: Image.asset('assets/images/calendar.png',width: 22,height: 22,),
                                             ),
                                             Text(' Date ${date} "${convertToDate2(date!)}"',style: Theme.of(context).textTheme.subtitle2),
                                           ],
                                         ),
                                       ),
                                       SizedBox(height: 7,),
                                       Container(
                                         // decoration: BoxDecoration(border: Border.all(color:Colors.green)),
                                         padding:EdgeInsets.only(left:3),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           children: [
                                             Container(

                                               width:260,
                                               child: Text(meetTitle==''?'Please Enter Tile Next Time':meetTitle,style:Theme.of(context).textTheme.subtitle2,),
                                             ),
                                           ],
                                         ),
                                       ),
                                       (userId==widget.userId && meetStatus=='pending') || (meetStatus=='cancel' || meetStatus=='closed')
                                           ?SizedBox(height:10,)
                                           :SizedBox(height:32),
                                       (meetStatus=='pending' && userId==widget.userId)
                                           ?InkWell(
                                           onTap: ()  async{
                                             //   Cancel Ka Funda
                                             bool userConfirmed = await showConfirmationDialog(context, userName!);
                                             if (userConfirmed) {
                                               // User confirmed, do something
                                               print('User confirmed');
                                               await updateLocalUserPings(userId, meetId, 'cancel');
                                               if(helperId!=null){
                                                 await updateLocalUserPings(helperId, meetId, 'cancel');
                                               }
                                               else{
                                                 await removePingsHelper(meetId);
                                               }
                                               // sendCustomNotificationToOneUser(
                                               //     helperToken,
                                               //     'Messages From ${userName}',
                                               //     'Meeting is Cancelled By ${userName}','Meeting is Cancelled By ${userName}',
                                               //     '${widget.meetId}','trip_assistance_required',helperId,'helper'
                                               // );
                                               await updateMeetingChats(meetId!,['','admin-cancel']);
                                               await updatePaymentStatus('cancel',meetId);
                                               _refreshPage();

                                             } else {
                                               // User canceled, do something else
                                               print('User canceled');
                                             }
                                           },
                                           child: Container(
                                             width: double.infinity,
                                             padding : EdgeInsets.only(top : 20,bottom : 10),

                                             child: Center(child: Text('Cancel',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Theme.of(context).floatingActionButtonTheme.backgroundColor),)),))
                                           :(meetStatus=='pending' && userId!=widget.userId)
                                           ?Center(child: Container(child: Text('*Payment Pending. Please wait for event. ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,fontFamily: 'Poppins',color: HexColor('#FF0000')),),))
                                           :(meetStatus=='accept' || meetStatus=='hold_accpet')
                                           ?Container(
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [

                                             InkWell(
                                                 onTap: ()async{

                                                           await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: widget.userId,
                                                             state: widget.userId==userId?'user':'helper',
                                                             meetId: meetId,
                                                           ),));


                                                 },
                                                 child: Container(child: Text('Go To Chats',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Theme.of(context).floatingActionButtonTheme.backgroundColor),),)),


                                             // SizedBox(width: screenWidth*0.08,),
                                             // InkWell(
                                             //     onTap: ()async{
                                             //       // payment ka funda
                                             //       bool res = await Navigator.push(
                                             //         context,
                                             //         MaterialPageRoute(
                                             //           builder: (context) => RazorPayIntegration(),
                                             //         ),
                                             //       );
                                             //       if(res){
                                             //         sendCustomNotificationToUsers([helperId!], localAssistantHelperPay(pingsDataStore.userName, meetId));
                                             //         await updateLocalUserPings(userId, meetId, 'schedule');
                                             //         await updateLocalUserPings(helperId!, meetId, 'schedule');
                                             //         await updatePaymentStatus('pending',meetId);
                                             //         await updateMeetingChats(meetId!,['','admin-helper-1']);
                                             //         await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: widget.userId,
                                             //           state: widget.userId==userId?'user':'helper',
                                             //           meetId: meetId,
                                             //         ),));
                                             //         _refreshPage();
                                             //       }else{
                                             //         ScaffoldMessenger.of(context).showSnackBar(
                                             //           const SnackBar(
                                             //             content: Text('Payment is UnSuccessful'),
                                             //           ),
                                             //         );
                                             //       }
                                             //     },
                                             //     child: Container(child: Text('Pay Charge',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#0A8100')),),)),

                                           ],
                                         ),
                                       )
                                           :(meetStatus=='choose')
                                           ?InkWell(
                                           onTap: ()  async{
                                             //   Accept ka funda

                                             await updateLocalHelperPings(meetId, 'hold_accept');
                                             await createUpdateLocalUserPings(userId ,meetId, 'hold_accept',pingsDataStore.userName,pingsDataStore.userPhotoPath);
                                             // await updateMeetingChats(meetId,[userID,'admin-user-1']);
                                             await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: widget.userId,
                                               state: 'helper',
                                               meetId: meetId,
                                             ),));


                                             // sendCustomNotificationToOneUser(
                                             //     helperToken,
                                             //     'Messages From ${userName}',
                                             //     'Meeting is Cancelled By ${userName}','Meeting is Cancelled By ${userName}',
                                             //     '${widget.meetId}','trip_assistance_required',helperId,'helper'
                                             // );
                                             _refreshPage();
                                             // sendCustomNotificationToUsers([userId],localAssistantHelperAccepted(userName!, meetId));
                                           },
                                           child: Center(child: Container(child: Text('Accept & Reply',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Theme.of(context).floatingActionButtonTheme.backgroundColor),),)))
                                           :(meetStatus=='close' && userId!=widget.userId)
                                           ?InkWell(
                                         onTap: (){
                                           Navigator.push(
                                             context,
                                             MaterialPageRoute(
                                               builder: (context) => RateFeed(meetId:meetId,service: 'Local Assistant',),
                                             ),
                                           );
                                         },
                                         child: Container(
                                           width: screenWidth*0.70,
                                           child: Center(child: Text('Rate & Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                         ),
                                       )
                                           :(meetStatus=='close')
                                           ? InkWell(
                                         onTap: (){
                                           Navigator.push(
                                             context,
                                             MaterialPageRoute(
                                               builder: (context) =>  RateFeed(meetId:meetId,service: 'Local Assistant',),
                                             ),
                                           );
                                         },
                                         child: Container(


                                           child: Center(child: Text('Give Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                         ),
                                       )
                                           :(meetStatus=='schedule')
                                           ? userId==userID?
                                       Container(
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                                           children: [
                                             InkWell(
                                                 onTap: ()async{
                                                   bool userConfirmed = await showConfirmationDialog(context, userName!);
                                                   if (userConfirmed) {
                                                     // User confirmed, do something
                                                     print('User confirmed');
                                                     await updateLocalUserPings(userId, meetId, 'close');
                                                     await updateLocalUserPings(helperId!, meetId, 'close');
                                                     await updatePaymentStatus('close',meetId);
                                                     // sendCustomNotificationToOneUser(
                                                     //     helperToken,
                                                     //     'Messages From ${userName}',
                                                     //     'Meeting is Closed By ${userName}','Meeting is Closed By ${userName}',
                                                     //     '${meetId}','trip_assistance_required',helperId,'helper'
                                                     // );
                                                     _refreshPage(time: 0,state: 'Closed');
                                                     // sendCustomNotificationToUsers([helperId!], localAssistantMeetCancel(pingsDataStore.userName));



                                                   } else {
                                                     // User canceled, do something else
                                                     print('User Closed');
                                                   }
                                                 },
                                                 child: Container(child: Text('Close',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Theme.of(context).floatingActionButtonTheme.backgroundColor),),)),
                                             InkWell(
                                                 onTap: ()async{
                                                   await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: widget.userId,
                                                     state: widget.userId==userId?'user':'helper',
                                                     meetId: meetId,
                                                   ),));
                                                   _refreshPage();
                                                 },
                                                 child: Center(child: Container(child: Text('Continue',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#0A8100')),),)))
                                           ],
                                         ),
                                       )
                                           :
                                       InkWell(
                                           onTap: ()async{
                                             await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: widget.userId,
                                               state: widget.userId==userId?'user':'helper',
                                               meetId: meetId,
                                             ),));
                                             _refreshPage();
                                           },
                                           child: Center(child: Container(child: Text('Continue',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#0A8100')),),)))
                                           :SizedBox(height: 0,),
                                     ],
                                   ),
                                 ),
                               )
                                   :SizedBox(height: 0,),
                             );
                           }),
                         )
                             :SizedBox(height:0),
                       ],
                     ),
                   ),
                 )
                     : Center(child: CircularProgressIndicator(color: Colors.orange,),),
                 Positioned(
                   top : 0, right : 0,left:  0,

                     child: Container(
                       padding : EdgeInsets.only(top : 20,left : 20,right : 20),
                      color : Theme.of(context).backgroundColor,
                   child : Column(
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           Expanded(
                             child: Container(
                               child: InkWell(
                                 splashColor: Colors.transparent,
                                 highlightColor: Colors.transparent,
                                 onTap: (){
                                   setState(() {
                                     toggle = true;
                                   });
                                 },
                                 child: Container(


                                   decoration:BoxDecoration(
                                     border: Border(
                                       bottom: BorderSide(
                                         color: toggle?HexColor('#FB8C00'):Theme.of(context).backgroundColor, // Choose the color you want for the bottom border
                                         width: 2.0, // Adjust the width of the border
                                       ),
                                     ),
                                   ),
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Container(
                                         child: Column(
                                           children: [
                                             Text('Requests',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold,color:toggle?HexColor('#FB8C00'):Colors.black),),
                                             SizedBox(height : 5),
                                           ],
                                         ),
                                       ),
                                       SizedBox(width: 5,),
                                       Container(
                                         width: 22,
                                         height: 22,
                                         decoration: BoxDecoration(
                                           color: Colors.red,
                                           shape: BoxShape.circle,
                                         ),
                                         child: Center(
                                           child: Text(
                                             '2',
                                             style: TextStyle(
                                               color: Theme.of(context).backgroundColor,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                         ),
                                       )
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                           ),
                           Expanded(
                             child: Container(
                               child: InkWell(
                                 splashColor: Colors.transparent,
                                 highlightColor: Colors.transparent,
                                 onTap: (){
                                   setState(() {
                                     toggle = false;
                                   });
                                 },
                                 child: Container(

                                   decoration:BoxDecoration(
                                     border: Border(
                                       bottom: BorderSide(
                                         color: !toggle?HexColor('#FB8C00'):Theme.of(context).backgroundColor, // Choose the color you want for the bottom border
                                         width: 2.0, // Adjust the width of the border
                                       ),
                                     ),
                                   ),
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Container(
                                         child: Column(
                                           children: [
                                             Text('Notification',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold,color: !toggle?HexColor('#FB8C00'):Colors.black),),
                                             SizedBox(height : 5),
                                           ],
                                         ),
                                       ),
                                       SizedBox(width: 5,),
                                       Container(
                                         width: 22,
                                         height: 22,
                                         decoration: BoxDecoration(
                                           color: Colors.red,
                                           shape: BoxShape.circle,
                                         ),
                                         child: Center(
                                           child: Text(
                                             '2',
                                             style: TextStyle(
                                               color: Theme.of(context).backgroundColor,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                         ),
                                       )
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                           ),
                         ],
                       ),

                       SizedBox(height : 20),

                       toggle
                           ? Container(

                         // width: screenWidth*0.85,
                         // height: 50,
                         child: Row(

                           children: [

                             Expanded(
                               child: Container(

                                 decoration: BoxDecoration(
                                   color : Theme.of(context).backgroundColor,
                                   boxShadow: [
                                     BoxShadow(
                                       color: Colors.grey.withOpacity(0.6),
                                       spreadRadius: 0.4,
                                       blurRadius: 0.6,
                                       offset: Offset(0.5, 0.8),
                                     ),
                                   ],
                                   // border: Border.all(
                                   //     color: HexColor('#FB8C00')
                                   // ),
                                   borderRadius: BorderRadius.circular(5),
                                 ),
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: <Widget>[
                                     Container(


                                       child: DropdownButton<String>(
                                         elevation: 1,
                                         alignment: AlignmentDirectional.bottomEnd,
                                         dropdownColor: Theme.of(context).backgroundColor,
                                         value: _selectedService,
                                         items: <String>['Trip Planning', 'Local Assistant']
                                             .map((String value) {
                                           return DropdownMenuItem<String>(
                                             value: value,
                                             child: Text(value,style:  TextStyle(color: Colors.orange,fontSize: 14,fontFamily: 'Poppins'),),);
                                         }).toList(),
                                         onChanged: (String? newValue) {
                                           if (newValue != null) {
                                             print(newValue);
                                             _updateSelectedService(newValue);
                                           }
                                         },
                                         // Change the dropdown text style
                                         underline: Container(), // Hide the underline
                                         icon: Icon(Icons.keyboard_arrow_down, color: HexColor('#FB8C00')), // Change the dropdown icon
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),

                             Container(width : 10),

                             Expanded(
                               child: Container(


                                 decoration: BoxDecoration(
                                   color : Theme.of(context).backgroundColor,
                                   boxShadow: [
                                     BoxShadow(
                                       color: Colors.grey.withOpacity(0.6),
                                       spreadRadius: 0.4,
                                       blurRadius: 0.6,
                                       offset: Offset(0.5, 0.8),
                                     ),
                                   ],
                                   // border: Border(
                                   //   bottom: BorderSide(
                                   //     color: HexColor('#FB8C00'),
                                   //     width: 1.0, // Adjust the width of the border as needed
                                   //   ),
                                   // ),
                                   borderRadius: BorderRadius.circular(5),
                                 ),
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: <Widget>[
                                     Container(
                                       child: DropdownButton<String>(
                                         elevation : 1,

                                         dropdownColor: Theme.of(context).backgroundColor,
                                         value: _selectedValue,
                                         items:  <String>['All Pings','Scheduled', 'Accepted', 'Pending' , 'Closed','Cancelled']
                                             .map((String value) {
                                           return DropdownMenuItem<String>(
                                             value: value,
                                             child: Text(value,style:  TextStyle(color: Colors.orange,fontSize: 14,fontFamily: 'Poppins'),),
                                           );
                                         }).toList(),
                                         onChanged: (String? newValue) {
                                           if (newValue != null) {
                                             print(':::');
                                             _updateSelectedValue(newValue);
                                           }
                                         },// Change the dropdown text style
                                         underline: Container(), // Hide the underline
                                         icon: Icon(Icons.keyboard_arrow_down, color: HexColor('#FB8C00')), // Change the dropdown icon
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           ],
                         ),
                       )
                           : SizedBox(height: 0,),

                     ],
                   ),
                 ))
               ],
                ),
            )
            :Center(
          // Show a circular progress indicator while data is being fetched
          child: CircularProgressIndicator(),
        ),),
    );
  }

}

class ScheduledCalendar extends StatefulWidget {
  String date,userId;
  String?name,meetStartTime;
  ScheduledCalendar({required this.date,required this.userId,this.name,this.meetStartTime});
  @override
  _ScheduledCalendarState createState() =>  _ScheduledCalendarState();
}

class _ScheduledCalendarState extends State<ScheduledCalendar>{


  bool updatedStatus = true;
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

  Duration _remainingTime = Duration();
  DateTime? timeleft;
  Timer? _timer;
  Timer? countdownTimer;
  bool dataLoaded = true,start20Min=false,closedMeet=false;
  Duration meetingDuration = Duration(minutes: 20); // Set your meeting duration
  String startTime='',endTime='',plannerName='',meetType='',meetStatus='',plannerId='',plannerToken='';
  @override
  void initState() {
    super.initState();
    startSetup();
  }

  Future<void> fetchTripPlanningMeetDetais()async{
    final serverUrl = Constant().serverUrl;
    final url = Uri.parse('$serverUrl/fetchMeetDetails');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId" : userID,
      "date" : widget.date,
      "meetStartTime":widget.meetStartTime,
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
          startTime = data['start'];
          endTime = data['end'];
          plannerName = data['plannerName'];
          plannerId = data['plannerId'];
          meetType = data['meetType'];
          meetStatus = data['meetStatus'];
          plannerToken = data['plannerToken'];
        });
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

  void startSetup()async{
    setState(() {
      dataLoaded = false;
    });
    await fetchTripPlanningMeetDetais();
    if(meetStatus!='close' && meetStatus!='closed'){
      timeleft = setDateTime(widget.date, startTime);
      _remainingTime = timeleft!.difference(DateTime.now());
      if(_remainingTime.inSeconds>0){
        startCountdown();
      }else{
        DateTime currentTime = DateTime.now();
        Duration elapsed = currentTime.difference(timeleft!);
        _remainingTime = meetingDuration - elapsed;
        if(_remainingTime.inSeconds>0){
          startMeetingTimer();
          setState(() {
            start20Min = true;
          });
        }else{
          print('Meet Closed');
        }
      }
      setState(() {
        dataLoaded = true;
      });
    }
    else{
      setState(() {
        closedMeet = true;
        dataLoaded = true;
      });
    }
    // if(!start20Min){
    //   startCountdown();
    // }else if(!closedMeet){
    //   startMeetingTimer();
    // }else{}
  }

  void updateRemainingTime() {
    if(mounted){
      setState(() {
        DateTime currentTime = DateTime.now();
        Duration elapsed = currentTime.difference(timeleft!);
        _remainingTime = meetingDuration - elapsed;
      });
    }
  }

  void startMeetingTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateRemainingTime();
      if (_remainingTime.inSeconds <= 0) {
        setState(() {
          closedMeet = true;
          startSetup();
        });
      }
    });
  }
  void startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(mounted){
        setState(() {
          _remainingTime = timeleft!.difference(DateTime.now());
          if (_remainingTime.inSeconds <= 0) {
            _timer!.cancel();
            start20Min=true;
            startSetup();
          }
        });
      }
    });
  }

  Future<void> cancelMeeting(String date,String startTime,String status,String otherId,String otherStatus)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': userID,
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


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    List<String> parts = widget.date.split('/'); // Split the string by '/'
    String useDate = '${parts[0]}/${parts[1]}'; // Concatenate the parts as needed
    String date=widget.date,userId=widget.userId;
    // dynamic meetDetails=widget.meetDetails;
    // String startTime= meetDetails['meetStartTime'][widget.index];
    // String endTime= meetDetails['meetEndTime'][widget.index];
    // String meetId = meetDetails['meetingId'][widget.index];
    // String meetType = meetDetails['meetingType'][widget.index];

    Future<void> fetchMeetStatus()async{
      final serverUrl = Constant().serverUrl;
      final url = Uri.parse('$serverUrl/fetchMeetDetails');
      // Replace with your data
      Map<String, dynamic> requestData = {
        "userId" : userID,
        "date" : widget.date,
        "meetStartTime":widget.meetStartTime,
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
    return Scaffold(
      appBar: AppBar(title: ProfileHeader(reqPage: 2,state:meetType=='sender'?'user':'helper',service: 'trip_planning', fromWhichPage: 'trip_planning_calendar_pings',meetStatus: start20Min?'started':meetStatus,
        onButtonPressed: ()async{
          await fetchMeetStatus();

          print('Meet is $meetStatus');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PingsSection(userId:userID,state:(meetStatus=='close'|| meetStatus=='closed')?'Closed':'Scheduled',selectedService: 'Trip Planning',fromWhichPage: 'trip_planning',),
              ),
            );
        },
        cancelCloseClick: ()async{
          // await updateMeetingChats(meetId,['','admin-close']);
          String currentMeetStatus = meetStatus;
          await fetchMeetStatus();
          if(currentMeetStatus!=meetStatus){
            Fluttertoast.showToast(
              msg:
              'Meeting Is Already Closed By ${plannerName}.Update Page!!',
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
              closedMeet = true;
            });
          }
          else{
              showDialog(
              context: context,
              builder: (BuildContext context) {
                return ImagePopUpWithTwoOption(imagePath: 'assets/images/logo.png',textField:'You are closing this request ?',extraText: 'Thank you for using our services !', what: 'a',
                  option2Callback:()async{
                    setState(() {
                      updatedStatus = false;
                    });
                    await cancelMeeting(widget.date!,startTime,'close',plannerId,'close');
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
                      closedMeet = true;
                      updatedStatus = true;
                    });
                  },);
              },
            );
          }
      },),automaticallyImplyLeading: false,backgroundColor: Theme.of(context).backgroundColor,shadowColor: Colors.transparent,),
      body: dataLoaded
          ? SingleChildScrollView(
        child:  WillPopScope(
          onWillPop: ()async{
            await fetchMeetStatus();
            if(meetStatus=='close'||closedMeet){
              Navigator.pop(context,'Closed');
            }else{
              Navigator.pop(context,'Scheduled');
            }
            return true;
        },
          child: Container(
            width:screenWidth,
            margin: EdgeInsets.only(left: 20,right:20),
            // color:Colors.red,
            // decoration: BoxDecoration(border:Border.all(width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 30,),
                Text('Scheduled Calendar',style: Theme.of(context).textTheme.subtitle1,),
                SizedBox(height: 30,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date',style: Theme.of(context).textTheme.subtitle1),
                    SizedBox(height: 10,),
                    Container(
                      width:155,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: HexColor('#FB8C00')
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 5,),
                          SvgPicture.asset(
                            'assets/images/calendar.svg', // Replace with the path to your SVG file
                            width: 18, // Specify the width
                            height: 18, // Specify the height
                            color: Colors.orange, // Change the color if needed
                          ),
                          SizedBox(width: 10,),
                          Text('${date}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),)
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30,),
                Text('Planned Call',style: Theme.of(context).textTheme.subtitle1),
                SizedBox(height: 10,),
                Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor, // Container background color
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
                child: InkWell(
                  onTap: (){
                    meetType=='sender'
                        ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatApps(senderId:userID,receiverId:'',date:widget.date,startTime:startTime),
                      ),
                    )
                        :Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatApps(senderId:'',receiverId:userID,date:widget.date,startTime:startTime),
                      ),
                    );
                  },
                  // Navigator.push(
                  //                       context,
                  //                       MaterialPageRoute(
                  //                         builder: (context) => ChatApps(callbacker:widget.callbacker,senderId:'',receiverId:userId,meetingId:meetId,date:date,index:widget.index,currentTime:setDateTime(date, startTime)),
                  //                       ),
                  //                     );
                  child: Container(
                    padding: EdgeInsets.all(20),
                    // color: Colors.red,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text('${startTime} - ${endTime}',style: Theme.of(context).textTheme.subtitle2),
                              SizedBox(height:10),
                              Container(
                                  child: Text('Trip planning Call with ${Constant().extractFirstName(plannerName)}',style: Theme.of(context).textTheme.subtitle2,))
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,size: 25,color: Colors.orange,),
                      ],
                    ),
                  ),
                  // child: Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     Container(
                  //       // color: Colors.red,
                  //       padding: EdgeInsets.only(left: 10,right:10),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text('${startTime} - ${endTime} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                  //           Container(
                  //             child: Image.asset('assets/images/arrow_fwd.png',width: 25,height: 25,),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     Text('Trip planning Call with     customer',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                  //   ],
                  // ),
                ),
                  ),
              ],
            ),
          ),
        ),
      )
          : Center(child:CircularProgressIndicator(color:Colors.orange)),
      // bottomNavigationBar: dataLoaded && updatedStatus?
      //         start20Min==false && closedMeet==false
      //             ? Container(
      //                 height : 63,
      //                 padding:EdgeInsets.only(left:10,right:10),
      //                 decoration: BoxDecoration(
      //                   color : Colors.white60,
      //                   // borderRadius: BorderRadius.circular(0),
      //                   // border: Border.all(color: Colors.orange),
      //                 ),
      //                 // alignment: Alignment.center,
      //                 child: Center(
      //                   child: Text(
      //                     '${_remainingTime.inDays<=0?'0':_remainingTime.inDays}D : ${(_remainingTime.inHours % 24)<=0?'00':(_remainingTime.inHours % 24)}H : ${(_remainingTime.inMinutes % 60)<=0?'00':(_remainingTime.inMinutes % 60)}M : ${(_remainingTime.inSeconds % 60)<=0?'00':(_remainingTime.inSeconds % 60)}S',
      //                     style: TextStyle(fontSize: 25, fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.red),
      //                   ),
      //                 )
      //               )
      //             : closedMeet==false
      //                 ? Container(
      //                   height : 63,
      //                   padding:EdgeInsets.only(left:10,right:10),
      //                   decoration: BoxDecoration(
      //                     color : Colors.white60,
      //                     // borderRadius: BorderRadius.circular(0),
      //                     // border: Border.all(color: Colors.orange),
      //                   ),
      //                 // alignment: Alignment.center,
      //                 child: Center(
      //                   child: Text(
      //                     '${(_remainingTime.inMinutes % 60)<=0?'00':(_remainingTime.inMinutes % 60)}M : ${(_remainingTime.inSeconds % 60)<=0?'00':(_remainingTime.inSeconds % 60)}S',
      //                     style: TextStyle(fontSize: 25, fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.green),
      //                   ),
      //                 ),
      //               )
      //                 : Container(
      //           height : 63,
      //
      //           padding:EdgeInsets.only(left:10,right:10),
      //           decoration: BoxDecoration(
      //             color : Colors.grey[200],
      //             borderRadius: BorderRadius.circular(0),
      //             border: Border.all(color: Colors.orange),
      //           ),
      //           child: Center(child:Text('Closed Call',style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //               color: Colors.orange,
      //               fontSize: 18))),
      //         )
      //         : SizedBox(height: 0,),
    );
  }
}

class RateFeedBack extends StatefulWidget{
  String?userPhoto,userName,startTime,endTime,date,meetTitle,meetType,meetId,userId,fromWhichPage;
  int?index;
  final VoidCallback? pingsCallback;
  RateFeedBack({this.meetId,this.meetType,this.meetTitle,this.endTime,this.startTime,this.userName,this.date,this.userPhoto,this.userId,this.index,this.pingsCallback,this.fromWhichPage});
  @override
  _RateFeedBackState createState() => _RateFeedBackState();
}

class _RateFeedBackState extends State<RateFeedBack>{
  FocusNode _feedbackFocusNode = FocusNode(),_additionalFocusNode=FocusNode();
  String userId='',plannerId='',meetId='',meetStatus='',startTime='',endTime='',meetType='',plannerToken='',userName='',userPhoto='',plannerName='',plannerPhoto='',meetingTitle='';
  bool dataLoaded = true;
  @override
  void initState(){
    super.initState();
    fetchData();
  }

  Future<void> fetchData()async{
    setState(() {
      dataLoaded = false;
    });
    await fetchTripPlanningMeetDetais();
    setState(() {
      dataLoaded = true;
    });
  }


  Future<void> fetchTripPlanningMeetDetais()async{
    String serverUrl = Constant().serverUrl;
    final url = Uri.parse('$serverUrl/fetchMeetDetails');
    // Replace with your data
    Map<String, dynamic> requestData = {
      "userId" : userID,
      "date" : widget.date,
      'meetStartTime':widget.startTime,
    };
    print('Data is');
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
          meetingTitle = data['meetingTitle'];
        });
        // print('Meeting is ${widget.meetingId}');
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


  String convertToDate(String dateStr) {
    final Map<String, String> months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };

    final List<String> parts = dateStr.split('/');
    final day = int.parse(parts[0]);
    final month = months[parts[1]]!;
    final year = parts[2];

    final formattedDate = DateTime(int.parse(year), int.parse(month), day);
    final dayName = formattedDate.weekday; // Get the day of the week (1 for Monday, 7 for Sunday)

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return days[dayName - 1]; // Adjust to index of days array (0 for Monday, 6 for Sunday)
  }


  Future<void> updateMeetingFeedback(String meetingId,int rating,String info,String type,String userId,String startTime,String date,String info2)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'meetId': meetingId,
        'rating':rating,
        'info':info,
        'companyInfo':info2,
        'type':type,
      };
      print('PPPPP::$data');
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/updateMeetingFeedback'), // Adjust the endpoint as needed
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

    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': userId,
        'date':date,
        'startTime':startTime
      };
      print('PPPPP::$data');
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/closeMeeting'), // Adjust the endpoint as needed
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

  int rating = 0;
  String textValue = '',textValue2='';
  @override
  Widget build(BuildContext context) {

    // final screenWidth = MediaQuery.of(context).size.width;
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Row(
    //       children: [
    //         SizedBox(width: 10,),
    //         Container(
    //           width: screenWidth<400?screenWidth*0.80:360,
    //           height:50,
    //           // decoration: BoxDecoration(border:Border.all(width: 1)),
    //           // padding: EdgeInsets.only(left:10,right:10),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             crossAxisAlignment: CrossAxisAlignment.end,
    //             children: [
    //               Container(
    //                   height:50,child: Text('\nRate & Feedback.',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
    //               Container(
    //                 height: 35,
    //                 child: IconButton(onPressed: (){
    //                   Navigator.of(context).pop();
    //                 }, icon: Icon(Icons.close)),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //     automaticallyImplyLeading: false,
    //   ),
    //   body: SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         Row(
    //           children: [
    //             SizedBox(width: 25,),
    //             Container(
    //               width: screenWidth<400?screenWidth*0.85:360,
    //               height: 180,
    //               margin: EdgeInsets.only(top:75),
    //               // decoration: BoxDecoration(border:Border.all(width: 1)),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Container(
    //                     width: screenWidth<400?screenWidth*0.80:370,
    //                     height: 40,
    //                     // decoration: BoxDecoration(
    //                     //   border:Border.all(
    //                     //     width: 1,
    //                     //     color: Colors.lightBlue
    //                     //   ),
    //                     // ),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.start,
    //                       crossAxisAlignment: CrossAxisAlignment.center,
    //                       children: [
    //                         widget.meetType=='sender'
    //                             ? CircleAvatar(
    //                           radius: 20.0,
    //                           backgroundImage: widget.userPhoto != null && widget.userPhoto != ''
    //                               ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
    //                               : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
    //                         )
    //                             :CircleAvatar(
    //                           radius: 20.0,
    //                           backgroundImage: (widget.userPhoto!) != null && widget.userPhoto != ''
    //                               ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
    //                               : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
    //                         ),
    //                         SizedBox(width: 10,),
    //                         Image.asset('assets/images/arrow_dir.png'),
    //                         SizedBox(width: 10,),
    //                         widget.meetType=='sender'
    //                             ? CircleAvatar(
    //                           radius: 20.0,
    //                           backgroundImage: (widget.userPhoto) != null && widget.userPhoto != ''
    //                               ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
    //                               : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
    //                         )
    //                             :CircleAvatar(
    //                           radius: 20.0,
    //                           backgroundImage: (widget.userPhoto) != null && widget.userPhoto != ''
    //                               ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
    //                               : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //
    //
    //                   Container(
    //                     height: 85,
    //                     child: Column(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         widget.meetType=='sender'
    //                             ?Container(
    //
    //                           child: Row(
    //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                             children: [
    //                               Text('Trip planning Call with    ',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
    //                               Text('${widget.userName!}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
    //                             ],
    //                           ),
    //                         )
    //                             :Row(
    //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                           children: [
    //                             Text('Call requested by',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
    //                             Text('${widget.userName!}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
    //                           ],
    //                         ),
    //                         Container(
    //                           height: 50,
    //                           // decoration: BoxDecoration(border:Border.all(width: 1)),
    //                           child: Column(
    //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                             children: [
    //                               Row(
    //                                 children: [
    //                                   Container(
    //                                     child: Image.asset('assets/images/time_icon.png',width: 20,height: 20,),
    //                                   ),
    //                                   SizedBox(width: 5,),
    //                                   Text('${widget.startTime!} - ${widget.endTime!} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
    //                                   Text('India',style: TextStyle(fontWeight: FontWeight.bold,fontSize:14,fontFamily: 'Poppins'),)
    //                                 ],
    //                               ),
    //                               Row(
    //                                 children: [
    //                                   Container(
    //                                     child: Image.asset('assets/images/calendar.png',width: 20,height: 20,),
    //                                   ),
    //                                   SizedBox(width: 5,),
    //                                   Text('Date ${widget.date!} "${convertToDate(widget.date!)}"',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
    //                                 ],
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   Container(
    //                     width: screenWidth<400?screenWidth*0.80:370,
    //                     child: Text(widget.meetTitle==''?'Please Enter Tile Next Time':widget.meetTitle!,style: TextStyle(fontSize: 16,fontFamily: 'Poppins'),),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 40,),
    //         Row(
    //           children: [
    //             SizedBox(width: 26,),
    //             Container(
    //               // decoration: BoxDecoration(border:Border.all(width: 1)),
    //               width: screenWidth<400?screenWidth*0.80:370,
    //               height: 333,
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Container(
    //                     height:64,
    //                     child: Column(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Container(
    //                           width: screenWidth<400?screenWidth*0.80:370,
    //                           child: Text(
    //                             'Rate your Experience',
    //                             style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),
    //                           ),
    //                         ),
    //                         Container(
    //                           // decoration: BoxDecoration(border:Border.all(width: 1)),
    //                           child: Row(
    //                             mainAxisAlignment: MainAxisAlignment.start,
    //                             children: List.generate(5, (index) {
    //                               return GestureDetector(
    //                                 onTap: () {
    //                                   setState(() {
    //                                     rating = index + 1;
    //                                     print('Rating is$rating');
    //                                   });
    //                                 },
    //                                 child: Icon(
    //                                   Icons.star,
    //                                   color: (index < rating) ? HexColor('#FB8C00') : Colors.grey,
    //                                   size: 32,
    //                                 ),
    //                               );
    //                             }),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   Container(
    //                     height: widget.meetType=='sender'?156:185,
    //                     child: Column(
    //                       mainAxisAlignment: MainAxisAlignment.start,
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Container(
    //                             padding:EdgeInsets.only(top: widget.meetType=='sender'?23:0),
    //                             width: screenWidth<400?screenWidth*0.80:370,
    //                             child: Text('Additional Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
    //                         Container(
    //                           color: HexColor('#E9EAEB'),
    //                           width: screenWidth<400?screenWidth*0.80:370,
    //                           height: widget.meetType=='sender'?104:152,
    //                           child: TextField(
    //                             style: TextStyle(fontSize: 16,),
    //                             onChanged: (value) {
    //                               textValue = value;
    //                             },
    //                             decoration: InputDecoration(
    //                               hintText: 'Type here........',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                             maxLines: 5, // Increase the maxLines for a larger text area
    //                           ),
    //                         ),
    //
    //                       ],
    //                     ),
    //                   ),
    //                   widget.meetType=='sender'?SizedBox(height: 5,):SizedBox(height: 0,),
    //                   widget.meetType=='sender'
    //                       ?Container(
    //                     height: 1,
    //                     decoration: BoxDecoration(
    //                       border: Border.all(
    //                           color: Colors.black
    //                       ),
    //                     ),
    //                   )
    //                       :SizedBox(height: 0,),
    //                   widget.meetType=='sender'?SizedBox(height: 5,):SizedBox(height: 0,),
    //                   widget.meetType=='sender'
    //                       ?Container(
    //                     height: 102,
    //                     child: Column(
    //                       mainAxisAlignment: MainAxisAlignment.start,
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Container(
    //                             width: screenWidth<400?screenWidth*0.80:370,
    //                             height: 21,
    //                             child: Text('Wanna say something to Culturtap ?',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
    //                         SizedBox(height: 10,),
    //                         Container(
    //                           color: HexColor('#E9EAEB'),
    //                           width: screenWidth<400?screenWidth*0.80:370,
    //                           height: 70,
    //                           child: TextField(
    //                             style: TextStyle(fontSize: 16,),
    //                             onChanged: (value) {
    //                               textValue2 = value;
    //                             },
    //                             decoration: InputDecoration(
    //                               hintText: 'Type here........',
    //                               border: OutlineInputBorder(),
    //                             ),
    //                             maxLines: 5, // Increase the maxLines for a larger text area
    //                           ),
    //                         ),
    //
    //                       ],
    //                     ),
    //                   )
    //                       :SizedBox(height: 0,),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //         widget.meetType=='sender'?SizedBox(height: 30,):SizedBox(height: 90,),
    //         Container(
    //           width: screenWidth<400?screenWidth*0.80:370,
    //           height: 55,
    //           child: FiledButton(
    //               backgroundColor: HexColor('#FB8C00'),
    //               onPressed: () {
    //                 print('${widget.meetId},${widget.meetType}');
    //                 updateMeetingFeedback(widget.meetId!,rating,textValue,widget.meetType!,widget.userId!,widget.index!,widget.date!,textValue2);
    //                 // Navigator.push(
    //                 //   context,
    //                 //   MaterialPageRoute(
    //                 //     builder: (context) => HomePage(userId: widget.userId,userName: widget.userName,),
    //                 //   ),
    //                 // );
    //
    //                 Navigator.of(context).pop();
    //               },
    //               child: Center(
    //                   child: Text('SUBMIT',
    //                       style: TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                           color: Theme.of(context).backgroundColor,
    //                           fontSize: 16)))),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: dataLoaded?SingleChildScrollView(
        child:  Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rate & Feedback',style: Theme.of(context).textTheme.headline2,),
                  InkWell(
                      onTap: (){
                        if(widget.fromWhichPage=='trip_planning_chat'){
                          Navigator.of(context).pop();
                        }else{
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PingsSection(userId: userID,selectedService: 'Trip Planning',state: 'Closed',),
                            ),
                          );
                        }
                      },
                      child: Icon(Icons.close,size: 26,color: Theme.of(context).primaryColor,)),
                ],
              ),
              SizedBox(height: 51,),
              Container(
                padding: EdgeInsets.only(right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        meetType=='sender'
                            ? CircleAvatar(
                          radius: 20.0,
                          backgroundImage: AssetImage('assets/images/profile_image.svg'),// Use a default asset image
                        )
                            :CircleAvatar(
                          radius: 20.0,
                          backgroundImage: AssetImage('assets/images/profile_image.svg'),// Use a default asset image
                        ),
                        SizedBox(width: 10,),
                        SvgPicture.asset(
                          'assets/images/arrow_dir.svg', // Replace with the path to your SVG file
                          width: 25, // Specify the width
                          height: 25, // Specify the height
                          color: Colors.black, // Change the color if needed
                        ),
                        SizedBox(width: 10,),
                        meetType=='sender'
                            ? CircleAvatar(
                          radius: 20.0,
                          backgroundImage: AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                        )
                            :CircleAvatar(
                          radius: 20.0,
                          backgroundImage:  AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                        ),
                      ],
                    ),

                    SizedBox(height: 15,),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          meetType=='sender'
                              ?Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Trip planning Call with ',style: Theme.of(context).textTheme.subtitle2,),
                                SizedBox(width:5),
                                Container(
                                    // width: 100,
                                    color: Colors.red,
                                    alignment: Alignment.centerLeft,
                                    child: Text('${Constant().extractFirstName(plannerName)}',style:  Theme.of(context).textTheme.subtitle2,))
                              ],
                            ),
                          )
                              :Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Call requested by',style: Theme.of(context).textTheme.subtitle2,),
                              SizedBox(width:5),
                              Container(
                                  width: 100,
                                  alignment: Alignment.centerLeft,
                                  child: Text('${Constant().extractFirstName(plannerName)}',style: Theme.of(context).textTheme.subtitle2,))
                            ],
                          ),
                          SizedBox(height: 17,),
                          Container(
                            // decoration: BoxDecoration(border:Border.all(width: 1)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      child: Image.asset('assets/images/time_icon.png',width: 20,height: 20,),
                                    ),
                                    SizedBox(width: 10,),
                                    Text('${startTime} - ${endTime} \t',style: Theme.of(context).textTheme.headline6),
                                    Text('India',style: Theme.of(context).textTheme.headline6,)
                                  ],
                                ),
                                SizedBox(height: 4,),
                                Row(
                                  children: [
                                    Container(
                                      child: Image.asset('assets/images/calendar.png',width: 20,height: 20,),
                                    ),
                                    SizedBox(width: 10,),
                                    Text('Date ${widget.date} "${convertToDate(widget.date!)}"',style: Theme.of(context).textTheme.headline6),
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
              ),
              SizedBox(height: 22,),
              Container(
                alignment: Alignment.topLeft,
                // decoration: BoxDecoration(border:Border.all(color: Colors.red)),
                child: Text(meetingTitle,style:Theme.of(context).textTheme.subtitle2),
              ),
              SizedBox(height: 28,),
              SizedBox(width: 26,),
              Container(
                // decoration: BoxDecoration(border:Border.all(width: 1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            'Rate your Experience',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        SizedBox(height: 11,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  rating = index + 1;
                                  print('Rating is$rating');
                                });
                              },
                              child: index<rating
                                  ?SvgPicture.asset('assets/images/star-color.svg',width: 40,height: 40,)
                                  :SvgPicture.asset('assets/images/star-no-color.svg',width: 30,height: 30),
                            );
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: 28,),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              child: Text('Additional Feedback',style: Theme.of(context).textTheme.subtitle1)),
                          SizedBox(height: 11,),
                          Container(
                            color: HexColor('#E9EAEB'),
                            padding: EdgeInsets.only(left:10,right:10),
                            height: meetType=='sender'?104:152,
                            child: TextField(
                              cursorColor: Colors.orange,
                              focusNode: _feedbackFocusNode,
                              style: Theme.of(context).textTheme.headline6,
                              onChanged: (value) {
                                textValue = value;
                              },
                              onTapOutside: (value){
                                _feedbackFocusNode.unfocus();
                              },
                              onEditingComplete: (){
                                _feedbackFocusNode.unfocus();
                              },
                              onSubmitted: (value){
                                _feedbackFocusNode.unfocus();
                              },
                              decoration: InputDecoration(
                                hintText: 'Type here........',
                                hintStyle: Theme.of(context).textTheme.subtitle1,
                                // focusColor: Colors.orange,
                                focusedBorder: InputBorder.none,
                              ),
                              maxLines: 50, // Increase the maxLines for a larger text area
                            ),
                          ),

                        ],
                      ),
                    ),
                    meetType=='sender'?SizedBox(height: 23.5,):SizedBox(height: 0,),
                    meetType=='sender'
                        ?Container(
                      height: 1,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black
                        ),
                      ),
                    )
                        :SizedBox(height: 0,),
                    meetType=='sender'?SizedBox(height: 13.5,):SizedBox(height: 0,),
                    meetType=='sender'
                        ?Container(
                      height: 102,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 21,
                              child: Text('Wanna say something to Culturtap ?',style: Theme.of(context).textTheme.subtitle1,)),
                          SizedBox(height: 11,),
                          Container(
                            color: HexColor('#E9EAEB'),
                            height: 70,
                            child: TextField(
                              cursorColor: Colors.orange,
                              style:Theme.of(context).textTheme.headline6,
                              onChanged: (value) {
                                textValue2 = value;
                              },
                              decoration: InputDecoration(
                                hintText: 'Type here........',
                                hintStyle: Theme.of(context).textTheme.subtitle1,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange,
                                  )
                                ),
                              ),
                              maxLines: 50, // Increase the maxLines for a larger text area
                            ),
                          ),

                        ],
                      ),
                    )
                        :SizedBox(height: 0,),
                  ],
                ),
              ),
              meetType=='sender'?SizedBox(height: 32,):SizedBox(height: 50,),
              Container(
                height: 55,
                child: FiledButton(
                    backgroundColor: HexColor('#FB8C00'),
                    onPressed: () async{
                      print('${widget.meetId},${meetType}');
                      await updateMeetingFeedback(meetId,rating,textValue,meetType,userID,startTime,widget.date!,textValue2);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => HomePage(userId: widget.userId,userName: widget.userName,),
                      //   ),
                      // );

                      // Navigator.of(context).pop();
                    },
                    child: Center(
                        child: Text('SUBMIT',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16)))),
              ),
            ],
          ),
        ),
      ):Center(child: CircularProgressIndicator(),),
    );
  }
}


class PaymentDemo extends StatelessWidget {
  String name,merchantName,phone;
  double amount;
  PaymentDemo({required this.name,required this.amount,required this.merchantName,required this.phone});
  Future<void> initPayment({required BuildContext context}) async {
    try {
      // 1. Create a payment intent on the server
      final response = await http.post(Uri.parse('${Constant().serverUrl}/customerPayment'),
          body: {
            'phone':'6971833439',
            'amount': amount.toString(),
            'name':name
          });

      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            merchantDisplayName: merchantName,
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
          ));
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment is successful'),
        ),
      );
    } catch (errorr) {
      print(errorr);
      if (errorr is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured ${errorr.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured $errorr'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
            child: const Text('Pay 20\$'),
            onPressed: () async {
              await initPayment(context: context);
            },
          )),
    );
  }
}