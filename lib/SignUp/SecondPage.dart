import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:learn_flutter/SignUp/OtpScreen.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/Utils/BackButtonHandler.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:sms_autofill/sms_autofill.dart';

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

  late FocusNode _inputFocusNode;




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
  void initState() {
    super.initState();
    _inputFocusNode = FocusNode();
    _inputFocusNode.requestFocus();
  }


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
          toolbarHeight: 90,
        ),
        body: Container(
          color : Colors.white,
          height : MediaQuery.of(context).size.height,
          width: double.infinity,

          child: Stack(
            children: [
              Center(
                child: Container(
                 padding : EdgeInsets.only(left : 22, right : 22),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Image.asset('assets/images/secondPage.png'),
                          margin: const EdgeInsets.only(bottom: 25),
                          height: 250,
                          color: Colors.white,
                        ), 


                        Container(
                          child : Image.asset('assets/images/SignUp1.png'),
                        ),
                        Container(
                          height : 20,
                        ),

                        Container(
                          margin: EdgeInsets.only(bottom: 31),
                          child: Text(
                            'Start Your Adventure now ! ',
                            style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                        Text(
                          'Please Enter Your',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(height: 20),
                        Text(
                          'Mobile Number',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Container(height: 0),
                        // const PhoneFieldHint(),

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
                                    child: Text(value,style : TextStyle(fontSize : 18)),
                                  );
                                }).toList(),
                              ),
                              SizedBox(width: 5), // Add spacing between the dropdown and input field
                              // Phone number input field
                              Expanded(
                                child: Container(

                                  child: TextField(

                                    focusNode: _inputFocusNode,
                                    cursorColor : Theme.of(context).primaryColorDark,


                                    style: TextStyle(fontSize: (18  ),color :Color(0xFF001B33) , fontWeight: FontWeight.bold,),textAlign : TextAlign.start,

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
                                      fillColor: Theme.of(context).primaryColorLight,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide.none, // No border
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 20.0),
                                      hintText: ' Ex : 9876543210',
                                      hintStyle : TextStyle(fontSize : 18,letterSpacing : 2.0,fontWeight : FontWeight.w600,color : Color(0xFFBABABA) ),
                                      errorText: _isPhoneNumberValid ? null : 'Invalid Phone Number',
                                      errorStyle : TextStyle(fontSize : 16),


                                    ),

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _inputFocusNode.hasFocus ? SizedBox(height: 63) : SizedBox(height: 0),






                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom : 0,right : 0, left : 0,
                child :
              Container(
                margin: EdgeInsets.only(top: 10),

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
                      'NEXT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              )
            ]
          ),
        ),
      ),
    );
  }


  Future<void> checkUserInDataBase(String userNumber) async {
    final apiUrl = '${Constant().serverUrl}/user/$userNumber';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response);

      if (response.statusCode == 200) {
        // If the response status is 200 (OK), parse the JSON data
        final Map<String, dynamic>? data = json.decode(response.body);


        if (data != null) {
          // Check if 'userName' and 'userPhotoUrl' are not null before updating state
          print(userName + 'hahahah');
          setState(() {
            userName = data['userName'] ?? '';
            userPhotoUrl = data['userPhotoUrl'] ?? '';

            showPopup(userName, userPhotoUrl,userNumber);

            print(userName);
          });
        } else {
          verifyNumber(userNumber);
          // Handle the case where the server response is not in the expected format
          setState(() {
            userName = '';
            userPhotoUrl = '';
          });
        }
      } else {
        verifyNumber(userNumber);
        // If the response status is not 200, handle the error
        final Map<String, dynamic> errorData = json.decode(response.body);

        // Update the state variables to indicate an error condition
        setState(() {
          userName = '';
          userPhotoUrl = '';
        });
      }
    } catch (e) {
      verifyNumber(userNumber);
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
        return Center(
          child: Container(
            margin : EdgeInsets.only(left : 20, right : 20),
            color :  Theme.of(context).backgroundColor,
            height : 400,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
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
                      Column(
                        children: [
                          Text('Hello',style:Theme.of(context).textTheme.headline2),
                          Text('$userName',style:Theme.of(context).textTheme.headline2),
                        ],
                      ),
                      SizedBox(height : 0),

                      SizedBox(height : 20),
                      Text('We identify your mobile number is\nalready registered with us, ', style:Theme.of(context).textTheme.subtitle2,textAlign : TextAlign.center),

                      SizedBox(height : 20),

                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                },
                                child: Text(
                                  'Not Me',
                                  style: TextStyle(
                                    fontWeight : FontWeight.w300,
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
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
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