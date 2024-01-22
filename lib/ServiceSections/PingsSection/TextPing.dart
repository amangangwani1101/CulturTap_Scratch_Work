import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/Notifications/CustomNotificationMessages.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/Payments/RazorPay.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/Payments/UpiPayments.dart';
import 'package:learn_flutter/widgets/Constant.dart';

import '../../All_Notifications/customizeNotification.dart';
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
  String?text,userName,state;
  String selectedService = 'Local Assistant';
  PingsSection({required this.userId,required this.selectedService,this.text,this.userName,this.state});
  @override
  _PingSectionState createState() => _PingSectionState();
}

class _PingSectionState extends State<PingsSection>{
  late PingsDataStore pingsDataStore;
  VoidCallback? callbacker;
  bool isLoading = true; // Add a boolean flag to indicate loading state
  @override
  void initState() {
    super.initState();
    print('Usss:${widget.userId}');
    fetchDatasets(widget.userId);
    _selectedService = widget.selectedService!;
    initialHandler();
    setState(() {
      _selectedService = 'Local Assistant';
    });
  }





  void callback() {
    print('I am !!');
    _refreshPage(time:0);
  }


  Future<void> initialHandler() async{
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey = Constant().publishableKey;
    Stripe.instance.applySettings();
  }

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
  Future<void> _refreshPage({int time = 2,String state = 'All'}) async {
    // Add your data fetching logic here
    // For example, you can fetch new data from an API
    await Future.delayed(Duration(seconds: time));
    // Update the UI with new data if needed
    setState(() {
      isLoading = false;
      widget.state = state;
      fetchDatasets(widget.userId);
    });
  }


  void cancelMeeting(String date,int index,String status,String otherId,String otherStatus)async{
    try {
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': widget.userId,
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

  String _selectedValue = 'All';
  // String _selectedService='Trip Planning';
  String _selectedService = 'Trip Planning';
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

  void checkStatus(String date,int index,String receiver,String sender,String receiverName,String status) async{
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final Map<String,dynamic> data = {
        'userId': sender,
        'date':date,
        'index':index,
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
        print('Ama ${responseData['status']}');
        if(responseData['status']!=status){
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return ConfirmationDialog(
                  message:'Are You Sure To Cancel Meet With ${receiverName} Scheduled At ${date}',
                  onCancel: () {
                    // Perform action on confirmation
                    Navigator.of(context).pop(); // Close the dialog
                    // Add your action here
                    print('Action cancelled');
                  },
                  onConfirm: () {
                    cancelMeeting(date, index, 'cancel', receiver, 'cancel');
                    // Perform action on cancellation
                    // Add your action here
                    _refreshPage(time:0,state:'Cancelled');
                    print('Action confirmed');
                  },
                );});

        }else{
          if(status=='choose' && responseData['status']=='choose'){
            cancelMeeting(date, index, 'pending', receiver, 'accept');
            _refreshPage(time:0,state:'Pending');
          }
          else{
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meeting Is Cancelled! Refresh Page'),
              ),
            );
          }

        }


