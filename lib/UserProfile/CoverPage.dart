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
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../widgets/hexColor.dart';
import '../BackendStore/BackendStore.dart';
import 'ProfileHeader.dart';

typedef void ImageCallback(File image);


// BackGround Video Set By User : Have To Work
class CoverPage extends StatelessWidget {
  final bool hasVideoUploaded = false; // Replace with backend logic
  final int reqPage;
  final String? imagePath;
  final String? name;
  final ProfileDataProvider? profileDataProvider;
  String ?image;
  CoverPage({required this.reqPage,this.profileDataProvider,this.imagePath,this.name,this.image});

  @override
  Widget build(BuildContext context) {
    return UserImage(reqPages: reqPage,profileDataProvider: profileDataProvider!,imagePath:imagePath,name: name,image:image);
  }
}



// Image Section
class UserImage extends StatefulWidget {
  final int reqPages;
  final ProfileDataProvider? profileDataProvider;
  final String? name;// Pass the profileDataProvider here
  final String? imagePath,image;
  UserImage({required this.reqPages, this.profileDataProvider,this.imagePath,this.name,this.image});
  @override
  _UserImageState createState() => _UserImageState();
}
class _UserImageState extends State<UserImage>{

  File? _userProfileImage;

  void handleImageUpdated(File image) {
    setState(() {
      _userProfileImage = image; // Update the parameter in the main class
      widget.profileDataProvider?.updateImagePath((image.path)!); // Update image path in the provider
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
                              fit: BoxFit.contain,
                              color: Colors.orange,// Adjust the fit as needed
                            ),
                          ):Column(
                            children:[
                              Container(
                                child: Image.asset(
                                  'assets/images/video_icon.png', // Replace with the actual path to your asset image
                                  width: 35, // Set the desired image width
                                  height: 35, // Set the desired image height
                                  fit: BoxFit.contain,
                                  color: Colors.orange,// Adjust the fit as needed
                                ),
                              ),
                              Text('Add your cover'),
                              Text('Expereince via video here !',style: TextStyle(fontSize: 18,color: Color(0xFF263238),fontFamily: 'Poppins'),
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
                    child: IconButton(icon:Icon(Icons.help_outline),color: Colors.orange,onPressed: (){
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
                        child: widget.imagePath!=null?
                        widget.image=='network'
                        ?CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(widget.imagePath!), // Replace with the actual image URL
                        )
                        : CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(File(widget.imagePath!)) as ImageProvider<Object>,
                        )
                            : _userProfileImage!=null?
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
                          width: 38,
                          height: 35,
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
                  widget.name!=null?widget.name!:'', // Replace with actual user name
                  style: TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ):EditNameForm(profileDataProvider:widget.profileDataProvider!,name:widget.name==null?'Hemant Singh':widget.name!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Image Uploading Optoins
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
                              Text('Upload',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Color(0xFF263238),decoration: TextDecoration.none,),),
                              Icon(Icons.arrow_forward_rounded,color: Color(0xFF263238),),
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
                            color: Color(0xFF263238), // Set the border color
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
                              Text('Open Camera',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Color(0xFF263238),decoration: TextDecoration.none,),),
                              Icon(Icons.arrow_forward_rounded,color: Color(0xFF263238),),
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



// Edit Name
class EditNameForm extends StatefulWidget {
  final ProfileDataProvider profileDataProvider;
  final String name;
  EditNameForm({required this.profileDataProvider,required this.name});
  @override
  _EditNameFormState createState() => _EditNameFormState();
}
class _EditNameFormState extends State<EditNameForm> {
  TextEditingController nameController = TextEditingController();
  // String editedName = ""; // Stores the edited name
  bool isEditing = false;
  String userName='';
  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    userName = widget.name;
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
              style: TextStyle(fontSize: 18.0,color: Color(0xFF263238),fontWeight: FontWeight.w500,fontFamily: 'Poppins'),
            ),
          )
              : Text(
            userName,
            style: TextStyle(fontSize: 18.0,color: Color(0xFF263238),fontWeight: FontWeight.bold,fontFamily: 'Poppins'),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.save_outlined : Icons.edit_outlined,color: Color(0xFF263238),),
            onPressed: toggleEdit,
          ),
        ],
      ),
    );
  }
}
