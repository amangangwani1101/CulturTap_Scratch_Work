// profile header section -- state1
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/CustomItems/CustomPopUp.dart';
import 'package:learn_flutter/CustomItems/ImagePopUpWithTwoOption.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/LocalAssistance/LocalAssist.dart';
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


String profileHeaderOfPage = '';
// AppBar Section
class ProfileHeader extends StatefulWidget {

  int reqPage;
  String? imagePath;
  String? userId,text,userName;
  VoidCallback? onButtonPressed,cancelCloseClick,downloadClick,raiseCloseRequest,helpClicked;
  ProfileDataProvider?profileDataProvider;
  String? profileStatus;
  String? assistMeetId;
  String? tripHelperId;
  String? meetStatus;
  String? requestSend;
  String? state,service;
  String? fromWhichPage;
  String? chatsToWhere,goToHome;
  final String? profileHeaderOfPage;

  ProfileHeader({required this.reqPage,this.service,this.imagePath,this.userId,this.text,this.profileDataProvider,this.profileStatus, this.userName,this.onButtonPressed,this.assistMeetId,this.tripHelperId,this.meetStatus,this.requestSend,this.cancelCloseClick,this.downloadClick,this.state,this.fromWhichPage,this.chatsToWhere,this.profileHeaderOfPage,this.raiseCloseRequest,this.helpClicked,this.goToHome});
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
        widget.imagePath = data['userPhoto'];
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

