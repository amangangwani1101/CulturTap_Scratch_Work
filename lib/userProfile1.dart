import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn_flutter/camera.dart';
import 'package:learn_flutter/rating.dart';
import 'package:learn_flutter/slider.dart';
import 'package:learn_flutter/widgets/01_helpIconCustomWidget.dart';
import 'package:learn_flutter/widgets/02_customNavbar.dart';
import 'package:learn_flutter/widgets/03_imageUpoad_Crop.dart';
import 'package:learn_flutter/widgets/sample.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

typedef void ImageCallback(File image);
typedef void SetQuote(String? image);

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
      create:(context) => ProfileDataProvider(),
      child: ProfileApp(),
    ),
  );
}
class ProfileData{
  File? imagePath;
  String? name;

  ProfileData({this.name,this.imagePath});

  Map<String,dynamic> toJson(){
    return {
      'userPhoto':imagePath,
      'userName':name,
    };
  }
}

class ProfileDataProvider extends ChangeNotifier {
  ProfileData _profileData = ProfileData();

  ProfileData get profileData => _profileData;

  void updateImagePath(File path) {
    _profileData.imagePath = path!;
    notifyListeners();
  }

  void updateName(String userName) {
    _profileData.name = userName!;
    notifyListeners();
  }
}

  
class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileDataProvider = Provider.of<ProfileDataProvider>(context);
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      home: ProfilePage(reqPage:0,profileDataProvider: profileDataProvider,),
      debugShowCheckedModeBanner: false,
    );
  }
}


class ProfilePage extends StatelessWidget {
  final int reqPage;
  final ProfileDataProvider profileDataProvider;
  ProfilePage({required this.reqPage,required this.profileDataProvider});
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
            ProfileHeader(reqPage: reqPage),
            reqPage==1?ProfileStrengthCard():SizedBox(height: 0,),
            reqPage==1?SizedBox(height: 17,):SizedBox(height: 0,),
            CoverPage(reqPage:reqPage,profileDataProvider: profileDataProvider,),
            UserInformationSection(reqPage:reqPage),

          ],
        ),
      ),
    );
  }
}

// Converts hex string to color
class HexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex =  "FF" + hex.toUpperCase().replaceAll("#", "");
    return int.parse(formattedHex, radix: 16);
  }
  HexColor(final String hex) : super(_getColor(hex));
}


// profile header section -- state1
class ProfileHeader extends StatefulWidget {
  final int reqPage;

  ProfileHeader({required this.reqPage});
  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  // notification count will be made dynamic from backend
  int notificationCount = 2;
  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.red,
      //     width: 2,
      //   ),
      // ),
      height: 92,
      padding: EdgeInsets.only(top: 12.0,left: 25.0,right: 24.0,bottom:16.0),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.reqPage<1?
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  // Handle profile image click
                },
                child: Container(
                  // width: 100,
                  height: 35,
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundImage: AssetImage('assets/images/profile_image.jpg'),
                  ),
                ),
              ),
              Text('Profile',style: TextStyle(fontSize: 14,color:HexColor("#FB8C00"),fontWeight: FontWeight.w900,fontFamily: 'Poppins',),),
            ],
          ):
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.black,
            //     width: 2,
            //   ),
            // ),
            width: 60,
            height: 45,
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: Image.asset('assets/images/back.png',width: 60,height: 30,),
              ),
            ),
          ),
          widget.reqPage>=1?
          Padding(
              padding:EdgeInsets.only(top: 13.0),
              child:Align(
                alignment: Alignment.topLeft,
                child: Image.asset('assets/images/logo.png',width: 145),
            ),
          ):Padding(
            padding:EdgeInsets.only(top: 13.0,right: 12,),
            child:Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/logo.png',width: 145),
            ),
          ),
          widget.reqPage<=1?
          Column(
            children: [
              Container(
                width: 55,
                height: 35,
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.orange,
                //     width: 2,
                //   ),
                // ),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top: 6.0,right: 4.0),
                        child: Image.asset('assets/images/ping_image.png',height: 28 ,fit: BoxFit.cover,
                        ),
                    ),
                    if(notificationCount>0)
                      Positioned(
                        top: -6,
                        right: 0,
                        // height: 20,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            notificationCount.toString(),
                            style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text('Pings',style: TextStyle(fontSize: 14,color:Colors.black,fontWeight: FontWeight.w600,fontFamily: 'Poppins'),),
            ],
          ):
            Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.black,
            //     width: 2,
            //   ),
            // ),
            width: 60,
            height: 45,
            child: Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                onTap: (){
                  showDialog(context: context, builder: (BuildContext context){
                    return Container(child: CustomHelpOverlay(imagePath: 'assets/images/icon.jpg',serviceSettings: false,),);
                  },
                  );
              },
              child: Image.asset('assets/images/skip.png',width: 60,height: 30,),
            ),
          ),
        ),
      ],
    ),
  );
  }
}


