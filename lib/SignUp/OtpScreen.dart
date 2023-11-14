import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/SignUp/FourthPage.dart';
import '../CustomItems/CostumAppbar.dart';


class OtpScreen extends StatefulWidget {
  String? otp;
  final String userName,phoneNumber;

  OtpScreen({this.otp,required this.userName,required this.phoneNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>{
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController(),);

  @override
  void dispose() {
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  var otpCodeControlloer = TextEditingController();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: CustomAppBar(title:""),
      body: Container(
          width: double.infinity,
          height : double.infinity,
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
                        height: 250,
                        child : Image.asset('assets/images/thirdPage.png'),
                        color: Colors.white54),
                    Container(
                      child : Image.asset('assets/images/SignUp3.png'),
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
                        margin: EdgeInsets.only(bottom: 31),
                        child: Text('it should be autofilled or type manually',
                            style: TextStyle(
                                fontSize: 20, color: Colors.black))),

                    Container(
                      margin: EdgeInsets.only(bottom: 19),

                      width: 325,
                      child :Row(

                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 40,
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (index < 5) {
                                    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                                  } else {
                                    _focusNodes[index].unfocus();
                                  }
                                } else {
                                  if (index > 0) {
                                    FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                                  }
                                }
                              },
                            ),
                          );
                        }),
                      ),


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
                            TextButton(
                              onPressed: () {
                                // Resend login here
                              },
                              child: Text('RESEND !',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  )),
                            )
                          ],
                        )),

                    Container(
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
                                child: Text('Next',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 25))))
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }


  late final dynamic authCredential;
  late String userCredId;  // Declare userCredId here
  Future<void> verifyCode() async {

    print('Received OTP: ${widget.otp}');
    print('User-Entered OTP: ${_controllers.map((controller) => controller.text).join('')}');
    String OTPP = widget.otp!; // Access the OTP passed from the previous page

    // Now you can compare it with the OTP entered by the user
      // OTPs match, proceed with verification
    try{
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: OTPP,
        smsCode: _controllers.map((controller) => controller.text).join(''),
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

      // await auth.signInWithCredential(credential).then((value) {
      //   print("you are logged in successfully");
      //   // Navigate to the FourthPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FourthPage(userName:widget.userName,phoneNumber:widget.phoneNumber,userCredId:userCredId)),
        );
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