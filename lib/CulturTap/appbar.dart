// profile header section -- state1
import 'dart:convert';
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
import 'package:http/http.dart' as http;
import '../widgets/Constant.dart';

// AppBar Section
class ProfileHeader extends StatefulWidget {

  int reqPage;
  String? imagePath;
  String? userId,text,userName;
  VoidCallback? onButtonPressed;
  ProfileDataProvider?profileDataProvider;
  String? profileStatus;




  ProfileHeader({required this.reqPage,this.imagePath,this.userId,this.text,this.profileDataProvider,this.profileStatus, this.userName,this.onButtonPressed});
  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}
class _ProfileHeaderState extends State<ProfileHeader> {
  // notification count will be made dynamic from backend
  int notificationCount = 4;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchDataset() async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userID}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched Data ${data}');
      setState(() {
        widget.userId = userID;
        widget.userName = data['userName'];
        widget.profileStatus = data['profileStatus'];
      });
    } else {
      // Handle error
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Use:${widget.userId}');
    return Container(



      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [



          widget.reqPage<1

              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              InkWell(
                onTap: () async{
                  await fetchDataset();
                  print('Profile Status ${widget.profileStatus}');
                  if( widget.profileStatus ==''){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => ProfileDataProvider(),
                          child: ProfileApp(userId: userID, userName: widget.userName),
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

                  width: 70,

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
          )
              : widget.reqPage!=6 && widget.reqPage!=4 && widget.reqPage!=8

              ? Container (


            width: 70,
            height: 75,

            child: GestureDetector(
              onTap: (){
                if(widget.text=='calendar' || widget.text=='calendarhelper' || widget.text=='edit') {
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
                else if(widget.text=='You are all set'){
                  widget.onButtonPressed!();
                }
                else{
                  Navigator.of(context).pop();
                }
              },
              child: Center(child: Text('< Back ', style : TextStyle(fontSize: 16,fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
            ),
          )
              : widget.reqPage==4 || widget.reqPage==6 || widget.reqPage==8 ?SizedBox(width: 0,): SizedBox(height: 0,),
          widget.reqPage>=1



              ? Column(

            children: [
              SizedBox(height : 5),
              Container(height : 75,child: Center(child: Image.asset('assets/images/logo.png',width: 155,))),
            ],
          )
              :Column(
            children: [
              SizedBox(height : 5),
              Container(height : 75,child: Center(child: Image.asset('assets/images/logo.png',width: 155,))),
            ],
          ),
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
                  width: 70,

                  height: 75,



                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Align(alignment: Alignment.topCenter, child: SvgPicture.asset(
                            'assets/images/pings_icon.svg', // Replace with the path to your SVG icon
                            color : Theme.of(context).primaryColor,
                            width: 28,
                            height: 28,



                          ),),
                          if(notificationCount>0)
                            Positioned(
                              top: -4,
                              right: 18,
                              // height: 20,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  notificationCount.toString(),

                                  style: Theme.of(context).textTheme.button,
                                ),
                              ),
                            ),
                        ],
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
          ):SizedBox(width: 70,),
        ],
      ),
    );
  }
}