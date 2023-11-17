import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import 'package:learn_flutter/widgets/01_helpIconCustomWidget.dart';
import 'package:learn_flutter/widgets/03_imageUpoad_Crop.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../ServiceSections/ServiceCards.dart';
import '../StoriesSection/StoryCategories.dart';
import '../widgets/CustomButton.dart';
import '../widgets/hexColor.dart';
import '../BackendStore/BackendStore.dart';
import 'CoverPage.dart';
import 'ExpertCard.dart';
import 'FinalUserProfile.dart';
import 'ProfileHeader.dart';
import 'ReviewPage.dart';
import 'UserInfo.dart';

// raw data variable
typedef void SetQuote(String? image);


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
  runApp(ChangeNotifierProvider(
      create:(context) => ProfileDataProvider(),
      child: ProfileApp(),
    ),
  );
}


// start of profile page
class ProfileApp extends StatelessWidget {
  String?userId,userName;
  ProfileApp({this.userId,this.userName});
  @override
  Widget build(BuildContext context) {
    final profileDataProvider = Provider.of<ProfileDataProvider>(context);
    // final profileDataProvider = context.watch<ProfileDataProvider>();
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      home: ProfilePage(reqPage:0,profileDataProvider: profileDataProvider,userId:userId,userName:userName),
      debugShowCheckedModeBanner: false,
    );
  }
}
class ProfilePage extends StatefulWidget {
  final int reqPage;
  final ProfileDataProvider? profileDataProvider;
  final String?userId,userName;
  ProfilePage({required this.reqPage, this.profileDataProvider,this.userId,this.userName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState(){
    super.initState();
    if(widget.userName!=null){
      print('UserName ${widget.userName}');
      widget.profileDataProvider?.setUserId(widget.userId!);
      widget.profileDataProvider?.updateName(widget.userName!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Set the preferred height to 0
        child: AppBar(
          elevation: 0, // Remove the shadow
          backgroundColor: Colors.transparent, // Make the background transparent
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(reqPage: widget.reqPage),
            widget.reqPage==0?ProfileStrengthCard():SizedBox(height: 0,),
            SizedBox(height: 17,),
            CoverPage(reqPage:widget.reqPage,profileDataProvider: widget.profileDataProvider,name:widget.userName),
            UserInformationSection(reqPage:widget.reqPage,profileDataProvider:widget.profileDataProvider,userName:widget.userName,userId:widget.userId),
          ],
        ),
      ),
    );
  }
}


// profile strength
class ProfileStrengthCard extends StatefulWidget {
  @override
  _ProfileStrengthCardState createState() => _ProfileStrengthCardState();
}
class _ProfileStrengthCardState extends State<ProfileStrengthCard> {
  final String profileStatus = 'low'; // Replace this with the actual profile status

