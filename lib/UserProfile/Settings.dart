import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/CalendarHelper.dart';
import 'package:learn_flutter/UserProfile/ProfileHeader.dart';
import 'package:learn_flutter/VIdeoSection/Draft/SavedDraftsPage.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/widgets/01_helpIconCustomWidget.dart';
import 'package:learn_flutter/widgets/AlertBox2Option.dart';
import 'package:learn_flutter/widgets/CustomAutoSuggestionDropDown.dart';
import 'package:learn_flutter/widgets/CustomButton.dart';
import 'package:learn_flutter/widgets/hexColor.dart';
import 'package:http/http.dart' as http;
import '../ServiceSections/ServiceCards.dart';
import '../SignUp/FirstPage.dart';
import 'CoverPage.dart';
import 'UserInfo.dart';
import '../widgets/Constant.dart';
import '../widgets/CustomAlertImageBox.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD_Q30r4nDBH0HOpvpclE4U4V8ny6QPJj4",
      authDomain: "culturtap-19340.web.app",
      projectId: "culturtap-19340",
      storageBucket: "culturtap-19340.appspot.com",
      messagingSenderId: "268794997426",
      appId: "1:268794997426:android:694506cda12a213f13f7ab ",
    ),
  );
  runApp(SettingsPage(userId: '655e6f1aaa077c80bc0da471',));
}
class SettingsPage extends StatefulWidget{

