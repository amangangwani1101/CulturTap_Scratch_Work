import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/LocalAssistance/EmergenceAssist.dart';
import 'package:learn_flutter/LocalAssistance/LocalAssist2.dart';
import 'package:learn_flutter/LocalAssistance/ChatsPage.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ServiceSections/PingsSection/Pings.dart';
import '../widgets/CustomDialogBox.dart';

class LocalAssist extends StatefulWidget {
  @override
  _LocalAssistState createState() => _LocalAssistState();
}

class _LocalAssistState extends State<LocalAssist> {

  String ?meetId,state;
  bool? eligible;

  bool loaded = false;


  String liveLocation = '';

  @override
  void initState() {
    super.initState();
    // Your initialization code goes here
    localAssistOperation();
  }
  Future<void> localAssistOperation() async{
    await _getUserLocation();
    await checkIsMeetOngoing();
    setState(() {
      loaded = true;
    });
  }


  Future<Map<String, double>> getUserIdsAndDistances(String providedLatitude, String providedLongitude) async {
    final String serverUrl = Constant().serverUrl;
    final Uri uri = Uri.parse('$serverUrl/findUserIdsAndDistancesWithin10Km?providedLatitude=$providedLatitude&providedLongitude=$providedLongitude');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['allUserIdsAndDistances'];

        final Map<String, double> userIdsAndDistances = {};

        data.forEach((item) {
          userIdsAndDistances[item['userId']] = item['distance'].toDouble();
        });
        print('helping hands');
        print(userIdsAndDistances);
        return userIdsAndDistances;
      } else {
        throw Exception('Failed to load data for helping hands');
      }
    } catch (error) {
      print('Error fetching user IDs and distances: $error');
      throw error; // Rethrow the error to propagate it to the calling code
    }
  }


  Future<void> getAndPrintLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark first = placemarks.first;
        String locationName = "${first.country}";
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


  // Function to get user location
  Future<void> _getUserLocation() async {
    setState(() {
      liveLocation = '';
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // Convert latitude and longitude to a string
      String providedLatitude = '${position.latitude}';
      String providedLongiude = '${position.longitude}';


      getAndPrintLocationName(position.latitude, position.longitude);
      getUserIdsAndDistances(providedLatitude, providedLongiude);
      // Update the state with the user location

    } catch (e) {
      print("Error getting location: $e");
      setState(() {

      });
    }
  }

  // check is meeting ongoing
  Future<void> checkIsMeetOngoing()async {
    await PingsAssistanceChecker(userID);
  }

  Future<void> checkIsEligible() async{
    await PingsAssistanceEligible(userID);
  }

  Future<void> PingsAssistanceChecker(userId) async {
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final url = Uri.parse('$serverUrl/checkLocalUserPings/${userId}'); // Replace with your backend URL
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          if(data['meetId']!=null){
            meetId = data['meetId'];
          }
          if(data['state']!=null){
            state = data['state'];
          }
          if(data['eligible']!=null){
            eligible = data['eligible'];
          }
        });
        print('Meeting Ongoing : $meetId');

      } else {
        // Handle error
        print('Failed to fetch dataset: ${response.statusCode}');
      }
    }
    catch(err){
      print('Error $err');
    }
  }

  Future<void> PingsAssistanceEligible(userId) async {
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final url = Uri.parse('$serverUrl/checkLocalUserEligible/${userId}'); // Replace with your backend URL
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

      } else {
        // Handle error
        print('Failed to fetch dataset: ${response.statusCode}');
      }
    }
    catch(err){
      print('Error $err');
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
    return WillPopScope(
      onWillPop: () async {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        return false;
      },
      child: Scaffold(

        appBar: AppBar(title : ProfileHeader(reqPage: 0,userId: userID,),  automaticallyImplyLeading:false, toolbarHeight: 90, shadowColor: Colors.transparent,),


        body: SingleChildScrollView(
          child: Container(
            color : Theme.of(context).backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // SizedBox(height: 20,),
                  state!=null && state!='ongoing'
                      ?Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PingsSection(userId: userID,selectedService: 'Local Assistant',)));
                          },
                          child: Container(
                            width: 328,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.orange),
                            ),
                            padding: EdgeInsets.only(left: 20,right: 20,top: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Ongoing Services',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.orange),),
                                Icon(Icons.arrow_forward_ios,size: 14,color: Colors.orange,),
                              ],
                            ),
                          ),
                        );
                      }
                  )
                      :SizedBox(height: 0,),
                  state!=null && state!='ongoing'
                      ? SizedBox(height : 20)
                      : SizedBox(height: 0,),
                  SizedBox(height : 30),
                  InkWell(
                    onTap: ()async{
                      bool userConfirmed = true;
                      if(eligible!=null && eligible==false){
                        userConfirmed = await showConfirmationDialog(context, userName!);
                        if(userConfirmed){
                          await checkIsEligible();
                        }
                      }
                      if(userConfirmed){
                        if(meetId!=null){
                          print('meet id print krwa rhe hian $meetId');
                          if(state=='user' || state=='ongoing'){
                            await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: userID,
                              state: 'user',
                              meetId: meetId,
                            ),));
                            await checkIsMeetOngoing();
                          }
                          else if(state=='helper'){
                            // toast
                            Fluttertoast.showToast(
                              msg: "Finish Ongoing Services",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                            );
                            await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: userID,
                              state: 'helper',
                              meetId: meetId,
                            ),));
                            await checkIsMeetOngoing();
                          }
                        }
                        else {
                          await Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                ChatsPage(userId: userID,
                                  state: 'user',
                                ),));
                          await checkIsMeetOngoing();
                        }
                      }
                    },
                    child: Container(

                      height : 150,

                      decoration: BoxDecoration(
                        color : Theme.of(context).backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 0.5,
                            blurRadius: 3,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.white30), // Optional: Add border for visual clarity
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,


                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.help_outline,color : Colors.orange),
                                      onPressed: () {

                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  'Immediate Local Assistance',
                                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Get help at your fingertip by locals',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                                      onPressed: () {
                                        // Handle bottom icon press
                                      },
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

                  SizedBox(height : 30),

                  InkWell(
                    onTap: (){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => EmergenceAssist()),
                      );
                    },
                    child: Container(

                      height : 150,

                      decoration: BoxDecoration(
                        color : Theme.of(context).backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 0.5,
                            blurRadius: 3,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        // border: Border.all(color: Colors.white30), // Optional: Add border for visual clarity
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,


                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.help_outline,color : Colors.orange),
                                      onPressed: () {

                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  'Emergency trip assistance',
                                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Police & Ambulence',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                                      onPressed: () {
                                        // Handle bottom icon press
                                      },
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

                  SizedBox(height : 60),

                  Container(




                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,


                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left : 28.0),
                                child: Row(

                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cost of Trip Assistance ',
                                          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                                        ),
                                        liveLocation == '' ? Text('...',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color : Colors.green)) :
                                        Text(
                                          liveLocation =='India' ? '500 INR/Event' : '\$10 Dollar/Event',
                                          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color : Colors.green),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.help_outline,color : Colors.orange),
                                      onPressed: () {

                                      },
                                    ),
                                  ],
                                ),
                              ),

                              Container(

                                child: Padding(
                                  padding: const EdgeInsets.only(left : 28.0, top : 10, right : 28),
                                  child: Column(
                                    children: [
                                      SizedBox(height : 20),
                                      Text(
                                        'Emergency trip assistance is free for public reasons & safety purpose.',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height : 10),
                                      Text(
                                        'You have to pay other cost of items directly to the person , who will helps you there.',
                                        style: TextStyle(fontSize: 14),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height : 50),


                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: AnimatedContainer(
            duration: Duration(milliseconds: 100),


            height:  70 ,
            child: CustomFooter(addButtonAdd: 'add',)
        ),
      ),
    );
  }
}
