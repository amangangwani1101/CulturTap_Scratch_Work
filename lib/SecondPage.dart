import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/ThirdPage.dart';

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
  String verificationIDRecieved = "";
  bool _isPhoneNumberValid = true; // Default to true



  // Function to validate phone number using regex
  bool validatePhoneNumber(String input) {
    final RegExp regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin : EdgeInsets.only(top : 3, left : 40),
          child: Text(

            'CULTURTAP',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w900,
              fontSize: 35,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Container(
            width: double.infinity,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child : Image.asset('assets/images/secondPage.png'),
                      margin: const EdgeInsets.only(bottom: 35),
                      height: 300,
                      color: Colors.white,
                    ),
                    Text(
                      'SIGNUP',
                      style: TextStyle(
                          fontSize: 35,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 31),
                      child: Text(
                        'Start Your Adventure now !',
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                    ),
                    Text(
                      'Please Enter Your Number',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 19),
                      width: 300,
                      child: TextField(
                        controller: widget.phoneNumberController,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          setState(() {
                            _isPhoneNumberValid = true; // Reset to true on change
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '+91 ' + 'Ex : 9026966203',
                          errorText: _isPhoneNumberValid
                              ? null
                              : 'Invalid Phone Number',
                        ),
                      ),
                    ),
                    Container(
                      width: 330,
                      height: 70,
                      child: FilledButton(
                        backgroundColor: Colors.orange,
                        onPressed: () {
                          String number = widget.phoneNumberController.text;
                          bool isValid = validatePhoneNumber(number);

                          //for verifying the number using firebase
                          verifyNumber();

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ThirdPage(),
                          ));

                          setState(() {
                            _isPhoneNumberValid = isValid;
                          });

                          if (isValid) {
                            print('PhoneNumber: $number');
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => ThirdPage()),
                            // );
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
  void verifyNumber(){

    auth.verifyPhoneNumber(
       phoneNumber: widget.phoneNumberController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then((value)=>{
            print("you are logged in successfully")
          });
        },
        verificationFailed: (FirebaseAuthException exception){
          print(exception.message);
        },
        codeSent: (String verificationID, int? resendToken){
         verificationIDRecieved = verificationID;

        },
        codeAutoRetrievalTimeout: (String verificationID){

        }
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
      ),
      child: child,
    );
  }
}