  String userId;
  SettingsPage({required this.userId});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String showSubmit = '';
  Map<String, dynamic>? dataset;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    fetchDataset();
  }
  Future<void> fetchDataset() async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${widget.userId}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched Data ${data}');
      setState(() {
        dataset = data;
      });
    } else {
      // Handle error
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }

  String formatDate(DateTime date) {
    // Extract components of the date
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();

    // Concatenate the components in the desired format
    String formattedDate = '$day/$month/$year';

    return formattedDate;
  }

  String formatToSpecialDate(DateTime date) {
    // Define month abbreviations
    List<String> monthAbbreviations = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];

    // Extract components of the date
    String day = date.day.toString().padLeft(2, '0');
    String monthAbbreviation = monthAbbreviations[date.month - 1];

    // Concatenate the components in the desired format
    String formattedDate = '$day $monthAbbreviation';

    return formattedDate;
  }

  void showCustomAlertBox(BuildContext context) {
    showDialog(context: context, builder: (BuildContext context){
      return ImagePopUpWithTwoOption(imagePath: 'assets/images/logout-icon.png',textField: 'Are You Sure ?',extraText: 'You Try To Logout From CulturTap',option1:'Cancel',option2:'Yes',onButton1Pressed: (){
        // Perform action on confirmation
        Navigator.of(context).pop();
      },onButton2Pressed: (){
        Future<void> _signOut() async {
          try {
            await _auth.signOut();
            // Redirect to the login or splash screen after logout
            // For example:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FirstPage()));
          } catch (e) {
            print('Error while logging out: $e');
            // Handle the error as needed
          }
        }
        _signOut();
        Navigator.of(context).pop();
      },);
    },);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title : ProfileHeader(reqPage: 0,userId: userID,),  automaticallyImplyLeading:false, toolbarHeight: 90, shadowColor: Colors.transparent,),
      body: WillPopScope(
        onWillPop: ()async{

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );

          return false;
        },
        child: SingleChildScrollView(
          child: Container(
            color:Theme.of(context).backgroundColor,


            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                // Padding(
                //   padding: const EdgeInsets.only(left : 14.0, top : 5, bottom : 5),
                //   child: Container(
                //     child: Text('Settings',style: Theme.of(context).textTheme.subtitle2,),
                //   ),
                // ),
                // SizedBox(height: 20,),
                Container(

                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Builder(
                            builder: (context) {
                              return GestureDetector(
                                onTap: ()async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(),));
                                  // setState(() {
                                  //   fetchDataset();
                                  // });
                                },
                                child: Container(
                                  width: 330,
                                  // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                  // decoration: BoxDecoration(border: Border(top: BorderSide(width: 0,color: HexColor('#263238').withOpacity(0.3)))),
                                  height: 83,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment. center,
                                    children: [
                                      Container(
                                        width:20,
                                        height: 20,
                                        child: SvgPicture.asset('assets/images/profile_image.svg', color:Theme.of(context).primaryColor),
                                      ),
                                      Container(
                                        width: 220,
                                        child: Text('Edit Profile',style: Theme.of(context).textTheme.subtitle2,),
                                      ),
                                      IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11, color:Theme.of(context).primaryColor), onPressed: () {  },),



                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                        Builder(
                            builder: (context) {
                              return GestureDetector(
                                onTap: ()async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => EditServices(),));
                                  setState(() {
                                    fetchDataset();
                                  });
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
                                        child: SvgPicture.asset('assets/images/services-icon.svg', color:Theme.of(context).primaryColor),
                                      ),
                                      Container(
                                        width: 220,
                                        child: Text('Services',style: Theme.of(context).textTheme.subtitle2,),
                                      ),
                                      IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11, color:Theme.of(context).primaryColor), onPressed: () {  },),

                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                        Builder(
                            builder: (context) {
                              return GestureDetector(
                                onTap: ()async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => EditPayments()));
                                  setState(() {
                                    fetchDataset();
                                  });
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
                                        child: SvgPicture.asset('assets/images/payments-icon.svg', color:Theme.of(context).primaryColor),
                                      ),
                                      Container(
                                        width: 220,
                                        child: Text('Payments',style: Theme.of(context).textTheme.subtitle2,),
                                      ),
                                      IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11, color:Theme.of(context).primaryColor), onPressed: () {  },),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                        dataset?['userServiceTripCallingData']!=null && dataset?['userServiceTripCallingData']['startTimeFrom']!=null
                            ? Builder(
                            builder: (context) {
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CalendarHelper(userName:dataset?['userName']!=null?(dataset?['userName']):'',plans:dataset?['userServiceTripCallingData']['dayPlans']!=null?(dataset?['userServiceTripCallingData']['dayPlans']):{},choosenDate:formatDate(DateTime.now()),startTime:dataset?['userServiceTripCallingData']['startTimeFrom'],endTime:dataset?['userServiceTripCallingData']['endTimeTo'],slotChossen:dataset?['userServiceTripCallingData']['slotsChossen'],date:formatToSpecialDate(DateTime.now())!),
                                    ),
                                  );
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
                                        child: SvgPicture.asset('assets/images/calendar.svg'),
                                      ),
                                      Container(
                                        width: 220,
                                        child: Text('Calendar',style: Theme.of(context).textTheme.subtitle2,),
                                      ),
                                      IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11, color:Theme.of(context).primaryColor), onPressed: () {  },),
                                    ],
                                  ),
                                ),
                              );
                            }
                        )
                            : SizedBox(height: 0,),
                        Builder(
                            builder: (context) {
                              return GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SavedDraftsPage(),
                                    ),
                                  );
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
                                        child: SvgPicture.asset('assets/images/draft-icon.svg', color:Theme.of(context).primaryColor),
                                      ),
                                      Container(
                                        width: 220,
                                        child: Text('Drafts',style: Theme.of(context).textTheme.subtitle2,),
                                      ),
                                      IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11, color:Theme.of(context).primaryColor), onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SavedDraftsPage(),
                                          ),
                                        );
                                      },),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                        Builder(
                            builder: (context) {
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AboutUs(),
                                    ),
                                  );
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
                                        child: SvgPicture.asset('assets/images/about-icon.svg', color:Theme.of(context).primaryColor),
                                      ),
                                      Container(
                                        width: 220,
                                        child: Text('About CulturTap',style: Theme.of(context).textTheme.subtitle2,),
                                      ),
                                      IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11, color:Theme.of(context).primaryColor), onPressed: () {  },),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                        Builder(
                            builder: (context) {
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Help(),
                                    ),
                                  );
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
                                        child: SvgPicture.asset('assets/images/help-icon.svg', color:Theme.of(context).primaryColor),
                                      ),
                                      Container(
                                        width: 220,
                                        child: Text('Help',style: Theme.of(context).textTheme.subtitle2,),
                                      ),
                                      IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11, color:Theme.of(context).primaryColor), onPressed: () {  },),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                        Builder(
                            builder: (context) {
                              return GestureDetector(
                                onTap: (){
                                  showCustomAlertBox(context);
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
                                        child: SvgPicture.asset('assets/images/logout-icon.svg', color:Theme.of(context).primaryColor),
                                      ),
                                      Container(
                                        width: 220,
                                        child: Text('Logout',style: Theme.of(context).textTheme.subtitle2,),
                                      ),
                                      IconButton(icon: Icon(Icons.arrow_forward_ios,size: 11, color:Theme.of(context).primaryColor), onPressed: () {  },),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height : 18),
                        Text('All right reserve to', style: Theme.of(context).textTheme.subtitle2,),
                        Text('Culturtap Tourism India Pvt. Ltd.', style: Theme.of(context).textTheme.subtitle1,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
          duration: Duration(milliseconds: 100),


          height:  70 ,
          child: CustomFooter(addButtonAdd: 'add',)
      ),
    );
  }
}

