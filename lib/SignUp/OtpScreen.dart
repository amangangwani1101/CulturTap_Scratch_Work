import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/SignUp/UserNamePage.dart';
import 'package:learn_flutter/SignUp/FourthPage.dart';
import 'package:learn_flutter/UserProfile/ProfileHeader.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../CustomItems/CostumAppbar.dart';
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
  late TextEditingController _otpController;
  String _code = '';

  @override
  void initState() {
    super.initState();


    _otpController = TextEditingController();

    _listenSmsCode();
  }





  @override
  void dispose() {

    SmsAutoFill().unregisterListener();
    _otpController.dispose();


    super.dispose();
  }

  _listenSmsCode() async {
    final String signature = await SmsAutoFill().getAppSignature;
    print('App Signature: $signature');

    SmsAutoFill().listenForCode();
    // SmsAutoFill().codeUpdated((String code) {
    //   setState(() {
    //     _otpController.text = code;
    //   });
    // });
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
          MaterialPageRoute(builder: (context) => UserNamePage(phoneNumber:widget.phoneNumber,userCredId:userCredId)),
        );
      }

    }catch(err){
      print('Error $err');
    }
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(title : ProfileHeader(reqPage: 2, userId:userID),automaticallyImplyLeading:false,toolbarHeight: 90, ),

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
                            margin: const EdgeInsets.only(bottom: 35),
                            height: 300,
                            child : Image.asset('assets/images/thirdPage.png'),
                            color: Colors.white54),
                        Container(
                          child : Image.asset('assets/images/SignUp3.png'),
                        ),
                        Container(
                          height : 20,
                        ),
                        Text('Earn by assisting nearby turists !',style: TextStyle(fontWeight: FontWeight.w200,fontSize: 20,color: Theme.of(context).primaryColorDark),),
                        Container(
                          width : double.infinity,
                          height : 20,
                        ),

                        Text('ENTER OTP',
                            style: TextStyle(
                              fontSize: 24,
                              color:Theme.of(context).primaryColorDark,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            )
                        ),
                        Container(
                            margin: EdgeInsets.only(bottom: 31),
                            child: Text('it should be autofilled or type manually',
                                style: TextStyle(
                                    fontSize: 16,color: Theme.of(context).primaryColorDark))),

                        Center(
                          child: PinFieldAutoFill(
                            codeLength: 6,
                            autoFocus: true,
                            controller: _otpController,
                            currentCode : _code,

                            decoration: UnderlineDecoration(
                              lineHeight: 1,
                              lineStrokeCap: StrokeCap.square,
                              bgColorBuilder: PinListenColorBuilder(
                                  Colors.orange.shade200, Colors.grey.shade200),
                              colorBuilder: const FixedColorBuilder(Colors.transparent),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),



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
                                    ))

                              ],
                            )),

SizedBox(height : 80),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom : 0,right : 0, left : 0,
                child :
                Container(

                    height: 63,
                    child: FilledButton(
                        backgroundColor: Colors.orange,

                        onPressed: () {

                          verifyCode();

                        },
                        child: Center(
                            child: Text('Next',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 25)))
                    )
                ),
              )

            ],
          )),
    );
  }


  late final dynamic authCredential;
  late String userCredId;

  Future<void> verifyCode() async {

    print('Received OTP: ${widget.otp}');
    print('User-Entered OTP:${_otpController.text}');
    String OTPP = widget.otp!;

    // Now you can compare it with the OTP entered by the user
    // OTPs match, proceed with verification
    try{
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: OTPP,
        smsCode: '${_otpController.text}',
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