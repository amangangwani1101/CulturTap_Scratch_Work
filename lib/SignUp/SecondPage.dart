import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:learn_flutter/SignUp/OtpScreen.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/Utils/BackButtonHandler.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/widgets/Constant.dart';

import '../CustomItems/CostumAppbar.dart';



class SecondPage extends StatefulWidget {

  final TextEditingController? phoneNumberController;

  final String? userName;
  final bool signIn;


  SecondPage({
    this.userName,
    this.phoneNumberController,
    this.signIn = false,




  });

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController _phoneNumberController = TextEditingController();
  String verificationIDReceived = "";
  bool _isPhoneNumberValid = true; // Default to true

  // List of country codes
  List<String> countryCodes = ['+91', '+1', '+44', '+61'];
  String _selectedCountryCode = '+91'; // Default country code

  String userName = '';
  String userPhotoUrl = '';


  // Function to validate phone number using regex
  bool validatePhoneNumber(String input) {
    print('Number : $input');
    final RegExp regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(input);
  }

  BackButtonHandler backButtonHandler10 = BackButtonHandler(
    imagePath: 'assets/images/exit.svg',
    textField: 'Do you want to exit?',
    what: 'exit',
    button1: 'NO',
    button2:'EXIT',
  );




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => backButtonHandler10.onWillPop(context, true),
      child: Scaffold(

        appBar : AppBar(
          title: Center(
            child: Container(
                width: 156, height: 90.6, child: Image.asset('assets/images/logo.png')),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          color : Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 325,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Image.asset('assets/images/secondPage.png'),
                      margin: const EdgeInsets.only(bottom: 35),
                      height: 300,
                      color: Colors.white,
                    ),


                    Container(
                      child : Image.asset('assets/images/SignUp1.png'),
                    ),
                    Container(
                      height : 20,
                    ),
                    //
                    // Text(
                    //   widget.signIn ? 'SIGNIN' : 'SIGNUP',
                    //   style: TextStyle(
                    //       fontFamily: 'Poppins',
                    //       fontSize: 22,
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.bold),
                    // ),
                    Container(
                      margin: EdgeInsets.only(bottom: 31),
                      child: Text(
                        'Start Your Adventure now ! ',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    Text(
                      'Please Enter Your Number',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(height: 20),

                    Container(

                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 0.0),

                      child: Row(
                        children: [
                          // Country code dropdown
                          DropdownButton<String>(
                            value: _selectedCountryCode,
                            onChanged: (String? newValue) {

                              setState(() {

                                _selectedCountryCode = newValue!;
                              });
                            },
                            items: countryCodes
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(width: 5), // Add spacing between the dropdown and input field
                          // Phone number input field
                          Expanded(
                            child: Container(

                              child: TextField(

                                style: Theme.of(context).textTheme.subtitle1,

                                controller: _phoneNumberController,
                                keyboardType: TextInputType.phone,

                                onEditingComplete: () {
                                  // Call the verifyNumber method here
                                  bool isValid = validatePhoneNumber(_phoneNumberController.text);

                                  setState(() {
                                    _isPhoneNumberValid = isValid;
                                  });

                                  if (isValid) {
                                    // For verifying the number using Firebase
                                    verifyNumber(_phoneNumberController.text);
                                  }
                                },


                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none, // No border
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 10.0),
                                  hintText: 'Ex : 9026966203',
                                  errorText: _isPhoneNumberValid ? null : 'Invalid Phone Number',


                                ),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(height: 10),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 325,
                      height: 63,
                      child: FilledButton(
                        backgroundColor: Colors.orange,
                        onPressed: () {
                          bool isValid = validatePhoneNumber(_phoneNumberController.text);

                          setState(() {
                            _isPhoneNumberValid = isValid;
                          });

                          if (isValid) {
                            checkUserInDataBase(_phoneNumberController.text);

                          }
                        },

                        child: Center(
                          child: Text(
                            'Next',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }


  Future<void> checkUserInDataBase(String userNumber) async {

    print('check krne gya hai');
    final apiUrl = '${Constant().serverUrl}/user/$userNumber';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response);

      if (response.statusCode == 200) {
        // If the response status is 200 (OK), parse the JSON data
        final Map<String, dynamic>? data = json.decode(response.body);
        print(data);
        if(data!=null)
          print(data['userName']);


        if (data != null) {
          // Check if 'userName' and 'userPhotoUrl' are not null before updating state
          print(userName + 'hahahah');
          setState(() {
            userName = data['userName'] ?? '';
            userPhotoUrl = data['userPhotoUrl'] ?? '';

            print(userName);
            print(userPhoneNumber);
            print(userPhotoUrl);

            showPopup(userName, userPhotoUrl,userNumber);

            print(userName);
          });

          print('check kar liya');
        } else {
          // Handle the case where the server response is not in the expected format
          setState(() {
            userName = '';
            userPhotoUrl = '';
          });
        }
      } else {
        // If the response status is not 200, handle the error
        final Map<String, dynamic> errorData = json.decode(response.body);

        // Update the state variables to indicate an error condition
        setState(() {
          userName = '';
          userPhotoUrl = '';
        });
      }
    } catch (e) {
      // If an exception occurs during the HTTP request, handle the error
      print('Error: $e');

      // Update the state variables to indicate an error condition
      setState(() {
        userName = '';
        userPhotoUrl = '';
      });
    }
  }
  void showPopup(String userName, String userPhotoUrl, String userNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height : 400,

          child: AlertDialog(
            content: Container(
              height : 300,
              child: Column(



                children: [
                  SizedBox(height : 50),
                Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: Colors.blue, // Container background color
                )),
                  SizedBox(height : 30),


                  // Display the user name
                  Text('Hello',style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16,

                  ),textAlign: TextAlign.center,),
                  Text('$userName',style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16,

                  ),textAlign: TextAlign.center,),
                  SizedBox(height : 20),
                  Center(
                    child: Text('We identify your mobile number is already registered with us, ', style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 16,

                    ),textAlign: TextAlign.center,),
                  )


                  // Display two buttons in a row

                ],

              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);

                    },
                    child: Text(
                      'Not Me',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Remove video logic here

                      verifyNumber(userNumber);
                    },
                    child: Text(
                      "Yes it's Me",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void verifyNumber(String number) {
    auth.verifyPhoneNumber(
      phoneNumber: _selectedCountryCode + number,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen( phoneNumber: number),
            ),
          );
        });
      },
      verificationFailed: (FirebaseAuthException exception) {
        if(exception.code=='invalid-phone-number'){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phone Number is invalid.'),
            ),
          );
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something Went Wrong!'),
            ),
          );
        }
        print(exception.message);
      },
      codeSent: (String verificationID, int? resendToken) {
        setState(() {
          verificationIDReceived = verificationID;
          _isPhoneNumberValid = true;
          print("verification id recieved" + verificationIDReceived);
          // registerUser();
        });
        print('Phoen Number ${number}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(otp: verificationIDReceived,phoneNumber:number),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        setState(() {
          verificationIDReceived = verificationID;
        });
      },
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