class EditProfile extends StatefulWidget{
  String?userId;
  EditProfile({this.userId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>{
  bool showSubmit = false;
  String?homeCity,profession,dob,gender,imagePath,name,quote;
  List<String>?language;
  Future<Map<String, dynamic>>? profileData;
  DateTime?dateOfBirth;

  @override
  void initState(){
    super.initState();
    fetchProfileData();
  }

  void sendDataToBackend () async{
    print('Status');
    try {
      Map<String,dynamic> data = {
        'userId':userID,
        'userPlace':homeCity,
        'userProfession':profession,
        'userAge':dob,
        'userGender':gender,
        'userPhoto':imagePath,
        'userName':name,
        'userQuote':quote,
        'userLanguages':language,
        'userDOB':dateOfBirth?.toUtc()?.toIso8601String(),
      };

      print(data);
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final http.Response response = await http.patch(
        Uri.parse('$serverUrl/updateProfile'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile Updated Successfully!',style: Theme.of(context).textTheme.subtitle2,),
          ),
        );
        Navigator.of(context).pop();
        print('Data updated successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Try Again!!',style: Theme.of(context).textTheme.subtitle2,),
          ),
        );
        print('Failed to save data: ${response.statusCode}');
      }
    }catch(err){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try Again!!',style: Theme.of(context).textTheme.subtitle2,),
        ),
      );
      print("Error: $err");
    }
  }
  // setState(() {
  // imagePath = data['imagePath'];
  // homeCity = data['homeCity'];
  // profession = data['profession'];
  // dob = data['dob'];
  // gender = data['gender'];
  // name = data['name'];
  //  = data['quote'];
  // });

  Future<void> fetchProfileData() async {
    final String serverUrl = Constant().serverUrl;
    final url = Uri.parse('$serverUrl/profileDetails/${userID}');
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      setState(() {
        imagePath = data['imagePath'];
        homeCity = data['homeCity'];
        profession = data['profession'];
        dob = data['dob'];
        gender = data['gender'];
        name = data['name'];
        quote = data['quote'];
        dateOfBirth =data['dateOfBirth']!=null?DateTime.parse(data['dateOfBirth']):null;
        language = data['language']!=null?data['language'].cast<String>().toList():[];
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try Again!!',style: Theme.of(context).textTheme.subtitle2,),
        ),
      );
      Navigator.of(context).pop();
      print('Failed to fetch dataset: ${response.statusCode}');
      throw Exception('Failed to fetch profile data');
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage(userId: userID)),
        );

        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 0,userId: widget.userId,),automaticallyImplyLeading: false, shadowColor: Colors.transparent,toolbarHeight: 90),
        body: name!=null
            ?SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(5),
            color : Theme.of(context).backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Container(
                    width: 360,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [


                        SizedBox(height: 20,),
                        UserImage(
                          reqPages:1,
                          text:'edit',
                          imagePathCallback: (value){imagePath=value;print(value);},
                          nameCallback: (value){name = value;print('Name:::$value');},
                          imagePath:imagePath,
                          name:name,
                        ),
                        SizedBox(height: 30,),
                        MotivationalQuote(text:'edit',quote:quote,quoteCallback: (value){quote = value;print(value);},),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ProfileForm(text:'edit',homeCityCallback: (value){
                        homeCity = value;
                      },professionCallback:(value){
                        profession = value;
                      },dobCallback:(value){
                        dateOfBirth = value;
                      },genderCallback:(value){
                        gender = value;
                      },languageCallback:(values){
                        language = values;
                      },ageCallBack:(value){
                        dob = value;
                      }, setHomeCity:homeCity,setProfession:profession,setGender:gender,setLanguage:language,setDOB:dateOfBirth,setAge:dob,
                      ),
                      SizedBox(height : 0),
                    ],

                  ),
                ),
              ],
            ),
          ),
        )
            :Center(child: CircularProgressIndicator(),),
          bottomNavigationBar: AnimatedContainer(

            duration: Duration(milliseconds: 100),
            height : 80,
            color: Colors.white,



            child:Center(
              child: Container(
                color : Colors.white,

                child: Container(
                  width : 326,
                  height : 53,
                  child: FiledButton(

                      backgroundColor: Colors.orange,
                      onPressed: () {
                        sendDataToBackend();
                      },
                      child: Center(
                          child: Text('SUBMIT',
                            style: Theme.of(context).textTheme.headline5,
                          )
                      )
                  ),
                ),
              ),
            ),
          )

      ),
    );
  }
}

