import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package
import 'package:learn_flutter/CulturTap/appbar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/LocalAssistance/LocalAssist.dart';
import 'package:learn_flutter/Utils/location_utils.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class LocalAssist2 extends StatefulWidget {
  @override
  _LocalAssist2State createState() => _LocalAssist2State();
}

class _LocalAssist2State extends State<LocalAssist2> {

  String liveLocation = 'Fetching location...';
  List<String>userIds = [];
  List<String>distance = [];
  List<String>suggestedTexts = [
    'Need Mechanical help for my car ',
    'My Vehicle get Puncture  ',
    'My vehicle is out of fuel ',
    'My car battery get discharge ',
    'I need medical assistance ',


  ];
  bool _isUiEnabled = true;
  final TextEditingController _controller = TextEditingController();
  bool pageVisitor = true; // true means person coming to this page is user while in else condition its helper
  bool messageTyping = false;// Default text

  int helpingHands = 0;


  @override
  void initState() {
    super.initState();
    // Your initialization code goes here
    print('LocalAssist2 Page initialized');

    _getUserLocation();
  }


  Future<Map<String, double>> getUserIdsAndDistances(String providedLatitude, String providedLongitude, String userIdToRemove, int vardis) async {
    setState(() {

      print('printingakl lalalalla');
      helpingHands = 10;
    });


    final String serverUrl = Constant().serverUrl;
    final Uri uri = Uri.parse('$serverUrl/findUserIdsAndDistancesWithin10Km?providedLatitude=$providedLatitude&providedLongitude=$providedLongitude&vardis=${vardis}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['allUserIdsAndDistances'];

        final Map<String, double> userIdsAndDistances = {};

        data.forEach((item) {
          userIdsAndDistances[item['userId']] = item['distance'].toDouble();
        });

        // Check if the userIdToRemove exists and remove it
        if (userIdsAndDistances.containsKey(userIdToRemove)) {
          userIdsAndDistances.remove(userIdToRemove);
        }



        print('helping hands');
        setState(() {
          helpingHands = userIdsAndDistances.length;
        });
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
      // Update the state with the user location

      getUserIdsAndDistances(providedLatitude, providedLongiude, userID,12);



    } catch (e) {
      print("Error getting location: $e");
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // If you want to prevent the user from going back, return false
        // return false;

        // If you want to navigate directly to the homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LocalAssist()),
        );

        return false; // Returning true will allow the user to pop the page
      },
      child: Scaffold(
        appBar: AppBar(
          title: ProfileHeader(reqPage: 0),
          automaticallyImplyLeading: false,
          toolbarHeight: 90,
          shadowColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Container(

            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: 20),
                  Text('Immediate Local Assistance',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Get help at your fingertip from locals',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.location_on, color: Colors.black,size: 35,),
                        onPressed: () {},
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Location '),



                            ],
                          ),
                          Text(liveLocation), // Display user location here
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap:(){

                          _getUserLocation();

                        },
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.refresh, color: Colors.orange,size: 25,),
                              onPressed: () {

                              },
                            ),
                            Text('Refresh',style:TextStyle(fontWeight : FontWeight.bold,fontSize:16,color :Colors.orange)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.orange,size: 25,),
                            onPressed: () {},
                          ),
                          Text('Share Location',style:TextStyle(fontWeight : FontWeight.bold,fontSize:16,color :Colors.orange)),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height : 20),
                  helpingHands == 0 ? Container(
                    height : 300,

                    child: Center(
                      child: Text('Finding Helping Hands ...',style : TextStyle(fontSize:16))
                    ),
                  ) :
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height : 20),
                            Row(
                              children: [


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
                                                  child: Text.rich(
                                                    TextSpan(
                                                      text: 'You can find here local assistance immediately, we have found ',
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins', fontSize: 13),
                                                      children: [
                                                        TextSpan(
                                                          text: '$helpingHands helping hands',
                                                          style: TextStyle(fontWeight: FontWeight.bold, ),
                                                        ),
                                                        TextSpan(
                                                          text: ' near you. Please raise a request for help.',
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign: TextAlign.justify,
                                                  ),

                                              ),
                                              Container(
                                                width: 236,
                                                child: Text('Type your request carefully before sending it to the local assistant .',textAlign: TextAlign.justify,
                                                  style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 13,color: Colors.green),),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
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
                                    ):SizedBox(height: 0,),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(child: SizedBox(height: 10,)),
                              ],
                            ),

                            SizedBox(height: 6,),
                          ],
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          height: 70,
          child: CustomFooter(
            addButtonAdd: 'add',
          ),
        ),
      ),
    );
  }
}