  Color _getStatusColor() {
    switch (profileStatus) {
      case 'low':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      height: 120,
      child: Center(
        child: Container(
          width: screenWidth*0.9,
          // padding: EdgeInsets.only(top: 12.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          child:Row(
            children: [
              Container(
                child: Image.asset('assets/images/profile_strength.jpg', width: 110,height: 92,fit: BoxFit.contain,),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Container(
                  width: screenWidth*0.41,
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color:Colors.lightGreen,
                  //     width: 2,
                  //   ),
                  // ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text('Lets Complete\nProfile Section First!',style: TextStyle(fontWeight: FontWeight.w900,fontSize: 14,fontFamily: 'Poppins'),),
                      SizedBox(height: 10,),
                      Text('Profile Strength',style: TextStyle(fontSize: 11,fontFamily: 'Poppins',shadows: <Shadow>[
                        Shadow(
                          offset: Offset(2.0, 1.0), // Specify the x and y offset of the shadow
                          blurRadius: 6.0, // Specify the blur radius of the shadow
                          color: Colors.grey, // Specify the color of the shadow
                        ),
                      ],),),
                      Text('LOW',style: TextStyle(color: Colors.red,fontWeight: FontWeight.w900,fontFamily: 'Poppins',fontSize: 11),),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: screenWidth*0.01),
                child: Align(
                  alignment: Alignment.topRight,
                  child:  IconButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompleteProfilePage(),
                      ),
                    );
                  }, icon: Icon(Icons.arrow_forward,),color: Colors.orange,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// user info schema complete
class UserInformationSection extends StatelessWidget {
  final int reqPage;
  bool videoUploaded =  false;
  final ProfileDataProvider? profileDataProvider;
  String ?userId,userName;
  final ratings = [
    RatingEntry(name: 'Aishwary Shrivastava', count: 3, comment: 'Good in communication... Not the explorer'),
    RatingEntry(name: 'Pushpit Kant', count: 4, comment: 'Funny!Helpful! if you are a girl then. '),
    RatingEntry(name: 'Anonomus', count: 5, comment: 'Good Services.'),
  ];
  final currentReview = 0;
  UserInformationSection({required this.reqPage,this.profileDataProvider,this.userId,this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 10,),
          MotivationalQuote(profileDataProvider:profileDataProvider),
          SizedBox(height: 20.0),
          ReachAndLocation(profileDataProvider:profileDataProvider),
          SizedBox(height: 30,),
          reqPage==0?SizedBox(height: 0):SignIn(),
          SizedBox(height: 30.0),
          reqPage==0?SizedBox(height: 0):LocationEditor(profileDataProvider:profileDataProvider),
          SizedBox(height: 30.0),
          reqPage==0?UserDetailsTable():ProfileForm(profileDataProvider:profileDataProvider),
          SizedBox(height: 45.0),
          ExpertCardDetails(),
          SizedBox(height: 35.0),
          reqPage==0?SizedBox(height: 0,) :Container(
                height: 860,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ServiceCard(titleLabel: 'Become a Trip Planner ', serviceImage: 'assets/images/service_card_1.jpg', iconImage: 'assets/images/service_help_1.jpg', subTitleLabel: 'Help others to \nplan their trips.', endLabel: 'Turn youself ON for Becoming \nTrip planner ',profileDataProvider:profileDataProvider),
                    ServiceCard(titleLabel: 'Become a Trip Assistant for \nother’s journey ', serviceImage: 'assets/images/service_card_2.jpg', iconImage: 'assets/images/service_help_2.jpg', subTitleLabel: 'Assist other \nneedy tourist !', endLabel: 'Turn youself ON for Becoming \nSuperhero as a saviour ! ',profileDataProvider:profileDataProvider),
                    ServiceCard(titleLabel: 'Become a Local Guide ', serviceImage: 'assets/images/service_card_3.jpg', iconImage: 'assets/images/service_help_3.jpg', subTitleLabel: 'Guide other \nTourists !', endLabel: 'Turn youself ON for Becoming \na smart guide for tourists !',profileDataProvider:profileDataProvider),
                  ],
                ),
              ),
          // SizedBox(height: 30,),
          reqPage==0?SizedBox(width: 0,): RatingSection(ratings: ratings,reviewCnt:currentReview,profileDataProvider:profileDataProvider),
          SizedBox(height: 20,),
          reqPage==0
              ?SizedBox(width: 0,)
              : !videoUploaded
                ?Container(
              width: 335,
              height: 195,
              child: Center(
                child: SizedBox(
                  width: 340,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Other visits',
                        style: TextStyle(fontSize: 24,
                            fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
                      Text('No visits till yet, You can start it now even, Just click on add “ + “ button at the bottom of your screen & '
                          ' record your outside surroundings.',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                      SizedBox(height: 7,),
                      Text('You can make video post private & public as per your choice. ',
                        style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                      SizedBox(height:7,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Profile Strength Now',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily:'Poppins',),),
                          Text('Medium',style: TextStyle(fontSize: 12,fontFamily: 'Poppins',color: HexColor('#FB8C00'),fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
                :VisitsSection(),
          SizedBox(height: 20,),

          ProfielStatusAndButton(reqPages: reqPage,userId:userId,userName:userName),
        ],
      ),
    );
  }
}


// saving all user data in databse and submit section
class ProfielStatusAndButton  extends StatelessWidget{
  final int reqPages;
  String?userId,userName;
  ProfielStatusAndButton({required this.reqPages,this.userName,this.userId});

  @override
  Widget build(BuildContext context) {
    final profileDataProvider = Provider.of<ProfileDataProvider>(context);

    void sendDataToBackend () async{
      print('Status');
      try {
        final profileData = profileDataProvider.profileData.toJson();
        print('Path is $profileData');
        final String serverUrl = Constant().serverUrl; // Replace with your server's URL
        final http.Response response = await http.put(
          Uri.parse('$serverUrl/profileSection'), // Adjust the endpoint as needed
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(profileData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print('User Id : ${responseData}');
          print('Data saved successfully');
        } else {
          print('Failed to save data: ${response.statusCode}');
        }
      }catch(err){
        print("Error: $err");
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Container(
            width: 400,
            height: 70,
            child: FiledButton(
                backgroundColor: HexColor('#FB8C00'),
                onPressed: () {
                  print('Reqpages is $reqPages');
                  reqPages==1?sendDataToBackend():null;
                  reqPages<1
                    ?Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteProfilePage(userId:userId,userName:userName),))
                    :Navigator.push(context, MaterialPageRoute(builder: (context) => FinalProfile(userId:profileDataProvider.retUserId()!,clickedId:profileDataProvider.retUserId()!,),));
                },
                child: Center(
                    child: Text(reqPages<1?'COMPLETE PROFILE':'SET PROFILE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18)))),
                ),
              ],
            ),
        );
  }

}


// showing edit profile section
class CompleteProfilePage extends StatelessWidget {
  String ?userId,userName;
  CompleteProfilePage({this.userName,this.userId});
  @override
  Widget build(BuildContext context) {
    final profileDataProvider = Provider.of<ProfileDataProvider>(context);
    return ProfilePage(reqPage: 1, profileDataProvider: profileDataProvider,userName: userName,userId: userId,);
  }
}