// profile strength card -- state2
class IconHover extends StatefulWidget {
  @override
  _IconHoverState createState() => _IconHoverState();
}

class _IconHoverState extends State<IconHover> {
  bool isClicked = false;

  void _toggleClick() {
    setState(() {
      isClicked = !isClicked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleClick,
      child: Icon(
        Icons.arrow_forward,
        size: 30,
        color: (!isClicked) ? HexColor("#FB8C00") : Colors.black,
      ),
    );
  }
}

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
    // return Container(
    //   height: 110,
    //   width: 46,
    //   margin: EdgeInsets.only(top: 10.0,left: 16.0,right: 16.0,),
    //   decoration: BoxDecoration(
    //     color: Colors.white, // Container background color
    //     border: Border.all(
    //       color: HexColor('#001B33'), // Border color
    //       width: 1.0, // Border width
    //     ),
    //   ),
    //   child: ListView.builder(itemBuilder: (context,index)=>
    //       ListTile(
    //         leading:Image.asset('assets/images/profile_strength.jpg',
    //         width: 80,height: 120,),
    //         title: Text('Lets Complete\nProfile Section First!',style: TextStyle(fontWeight: FontWeight.w800,fontSize: 14,fontFamily: 'Poppins'),),
    //         subtitle: RichText(
    //           text: TextSpan(
    //               style: TextStyle(color: Colors.black),
    //               children: [
    //                 TextSpan(text: 'Profile Strength\n',style: TextStyle(fontSize: 13,fontFamily: 'Poppins',shadows: <Shadow>[
    //                 Shadow(
    //                 offset: Offset(2.0, 1.0), // Specify the x and y offset of the shadow
    //                   blurRadius: 6.0, // Specify the blur radius of the shadow
    //                   color: Colors.grey, // Specify the color of the shadow
    //                 ),
    //               ],),),
    //                 TextSpan(text: '${profileStatus.toUpperCase()}',style: TextStyle(color: _getStatusColor(),fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
    //               ],
    //             ),
    //           ),
    //         trailing:Container(
    //             child: IconHover(),
    //         ),
    //       ),
    //     itemCount: 1,
    //   ),
    // );
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
                  child:  IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward,),color: Colors.orange,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoverPage extends StatelessWidget {
  final bool hasVideoUploaded = false; // Replace with backend logic
  final int reqPage;
  final ProfileDataProvider profileDataProvider;
    CoverPage({required this.reqPage, required this.profileDataProvider});

  @override
  Widget build(BuildContext context) {
    return UserImage(reqPages: reqPage,profileDataProvider: profileDataProvider);
  }
}

