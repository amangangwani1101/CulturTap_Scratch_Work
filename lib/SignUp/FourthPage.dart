import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../BackendStore/BackendStore.dart';
import '../CustomItems/CostumAppbar.dart';

class FourthPage extends StatefulWidget {
  final String userName,phoneNumber,userCredId;
  FourthPage({required this.userName,required this.phoneNumber,required this.userCredId});
  @override
  _FourthPageState createState() => _FourthPageState();
}


// firebase cloudstore user model
class UserModel{
  final String uid;
  final String name;
  final int phoneNo;
  final String token;
  final String createdAt;
  final String userMongoId;
  const UserModel({
    required this.name,
    required this.token,
    required this.createdAt,
    required this.phoneNo,
    required this.uid,
    required this.userMongoId
  });

  factory UserModel.fromJson(Map<String,dynamic>json)=>UserModel(
    uid:json['uid'],
    name:json['name'],
    token:json['token'],
    phoneNo:json['phoneNo'],
    createdAt:json['createdAt'],
    userMongoId: json['userMongoId']
  );

  Map<String,dynamic> toJson()=>{
    'uid':uid,
    'name':name,
    'token':token,
    'phoneNo':phoneNo,
    'createdAt':createdAt,
    'userMongoId':userMongoId,
  };
}

class _FourthPageState extends State<FourthPage> {
  var _locationController = TextEditingController();
  bool _isLoading = false;
  String?latitude,longitude,token,userId;
  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  void registerUser() async {


    try {
      final String userName = widget.userName; // Access the userName from the widget
      final String phoneNumber = widget.phoneNumber; // Assuming you have a phoneNumberController

      final Map<String, dynamic> regBody = {
        "userName": userName,
        "phoneNumber": phoneNumber,
        "latitude":latitude!,
        "longitude":longitude!,
        "profileStatus":"low",
        "pings":0,
        "uniqueToken":token==null?'':token!,
      };

      print('Request Body: $regBody');


      final String serverUrl = Constant().serverUrl; // Replace with your server's URL


      final http.Response response = await http.post(
        Uri.parse('$serverUrl/SignUp'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(regBody),
      );

      print('Response: ${response.statusCode} ${response.reasonPhrase}');

      if (response.statusCode == 200) {
        // Request was successful

        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Response Data: ${responseData}');
        userId = responseData['id'];
        // You can handle the response here as needed, e.g., show a success message or navigate to a new page.
      } else {
        // Request failed with a non-200 status code
        print('Request failed with status: ${response.statusCode}');
        print('Response Data: ${response.body}');

        // Handle the error here, e.g., show an error message.
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()),),
      );
      // Handle network or other errors
      print("Error: $error");
    }

    try{
      final FirebaseFirestore _db = FirebaseFirestore.instance;
      print(widget.phoneNumber);
      print(widget.userCredId);
      print(widget.userName);
      var userRef = _db.collection('users').doc(widget.userCredId);
      final current = DateTime.now();

      final String createdAt = '${current.day}/${current.month}/${current.year}';
      token = '';
      print(token);
      final userModel = UserModel(name: widget.userName, token: token==null?'':token!, createdAt: createdAt, phoneNo: int.parse(widget.phoneNumber), uid: widget.userCredId,userMongoId:userId!);

      await userRef.set(userModel.toJson());
    }catch(err){
      print('Error:$err');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString()),),
      );
    }
  }


  String? fullAddress;
  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
    });
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationController.text = "Location permission denied forever.";
        _isLoading = false;
      });
      return;
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        _locationController.text = "Location permission denied.";
        _isLoading = false;
      });
      return;
    }




    Future<String?> fetchAddressFromCoordinates(double latitude, double longitude) async {
      final String apiUrl = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final String address = decoded['display_name'];
          print('Address: $address');
          return address;
        } else {
          print('Failed to fetch address. Status code: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('Error: $e');
        return null;
      }
    }


    try{
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (kIsWeb) {
        fullAddress = await fetchAddressFromCoordinates(position.latitude,position.longitude);
        print('Running on the web');
      } else if (Platform.isAndroid) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          fullAddress = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
          print('AAA::$fullAddress');
        }
        else{
          print('None');
        }
        print('Running on Android');
        // Your Android-specific code here
      } else if (Platform.isIOS) {
        print('Running on iOS');
        // Your iOS-specific code here
      } else {
        print('Running on another platform');
        // Handle other platforms (like macOS, Windows, Linux) if needed
      }
      setState(() {
        _locationController.text = fullAddress!;
        _isLoading = false;
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });



      print("Latitude: ${latitude}");
      print("Longitude: ${longitude}");
      // print('Address: $fullAddress');

    }catch(err){
      setState(() {
        _locationController.text = "Error fetching location: ${err.toString()}";
        _isLoading = false;
      });
    }
    registerUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title:""),
      body: Container(
        height : double.infinity,
        width: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width : 325,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 35),
                    height: 248,
                    width : 389,
                    child : Image.asset('assets/images/fourthPage.png'),
                    color: Colors.white,
                  ),
                  Container(
                    child : Image.asset('assets/images/SignUp4.png'),
                  ),
                  Container(
                    height : 20,
                  ),
                  Text(
                    'CONFIRM YOUR LOCATION',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      fontWeight: FontWeight.w600,),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 31),
                    child: Text(
                      'Fetched Location',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 19),
                    width: 325,
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Fetching location...',
                      ),
                      enabled: false,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _fetchLocation,
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    width: 325,
                    height: 63,
                    child: FilledButton(
                      backgroundColor: Colors.orange,
                      onPressed: () {
                        String fetchedLocation = _locationController.text;
                        print('Location: $fetchedLocation');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: Center(
                        child: Text(
                          'DONE',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilledButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  final Color backgroundColor;

  const FilledButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Updated border radius
        ),
      ),
      child: child,

    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: FourthPage(),
//   ));
// }
