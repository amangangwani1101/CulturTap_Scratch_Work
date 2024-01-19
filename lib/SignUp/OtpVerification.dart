import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/SignUp/FourthPage.dart';
import 'package:learn_flutter/UserProfile/ProfileHeader.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../HomePage.dart';



class OtpScreen extends StatefulWidget {
  String? otp;
  final String phoneNumber;
  final String? userName;

  OtpScreen({this.otp,this.userName,required this.phoneNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>{
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController(),);
  bool isFilling = false;
  String _code = '123456';


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _listenOtp();
    });

  }


  void _listenOtp() async {
    await SmsAutoFill().listenForCode;
    print("OTP Listen is called: ");
  }


  void autofillOtp() {
    if (widget.otp != null && widget.otp!.length == 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = widget.otp![i];
      }
    }
  }



  @override
  void dispose() {

    SmsAutoFill().unregisterListener();
    print("Unregistered Listener");

    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;



  void checkUserSaved(String phoneNumber,String userCredId) async {
    print('Phoen Number ${widget.phoneNumber},${phoneNumber}');
    try{
      var userQuery = await firestore.collection('users').where('phoneNo',isEqualTo:int.parse(phoneNumber)).limit(1).get();

      if (userQuery.docs.isNotEmpty) {
        var userData = userQuery.docs.first.data();
        String userName = userData['name'];
        String userId = userData['userMongoId'];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
      else{
        print('${widget.userName} , ${widget.phoneNumber} , ${userCredId}');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FourthPage(userName:widget.userName!,phoneNumber:widget.phoneNumber,userCredId:userCredId)),
        );
      }

    }catch(err){
      print('Error $err');
    }
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(

        title:  ProfileHeader(reqPage: 2, userId:userID),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
      ),
      body: Container(
          color : Colors.white,


          child: Stack(
              children : [Center(
                child: SingleChildScrollView(
                  reverse : true,
                  child: Container(
                    width : 325,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                            margin: const EdgeInsets.only(bottom: 35),
                            height: 250,
                            child : Image.asset('assets/images/thirdPage.png'),
                            color: Colors.white54),
                        Container(
                          child : Image.asset('assets/images/SignUp2.png'),
                        ),
                        Container(
                          height : 20,
                        ),
                        Text('Earn by assisting nearby turists !',style: TextStyle(fontWeight: FontWeight.w200,fontSize: 20,),),
                        Container(
                          width : double.infinity,
                          height : 20,
                        ),

                        Text('ENTER OTP',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            )),
                        Container(
                            margin: EdgeInsets.only(bottom: 11),
                            child: Text('it should be autofilled or type manually',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black))),

                        PinFieldAutoFill(
                          decoration: UnderlineDecoration(
                            textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                            colorBuilder: FixedColorBuilder(Colors.black.withOpacity(0.3)),
                          ),
                          currentCode: _code,
                          onCodeSubmitted: (code) {
                            setState((){
                              _code = code;
                            });
                          },
                          onCodeChanged: (code) {
                            setState((){
                              _code  = code!;
                            });

                            if (code!.length == 6) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            }
                          },
                        ),

                        SizedBox(height : 20),

                        Container(
                            margin: EdgeInsets.only(bottom: 21),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Didn't receive it?",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w100)),
                                Text('RESEND !',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    )),
                                SizedBox(height : 63),
                              ],
                            )),

                        isFilling ? SizedBox(height : 63) : SizedBox(height : 0),


                      ],
                    ),
                  ),
                ),
              ),
                Positioned(
                  bottom : 0,
                  right : 0,
                  left : 0,
                  child:  Container(
                      width: 325,
                      height: 63,
                      child: FilledButton(
                          backgroundColor: Colors.orange,

                          onPressed: () {

                            verifyCode();


                            // String OTPP = otpCodeControlloer.text;
                            // print('otp  : ${OTPP} ');
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => FourthPage(),));
                          },
                          child: Center(
                              child: Text('NEXT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20))))
                  ),)
              ]
          )),
    );
  }


  late final dynamic authCredential;
  late String userCredId;  // Declare userCredId here
  Future<void> verifyCode() async {

    print('Received OTP: ${widget.otp}');
    print('User-Entered OTP: ${_code}_code');
    String OTPP = widget.otp!; // Access the OTP passed from the previous page

    // Now you can compare it with the OTP entered by the user
    // OTPs match, proceed with verification
    try{
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: OTPP,
        smsCode:_code,
      );

      authCredential = await auth.signInWithCredential(credential);

      print("You are logged in successfully");
      if (authCredential.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credentials Error'),
          ),
        );
        return;
      }
      userCredId = authCredential.user.uid;
      print(userCredId);
      checkUserSaved(widget.phoneNumber,userCredId);
      // await auth.signInWithCredential(credential).then((value) {
      //   print("you are logged in successfully");
      //   // Navigate to the FourthPage

    } catch(err){
      print('Error is$err');
    }
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