class UserImage extends StatefulWidget {
  final int reqPages;
  final ProfileDataProvider profileDataProvider; // Pass the profileDataProvider here
  UserImage({required this.reqPages, required this.profileDataProvider});
  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage>{

  File? _userProfileImage;

  void handleImageUpdated(File image) {
    setState(() {
      _userProfileImage = image; // Update the parameter in the main class
      widget.profileDataProvider.updateImagePath(_userProfileImage!); // Update image path in the provider
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVideoUploaded = false; // Replace with backend logic
    return Container(
      width: double.infinity,
      height: 290,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.orange,
      //   ),
      // ),
      child: Stack(
        children: [
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.orange,
            //     width: 2,
            //   ),
            // ),
            width: double.infinity,
            height: 170,
            child:Center(
              child: Stack(
                children: [
                  Container(
                    width: 373,
                    color: HexColor("#EDEDED"),
                  ),
                  // height: 170,
                  !hasVideoUploaded?Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.orange,
                    //     width: 2,
                    //   ),
                    // ),
                    child: Container(
                      width: 373,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.reqPages<1?
                          Container(
                            child: Image.asset(
                              'assets/images/video_icon.png', // Replace with the actual path to your asset image
                              width: 35, // Set the desired image width
                              height: 35, // Set the desired image height
                              fit: BoxFit.contain, // Adjust the fit as needed
                            ),
                          ):Column(
                            children:[
                              Container(
                                child: Image.asset(
                                  'assets/images/video_icon.png', // Replace with the actual path to your asset image
                                  width: 35, // Set the desired image width
                                  height: 35, // Set the desired image height
                                  fit: BoxFit.contain, // Adjust the fit as needed
                                ),
                              ),
                              Text('Add your cover'),
                              Text('Expereince via video here !',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ): Container(
                    width: 373,
                    color: Colors.grey, // Replace with your video player or widget
                  ),
                  Positioned(
                    top: 20,
                    right: 30,
                    child: IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                      showDialog(context: context, builder: (BuildContext context){
                        return Container(child: CustomHelpOverlay(imagePath: 'assets/images/cover_icon.jpg',serviceSettings: false,),);
                      },
                      );
                    },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 290,
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.black,
            //     width: 2,
            //   ),
            // ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.black,
                  //     width: 2,
                  //   ),
                  // ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white, // Border color
                            width: 15.0, // Border width
                          ),
                        ),
                        child: _userProfileImage!=null?
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(_userProfileImage!),
                        ) :CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/images/user.png'),
                          backgroundColor: Colors.white,// Replace with user avatar image
                        ),
                      ),
                      if (widget.reqPages<1) SizedBox(height: 0,) else Positioned(
                        top: 100,
                        right:15,
                        child: Container(
                          width: 36,
                          height: 34,
                          decoration: BoxDecoration(
                            // border: Border.all(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                            shape: BoxShape.circle,
                            color: Colors.orange,
                          ),
                          child:IconButton(icon:Icon(Icons.camera_alt_outlined),color: Colors.white,onPressed: (){
                                showDialog(context: context, builder: (BuildContext context){
                                return Container(child: UploadMethods(onImageUpdated : handleImageUpdated));
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                widget.reqPages<1?
                Text(
                  'Hemant Singh', // Replace with actual user name
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ):EditNameForm(profileDataProvider:widget.profileDataProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UploadMethods extends StatefulWidget{
  final ImageCallback onImageUpdated;
  UploadMethods({required this.onImageUpdated});


  @override
  State<UploadMethods> createState() => _UploadMethodsState();
}

class _UploadMethodsState extends State<UploadMethods> {

  File? _userProfileImage;
  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _userProfileImage = File(pickedFile.path);
        widget.onImageUpdated(_userProfileImage!); // Call the callback to update the parameter in the parent class
      });
    }
  }
  // upload from gallery
  Future<void> _updateProfileImage() async{
    final croppedImage = await ImageUtil.pickAndCropImage();

    if(croppedImage!=null){
      setState(() {
        _userProfileImage = croppedImage;
        widget.onImageUpdated(_userProfileImage!); // Call the callback to update the parameter in the parent class
      });
    }
    return;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children:[
          GestureDetector(
            onTap:(){
              Navigator.of(context).pop();
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                color: Colors.grey.withOpacity(0),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 411,
                height: 188,
                color:Colors.white,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        height: 90,
                        width: 300,
                        child: GestureDetector(
                          onTap: _updateProfileImage,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Upload',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.black,decoration: TextDecoration.none,),),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 380,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black, // Set the border color
                            width: 1.0, // Set the border width
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 90,
                        width: 300,
                        child: GestureDetector(
                          onTap: _takePicture,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Open Camera',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.black,decoration: TextDecoration.none,),),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class EditNameForm extends StatefulWidget {
  final ProfileDataProvider profileDataProvider;
  EditNameForm({required this.profileDataProvider});
  @override
  _EditNameFormState createState() => _EditNameFormState();
}

class _EditNameFormState extends State<EditNameForm> {
  TextEditingController nameController = TextEditingController();
  String userName = "Hemant Singh"; // Initial static name
  // String editedName = ""; // Stores the edited name
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController.text = userName;
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;

      if (!isEditing) {
        if(nameController.text.length<1){
          isEditing = !isEditing;
          print('Name is too small');
        }else{
          // Save the edited name when exiting edit mode
          userName = nameController.text;
          widget.profileDataProvider.updateName(userName);
          // Here, you can send the updated name to your backend for processing
          // For demonstration, we'll just print it
          print("Updated Name: $userName");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      // height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isEditing
              ? Container(
            width: 200,
            child: TextField(
              controller: nameController,
              onChanged: (value){
                userName = value;
              },
              style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,fontFamily: 'Poppins'),
            ),
          )
              : Text(
            userName,
            style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.save_outlined : Icons.edit_outlined),
            onPressed: toggleEdit,
          ),
        ],
      ),
    );
  }
}


// class UserPhoto extends StatelessWidget{
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height:120,
//       // decoration: BoxDecoration(
//       //   border: Border.all(
//       //     color: Colors.black,width: 2,
//       //   ),
//       // ),
//       // dec
//       child: Stack(
//         children: [
//           Positioned(
//             top: -70,
//             left: 0,
//             right: 0,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Colors.white, // Border color
//                       width: 15.0, // Border width
//                     ),
//                   ),
//                   child: CircleAvatar(
//                     radius: 60,
//                     backgroundImage: AssetImage('assets/images/user.png'),
//                     backgroundColor: Colors.white,// Replace with user avatar image
//                   ),
//                 ),
//                 Text(
//                     'Hemant Singh', // Replace with actual user name
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w900,
//                         fontFamily: 'Poppins',
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// }


class UserInformationSection extends StatelessWidget {
  final int reqPage;
  bool videoUploaded =  true;
  final ratings = [
    RatingEntry(name: 'Aishwary Shrivastava', count: 3, comment: 'Good in communication... Not the explorer'),
    RatingEntry(name: 'Pushpit Kant', count: 4, comment: 'Funny!Helpful! if you are a girl then. '),
    RatingEntry(name: 'Anonomus', count: 5, comment: 'Good Services.'),
  ];
  final currentReview = 3;
  UserInformationSection({required this.reqPage});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16.0,left: 16.0,right: 16.0 , bottom: 16.00),
      child: Column(
        children: [
          SizedBox(height: 10,),
          MotivationalQuote(),
          SizedBox(height: 20.0),
          ReachAndLocation(),
          SizedBox(height: 30,),
          reqPage==0?SizedBox(height: 0):SignIn(),
          SizedBox(height: 30.0),
          reqPage==0?SizedBox(height: 0):LocationEditor(),
          SizedBox(height: 30.0),
          reqPage==0?UserDetailsTable():ProfileForm(),
          SizedBox(height: 45.0),
          ExpertCardDetails(),
          SizedBox(height: 35.0),
          reqPage==0?SizedBox(height: 0,):
              Container(
                height: 860,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ServiceCard(titleLabel: 'Become a Trip Planner ', serviceImage: 'assets/images/service_card_1.jpg', iconImage: 'assets/images/service_help_1.jpg', subTitleLabel: 'Help others to \nplan their trips.', endLabel: 'Turn youself ON for Becoming \nTrip planner '),
                    ServiceCard(titleLabel: 'Become a Trip Assistant for \nother’s journey ', serviceImage: 'assets/images/service_card_2.jpg', iconImage: 'assets/images/service_help_2.jpg', subTitleLabel: 'Assist other \nneedy tourist !', endLabel: 'Turn youself ON for Becoming \nSuperhero as a saviour ! '),
                    ServiceCard(titleLabel: 'Become a Local Guide ', serviceImage: 'assets/images/service_card_3.jpg', iconImage: 'assets/images/service_help_3.jpg', subTitleLabel: 'Guide other \nTourists !', endLabel: 'Turn youself ON for Becoming \na smart guide for tourists !'),
                  ],
                ),
              ),
          // SizedBox(height: 30,),
          reqPage==0?SizedBox(width: 0,):
          RatingSection(ratings: ratings,reviewCnt:currentReview),
          // VisitedSection(),
          SizedBox(height: 20,),
          reqPage==0?SizedBox(width: 0,):
            !videoUploaded?
            Container(
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
          ProfielStatusAndButton(reqPages: reqPage,),
        ],
      ),
    );
  }
}

class CardItem {
  final String image;
  // final String videoUrl;
  final int countVideos;
  final String location;
  final String category;
  final int viewCnt;
  final int likes;
  final String distance;

  CardItem({
    required this.image,
    required this.location,
    required this.countVideos,
    required this.category,
    required this.viewCnt,
    required this.likes,
    required this.distance,
    // required this.videoUrl,
  });
}

class CardSlider extends StatefulWidget {
  final List<CardItem> cards;
  final String category;
  CardSlider({required this.category,required this.cards});

  @override
  _CardSliderState createState() => _CardSliderState();
}

class _CardSliderState extends State<CardSlider> {
  int currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: currentIndex,
      viewportFraction: 0.8, // Adjust the viewportFraction for card width
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: <Widget>[
      //     Padding(
      //       padding: EdgeInsets.all(16),
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Text(
      //             widget.category,
      //             style: TextStyle(
      //               fontSize: 20,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           ElevatedButton(
      //             onPressed: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => AllCardsPage(cards: widget.cards),
      //                 ),
      //               );
      //             },
      //             child: Text('View All'),
      //           ),
      //         ],
      //       ),
      //     ),
      //     Container(
      //       height: 479,
      //       // width: 279,
      //       child: PageView.builder(
      //         itemCount: widget.cards.length,
      //         controller: PageController(
      //           initialPage: currentIndex,
      //         ),
      //         onPageChanged: (index) {
      //           setState(() {
      //             currentIndex = index;
      //           });
      //         },
      //         itemBuilder: (context, index) {
      //           return SizedBox(
      //               width: 279,
      //               child: CardItemWidget(card: widget.cards[index]));
      //         },
      //       ),
      //     ),
      //   ],
      // ),
      child: Container(
        height: 590,
        // decoration: BoxDecoration(
        //   border: Border.all(
        //     color: Colors.black,
        //     width: 1,
        //   ),
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 370,
              height: 50,
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //     width: 1,
              //   ),
              // ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.category,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllCardsPage(cards: widget.cards),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text('View All',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),),
                        Icon( Icons.arrow_forward_ios, size: 12,color: HexColor('#FB8C00'),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 479,
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.right,
                color: HexColor('#FB8C00'), // Set the color to your desired color
                showLeading: true, // Set to false to disable the leading glow effect
                showTrailing: true, child: ListView(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                children: widget.cards.map((card) {
                  return SizedBox(
                    width: 279,
                    child: CardItemWidget(card: card),
                  );
                }).toList(),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardItemWidget extends StatelessWidget {
  final CardItem card;

  CardItemWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    // return Card(
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: <Widget>[
    //       Image.network(
    //         card.image,
    //         height: 200, // Adjust the image height as needed.
    //         width: double.infinity, // Set image width to match card width.
    //         fit: BoxFit.cover, // Make the image cover the whole space.
    //       ),
    //       Padding(
    //         padding: EdgeInsets.all(16),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             Text(
    //               card.viewCnt.toString(),
    //               style: TextStyle(
    //                 fontSize: 18,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //             SizedBox(height: 8),
    //             Text(
    //               card.likes.toString(),
    //               style: TextStyle(fontSize: 16),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.black,
      //     width: 1,
      //   ),
      // ),
      child: Stack(
        children: [
          Center(
            child: Image.network(
              card.image,
              height: 440, // Adjust the image height as needed.
              width: 257, // Set image width to match card width.
              fit: BoxFit.cover,
              // Make the image cover the whole space.
            ),
          ),
          Positioned(
            top: 7,
            right:20,
            child: Container(
              width: 73,
              height: 21,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: HexColor('#263238'),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/arrow.png',width: 15,height: 10,fit: BoxFit.cover,),
                  Text(' ${card.distance} KM',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white),),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 57,
            right:20,
            child: Container(
              width: 63,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: HexColor('#263238'),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/video_bar.png',width: 17,height: 17,fit: BoxFit.cover,),
                  Text('+${card.countVideos}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white),),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            child: Container(
              width: 277,
              height: 56,
              color: HexColor('#FFFFFF'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Text('Category',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${card.location}',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                      Text('${card.category}',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon( Icons.remove_red_eye_outlined,size: 15,),
                          Text('${card.viewCnt}',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset('assets/images/heart_like.png',width: 13,height: 12,fit: BoxFit.cover,),
                          Text('${card.likes}',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class AllCardsPage extends StatelessWidget {
  final List<CardItem> cards;

  AllCardsPage({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Cards'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var card in cards) Container(
                width: 279,
                child: CardItemWidget(card: card)),
          ],
        ),
      ),
    );
  }
}

class VisitsSection extends StatelessWidget{
  List<String>categories = ['Most recent visits','local visits','Nearby Outings',
  'Solo trips','trips with family',
  'trips with friends','Attended Festivals',
  'food and restaurants','Pubs & Bars','Fashion'];

  List<CardItem> cards = [CardItem(
    // videoUrl: 'http://techslides.com/demos/sample-videos/small.mp4',
    image: 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg',
    viewCnt:  2112,
    location: 'HSR Layout, Sector 4',
    category: 'family Visit',
    likes: 21,
    countVideos: 3,
    distance: '1.9',
  ), CardItem(
      // videoUrl: 'http://techslides.com/demos/sample-videos/small.mp4',
      image: 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg',
      viewCnt:  2112,
      location: 'HSR Layout, Sector 4',
      category: 'family Visit',
      likes: 21,
      countVideos: 4,
      distance: '2.9',
    ), CardItem(
      // videoUrl: 'http://techslides.com/demos/sample-videos/small.mp4',
      image: 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg',
      viewCnt:  2112,
      location: 'HSR Layout, Sector 4',
      category: 'family Visit',
      likes: 21,
      countVideos: 4,
      distance: '0.7',
    ),];

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < categories.length; i++)
            Container(
              // width: 279,
              child: CardSlider(
                category: categories[i],
                cards: cards,
              ),
            ),
        ],
      ),
    );
  }
}

class RatingEntry {
  final String name;
  final int count;
  final String comment;

  RatingEntry({
    required this.name,
    required this.count,
    required this.comment,
  });
}


class RatingSection extends StatefulWidget {
  final List<RatingEntry> ratings;
  final reviewCnt;
  RatingSection({required this.ratings,required this.reviewCnt});

  @override
  _RatingSectionState createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  bool showAllRatings = false;

  @override
  Widget build(BuildContext context) {
    List<RatingEntry> displayedRatings =
    showAllRatings ? widget.ratings : widget.ratings.take(2).toList();

    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.black,
      //     width: 1,
      //   ),
      // ),
      child: Center(
        child: SizedBox(
          width: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Review About You ( ${widget.reviewCnt} )',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'
                ),
              ),
              SizedBox(height: 10),
              widget.reviewCnt==0?
              Text('You did’t receive any review or feedback yet. ',
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins'
                ),)
                  :SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: displayedRatings.map((rating) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rating.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,fontSize: 14,fontFamily: 'Poppins'
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            if(index<rating.count)
                              return Icon(Icons.star, color: HexColor('#FB8C00'),size: 17,);
                            else
                              return Icon(Icons.star, color: Colors.grey,size: 17,);
                          }),
                        ),
                        SizedBox(height: 5),
                        Text(rating.comment,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                        SizedBox(height: 12,),
                      ],
                    );
                  }).toList(),
                ),
              ),
              if (widget.reviewCnt!=0 && widget.ratings.length > 2)
                GestureDetector(
                  onTap: (){
                    setState(() {
                      showAllRatings = !showAllRatings;
                    });
                  },
                  child: Text(showAllRatings ? 'Show Less' : 'View All',style: TextStyle(fontSize: 14,fontFamily:'Poppins',color: HexColor('#FB8C00'),fontWeight: FontWeight.bold),),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class LocationEditor extends StatefulWidget {
  @override
  _LocationEditorState createState() => _LocationEditorState();
}

class _LocationEditorState extends State<LocationEditor> {
  TextEditingController _locationController = TextEditingController();
  String _currentLocation = "Bengaluru"; // Default location

  @override
  void initState() {
    super.initState();
    _locationController.text = _currentLocation;
  }

  Future<void> _editLocation() async {
    LocationPermission permission; permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String city = placemarks.first.locality ?? "Unknown City";
    String state = placemarks.first.administrativeArea ?? "Bengaluru";

    setState(() {
      _currentLocation = "$city";
      _locationController.text = _currentLocation;
    });

    print("Latitude: ${position.latitude}");
    print("Longitude: ${position.longitude}");
    print("State: $state");
    print("City: $city");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 360,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 140,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Icon(Icons.location_on),
                ),
                Text('Location',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                Text(_currentLocation,style: TextStyle(fontSize: 12),),
              ],
            ),
          ),
          GestureDetector(
            onTap: (){
              _editLocation();
            },
            child: Container(
              width: 62,
              height: 61,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text('Autio-Locate',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.orange),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}


class ServiceCard extends StatefulWidget{
  final String titleLabel,iconImage,serviceImage,subTitleLabel,endLabel;
  ServiceCard({
    required this.titleLabel,
    required this.serviceImage,
    required this.iconImage,
    required this.subTitleLabel,
    required this.endLabel,
  });

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>{
  bool buttonState = false;
  void toggleButton(){
    setState(() {
      buttonState = !buttonState;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(widget.titleLabel,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
              IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                showDialog(context: context, builder: (BuildContext context){
                  return Container(child: CustomHelpOverlay(imagePath: widget.iconImage,serviceSettings: false),);
                },
                );
              },
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: Container(

              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(widget.serviceImage,width: 160,height: 89,fit: BoxFit.contain,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(widget.subTitleLabel,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Container(
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                  text: 'Earn Easy'
                              ),
                              TextSpan(
                                text: ' 500 INR',
                                style: TextStyle(fontFamily: 'Poppins',fontSize: 14,color: Colors.green),
                              ),
                              TextSpan(
                                  text: '\nper Call'
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text('*Terms & Conditions applied',style: TextStyle(fontSize: 7,fontFamily: 'Poppins',color: Colors.red),),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(widget.endLabel),
              ConcentricCircles(),
            ],
          ),
        ],
      ),
    );
  }
}


class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  String? selectedProfession;
  DateTime? selectedDateOfBirth;
  String? selectedGender;
  String? selectedLanguage;

  final List<String> professions = [
    'Engineer',
    'Doctor',
    'Teacher',
    'Artist',
    // Add more professions as needed
  ];

  final List<String> genders = ['Male', 'Female', 'Other'];

  final List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
    // Add more languages as needed
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    @override
    void initState() {
      super.initState();
      // Get the device width using MediaQuery and store it in deviceWidth
      screenWidth = MediaQuery.of(context).size.width;
    }

    return Container(
      padding: EdgeInsets.all(10.0),

      child: Column(

        children: [
          CustomDropdown.build(
            label: 'Profession',
            items: professions,
            deviceWidth:screenWidth,
            onChanged: (String? newValue) {
              // Handle the selected value here, if needed
              print('Selected: $newValue');
            },
            setSelectedValue: (String? newValue) {
              // Set the selected value outside the widget
              selectedProfession = newValue;
            },
            selectedValue: selectedProfession, // Pass the selected value to the widget
          ),
          SizedBox(height: 10,),
          CustomDOBDropDown(
            label: 'Date of Birth',
            selectedDate: selectedDateOfBirth,
            deviceWidth: screenWidth,
            onDateSelected: (DateTime? newDate) {
              setState(() {
                selectedDateOfBirth = newDate;
                print('Selected: $newDate');
              });
            },
          ),
          SizedBox(height: 10,),
          CustomDropdown.build(
            label: 'Gender',
            items: genders,
            deviceWidth:screenWidth,
            onChanged: (String? newValue) {
              // Handle the selected value here, if needed
              print('Selected: $newValue');
            },
            setSelectedValue: (String? newValue) {
              // Set the selected value outside the widget
              selectedGender = newValue;
            },
            selectedValue: selectedGender, // Pass the selected value to the widget
          ),
          SizedBox(height: 10,),
          CustomDropdown.build(
            label: 'Language You Know',
            items: languages,
            deviceWidth:screenWidth,
            onChanged: (String? newValue) {
              // Handle the selected value here, if needed
              print('Selected: $newValue');
            },
            setSelectedValue: (String? newValue) {
              // Set the selected value outside the widget
              selectedLanguage = newValue;
            },
            selectedValue: selectedLanguage, // Pass the selected value to the widget
          ),
        ],
      ),
    );
  }
}


class CustomDropdown {

  static Widget build({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Function(String?) setSelectedValue, // Callback for setting the selected value
    String? selectedValue,
    required double deviceWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
        SizedBox(height: 10,),
        Container(
          width: deviceWidth*0.90,
          height: 60,
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            icon: Icon(Icons.arrow_drop_down_circle,color: HexColor('#FB8C00'),),
            hint: Text('Select'),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey), // Change the border color here
              ), // Add an outline border
            ),
            onChanged: (String? newValue) {
              newValue = newValue==''?newValue:selectedValue! +',${newValue}';
              onChanged(newValue); // Call the provided onChanged callback
              setSelectedValue(newValue);
              selectedValue = newValue;  // Set the selected value using the callback
            },
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class CustomDOBDropDown extends StatelessWidget{
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  double deviceWidth;

  CustomDOBDropDown({
    required this.label,
    required this.onDateSelected,
    required this.selectedDate,
    required this.deviceWidth,
  });

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
        SizedBox(height: 10,),
        InkWell(
          onTap: () async {
            DateTime? selected = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            onDateSelected(selected);

          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.grey), // Border style
              borderRadius: BorderRadius.circular(5.0), // Rounded corners
            ),
            width: deviceWidth*0.86,
            height: 55,
            child: Padding(
              padding: const EdgeInsets.only(left: 11.0,right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? "${selectedDate!.toLocal()}".split(' ')[0]
                        : 'Select Date',
                    style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                  Icon(Icons.calendar_today_rounded,color: HexColor('#FB8C00'),), // Calendar icon
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MotivationalQuote extends StatefulWidget{
  @override
  _MotivationalQuoteState createState() => _MotivationalQuoteState();
}
class _MotivationalQuoteState extends State<MotivationalQuote>{

  String? setQuote = '+ Add your Motivational quote';
  bool isQuoteSet = false;
  void handleQuote(String? quote) {
    setState(() {
      setQuote = quote ?? '+ Add your Motivational quote'; // Update the parameter in the main class
      isQuoteSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
              Container(
                width: 260,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> EditQuote(setQuote:handleQuote)));
                  },
                  child:
                  !isQuoteSet?
                  Text(setQuote!,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,color: HexColor('#FB8C00'),fontFamily: 'Poppins',),
                  ):
                  Center(
                    child: Text(setQuote!,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins',),maxLines: 2,overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              !isQuoteSet?
              IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                    showDialog(context: context, builder: (BuildContext context){
                      return Container(child: CustomHelpOverlay(imagePath: 'assets/images/help_motivation_icon.jpg',serviceSettings: false),);
                    },
                  );
                },
              ):SizedBox(width: 0,),
          ],
      ),
    );
  }
}

class ReachAndLocation extends StatelessWidget{
  int followers = 0,following = 0,locations=1;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InfoWidget(icon: Icons.person_add_alt, text: '${followers} Follower'),
        InfoWidget(icon: Icons.person_outline, text: '${following} Following'),
        InfoWidget(icon: Icons.add_location_outlined, text: '${locations} Location'),
      ],
    );
  }
}

class InfoWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  InfoWidget({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // IconButton(padding: EdgeInsets.zero,onPressed: (){},icon: Icon(icon),),
        Icon(icon),
        // SizedBox(height: 4.0),
        Text(text,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
      ],
    );
  }
}

class UserDetailsTable extends StatelessWidget {
  String place = 'NA',profession = 'NA',age = 'NA',gender = 'NA';
  List<String> languageList = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.red,
      //     width: 2.0,
      //   )
      // ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Text('Place - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 96,),
              Text('${place}',style: TextStyle(fontSize: 14),),
            ],
          ),
          Row(
            children: [
              Text('Profession - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 58,),
              Text('${profession}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Age/Gender - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 42,),
              Text(age=='NA'?age:'${age} Yr/ ${gender}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Language - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 60,),
              Container(
                  child: languageList.isEmpty ? Text('NA', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')):
                  Wrap(
                    runSpacing: 8.0, // Vertical spacing between lines of items
                    children: [
                      Row(
                        children: [
                          for (int i = 0; i < languageList.length; i++)
                            Container(
                              margin: EdgeInsets.only(right: 8.0),
                              child: Row(
                                children: [
                                  Text(languageList[i]),
                                  if (i < languageList.length - 1)
                                    Text(',', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpertCardDetails extends StatelessWidget{
  List<String> expertLocations = [];
  String profileStatus = "Out Standing";
  int visitedplace = 0,coveredLocation = 0, ratings = 0;
  @override
  Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: Colors.black,
          //   width: 2,
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              // offset: Offset(0.0,0.0),
              blurRadius: 5.0,
              spreadRadius: 7.9,
            ),
            BoxShadow(
              color: Colors.white,
              // offset: Offset(0.0,0.0),
              blurRadius:5,
              spreadRadius: 12.9,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20.0,top: 5.0,bottom: 9.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Expert Cards' ,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                  IconButton(onPressed: (){}, icon: Icon(Icons.share_outlined)),
                ],
              ),
              Column(
                // crossAxisAlignment: CrossAxisAlignment.end,
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text('Expert in locations -',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 31,),
                      Container(
                        child: expertLocations.isEmpty ? Text('NA', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')):
                        Wrap(
                          runSpacing: 8.0, // Vertical spacing between lines of items
                          children: [
                            Row(
                              children: [
                                for (int i = 0; i < expertLocations.length; i++)
                                  Container(
                                    margin: EdgeInsets.only(right: 8.0),
                                    child: Row(
                                      children: [
                                        Text(expertLocations[i]),
                                        if (i < expertLocations.length - 1)
                                          Text(',', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Text('Visited Places - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 61,),
                      Text('${visitedplace}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Covered Locations - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 23,),
                      Text('${coveredLocation}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Expertise Rating - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 37,),
                      Container(
                        child: ratings == 0
                            ? Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,color: HexColor('#FB8C00'),),
                              SizedBox(width: 5),
                              Text('N/A'),
                            ],
                          ),
                        )
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(ratings, (index) {
                            return Icon(Icons.star, color: HexColor('#FB8C00'));
                          }),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40,),
                  Row(
                    children: [
                      Text('Your Culturtap Status',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 30,),
                      Container(
                        child: profileStatus=='Out Standing'?
                        Text(profileStatus,style: TextStyle(color: HexColor('#0A8100'),fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),):
                        Text('Working',style: TextStyle(color: Colors.red,fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}

class ProfielStatusAndButton  extends StatelessWidget{
  final int reqPages;
  ProfielStatusAndButton({required this.reqPages});

  @override
  Widget build(BuildContext context) {
    final profileDataProvider = Provider.of<ProfileDataProvider>(context);

    void sendDataToBackend () async{
      final profileData = profileDataProvider.profileData.toJson();
      final url = Uri.parse('');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body:json.encode(profileData),
      );

      if (response.statusCode == 201) {
        print('Data saved successfully');
      } else {
        print('Failed to save data: ${response.statusCode}');
      }

    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Container(
            width: 400,
            height: 70,
            child: FilledButton(
                backgroundColor: HexColor('#FB8C00'),
                onPressed: () {
                  sendDataToBackend;
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteProfilePage(),));
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

class FilledButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  final Color backgroundColor;

  const FilledButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape:RoundedRectangleBorder(),
        primary: backgroundColor,
      ),
      child: child,
    );
  }
}

