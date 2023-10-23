import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learn_flutter/SignUp/FirstPage.dart';

class splashScreen extends StatefulWidget {
  @override
  State<splashScreen> createState() => _splashScreenState();

}
class _splashScreenState extends State<splashScreen>{

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () {

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FirstPage()));

    });

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:Container(
        width : double.infinity,
        height : double.infinity,
        child : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin:EdgeInsets.only(bottom : 20),
                height : 400,
                width : double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width : 215,
                        child: Image.asset('assets/images/logo.png')
                    ),
                    Container(
                        child : Column(
                          children: [
                            Text('All right reserve to ',style:TextStyle(fontSize : 20)),
                            Text('Culturtap Tourism India Pvt. Ltd.',style:TextStyle(fontSize : 20,fontWeight: FontWeight.bold)),
                          ],
                        )
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