class EditServices extends StatefulWidget{
  bool ?service1,service2,service3,haveCards;
  String?userId;
  EditServices({this.service1,this.service2,this.service3,this.userId,this.haveCards});
  @override
  _EditServicesState createState()=> _EditServicesState();
}

class _EditServicesState extends State<EditServices>{

  @override
  void initState() {
    super.initState();
    fetchServiceData();
  }


  Future<void> fetchServiceData() async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userID}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final dataset = json.decode(response.body);
      print('Data is $dataset');
      setState(() {
        widget.service1 = dataset?['userServiceTripCallingData']!=null?(dataset?['userServiceTripCallingData']['startTimeFrom']!=null?true:false):false;
        widget.service2 = dataset?['userServiceTripAssistantStatus']!=null?(dataset?['userServiceTripAssistantStatus']):false;
        widget.service3 = false;
        widget.haveCards = (dataset?['userPaymentData']!=null && dataset?['userPaymentData'].length>0)?true:false;
      });
    } else {
      // Handle error
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }




  @override
  Widget build(BuildContext context) {
    print('Cards ${widget.haveCards}');
    return Scaffold(
      appBar: AppBar(title: ProfileHeader(reqPage: 0,userId: userID,),automaticallyImplyLeading: false,shadowColor: Colors.transparent,toolbarHeight: 90),
      body:  WillPopScope(
        onWillPop: ()async{

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage(userId: userID)),
          );

          return true;
        },
        child: widget.service1!=null
            ? Container(
          padding : EdgeInsets.only(left : 22, right : 22, ),

          color : Colors.white,

          height: 860,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              SizedBox(height: 40,),
              ServiceCard(text:'edit',haveCards:widget.haveCards,userId:userID,isToggle:widget.service1,titleLabel: 'Become a Trip Planner ', serviceImage: 'assets/images/service_card_1.jpg', iconImage: 'assets/images/service_help_1.jpg', subTitleLabel: 'Help others to \nplan their trips.', endLabel: ' for Becoming \nTrip planner '),
              SizedBox(height: 30,),
              ServiceCard(text:'editService2',userId:userID,isToggle:widget.service2,titleLabel: 'Become a Trip Assistant for \nother’s journey ', serviceImage: 'assets/images/service_card_2.jpg', iconImage: 'assets/images/service_help_2.jpg', subTitleLabel: 'Assist other \nneedy tourist !', endLabel: 'for Becoming \nSuperhero as a saviour ! '),
              // ServiceCard(isToggle:widget.service3,titleLabel: 'Become a Local Guide ', serviceImage: 'assets/images/service_card_3.jpg', iconImage: 'assets/images/service_help_3.jpg', subTitleLabel: 'Guide other \nTourists !', endLabel: 'Turn youself ON for Becoming \na smart guide for tourists !'),
            ],
          ),
        )
            :Center(child: CircularProgressIndicator(),),
      ),
    );
  }
}