                            visible: true,
                            child: widget.imagePath != null && widget.imagePath!='' ? CircleAvatar(
                              backgroundImage: FileImage(File(widget.imagePath!)) as ImageProvider<Object>?,
                              // backgroundColor: Colors.transparent,
                              radius: 20.0,

                            )
                                : SvgPicture.asset(
                              'assets/images/profile_icon.svg',
                              color : Theme.of(context).primaryColor,
                              width: 50.0,
                              height: 50.0,
                            ),
                          ),




                        ),
                        SizedBox(height: 2,),
                        Text(Constant().extractFirstName(userName),style: Theme.of(context).textTheme.bodyText1),
                      ]
                  ),
                ),
              ),

            ],
          )
              : widget.reqPage!=6 && widget.reqPage!=4 && widget.reqPage!=8

              ? Container (

            // color: Colors.red,
            width: 70,
            height: 75,

            child: GestureDetector(
              onTap: (){
                if(widget.fromWhichPage=='trip_planning'){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                }
                else if(widget.fromWhichPage=='trip_planning_schedule_profile' || widget.fromWhichPage=='trip_planning_calendar_pings' || widget.fromWhichPage=='trip_planning_chat' || widget.fromWhichPage=='final_profile_edit'){
                  widget.onButtonPressed!();
                }
                else if(widget.fromWhichPage=='local-assistant-call'){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                }
                else if(widget.fromWhichPage == 'yes' ){

                  widget.chatsToWhere == 'local_assist' ?

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LocalAssist(),
                      )) :


                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PingsSection(userId: userID,selectedService: 'Local Assistant', state : 'All Pings',fromWhichPage: 'local-assistant-call')),
                  );

                }




                else if(widget.text=='calendar' || widget.text=='calendarhelper' || widget.text=='edit') {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
                else if(widget.text=='chats'){
                  widget.onButtonPressed!();
                }
                else if(widget.text=='meetingPings' || widget.goToHome=='homePage'){
                  // print('${widget.userName!}');
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
              child: Center(child: Text('< Back ', style : TextStyle(fontSize: 14,fontWeight: FontWeight.w600))),
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
                        builder: (context) => PingsSection(userId: userID,selectedService: widget.fromWhichPage=='local_assist' ? 'Local Assistant' : 'Trip Planning',),
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
          )
              :  widget.service!='trip_planning' && ( widget.meetStatus=='scheduledCloseRequest' || widget.meetStatus=='pending' || widget.meetStatus == 'schedule' || widget.meetStatus=='accept' || widget.meetStatus=='hold_accept' || widget.meetStatus=='close' || widget.meetStatus=='closed') ?
                   Container(  width : 70, height: 80,
            child : PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                // Handle the selected option
                if (value == 'closeRequest') {
                  // Display the custom popup when "Close Request" is selected
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ImagePopUpWithTwoOption(imagePath: 'assets/images/logo.png',textField:  'Are You Sure ?' ,extraText: widget.state=='helper' ? 'You Want To Close This request' : widget.meetStatus=='schedule'?'You Want To Close This Request\nWe hope everything is fine now !':'You Want To Cancel This Request\nWe hope everything is fine now !', what: 'a',
                        meetId:widget.assistMeetId ,helperId: widget.tripHelperId,meetStatus:widget.meetStatus,option2Callback:widget.cancelCloseClick,);
                    },
                  );
                }
                else if (value == 'downloadRecording') {
                  // Handle the "Download Recording" option
                  // ...
                }
                else if (value == 'raiseRequest') {

                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context)
                  // {
                  //   return CustomPopUp(imagePath: '',
                  //       textField: 'Request Raised Successfully',
                  //       extraText: 'Thankyou for your Service',
                  //       what: '',
                  //       button: 'OK');
                  // });

                  widget.raiseCloseRequest!();

                }
                else if(value=='help'){
                  widget.helpClicked!();
                }
              },
              itemBuilder: (BuildContext context) => [
                if(widget.meetStatus!='close' && widget.meetStatus!='closed' && !(widget.state=='helper' && (widget.meetStatus=='accept' || widget.meetStatus=='hold_accept') ))
                  PopupMenuItem<String>(
                  value: (widget.meetStatus=='scheduledCloseRequest' || widget.meetStatus=='schedule') && widget.state=='helper' ? 'raiseRequest' : 'closeRequest',
                  child: Container(
                    child: Row(
                      children: [
                        widget.meetStatus == 'schedule' || widget.meetStatus=='scheduledCloseRequest'  ?
                        Icon(Icons.cancel_schedule_send_rounded, color: widget.meetStatus=='scheduledCloseRequest' && widget.state=='helper' ?Colors.grey.withOpacity(0.5):Colors.grey) : Icon(Icons.close, color: Colors.black),
                        SizedBox(width: 8),
    //                     widget.state == 'helper' ? Text(
    //  widget.meetStatus == 'schedule' ? 'Raise Close Request' :  '',
    // style: Theme.of(context).textTheme.subtitle2,
    // ) :
                        Text(
                         widget.meetStatus=='scheduledCloseRequest' || widget.meetStatus == 'schedule' ? widget.state=='user'? 'Close Request' :'Raise Close Request' :  'Cancel Request',
                          style: widget.meetStatus=='scheduledCloseRequest' && widget.state=='helper'?  TextStyle(fontSize: (14  ),color : Color(0xFF001B33).withOpacity(0.5), fontWeight : FontWeight.w400): Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                ),
                if(widget.meetStatus=='schedule' || widget.meetStatus=='scheduledCloseRequest' )
                  PopupMenuItem<String>(
                    value:'help',
                    child: Container(
                      child: Row(
                        children: [
                          Icon(Icons.help, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Help',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ],
                      ),
                    ),
                  ),
                PopupMenuItem<String>(
                  value: 'downloadRecording',
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.download, color:  widget.meetStatus == 'closed' ? Colors.black :Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Download Recording',
                          style: TextStyle( fontSize : 14, fontWeight:FontWeight.w300,color : widget.meetStatus == 'closed' ? Colors.black :Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              child: Container(
                width: 70,
                height: 80,
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).primaryColorDark,
                  size: 24,
                ),
              ),
            ),



          )
              : widget.service=='trip_planning'
                ? Container(  width : 70, height: 80,
            child : PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                // Handle the selected option
                if (value == 'closeRequest') {
                  // Display the custom popup when "Close Request" is selected
                  if(widget.fromWhichPage=='trip_planning_calendar_pings' || widget.fromWhichPage=='trip_planning_chat'){
                    widget.cancelCloseClick!();
                  }
                  else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ImagePopUpWithTwoOption(imagePath: 'assets/images/logo.png',textField: widget.meetStatus == 'accept' || widget.meetStatus == 'schedule' ? 'You are closing this request ?' : 'Are you sure ?',extraText: widget.meetStatus == 'accept' || widget.meetStatus == 'schedule' ? 'Thank you for using our services !' : 'We hope everything is fine now !', what: 'a',
                          meetId:widget.assistMeetId ,helperId: widget.tripHelperId,meetStatus:widget.meetStatus,option2Callback:widget.cancelCloseClick,);
                      },
                    );
                  }
                } else if (value == 'downloadRecording') {
                  // Handle the "Download Recording" option
                  // ...
                }
                else if (value == 'raiseRequest') {

                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context)
                  // {
                  //   return CustomPopUp(imagePath: '',
                  //       textField: 'Request Raised Successfully',
                  //       extraText: 'Thankyou for your Service',
                  //       what: '',
                  //       button: 'OK');
                  // });

                  widget.raiseCloseRequest!();

                }
              },
              itemBuilder: (BuildContext context) => [
                if(!(widget.state=='helper' && widget.meetStatus=='started') && (widget.meetStatus!='close' && widget.meetStatus!='closed'))
                    PopupMenuItem<String>(
                  value: 'closeRequest',
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Close Request' , style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'downloadRecording',
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.download, color:  widget.meetStatus == 'closed' ? Colors.black :Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Download Recording',
                          style: TextStyle( fontSize : 14, fontWeight:FontWeight.w300,color : widget.meetStatus == 'closed' ? Colors.black :Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              child: Container(
                width: 70,
                height: 80,
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).primaryColorDark,
                  size: 24,
                ),
              ),
            ),



          )
                : Container(height: 70,width: 70,) ,
        ],
      ),
    );
  }
}