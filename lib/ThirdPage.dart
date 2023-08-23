import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/FourthPage.dart';

class ThirdPage extends StatelessWidget {
  var OTP = TextEditingController();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('THird Page'),
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
                          margin: const EdgeInsets.only(bottom: 35),
                          height: 250,
                          color: Colors.white54),
                      Text('Earn by assisting nearby turists !',style: TextStyle(fontWeight: FontWeight.w200,fontSize: 25,),),
                      Container(
                        width : double.infinity,
                        height : 20,
                      ),

                      Text('ENTER OTP',
                          style: TextStyle(
                              fontSize: 35,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Container(
                          margin: EdgeInsets.only(bottom: 31),
                          child: Text('it should be autofilled or type manually',
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black))),

                      Container(
                        margin: EdgeInsets.only(bottom: 19),
                        width: 300,
                        child:
                        TextField(
                          controller: OTP,

                          decoration: InputDecoration(
                            hintText: 'otp',
                          ),
                        ),
                      ),

                      Container(
                          margin: EdgeInsets.only(bottom: 21),
                          child: Column(
                            children: [
                              Text("Didn't receive it?",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w100)),
                              TextButton(
                                onPressed: () {},
                                child: Text('RESEND !',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 25,
                                    )),
                              )
                            ],
                          )),

                      Container(
                          width: 330,
                          height: 70,
                          child: FilledButton(
                              backgroundColor: Colors.orange,

                              onPressed: () {
                                String OTPP = OTP.text;
                                print('PhoneNumber  : ${OTPP} ');
                                Navigator.push(context, MaterialPageRoute(builder: (context) => FourthPage(),));
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
              )),
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
      ),
      child: child,
    );
  }
}