class EditPayments extends StatefulWidget{
  List<dynamic>?savedCards;
  String?userId;
  EditPayments({this.savedCards,this.userId});
  @override
  _EditPaymentsState createState()=> _EditPaymentsState();
}

class _EditPaymentsState extends State<EditPayments>{

  void initState() {
    super.initState();
    fetchPaymentData();
  }

  Future<void> fetchPaymentData() async {
    final String serverUrl = Constant().serverUrl; // Replace with your server's URL
    final url = Uri.parse('$serverUrl/userStoredData/${userID}'); // Replace with your backend URL
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final dataset = json.decode(response.body);
      print('Data is $dataset');
      setState(() {
        widget.userId = userID;
        widget.savedCards =  dataset?['userPaymentData']!=null?(dataset?['userPaymentData']):[];
      });
    } else {
      // Handle error
      print('Failed to fetch dataset: ${response.statusCode}');
    }
  }

  List<CardDetails> convertToCardDetailsList(List<dynamic> userPaymentDataList) {
    List<CardDetails> cardDetailsList = [];

    for (dynamic paymentData in userPaymentDataList) {
      CardDetails cardDetails = CardDetails(
        name: paymentData['name'] ?? '',
        cardNo: paymentData['cardNo'] ?? '',
        cardChoosen: null, // Assuming cardChoosen is not provided in the backend data
        month: paymentData['month'] ?? '',
        year: paymentData['year'] ?? '',
        cvv: paymentData['cvv'] ?? '',
        options: false, // Assuming options is not provided in the backend data
      );

      cardDetailsList.add(cardDetails);
    }

    return cardDetailsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.savedCards!=null
      ? PaymentSection(savedCards: convertToCardDetailsList(widget.savedCards!),text: 'edit',userId: widget.userId,)
      :Center(child: CircularProgressIndicator(),),
    );

  }

}

