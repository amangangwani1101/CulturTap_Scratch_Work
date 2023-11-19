import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/SignUp/OtpScreen.dart';

import '../CustomItems/CostumAppbar.dart';

class PhoneNumberValidator extends StatefulWidget {
  @override
  _PhoneNumberValidatorState createState() => _PhoneNumberValidatorState();
}

class _PhoneNumberValidatorState extends State<PhoneNumberValidator> {
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SecondPage(
      phoneNumberController: _phoneNumberController,
    );
  }
}

class SecondPage extends StatefulWidget {
  final TextEditingController phoneNumberController;

  SecondPage({
    required this.phoneNumberController,
  });

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationIDReceived = "";
  bool _isPhoneNumberValid = true; // Default to true

  // List of country codes
  List<String> countryCodes = ['+91', '+1', '+44', '+61'];
  String _selectedCountryCode = '+91'; // Default country code

  // Function to validate phone number using regex
  bool validatePhoneNumber(String input) {
    final RegExp regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ""),
      body: Container(
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
                    child : Image.asset('assets/images/SignUp2.png'),
                  ),
                  Container(
                    height : 20,
                  ),

                  Text(
                    'SIGNUP',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 31),
                    child: Text(
                      'Start Your Adventure now !',
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
                              controller: widget.phoneNumberController,
                              keyboardType: TextInputType.phone,
                              onChanged: (value) {
                                setState(() {
                                  _isPhoneNumberValid = true; // Reset to true on change
                                });
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
                                errorText:
                                _isPhoneNumberValid ? null : 'Invalid Phone Number',
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

                        String number =
                            _selectedCountryCode + widget.phoneNumberController.text;
                        bool isValid = validatePhoneNumber(widget.phoneNumberController.text);

                        if (isValid) {
                          // For verifying the number using Firebase
                          verifyNumber();
                        }

                        setState(() {
                          _isPhoneNumberValid = isValid;
                        });

                        if (isValid) {
                          print('PhoneNumber: $number');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(otp: verificationIDReceived),
                            ),
                          );
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
    );
  }

  void verifyNumber() {
    auth.verifyPhoneNumber(
      phoneNumber: _selectedCountryCode + widget.phoneNumberController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          print("You are logged in successfully");
        });
      },
      verificationFailed: (FirebaseAuthException exception) {
        print(exception.message);
      },
      codeSent: (String verificationID, int? resendToken) {
        setState(() {
          verificationIDReceived = verificationID;
          print("verification id recieved" + verificationIDReceived);
        });
      },
      codeAutoRetrievalTimeout: (String verificationID) {},
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