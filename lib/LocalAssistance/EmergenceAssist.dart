import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        appBar: AppBar(title : ProfileHeader(reqPage: 0,), backgroundColor : Theme.of(context).backgroundColor, automaticallyImplyLeading:false, toolbarHeight: 90, shadowColor: Colors.transparent,),
        body: Container(
          height : double.infinity,
          width : double.infinity,
          color : Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height : 20),
                InkWell(
                  onTap: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EmergenceAssist()),
                    );
                  },
                  child: Container(

                    height : 150,


                    decoration: BoxDecoration(
                      color : Theme.of(context).primaryColorLight,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0),
                          spreadRadius: 0.5,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      // border: Border.all(color: Colors.white30), // Optional: Add border for visual clarity
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,


                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.help_outline,color : Colors.orange),
                                onPressed: () {

                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width : 10),
                              IconButton(
                                icon: SvgPicture.asset('assets/images/police_icon.svg'),
                                onPressed: () {

                                },
                              ),
                              SizedBox(width : 20),
                              Column(
                                crossAxisAlignment : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Police',
                                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,),
                                  ),
                                  Text(
                                    'Get help at your fingertip by Police',
                                    style: Theme.of(context).textTheme.subtitle2,
                                  ),
                                ],
                              ),
                            ],
                          ),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                                onPressed: () {
                                  // Handle bottom icon press
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height : 20),
                InkWell(
                  onTap: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EmergenceAssist()),
                    );
                  },
                  child: Container(

                    height : 150,


                    decoration: BoxDecoration(
                      color : Theme.of(context).primaryColorLight,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0),
                          spreadRadius: 0.5,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      // border: Border.all(color: Colors.white30), // Optional: Add border for visual clarity
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,


                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.help_outline,color : Colors.orange),
                                onPressed: () {

                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width : 10),
                              IconButton(
                                icon: SvgPicture.asset('assets/images/ambulance_icon.svg'),
                                onPressed: () {

                                },
                              ),
                              SizedBox(width : 20),
                              Column(
                                crossAxisAlignment : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ambulance',
                                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,),
                                  ),
                                  Text(
                                    'Request here for your health safety',
                                    style: Theme.of(context).textTheme.subtitle2,
                                  ),
                                ],
                              ),
                            ],
                          ),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                                onPressed: () {
                                  // Handle bottom icon press
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height : 20),
                InkWell(
                  onTap: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EmergenceAssist()),
                    );
                  },
                  child: Container(

                    height : 150,


                    decoration: BoxDecoration(
                      color : Theme.of(context).primaryColorLight,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0),
                          spreadRadius: 0.5,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      // border: Border.all(color: Colors.white30), // Optional: Add border for visual clarity
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,


                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.help_outline,color : Colors.orange),
                                onPressed: () {

                                },
                              ),
                            ],
                          ),
                          Row(

                            children: [
                              SizedBox(width : 10),
                              IconButton(
                                icon: SvgPicture.asset('assets/images/fire_icon.svg'),
                                onPressed: () {

                                },
                              ),
                              SizedBox(width : 20),
                              Column(
                                crossAxisAlignment : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fire & Rescue ',
                                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,),
                                  ),
                                  Text(
                                    'Request here !',
                                    style: Theme.of(context).textTheme.subtitle2,
                                  ),
                                ],
                              ),
                            ],
                          ),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                                onPressed: () {
                                  // Handle bottom icon press
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

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