class AboutUs extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: ProfileHeader(reqPage: 2,),automaticallyImplyLeading: false,toolbarHeight: 90,shadowColor: Colors.transparent,),
      body:  SingleChildScrollView(
        child: Container(
          width: 390,
          height: 1571,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SvgPicture.asset('assets/images/about-us.svg'),
              Container(
                width: 313,
                height: 493,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('About Us',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                    Text('Culturtap is a travel app that aims to make your travel easier by providing real-time updates and connecting you with people to help whenever you need. It makes your travel easier,safer and more enjoyable. download CulturTap app: which helps you to explore the whole culture of your selected destinations! '
                        '\nExplore the whole culture with just a few taps! \nChoose your destination, CulturTap presents  you the whole culture of your destination with real-time updates, including popular visits, top-rated restaurants, trending locations, outskirts, traditional fashion, nearby pubs and cafes, street food, historical heritage, festivals, handy crafts, service shops and business shops.'
                    ,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),textAlign: TextAlign.justify,)
                  ],
                ),
              ),
              Container(
                width: 312,
                height: 735,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 313,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Trip planning calls:',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                          Text('You can connect with people who have \nalready experienced the destination or the \nlocals to help you plan your next trip better.'
                              ,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),textAlign: TextAlign.justify,)
                        ],
                      ),
                    ),
                    Container(
                      width: 313,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Immediate trip assistance:',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                          Text('Immediate trip assistance allows you to send a message to nearby people who can assist you with your immediate needs or connect you with them. Person will be physically available for you if needed.'
                            ,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),textAlign: TextAlign.justify,)
                        ],
                      ),
                    ),
                    Container(
                      width: 313,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Emergency Call Services:',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                          Text("Culturtap, prioritizes your safety by connecting you with all the emergency helpline numbers anywhere in the world and encouraging you to explore with confidentiality. stay safe in any situation with CulturTap's emergency call services Connect with police, ambulance, or fire brigade worldwide with just a few taps of CulturTap."
                            ,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),textAlign: TextAlign.justify,)
                        ],
                      ),
                    ),
                    Container(
                      width: 313,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('How to earn?',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                          Text('Explore, Update, Guide and Earn !'
                            ,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),textAlign: TextAlign.justify,)
                        ],
                      ),
                    ),
                    Container(
                      width: 313,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Trip planning calls:',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                          Text('share your travel experiences to connect with travelers and help them to plan their trips.'
                            ,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),textAlign: TextAlign.justify,)
                        ],
                      ),
                    ),
                    Container(
                      width: 313,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Immediate trip assistance:',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                          Text('Immediate Call Assistance connects you with them who are nearby and need your immediate help while they are traveling.'
                            ,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),textAlign: TextAlign.justify,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Help extends StatelessWidget{

  void sendEmail() {
    final String email = 'mailto:amangangwani1101@example.com';

    if (Platform.isIOS || Platform.isAndroid) {
      launch(email);
    } else {
      // For other platforms, provide a user prompt or alternative behavior
      print('Platform not supported for sending emails');
    }
  }

  Future<void> launch(String url) async {
    try {
        await launch(url);
        print('Launched');
    } catch(e) {
      print('Error launching URL: $e');
    }
  }

  String textValue='';
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: ProfileHeader(reqPage: 2,),automaticallyImplyLeading: false,toolbarHeight: 90,shadowColor: Colors.transparent,),
      body:Center(
        child: Container(
          width: 333,
          height: 838,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 593,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Help',style: TextStyle(fontFamily: 'Poppins',fontSize: 16,fontWeight: FontWeight.bold),),
                        Text('Tell us your concern !',style:TextStyle(fontFamily: 'Poppins',fontSize: 16,)),
                      ],
                    ),
                    Container(
                      color: HexColor('#D9D9D9'),
                      height:361,
                      child: TextField(
                        style: TextStyle(fontSize: 16,),
                        onChanged: (value) {
                          textValue = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Type here........',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 15, // Increase the maxLines for a larger text area
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Or',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',fontSize: 16),),
                          Text('Submit your concern with us at',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',fontSize: 16),),
                          Text('Info@culturtap.com',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 326,
                height: 53,
                child: FiledButton(
                    backgroundColor: HexColor('#FB8C00'),
                    onPressed: () {
                      sendEmail();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ThankYou(),));
                    },
                    child: Center(
                        child: Text('SUBMIT',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThankYou extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:ProfileHeader(reqPage: 6,),automaticallyImplyLeading: false,toolbarHeight: 90,shadowColor: Colors.transparent,),
      body:WillPopScope(
        onWillPop: ()async{

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage(userId: userID)),
          );

          return true;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/heart.png'),
              Center(child: Text('Thank you for submitting \nyour concern to us .',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,fontFamily: 'Poppins'),textAlign: TextAlign.center,)),
              SizedBox(height: 100,),
            ],
          ),

        ),
      ),
    );
  }
}