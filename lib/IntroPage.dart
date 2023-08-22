import 'package:flutter/material.dart';
import 'package:learn_flutter/loginPage.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar : AppBar(
            title : Text('INTRO'),
        ),
        body:Column(children:[

          Text('WElcome,',style : TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
          SizedBox(
            height : 200,

          ),

    ElevatedButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(title:"homepage"),
    ));
    }, child: Text('click')),

        ])

    );
  }

}

