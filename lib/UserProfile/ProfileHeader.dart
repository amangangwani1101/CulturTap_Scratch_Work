// profile header section -- state1
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:learn_flutter/UserProfile/FinalUserProfile.dart';

import '../BackendStore/BackendStore.dart';
import '../widgets/01_helpIconCustomWidget.dart';
import '../widgets/hexColor.dart';


// AppBar Section
class ProfileHeader extends StatefulWidget {
  final int reqPage;
  final String? imagePath;
  final String? userId,text,userName;
  final VoidCallback? onButtonPressed;
  ProfileDataProvider?profileDataProvider;
  ProfileHeader({required this.reqPage,this.imagePath,this.userId,this.text,this.profileDataProvider,this.userName,this.onButtonPressed});
  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}
class _ProfileHeaderState extends State<ProfileHeader> {
  // notification count will be made dynamic from backend
  int notificationCount = 4;
  @override
  Widget build(BuildContext context) {
    print('Use:${widget.userId}');
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 16,left: 20,right: 20),
        // decoration: BoxDecoration(
        //   border: Border.all(
        //     color: Colors.red,
        //     width: 2,
        //   ),
        // ),
        height: 90,
          // width: 320,
          // margin: EdgeInsets.only(top: 33.0,left:36.0,right: 34.0),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.reqPage<1?
            Container(
              width: 40,
              height: 54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle profile image click
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundImage: widget.imagePath != null
                            ? FileImage(File(widget.imagePath!)) as ImageProvider<Object>?
                            : AssetImage('assets/images/profile_image.png'), // Use a default asset image
                      ),
                    ),
                  ),
                  SizedBox(height: 2,),
                  Text('Profile',style: TextStyle(fontSize: 12,color:Colors.black,fontWeight: FontWeight.w600,fontFamily: 'Poppins',),),
                ],
              ),
            ):
            widget.reqPage!=6 && widget.reqPage!=4 && widget.reqPage!=8
            ? Container(
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //     width: 2,
              //   ),
              // ),
              width: 60,
              height: 30,
              child: GestureDetector(
                onTap: (){
                  if(widget.text=='calendar' || widget.text=='calendarhelper') {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                  else if(widget.text=='chats'){
                    widget.onButtonPressed!();
                  }
                  else if(widget.text=='meetingPings'){
                    print('${widget.userName!}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(userId: widget.userId!,userName: widget.userName!,),
                      ),
                    );
                  }
                  else{
                    Navigator.of(context).pop();
                  }
                },
                child: Image.asset('assets/images/back.png',width: 60,height: 30,),
              ),
            )
            :widget.reqPage==4 || widget.reqPage==6 || widget.reqPage==8 ?SizedBox(width: 30,): SizedBox(height: 0,),
            widget.reqPage>=1
            ? Container(
              child: Image.asset('assets/images/logo.png',width: 160,height: 50,),
            )
            : Container(
              child: Image.asset('assets/images/logo.png',width: 160,height: 50,),
            ),
            widget.reqPage<=1
            ? Container(
              width: 36,
              height: 55,
              // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      print('Us2e:${widget.userId}');
                      if(widget.userId!=null){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PingsSection(userId: widget.userId!,state: 'schedule',),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 35,
                      height: 24,
                      child: Stack(
                        children: [
                          Align(alignment: Alignment.topCenter, child: Image.asset('assets/images/ping_image.png',height: 24 ,width:24,fit: BoxFit.contain,)),
                          if(notificationCount>0)
                            Positioned(
                              top: -4,
                              right: 0,
                              // height: 20,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  notificationCount.toString(),
                                  style: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2,),
                  Text('Pings',style: TextStyle(fontSize: 12,color:Colors.black,fontWeight: FontWeight.w600,fontFamily: 'Poppins'),),
                ],
              ),
            )
            : widget.reqPage==4 || widget.reqPage==8
              ?Container(
              width: widget.reqPage==4? 60:53,
                height: widget.reqPage==4? 40:13,
                child: GestureDetector(
                onTap: (){
                  if(widget.reqPage==4){
                    showDialog(context: context, builder: (BuildContext context){
                      return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: widget.text,navigate: 'pop',onButtonPressed: (){
                        print(2);
                        widget.profileDataProvider?.removeAllCards();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },),);
                    },
                    );
                  }
                  else{
                    Navigator.of(context).pop();
                  }
                },
                child:widget.reqPage==4
                ? Image.asset('assets/images/skip.png',width: 60,height: 30,)
                : Image.asset('assets/images/close_icon.png'),
            ),
              ):SizedBox(width: 30,),

            ],
        ),
      ),
    );
  }
}

