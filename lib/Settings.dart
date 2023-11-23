import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/UserProfile/ProfileHeader.dart';
import 'package:learn_flutter/widgets/hexColor.dart';


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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Text('Settings',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold),),
                ),
                Container(
                  height: 680,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 330,
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment. end,
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
                              SizedBox(
                                height: 100,
                                // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                child: IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Container(
                                child: IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Container(
                                child: IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Container(
                                child: IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Container(
                                child: IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Container(
                                child: IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Container(
                                child: IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 330,
                          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1,color: HexColor('#263238').withOpacity(0.3)))),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Container(
                                child: IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11,), onPressed: () {  },),
                              ),
                            ],
                          ),
                        ),

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