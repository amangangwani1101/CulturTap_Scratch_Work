import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/LocalAssistance/EmergenceAssist.dart';
import 'package:learn_flutter/LocalAssistance/LocalAssist2.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocalAssist extends StatefulWidget {
  @override
  _LocalAssistState createState() => _LocalAssistState();
}

class _LocalAssistState extends State<LocalAssist> {

  String liveLocation = 'Fetching location...';
  @override
  void initState() {
    super.initState();
    // Your initialization code goes here
    _getUserLocation();
    print('LocalAssist Page initialized');
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
      liveLocation = 'fetching location';
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If you want to prevent the user from going back, return false
        // return false;

        // If you want to navigate directly to the homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        return false; // Returning true will allow the user to pop the page
      },
      child: Scaffold(
        appBar: AppBar(title : ProfileHeader(reqPage: 0,),  automaticallyImplyLeading:false, toolbarHeight: 90, shadowColor: Colors.transparent,),
        body: SingleChildScrollView(
          child: Container(
            color : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height : 20),
                  InkWell(
                    onTap: (){

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LocalAssist2()),
                      );

                    },
                    child: Container(

                      height : 150,

                      decoration: BoxDecoration(
                        color : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 0.5,
                            blurRadius: 3,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.white70), // Optional: Add border for visual clarity
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
                        color : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 0.5,
                            blurRadius: 3,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.white70), // Optional: Add border for visual clarity
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
