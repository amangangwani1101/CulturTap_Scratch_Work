import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:ffi';


import 'package:flutter/material.dart';
import 'package:learn_flutter/userProfile1.dart';
import 'package:learn_flutter/widgets/01_helpIconCustomWidget.dart';
typedef void SetQuote(String? image);
//
//
class SignIn extends StatefulWidget{
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn>{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  TextEditingController _namecontroller = TextEditingController();
  bool isSignedIn = false;

  Future<User?> handleSignIn() async{
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn
          .signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential authResult = await _auth.signInWithCredential(
          credential);
      final User? user = authResult.user;

      if (user != null) {
        setState(() {
          isSignedIn = true;
          _namecontroller.text = user.displayName ?? "";
        });
        return user;
       }
      }catch(e){
        print('Error SignIn With Google: $e');
        return null;
    }
  }

  @override
  void handleManualEntry(){
    setState(() {
      isSignedIn = false;
      _namecontroller.text = "";
    });
  }


  @override
  void dispose(){
    _namecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 120,
        child: Center(
          child: Container(
            width: 360,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Fetch Details From',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.black,
                  //     width: 1,
                  //   ),
                  // ),
                  // width: 40,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap:(){
                            print('Do it');
                            handleSignIn();
                          },
                          child: Column(
                            children: [
                              Container(
                                child: Image.asset('assets/images/gmail_icon.png',width: 27,height: 20,),
                              ),
                              SizedBox(height: 10,),
                              Text('Google',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),)
                            ],
                          ),
                        ),
                        SizedBox(width: 25,),
                        InkWell(
                          onTap:(){print('Do it');},
                          child: Column(
                            children: [
                              Container(
                                child: Image.asset('assets/images/facebook_icon.jpg',width: 22,height: 22,),
                              ),
                              SizedBox(height: 10,),
                              Text('Facebook',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),)
                            ],
                          ),
                        ),
                      ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

}



// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SignIn(),
//     );
//   }
// }
//
// class SignIn extends StatefulWidget {
//   @override
//   _SignInState createState() => _SignInState();
// }
//
// class _SignInState extends State<SignIn> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn googleSignIn = GoogleSignIn();
//
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _phoneController = TextEditingController();
//
//   bool _isSignedIn = false;
//
//   Future<User?> _handleSignIn() async {
//     try {
//       final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
//       final GoogleSignInAuthentication googleSignInAuthentication =
//       await googleSignInAccount!.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );
//
//       final UserCredential authResult = await _auth.signInWithCredential(credential);
//       final User? user = authResult.user;
//
//       if (user != null) {
//         setState(() {
//           _isSignedIn = true;
//           _nameController.text = user.displayName ?? "";
//           _phoneController.text = user.phoneNumber ?? "";
//         });
//       }
//
//       return user;
//     } catch (error) {
//       print("Error signing in with Google: $error");
//       return null;
//     }
//   }
//
//   void _handleManualEntry() {
//     setState(() {
//       _isSignedIn = false;
//       _nameController.text = "";
//       _phoneController.text = "";
//     });
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Google Sign-In Example"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             if (!_isSignedIn)
//               TextField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: "Name"),
//               ),
//             if (!_isSignedIn)
//               TextField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(labelText: "Phone Number"),
//               ),
//             ElevatedButton(
//               onPressed: !_isSignedIn ? _handleManualEntry : null,
//               child: Text("Save"),
//             ),
//             ElevatedButton(
//               onPressed: _isSignedIn ? null : _handleSignIn,
//               child: Text("Sign in with Google"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class HexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex =  "FF" + hex.toUpperCase().replaceAll("#", "");
    return int.parse(formattedHex, radix: 16);
  }
  HexColor(final String hex) : super(_getColor(hex));
}


//
//
class EditQuote extends StatefulWidget{
  final SetQuote setQuote;
  EditQuote({required this.setQuote});

  @override
  _EditQuoteState createState() => _EditQuoteState();
}

class _EditQuoteState extends State<EditQuote>{
  String? _setsQuote;
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 333,
            height: 572,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 303,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text('Quote',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Poppins',),),
                      ),
                      Container(
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: 333,
                  height: 361,
                  color: HexColor('#D9D9D9'),
                  child: TextField(
                    maxLines: null,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText:'Type your quote........',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 20,left: 20, ),
                      hintStyle: TextStyle(color: Colors.black,fontSize: 16,fontFamily: 'Poppins'),
                    ),
                    style: TextStyle(color:Colors.black,fontFamily: 'Poppins',fontSize: 16,),
                  ),
                ),
                Container(
                  width: 326,
                  height: 53,
                  child: FilledButton(
                      backgroundColor: HexColor('#FB8C00'),
                      onPressed: () {
                        setState(() {
                          _setsQuote = _textEditingController.text;
                          widget.setQuote(_setsQuote!);
                        });
                        Navigator.of(context).pop();
                      },
                      child: Center(
                          child: Text('SET QUOTE',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,)))),
                ),
              ],
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
        shape:RoundedRectangleBorder(),
        primary: backgroundColor,
      ),
      child: child,
    );
  }
}

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text("Concentric Circles Example"),
//         ),
//         body: Center(
//           child: ConcentricCircles(),
//         ),
//       ),
//     );
//   }
// }
// }
class ConcentricCircles extends StatefulWidget{
  bool isToggled = false;

  final animationDuration = Duration(milliseconds: 500);
  @override
  _ConcentricCirclesState createState() => _ConcentricCirclesState();
}

class _ConcentricCirclesState extends State<ConcentricCircles> {

  void onPressedHandler() {
    if (widget.isToggled) {
      showDialog(context: context, builder: (BuildContext context){
        return Container(child: CustomHelpOverlay(imagePath: 'assets/images/clock_icon.jpg',serviceSettings: true,),);
      },
    );
    }else {
      (){};
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          widget.isToggled = !widget.isToggled;
        });
        onPressedHandler();
      },
      child: AnimatedContainer(
        width: 90,
        height: 54,
        duration:widget.animationDuration,
        child: Stack(
          children: [
            Center(
              child: Container(
                height: 35,
                width: 77,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: widget.isToggled?HexColor('#FB8C00'):HexColor('#EDEDED'),
                ),
              ),
            ),
            Align(
              alignment: widget.isToggled?Alignment.centerRight:Alignment.centerLeft,
              child:Stack(
                children: [
                  Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 3,
                    left: 3,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.isToggled?HexColor('#128807'):Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HexColor('#FB8C00'),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Container(
              width: 83,
              height: 54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('OFF',style: widget.isToggled?TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white,):TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00'),),),
                  Text('ON',style: widget.isToggled?TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white,):TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#0A8100'),),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
