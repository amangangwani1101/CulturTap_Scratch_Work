import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/UserProfile/ProfileHeader.dart';
import 'package:learn_flutter/widgets/hexColor.dart';

import 'ServiceSections/ServiceCards.dart';


void main(){
  runApp(SettingsPage());
}
class SettingsPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 0,),),
        body: Center(
          child: Container(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Text('Settings',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold),),
                ),
                Container(
                  height: 680,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 330,
                          // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 83,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment. center,
                            children: [
                              Container(
                                width:20,
                                height: 20,
                                child: Image.asset('assets/images/profile_image.png'),
                              ),
                              Container(
                                width: 220,
                                child: Text('Edit Profile'),
                              ),
                              IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                            ],
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EditServices(),));
                              },
                              child: Container(
                                width: 330,
                                // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                                height: 83,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment. center,
                                  children: [
                                    Container(
                                      width:20,
                                      height: 20,
                                      child: Image.asset('assets/images/profile_image.png'),
                                    ),
                                    Container(
                                      width: 220,
                                      child: Text('Edit Profile'),
                                    ),
                                    IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                        Container(
                          width: 330,
                          // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 83,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment. center,
                            children: [
                              Container(
                                width:20,
                                height: 20,
                                child: Image.asset('assets/images/profile_image.png'),
                              ),
                              Container(
                                width: 220,
                                child: Text('Edit Profile'),
                              ),
                              IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 83,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment. center,
                            children: [
                              Container(
                                width:20,
                                height: 20,
                                child: Image.asset('assets/images/profile_image.png'),
                              ),
                              Container(
                                width: 220,
                                child: Text('Edit Profile'),
                              ),
                              IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 83,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment. center,
                            children: [
                              Container(
                                width:20,
                                height: 20,
                                child: Image.asset('assets/images/profile_image.png'),
                              ),
                              Container(
                                width: 220,
                                child: Text('Edit Profile'),
                              ),
                              IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 83,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment. center,
                            children: [
                              Container(
                                width:20,
                                height: 20,
                                child: Image.asset('assets/images/profile_image.png'),
                              ),
                              Container(
                                width: 220,
                                child: Text('Edit Profile'),
                              ),
                              IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 83,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment. center,
                            children: [
                              Container(
                                width:20,
                                height: 20,
                                child: Image.asset('assets/images/profile_image.png'),
                              ),
                              Container(
                                width: 220,
                                child: Text('Edit Profile'),
                              ),
                              IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 83,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment. center,
                            children: [
                              Container(
                                width:20,
                                height: 20,
                                child: Image.asset('assets/images/profile_image.png'),
                              ),
                              Container(
                                width: 220,
                                child: Text('Edit Profile'),
                              ),
                              IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 280,
                    height: 113,
                    // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('All right reserve to',style: TextStyle(fontSize: 16,fontFamily: 'Poppins'),),
                        Text('Culturtap Tourism India Pvt. Ltd.',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class EditServices extends StatefulWidget{
  @override
  _EditServicesState createState()=> _EditServicesState();
}

class _EditServicesState extends State<EditServices>{
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 860,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ServiceCard(titleLabel: 'Become a Trip Planner ', serviceImage: 'assets/images/service_card_1.jpg', iconImage: 'assets/images/service_help_1.jpg', subTitleLabel: 'Help others to \nplan their trips.', endLabel: 'Turn youself ON for Becoming \nTrip planner '),
          ServiceCard(titleLabel: 'Become a Trip Assistant for \nother’s journey ', serviceImage: 'assets/images/service_card_2.jpg', iconImage: 'assets/images/service_help_2.jpg', subTitleLabel: 'Assist other \nneedy tourist !', endLabel: 'Turn youself ON for Becoming \nSuperhero as a saviour ! '),
          ServiceCard(titleLabel: 'Become a Local Guide ', serviceImage: 'assets/images/service_card_3.jpg', iconImage: 'assets/images/service_help_3.jpg', subTitleLabel: 'Guide other \nTourists !', endLabel: 'Turn youself ON for Becoming \na smart guide for tourists !'),
        ],
      ),
    );
  }
}
