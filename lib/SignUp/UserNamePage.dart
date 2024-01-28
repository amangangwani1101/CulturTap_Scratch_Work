import 'package:flutter/material.dart';
import 'package:learn_flutter/SignUp/FourthPage.dart';

class UserNamePage extends StatefulWidget {
  final String phoneNumber;
  final String userCredId;

  UserNamePage({required this.phoneNumber, required this.userCredId});

  @override
  _UserNamePageState createState() => _UserNamePageState();
}

class _UserNamePageState extends State<UserNamePage> {
  late TextEditingController _userNameController;
  late FocusNode _inputFocusNode;

  @override
  void initState() {
    super.initState();
    _inputFocusNode = FocusNode();
    _userNameController = TextEditingController();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Container(
              padding : EdgeInsets.all(30),

              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 25),
                      child: Image.asset('assets/images/firstPage.png'),
                      height: 250,

                      color: Colors.white,
                    ),
                    SizedBox(height : 20),
                    Container(
                      child : Image.asset('assets/images/SignUp3.png'),
                    ),
                    Container(
                      height : 20,
                    ),

                    Container(
                        margin: EdgeInsets.only(bottom: 31),
                        child: Text('Explore, Update, Guide & Earn !',
                            style: TextStyle(fontSize: 18,  color: Theme.of(context).primaryColorDark))),
                    Text('Please Enter Your',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Text('  Name',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    SizedBox(height : 10),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),


                      height: 64,
                      child: TextField(

                        cursorColor : Theme.of(context).primaryColorDark,
                        style: TextStyle(fontSize: (18  ),color :Color(0xFF001B33) , fontWeight: FontWeight.bold,),textAlign : TextAlign.start,

                        focusNode: _inputFocusNode,
                        controller: _userNameController,
                        decoration: InputDecoration(
                          hintText: 'Ex : Utkarsh Gupta',
                          hintStyle : TextStyle(fontSize : 18,letterSpacing : 2.0,fontWeight : FontWeight.w600,color : Color(0xFFBABABA) ),
                          filled: true,
                          fillColor: Theme.of(context).primaryColorLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), // Updated border radius
                            borderSide: BorderSide.none, // No border
                          ),
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 26.0, horizontal: 20.0),
                        ),
                      ),
                    ), _inputFocusNode.hasFocus ? SizedBox(height: 63) : SizedBox(height: 0),


                  ],
                ),
              ),
            ),
            Positioned(
              bottom : 0, right : 0, left : 0,
              child :  Container(

              height: 63,
              child: FilledButton(
                backgroundColor: Colors.orange,
                onPressed: () async {
                  String name = _userNameController.text.toString();
                  print('userName: $name');

                  if (name.length > 2) {

                    // registerUser();

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FourthPage(userName:_userNameController.text,phoneNumber:widget.phoneNumber,userCredId:widget.userCredId)),
                    );
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
            ),)
          ],
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
