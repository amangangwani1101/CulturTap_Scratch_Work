// profile header section -- state1
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:learn_flutter/UserProfile/FinalUserProfile.dart';
import '../BackendStore/BackendStore.dart';
import '../widgets/01_helpIconCustomWidget.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:provider/provider.dart';



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
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.red,
      //     width: 2,
      //   ),
      // ),
      height: 145,

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
                        child: FinalProfile(userId: widget.userId!,clickedId: '652bb97a2310b75ec11cd2ed',),
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
                        height : 30,
                        width : 30,
                        child: CircleAvatar(

                          radius: 20.0,
                          backgroundImage: widget.imagePath != null
                              ? FileImage(File(widget.imagePath!)) as ImageProvider<Object>?
                              : AssetImage('assets/images/profile_image.jpg'), // Use a default asset image
                        ),
                      ),
                      SizedBox(height:2),
                      Text('Profile',style: TextStyle(fontSize: 14,color:Colors.black,fontWeight: FontWeight.w600,fontFamily: 'Poppins',),),
                    ],
                  ),
                ),
              ),

            ],
          ):
          widget.reqPage!=6 && widget.reqPage!=4 && widget.reqPage!=8
              ? Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.black,
            //     width: 2,
            //   ),
            // ),

            width: 75,
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => HomePage(userId: widget.userId!,userName: widget.userName!,),
                    //   ),
                    // );
                  }
                  else{
                    Navigator.of(context).pop();
                  }
                },
                child: Image.asset('assets/images/back.png',width: 60,height: 30,),
              ),
            ),
          )
              : SizedBox(height: 0,),
          widget.reqPage>=1
              ? Image.asset('assets/images/logo.png',width: 145)
              : Image.asset('assets/images/logo.png',width: 145),
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
                        builder: (context) => PingsSection(userId: widget.userId!,),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 80,
                  height: 85,
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.orange,
                  //     width: 2,
                  //   ),
                  // ),
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
                              Align(alignment: Alignment.topCenter, child: Image.asset('assets/images/ping_image.png',height: 27 ,width:24,fit: BoxFit.contain,)),
                              if(notificationCount>0)
                                Positioned(
                                  top: -3,
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
                ),
              ),

            ],
          ) else widget.reqPage==4 || widget.reqPage==8
              ?Container(
            color : Colors.purple,
            width: widget.reqPage==4? 60:13,
            height: widget.reqPage==4? 40:13,
            child: GestureDetector(
              onTap: (){
                if(widget.reqPage==4){
                  showDialog(context: context, builder: (BuildContext context){
                    return Container(
                      color : Colors.brown,
                      child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: widget.text,navigate: 'pop',onButtonPressed: (){
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
                  : Image.asset('assets/images/close_icon.png',width: 13,height: 13,),
            ),
          ):SizedBox(width: 0,),
        ],
      ),
    );
  }
}