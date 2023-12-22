import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/LocalAssistance/LocalAssist.dart';

class EmergenceAssist extends StatefulWidget {
  @override
  _EmergenceAssistState createState() => _EmergenceAssistState();
}

class _EmergenceAssistState extends State<EmergenceAssist> {
  @override
  void initState() {
    super.initState();
    // Your initialization code goes here
    print('EmergenceAssist Page initialized');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If you want to prevent the user from going back, return false
        // return false;

        // If you want to navigate directly to the homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LocalAssist()),
        );

        return false; // Returning true will allow the user to pop the page
      },
      child: Scaffold(
        appBar: AppBar(title : ProfileHeader(reqPage: 1,),  automaticallyImplyLeading:false, toolbarHeight: 90, shadowColor: Colors.transparent,),
        body: Container(
          height : double.infinity,
          width : double.infinity,
          color : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height : 20),

              ],
            ),
          ),
        ),
        bottomNavigationBar: AnimatedContainer(
            duration: Duration(milliseconds: 100),


            height:  70 ,
            child: CustomFooter(addButtonAdd: 'add',)
        ),
      ),
    );
  }
}
