// profile header section -- state1
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/HomePage.dart';
// import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:learn_flutter/UserProfile/FinalUserProfile.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import '../BackendStore/BackendStore.dart';
import '../widgets/01_helpIconCustomWidget.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:provider/provider.dart';

import 'package:flutter_svg/flutter_svg.dart';

// AppBar Section
class ProfileHeader extends StatefulWidget {
  final int reqPage;
  final String? imagePath;
  final String? userId,text,userName;
  final VoidCallback? onButtonPressed;
  ProfileDataProvider?profileDataProvider;
  final String? profileStatus;

  ProfileHeader({required this.reqPage,this.imagePath,this.userId,this.text,this.profileDataProvider,this.profileStatus, this.userName,this.onButtonPressed});
  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}
class _ProfileHeaderState extends State<ProfileHeader> {
  // notification count will be made dynamic from backend
  int notificationCount = 4;
  @override
  Widget build(BuildContext context) {
    print('Use:${widget.userId}');
    return Container(

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.reqPage<1?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              GestureDetector(
                onTap: () {
                  if( widget.profileStatus ==''){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => ProfileDataProvider(),
                          child: ProfileApp(userId: widget.userId, userName: widget.userName),
                        ),
                      ),
                    );
                  }
                  else{
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                        create:(context) => ProfileDataProvider(),
                        child: FinalProfile(userId: userID,clickedId: userID,),
                      ),),
                    );
                  }

                },
                child: Container(

                  width: 80,

                  height: 75,



                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Container(
                        height : 32,
                        width : 32,


                        child: Visibility(

                          visible: widget.imagePath != null,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 20.0,

                          ),
                          replacement: SvgPicture.asset(
                            'assets/images/profile_icon.svg',
                            color : Theme.of(context).primaryColor,
                            width: 50.0,
                            height: 50.0,
                          ),
                        ),




                  ),
                      SizedBox(height: 2,),
                      Text('Profile',style: Theme.of(context).textTheme.bodyText1),
                    ]
                ),
              ),
              ),

            ],
          ):
          widget.reqPage!=6 && widget.reqPage!=4 && widget.reqPage!=8
              ? Container(

            width: 80,

            height: 75,

            child: Container(

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
                        builder: (context) => HomePage(),
                      ),
                    );
                  }
                  else{
                    Navigator.of(context).pop();
                  }
                },
                child: Container(

                  width: 80,

                  height: 75,


                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Container(
                          height : 35,
                          width : 35,


                          child: Visibility(

                            visible: widget.imagePath != null,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 20.0,

                            ),
                            replacement: SvgPicture.asset(
                              'assets/images/profile_icon.svg',
                              width: 40.0,
                              height: 40.0,
                            ),
                          ),




                        ),
                        SizedBox(height: 2,),
                        Text('Profile',style: Theme.of(context).textTheme.bodyText1),
                      ]
                  ),
                ),
              ),
            ),
          )
              : SizedBox(width: 0,),

          widget.reqPage>=1
              ? Image.asset('assets/images/logo.png',width: 155,)
              : Image.asset('assets/images/logo.png',width: 155,),
          if (widget.reqPage<=1) Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: (){
                  print('Us2e:${widget.userId}');
                  if(widget.userId!=null){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PingsSection(userId: userID,),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 80,

                  height: 75,



                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          print('Us2e:${widget.userId}');
                          if(widget.userId!=null){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PingsSection(userId: userID,state: 'schedule',),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Align(alignment: Alignment.topCenter, child: SvgPicture.asset(
                              'assets/images/pings_icon.svg', // Replace with the path to your SVG icon
                              color : Theme.of(context).primaryColor,
                              width: 28,
                              height: 28,



                            ),),
                            if(notificationCount>0)
                              Positioned(
                                top: -3,
                                right: 21,
                                // height: 20,
                                child: Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    notificationCount.toString(),
                                    // style: Theme.of(context).textTheme.headline3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2,),
                      Text('Pings',style: Theme.of(context).textTheme.bodyText1),
                    ],
                  ),
                ),
              ),

            ],
          ) else widget.reqPage==4 || widget.reqPage==8
              ?Container(

            width: widget.reqPage==4? 60:13,
            height: widget.reqPage==4? 40:13,
            child: GestureDetector(
              onTap: (){
                if(widget.reqPage==4){
                  showDialog(context: context, builder: (BuildContext context){
                    return Container(
                      color : Colors.brown,

                      child: CustomHelpOverlay(imagePath: 'assets/images/profile_icon.svg',serviceSettings: false,text: widget.text,navigate: 'pop',onButtonPressed: (){
                        print(2);
                        widget.profileDataProvider?.removeAllCards();

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
                  : Image.asset('assets/images/close_icon.png',width: 13,height: 13,),
            ),
          ):SizedBox(width: 0,),
        ],
      ),
    );
  }
}