        print('$date,$index');
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to Update.Try Again!'),
          ),
        );
        print('Failed to save data: ${response.statusCode}');
        return;
      }
    }catch(err){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to Update.Try Again!'),
        ),
      );
      print('Error:$err');
      return ;
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


  @override
  Widget build(BuildContext context) {
    _selectedValue = 'All';
    final screenWidth = MediaQuery.of(context).size.width;
    // callback();
    return WillPopScope(
      onWillPop: ()async{
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
        return true;
      },
      child: Scaffold(

        appBar: AppBar(title: ProfileHeader(reqPage: 1 ,text: widget.text,userName:widget.userName),automaticallyImplyLeading: false,backgroundColor: Theme.of(context).primaryColorLight, shadowColor: Colors.transparent, toolbarHeight: 90,),
        body: !isLoading
            ? RefreshIndicator(
          onRefresh: ()=>_refreshPage(),
          child: Stack(
            children: [



              Container(
                color : Theme.of(context).backgroundColor,

                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 150,),

                      if(toggle == false)
                        if(_selectedService=='Trip Planning')
                          Column(
                            children: List.generate(pingsDataStore.meetData.length, (index)  {
                              final date = pingsDataStore.meetData.keys.elementAt(index);
                              final meetDetails = pingsDataStore.meetData[date];
                              print('2::${date}');
                              print('2::${meetDetails}');
                              return Container(
                                child: Column(
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
                                    return Container(
                                      child:
                                      ((_selectedValue == 'Scheduled' && meetStatus =='schedule') ||
                                          (_selectedValue == 'Accepted' && meetStatus =='accept')||
                                          (_selectedValue == 'Pending' && meetStatus =='pending')||
                                          (_selectedValue == 'Closed' && meetStatus =='close')||
                                          (_selectedValue == 'Cancelled' && meetStatus =='cancel')||
                                          _selectedValue =='All')
                                          ? Container(
                                        padding: EdgeInsets.only(top:10,bottom:20),

                                        margin: EdgeInsets.only(bottom: 40),
                                        decoration: BoxDecoration(
                                          color: Colors.white, // Container background color
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.4), // Shadow color
                                              spreadRadius: 0.5, // Spread radius
                                              blurRadius: 0.3, // Blur radius
                                              offset: Offset(0, 1),  // Changes the position of the shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10,),
                                            Center(
                                              child: Container(
                                                width:screenWidth*0.73,
                                                height: 36,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        meetType=='sender'
                                                            ? CircleAvatar(
                                                          radius: 20.0,
                                                          backgroundImage: pingsDataStore.userPhotoPath != null && pingsDataStore.userPhotoPath != ''
                                                              ? FileImage(File(pingsDataStore.userPhotoPath)) as ImageProvider<Object>?
                                                              : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                                        )
                                                            :CircleAvatar(
                                                          radius: 20.0,
                                                          backgroundImage: userPhoto!= null && userPhoto!= ''
                                                              ? FileImage(File(userPhoto)) as ImageProvider<Object>?
                                                              : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                                        ),
                                                        SizedBox(width: 6,),
                                                        Image.asset('assets/images/arrow_dir.png'),
                                                        SizedBox(width: 6,),
                                                        meetType=='sender'
                                                            ? CircleAvatar(
                                                          radius: 20.0,
                                                          backgroundImage: userPhoto!= null && userPhoto!= ''
                                                              ? FileImage(File(userPhoto)) as ImageProvider<Object>?
                                                              : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                                                        )
                                                            :CircleAvatar(
                                                          radius: 20.0,
                                                          backgroundImage: pingsDataStore.userPhotoPath != null && pingsDataStore.userPhotoPath != ''
                                                              ? FileImage(File(pingsDataStore.userPhotoPath)) as ImageProvider<Object>?
                                                              : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
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
                                                        style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
                                                      ),
                                                    )
                                                        : meetStatus=='accept'
                                                        ? Container(
                                                      color: HexColor('FB8C00'), // Background color red
                                                      height: 16  , // Height set to 16
                                                      constraints: BoxConstraints(
                                                        minWidth: 0,
                                                        maxWidth: double.infinity, // Adjust width according to text
                                                      ),
                                                      child: Text('   '+
                                                          'Accepted'+'   ',
                                                        style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
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
                                                        style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
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
                                                        style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15,),
                                            meetType=='sender'
                                                ?Center(
                                              child: Container(
                                                width: screenWidth*0.71,
                                                height:21,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('Trip planning Call with',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w500),),
                                                    Text('${userName}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                                                  ],
                                                ),
                                              ),
                                            )
                                                :Container(
                                              width: screenWidth*0.70,
                                              height:21,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Call requested by',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w500),),
                                                  Text('${userName}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 15,),
                                            Center(
                                              child: Container(
                                                width:screenWidth*0.72 ,
                                                height: 22,
                                                child: Row(
                                                  // mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      child: Image.asset('assets/images/time_icon.png',width: 22,height: 22,),
                                                    ),
                                                    Text(' ${startTime} - ${endTime} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                                    Text('India',style: TextStyle(fontSize:14,fontFamily: 'Poppins'),)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 4,),
                                            Container(
                                              width: screenWidth*0.72,
                                              // decoration: BoxDecoration(border:Border.all(width: 1)),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: Image.asset('assets/images/calendar.png',width: 22,height: 22,),
                                                  ),
                                                  Text(' Date ${date} "${convertToDate(date)}"',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 7,),
                                            Container(
                                              width: screenWidth*0.71,
                                              // decoration: BoxDecoration(border:Border.all(width: 1)),
                                              height: 24,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(meetTitle==''?'Please Enter Tile Next Time':meetTitle,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
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
                                                onTap: ()  {
                                                  checkStatus(date,index,userId,widget.userId,userName,'cancel');
                                                  print('$date,$index');
                                                },
                                                child: Container(width:screenWidth*0.72,child: Center(child: Text('Cancel',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),)),))
                                                :(meetStatus=='pending' && meetType=='receiver')
                                                ?Container(width:screenWidth*0.72,child: Text('*User need to unlock calendar before complete \n call scheduled.Please wait for event. ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300,fontFamily: 'Poppins',color: HexColor('#FF0000')),),)
                                                :(meetStatus=='choose')
                                                ? Container(
                                              width:screenWidth*0.70,
                                              // decoration: BoxDecoration(border:Border.all(width:1)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                      onTap: (){
                                                        checkStatus(date,index,userId,widget.userId,userName,'cancel');
                                                        print('$date,$index');
                                                      },
                                                      child: Container(child: Text('Cancel',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),),)),
                                                  SizedBox(width: screenWidth*0.17,),
                                                  InkWell(
                                                      onTap: (){
                                                        checkStatus(date, index, userId, widget.userId, userName, 'choose');
                                                        print('$date,$index');
                                                      },
                                                      child: Container(child: Text('Accept',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),),)),
                                                ],
                                              ),
                                            )
                                                :(meetStatus=='accept')
                                                ?Container(
                                              width: screenWidth*0.73,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                      onTap: (){
                                                        checkStatus(date,index,userId,widget.userId,userName,'cancel');
                                                        print('$date,$index');
                                                      },
                                                      child: Container(child: Text('Cancel',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),),)),
                                                  SizedBox(width: screenWidth*0.08,),
                                                  // InkWell(
                                                  //     onTap: ()async{
                                                  //       bool res = await Navigator.push(
                                                  //         context,
                                                  //         MaterialPageRoute(
                                                  //           builder: (context) => UpiPayments(name:pingsDataStore.userName,merchant:userName,amount:100000.0,phoneNo:generateRandomPhoneNumber()),
                                                  //         ),
                                                  //       );
                                                  //       if(res){
                                                  //         paymentHandler(pingsDataStore.userName,userName,100000.0,generateRandomPhoneNumber());
                                                  //         cancelMeeting(date,index,'schedule',userId,'schedule');
                                                  //         _refreshPage(time:0,state:'Scheduled');
                                                  //         print('$date,$index');
                                                  //       }else{
                                                  //         ScaffoldMessenger.of(context).showSnackBar(
                                                  //           const SnackBar(
                                                  //             content: Text('Try Again!'),
                                                  //           ),
                                                  //         );
                                                  //       }
                                                  //     },
                                                  //     child: Container(child: Text('Unlock Calendar',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#0A8100')),),)),
                                                ],
                                              ),
                                            )
                                                :(meetStatus=='schedule')
                                                ?InkWell(
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ScheduledCalendar(date:date,userId:widget.userId,meetDetails:meetDetails,index:index,callbacker:()=>_refreshPage(time:0,state: 'Closed')),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: screenWidth*0.70,
                                                child: Center(child: Text('Go To Calendar',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
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
                                                    builder: (context) => RateFeedBack(pingsCallback:callback,index:index,userPhoto: pingsDataStore.userPhotoPath,userName:userName,startTime:startTime,endTime:endTime,date:date,meetTitle:meetTitle,meetType:meetType,meetId:meetId,userId:widget.userId),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: screenWidth*0.70,
                                                child: Center(child: Text('Give Us A Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                              ),
                                            )
                                                :SizedBox(height:0),
                                          ],
                                        ),
                                      ):SizedBox(height:0),
                                    );
                                  }),
                                ),
                              );
                            }),
                          ),


                      if(toggle == true)
                        if(_selectedService=='Local Assistant')
                          Column(
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
                                    (_selectedValue == 'Accepted' && meetStatus =='accept')||
                                    (_selectedValue == 'Pending' && meetStatus =='pending')||
                                    (_selectedValue == 'Closed' && meetStatus =='close')||
                                    (_selectedValue == 'Cancelled' && meetStatus =='cancel')||
                                    _selectedValue =='All')
                                    ? GestureDetector(
                                  onTap: ()async{
                                    await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: widget.userId,
                                      state: widget.userId==userId?'user':'helper',
                                      meetId: meetId,
                                    ),));
                                    _refreshPage();
                                  },
                                  child: Container(

                                    padding: EdgeInsets.all(18),
                                    margin: EdgeInsets.only(left:12,right:15,top:10,bottom:20),
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Container background color
                                      borderRadius: BorderRadius.circular(3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.4), // Shadow color
                                          spreadRadius: 0.5, // Spread radius
                                          blurRadius: 0.3, // Blur radius
                                          offset: Offset(0, 1),  // Changes the position of the shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding:EdgeInsets.only(top:10,bottom:20),
                                          child: Text('Immediate Local Assistant',style:Theme.of(context).textTheme.subtitle1),
                                        ),
                                        Container(

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
                                                    backgroundColor: Colors.white,
                                                    backgroundImage: userPhoto!= null
                                                        ? FileImage(File(userPhoto)) as ImageProvider<Object>?
                                                        : AssetImage('assets/images/profile_image.png'),// Use a default asset image
                                                  )
                                                      :CircleAvatar(
                                                    radius: 20.0,
                                                    backgroundColor: Colors.white,
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
                                                  style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
                                                ),
                                              )
                                                  : meetStatus=='accept'
                                                  ? Container(
                                                color: HexColor('FB8C00'), // Background color red
                                                height: 16  , // Height set to 16
                                                constraints: BoxConstraints(
                                                  minWidth: 0,
                                                  maxWidth: double.infinity, // Adjust width according to text
                                                ),
                                                child: Text('   '+
                                                    'Accepted'+'   ',
                                                  style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
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
                                                  style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
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
                                                  style: TextStyle(color: Colors.white,fontSize: 10), // Text color white
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 18,),
                                        userName!=''
                                            ? userId==widget.userId
                                            ?Container(
                                          height:21,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text('Meesage With',style: Theme.of(context).textTheme.subtitle2,),
                                              SizedBox(width:3),
                                              Text('${userName}',style: Theme.of(context).textTheme.subtitle2,),
                                            ],
                                          ),
                                        )
                                            :Container(
                                          height:21,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text('Meesage From',style: Theme.of(context).textTheme.subtitle2,),
                                              SizedBox(width:3),
                                              Text('${userName}',style: Theme.of(context).textTheme.subtitle2,),
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
                                                await updateMeetingChats(meetId!,['','admin-cancel']);
                                                await updatePaymentStatus('close',meetId);
                                                _refreshPage();

                                              } else {
                                                // User canceled, do something else
                                                print('User canceled');
                                              }
                                            },
                                            child: Center(child: Container(child: Text('Cancel',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Theme.of(context).floatingActionButtonTheme.backgroundColor),),)))
                                            :(meetStatus=='pending' && userId!=widget.userId)
                                            ?Center(child: Container(child: Text('*Payment Pending. Please wait for event. ',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,fontFamily: 'Poppins',color: HexColor('#FF0000')),),))
                                            :(meetStatus=='accept')
                                            ?Container(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              InkWell(
                                                  onTap: ()async{
                                                    bool userConfirmed = await showConfirmationDialog(context, userName!);
                                                    if (userConfirmed) {
                                                      // User confirmed, do something
                                                      print('User confirmed');
                                                      await updateLocalUserPings(userId, meetId, 'cancel');
                                                      await updateLocalUserPings(helperId!, meetId, 'cancel');
                                                      await updateMeetingChats(meetId!,['','admin-cancel']);
                                                      await updatePaymentStatus('close',meetId);
                                                      _refreshPage();
                                                      sendCustomNotificationToUsers([helperId!], localAssistantMeetCancel(pingsDataStore.userName));
                                                    } else {
                                                      // User canceled, do something else
                                                      print('User canceled');
                                                    }
                                                  },
                                                  child: Container(child: Text('Cancel',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Theme.of(context).floatingActionButtonTheme.backgroundColor),),)),
                                              // SizedBox(width: screenWidth*0.08,),
                                              InkWell(
                                                  onTap: ()async{
                                                    // payment ka funda
                                                    bool res = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => RazorPayIntegration(),
                                                      ),
                                                    );
                                                    if(res){
                                                      await updateLocalUserPings(userId, meetId, 'schedule');
                                                      await updateLocalUserPings(helperId!, meetId, 'schedule');
                                                      await updatePaymentStatus('pending',meetId);
                                                      await updateMeetingChats(meetId!,['','admin-helper-1']);
                                                      await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: widget.userId,
                                                        state: widget.userId==userId?'user':'helper',
                                                        meetId: meetId,
                                                      ),));
                                                      _refreshPage();
                                                      sendCustomNotificationToUsers([helperId!], localAssistantHelperPay(pingsDataStore.userName, meetId));
                                                    }else{
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Payment is UnSuccessful'),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Container(child: Text('Pay Charge',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#0A8100')),),)),

                                            ],
                                          ),
                                        )
                                            :(meetStatus=='choose')
                                            ?InkWell(
                                            onTap: ()  async{
                                              //   Accept ka funda
                                              await updateLocalHelperPings(meetId, 'pending');
                                              await createUpdateLocalUserPings(userId ,meetId, 'accept',pingsDataStore.userName,pingsDataStore.userPhotoPath);
                                              await updateMeetingChats(meetId,[userID,'admin-user-1']);
                                              await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: widget.userId,
                                                state: 'helper',
                                                meetId: meetId,
                                              ),));
                                              _refreshPage();
                                              sendCustomNotificationToUsers([userId],localAssistantHelperAccepted(userName!, meetId));
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
                                            width: screenWidth*0.70,
                                            child: Center(child: Text('Give Us A Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),)),
                                          ),
                                        )
                                            :(meetStatus=='schedule')
                                            ? InkWell(
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
                          ) ,

                    ],
                  ),
                ),
              ),

              Positioned(
                top: 0,left: 0, right: 0,


                child: Container(
                  padding : EdgeInsets.only(left : 15, right : 15),


                  color:  Theme.of(context).backgroundColor,
                  child: Column(

                    children: [
                      SizedBox(height: 20,),

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
                                        color: toggle?HexColor('#FB8C00'): Theme.of(context).backgroundColor, // Choose the color you want for the bottom border
                                        width: 2.0, // Adjust the width of the border
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom : 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text('Requests',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold,color:toggle?HexColor('#FB8C00'):Colors.black),),
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
                                                color: Colors.white,
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
                                        color: !toggle?HexColor('#FB8C00'): Theme.of(context).backgroundColor, // Choose the color you want for the bottom border
                                        width: 2.0, // Adjust the width of the border
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom : 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text('Notification',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold,color: !toggle?HexColor('#FB8C00'):Colors.black),),
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
                                                color: Colors.white,
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
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),

                      Container(
                        padding: EdgeInsets.only(left:15,right:20),
                        // width: screenWidth*0.85,
                        // height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [

                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 35,

                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: HexColor('#FB8C00')
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: DropdownButton<String>(

                                      elevation: 1,

                                      dropdownColor: Theme.of(context).backgroundColor,
                                      value: _selectedService,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedService = newValue!;
                                        });
                                      },
                                      items: <String>['Trip Planning', 'Local Assistant']
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,style:  TextStyle(color: Colors.orange,fontSize: 14,fontFamily: 'Poppins'),),);
                                      }).toList(),

                                      // Change the dropdown text style
                                      underline: Container(), // Hide the underline
                                      icon: Icon(Icons.keyboard_arrow_down, color: HexColor('#FB8C00')), // Change the dropdown icon
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 35,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      boxShadow: null,

                                      border: Border.all(
                                          color: HexColor('#FB8C00')
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: DropdownButton<String>(
                                      dropdownColor: Theme.of(context).backgroundColor,
                                      elevation: 1,

                                      value: _selectedValue,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedValue = newValue!;
                                        });
                                      },
                                      items:  <String>['All','Scheduled', 'Accepted', 'Pending' , 'Closed','Cancelled']
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,style:  TextStyle(color: Colors.orange,fontSize: 14,fontFamily: 'Poppins'),),
                                        );
                                      }).toList(),

                                      underline: Container(), // Hide the underline
                                      icon: Icon(Icons.keyboard_arrow_down, color: HexColor('#FB8C00')),
                                      // Change the dropdown icon
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )


                    ],
                  ),
                ),
              ),
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
  dynamic meetDetails;
  VoidCallback? callbacker;
  int index;
  ScheduledCalendar({required this.date,required this.userId,required this.meetDetails,required this.index,this.callbacker});
  @override
  _ScheduledCalendarState createState() =>  _ScheduledCalendarState();
}

