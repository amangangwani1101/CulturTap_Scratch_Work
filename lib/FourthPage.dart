import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/ThirdPage.dart';

class FourthPage extends StatelessWidget{
  var Location = TextEditingController();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:Text('fourth page'),
      ),
      body:Center(
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


                      Text('CONFIRM YOUR LOCATION',
                          style: TextStyle(
                              fontSize: 35,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      Container(
                          margin: EdgeInsets.only(bottom: 31),
                          child: Text('Fetched Location',
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black))),

                      Container(
                        margin: EdgeInsets.only(bottom: 19),
                        width: 300,
                        child:
                        TextField(
                          controller: Location,

                          decoration: InputDecoration(
                            hintText: '189/2, Out Side Datia Gate, Jhansi 284001',
                          ),
                        ),
                      ),


                      TextButton(
                        onPressed: () {},
                        child: Text('Edit',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w900,
                              fontSize: 25,
                            )),
                      ),

                      Container(
                          width: 330,
                          height: 70,
                          child: FilledButton(
                              backgroundColor: Colors.orange,

                              onPressed: () {
                                String OTPP = Location.text;
                                print('PhoneNumber  : ${OTPP} ');
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ThirdPage(),));
                              },
                              child: Center(
                                  child: Text('DONE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
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