class _ScheduledCalendarState extends State<ScheduledCalendar>{

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



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    List<String> parts = widget.date.split('/'); // Split the string by '/'
    String useDate = '${parts[0]}/${parts[1]}'; // Concatenate the parts as needed
    String date=widget.date,userId=widget.userId;
    dynamic meetDetails=widget.meetDetails;
    String startTime= meetDetails['meetStartTime'][widget.index];
    String endTime= meetDetails['meetEndTime'][widget.index];
    String meetId = meetDetails['meetingId'][widget.index];
    String meetType = meetDetails['meetingType'][widget.index];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 1,),automaticallyImplyLeading: false,backgroundColor: Colors.white,shadowColor: Colors.transparent,),
        body: SingleChildScrollView(
          child: Row(
            children: [
              SizedBox(width: 35,),
              Container(
                width: screenWidth*0.90,
                // decoration: BoxDecoration(border:Border.all(width: 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25,),
                    Text('Scheduled Calendar',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,fontFamily: 'Poppins'),),
                    SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,fontFamily: 'Poppins')),
                        Container(
                          width:120,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: HexColor('#FB8C00')
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 10,),
                              Image.asset('assets/images/calendar.png',color: HexColor('#FB8C00'),),
                              SizedBox(width: 10,),
                              Text('${useDate}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),)
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Column(
                      children: [
                        Text('Planned Call',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,fontFamily: 'Poppins')),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Column(
                      children:[
                        Container(
                          width: screenWidth<400?screenWidth*0.80:340,
                          child: Column(
                            children:[Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white, // Container background color
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4), // Shadow color
                                    spreadRadius: 0.5, // Spread radius
                                    blurRadius: 0.3, // Blur radius
                                    offset: Offset(0, 1),  // Changes the position of the shadow
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
                                      builder: (context) => ChatApps(callbacker:widget.callbacker,senderId:userId,receiverId:'',meetingId:meetId,date:date,index:widget.index,currentTime:setDateTime(date, startTime)),
                                    ),
                                  )
                                      :Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatApps(callbacker:widget.callbacker,senderId:'',receiverId:userId,meetingId:meetId,date:date,index:widget.index,currentTime:setDateTime(date, startTime)),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 10,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width:screenWidth<400?screenWidth*0.75:320,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${startTime} - ${endTime} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                              Container(
                                                child: Image.asset('assets/images/arrow_fwd.png',width: 25,height: 25,),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text('Trip Planning call with customer',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),],
                          ),
                        ),
                      ],),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RateFeedBack extends StatefulWidget{
  String?userPhoto,userName,startTime,endTime,date,meetTitle,meetType,meetId,userId;
  int?index;
  final VoidCallback? pingsCallback;
  RateFeedBack({this.meetId,this.meetType,this.meetTitle,this.endTime,this.startTime,this.userName,this.date,this.userPhoto,this.userId,this.index,this.pingsCallback});
  @override
  _RateFeedBackState createState() => _RateFeedBackState();
}

class _RateFeedBackState extends State<RateFeedBack>{

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


  void updateMeetingFeedback(String meetingId,int rating,String info,String type,String userId,int index,String date,String info2)async{
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
        widget.pingsCallback!();
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
        'index':index,
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

    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 10,),
            Container(
              width: screenWidth<400?screenWidth*0.80:360,
              height:50,
              // decoration: BoxDecoration(border:Border.all(width: 1)),
              // padding: EdgeInsets.only(left:10,right:10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      height:50,child: Text('\nRate & Feedback.',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
                  Container(
                    height: 35,
                    child: IconButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, icon: Icon(Icons.close)),
                  ),
                ],
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 25,),
                Container(
                  width: screenWidth<400?screenWidth*0.85:360,
                  height: 180,
                  margin: EdgeInsets.only(top:75),
                  // decoration: BoxDecoration(border:Border.all(width: 1)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: screenWidth<400?screenWidth*0.80:370,
                        height: 40,
                        // decoration: BoxDecoration(
                        //   border:Border.all(
                        //     width: 1,
                        //     color: Colors.lightBlue
                        //   ),
                        // ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.meetType=='sender'
                                ? CircleAvatar(
                              radius: 20.0,
                              backgroundImage: widget.userPhoto != null && widget.userPhoto != ''
                                  ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                                  : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                            )
                                :CircleAvatar(
                              radius: 20.0,
                              backgroundImage: (widget.userPhoto!) != null && widget.userPhoto != ''
                                  ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                                  : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                            ),
                            SizedBox(width: 10,),
                            Image.asset('assets/images/arrow_dir.png'),
                            SizedBox(width: 10,),
                            widget.meetType=='sender'
                                ? CircleAvatar(
                              radius: 20.0,
                              backgroundImage: (widget.userPhoto) != null && widget.userPhoto != ''
                                  ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                                  : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                            )
                                :CircleAvatar(
                              radius: 20.0,
                              backgroundImage: (widget.userPhoto) != null && widget.userPhoto != ''
                                  ? FileImage(File(widget.userPhoto!)) as ImageProvider<Object>?
                                  : AssetImage('assets/images/profile_image.jpg'),// Use a default asset image
                            ),
                          ],
                        ),
                      ),


                      Container(
                        height: 85,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.meetType=='sender'
                                ?Container(

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Trip planning Call with',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
                                  Text('${widget.userName!}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                                ],
                              ),
                            )
                                :Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Call requested by',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
                                Text('${widget.userName!}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)
                              ],
                            ),
                            Container(
                              height: 50,
                              // decoration: BoxDecoration(border:Border.all(width: 1)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: Image.asset('assets/images/time_icon.png',width: 20,height: 20,),
                                      ),
                                      SizedBox(width: 5,),
                                      Text('${widget.startTime!} - ${widget.endTime!} \t',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                      Text('India',style: TextStyle(fontWeight: FontWeight.bold,fontSize:14,fontFamily: 'Poppins'),)
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        child: Image.asset('assets/images/calendar.png',width: 20,height: 20,),
                                      ),
                                      SizedBox(width: 5,),
                                      Text('Date ${widget.date!} "${convertToDate(widget.date!)}"',style: TextStyle(fontSize:14,fontFamily: 'Poppins')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenWidth<400?screenWidth*0.80:370,
                        child: Text(widget.meetTitle==''?'Please Enter Tile Next Time':widget.meetTitle!,style: TextStyle(fontSize: 16,fontFamily: 'Poppins'),),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40,),
            Row(
              children: [
                SizedBox(width: 26,),
                Container(
                  // decoration: BoxDecoration(border:Border.all(width: 1)),
                  width: screenWidth<400?screenWidth*0.80:370,
                  height: 333,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height:64,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: screenWidth<400?screenWidth*0.80:370,
                              child: Text(
                                'Rate your Experience',
                                style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              // decoration: BoxDecoration(border:Border.all(width: 1)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        rating = index + 1;
                                        print('Rating is$rating');
                                      });
                                    },
                                    child: Icon(
                                      Icons.star,
                                      color: (index < rating) ? HexColor('#FB8C00') : Colors.grey,
                                      size: 32,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: widget.meetType=='sender'?156:185,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding:EdgeInsets.only(top: widget.meetType=='sender'?23:0),
                                width: screenWidth<400?screenWidth*0.80:370,
                                child: Text('Additional Feedback',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
                            Container(
                              color: HexColor('#E9EAEB'),
                              width: screenWidth<400?screenWidth*0.80:370,
                              height: widget.meetType=='sender'?104:152,
                              child: TextField(
                                style: TextStyle(fontSize: 16,),
                                onChanged: (value) {
                                  textValue = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Type here........',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 5, // Increase the maxLines for a larger text area
                              ),
                            ),

                          ],
                        ),
                      ),
                      widget.meetType=='sender'?SizedBox(height: 5,):SizedBox(height: 0,),
                      widget.meetType=='sender'
                          ?Container(
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black
                          ),
                        ),
                      )
                          :SizedBox(height: 0,),
                      widget.meetType=='sender'?SizedBox(height: 5,):SizedBox(height: 0,),
                      widget.meetType=='sender'
                          ?Container(
                        height: 102,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: screenWidth<400?screenWidth*0.80:370,
                                height: 21,
                                child: Text('Wanna say something to Culturtap ?',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),)),
                            SizedBox(height: 10,),
                            Container(
                              color: HexColor('#E9EAEB'),
                              width: screenWidth<400?screenWidth*0.80:370,
                              height: 70,
                              child: TextField(
                                style: TextStyle(fontSize: 16,),
                                onChanged: (value) {
                                  textValue2 = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Type here........',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 5, // Increase the maxLines for a larger text area
                              ),
                            ),

                          ],
                        ),
                      )
                          :SizedBox(height: 0,),
                    ],
                  ),
                ),
              ],
            ),
            widget.meetType=='sender'?SizedBox(height: 30,):SizedBox(height: 90,),
            Container(
              width: screenWidth<400?screenWidth*0.80:370,
              height: 55,
              child: FiledButton(
                  backgroundColor: HexColor('#FB8C00'),
                  onPressed: () {
                    print('${widget.meetId},${widget.meetType}');
                    updateMeetingFeedback(widget.meetId!,rating,textValue,widget.meetType!,widget.userId!,widget.index!,widget.date!,textValue2);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => HomePage(userId: widget.userId,userName: widget.userName,),
                    //   ),
                    // );

                    Navigator.of(context).pop();
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