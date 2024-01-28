import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn_flutter/CustomItems/CustomPopUp.dart';
import 'package:learn_flutter/CustomItems/imagePopUpWithOK.dart';
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
  String? name;
  final ProfileDataProvider? profileDataProvider;
  String ?image;
  CoverPage({required this.reqPage,this.profileDataProvider,this.imagePath,this.name,this.image});

  @override
  Widget build(BuildContext context) {
    // return Container(height:20, child: Text('Hello'));
    return UserImage(reqPages: reqPage,profileDataProvider: profileDataProvider,imagePath:imagePath,name: name,image:image);
  }
}

String capitalizeWords(String input) {
  List<String> words = input.split(' ');
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1);
    }
  }
  return words.join(' ');
}



// Image Section
class UserImage extends StatefulWidget {
  final int reqPages;
  final Function(String)? imagePathCallback,nameCallback;
  final ProfileDataProvider? profileDataProvider;
  final String? name;// Pass the profileDataProvider here
   String? imagePath,image,text;
  UserImage({required this.reqPages, this.profileDataProvider,this.imagePath,this.name,this.image,this.nameCallback,this.imagePathCallback,this.text});
  @override
  _UserImageState createState() => _UserImageState();
}
class _UserImageState extends State<UserImage>{

  File? _userProfileImage;



  void handleImageUpdated(File image) {
    print('Updated Image :${image.path}');
    setState(() {
      _userProfileImage = image; // Update the parameter in the main class
    });
    print('Updated Image :${_userProfileImage?.path}');
    if (widget.text=='edit'){
      widget.imagePathCallback!((image.path)!);
    }
    else if(widget.profileDataProvider!=null)
      widget.profileDataProvider?.updateImagePath((image.path)!); // Update image path in the provider
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVideoUploaded = false; // Replace with backend logic
    print('Name is ${widget.name}');
    return Container(
      padding: EdgeInsets.only(left: 10,right: 10),
      height: 262,
      color: Theme.of(context).backgroundColor,
      // decoration: BoxDecoration(
      //   border:Border.all(color: Colors.red),
      // ),
      child: Stack(
        children: [
          Container(
            height: 161,
            child:Stack(
              children: [
                !hasVideoUploaded
                ? Container(
                  color : Theme.of(context).primaryColorLight,
                  width: 373,
                  padding: EdgeInsets.only(top: 10),
                  child: Column(
                    mainAxisAlignment: widget.reqPages<1 ? MainAxisAlignment.center:MainAxisAlignment.start,
                    children: [
                      widget.reqPages<1
                      ? Container(
                        child: Image.asset(
                          'assets/images/video_icon.png', // Replace with the actual path to your asset image
                          width: 35, // Set the desired image width
                          height: 35, // Set the desired image height
                          fit: BoxFit.contain, // Adjust the fit as needed
                        ),
                      )
                      :Column(children:[
                          Container(
                            child: Image.asset(
                              'assets/images/video_icon.png', // Replace with the actual path to your asset image
                              width: 35, // Set the desired image width
                              height: 35, // Set the desired image height
                              fit: BoxFit.contain, // Adjust the fit as needed
                            ),
                          ),
                          Text('Add your cover'),
                          Text('Expereince via video here !',style: Theme.of(context).textTheme.subtitle1,),

                        ],),
                    ],
                  ),
                )
                : Container(
                  width: 373,
                  color: Colors.grey, // Replace with your video player or widget
                ),
                Positioned(
                  top: 5,
                  right: 10,
                  child: IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return CustomPopUp(
                          imagePath: "assets/images/coverStoryPopup.svg",
                          textField: "Set Your Cover Story !" ,
                          extraText:'Upload or create here the most thrilled experience you have, for your future audience!' ,
                          what:'OK',
                          button : "OK, Get it"
                        );
                      },
                    );

                  },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 160,
              // decoration: BoxDecoration(
              //   border:Border.all(color: Colors.green),
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 132,
                        height: 132,
                        padding: widget.imagePath!=null || _userProfileImage!=null ?EdgeInsets.all(0) : EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.imagePath!=null || _userProfileImage!=null ? Colors.transparent:Colors.white,
                          // border: Border.all(
                          //   color: Theme.of(context).backgroundColor, // Border color
                          //   width: 15.0, // Border width
                          // ),
                        ),
                        child: widget.imagePath!=null && _userProfileImage==null
                          ? widget.image=='network'
                            ? CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(widget.imagePath!), // Replace with the actual image URL
                        )
                            : CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(File(widget.imagePath!)) as ImageProvider<Object>,
                        )
                          : _userProfileImage!=null
                            ? CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(_userProfileImage!),
                        )
                            : CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/images/user.png'),
                          backgroundColor: Colors.white,// Replace with user avatar image
                        ),
                      ),
                      if (widget.reqPages<1) SizedBox(height: 0,) else
                        Positioned(
                          bottom: 0,
                          right: 0,
                        child: InkWell(
                          onTap: (){
                            widget.text!='edit'
                                ? showDialog(context: context, builder: (BuildContext context){
                              return Container(child: UploadMethods(onImageUpdated : handleImageUpdated));
                            },)
                                :showDialog(context: context, builder: (BuildContext context){
                              return Container(child: UploadMethods(onImageUpdated : handleImageUpdated));
                            },);
                          },
                          child: Container(
                            width: 36,
                            height: 34,
                            decoration: BoxDecoration(color: Colors.orange,borderRadius: BorderRadius.circular(50),),
                            child: widget.text!='edit'
                                ? Center(
                              child: Icon(Icons.camera_alt_outlined,color: Colors.white ,),
                            )
                                : Center(
                              child: Icon(Icons.edit_outlined,color: Colors.white,),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  widget.reqPages<1?
                  Container(
                    height: 21,
                    child: Text(
                      widget.name!=null?capitalizeWords(widget.name!):'', // Replace with actual user name
                      style: TextStyle(
                        color : Theme.of(context).primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ):Container(
                    height: 21,
                    child: EditNameForm(text: widget.text,profileDataProvider:widget.profileDataProvider,name:widget.name==null?'':capitalizeWords(widget.name!),callback: (value){
                      widget.nameCallback!(value);
                    },),
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
      print('we have picked the file');
      // Call the callback to update the parameter in the parent class
      widget.onImageUpdated(File(pickedFile.path));
      print('here is profile image data');
      print(pickedFile.path);
      await uploadImage(pickedFile.path);
    }
  }

  Future<void> _updateProfileImage() async {
    final croppedImage = await ImageUtil.pickAndCropImage();
    if (croppedImage != null) {
      print('cropped image here');
      // Call the callback to update the parameter in the parent class
      widget.onImageUpdated(croppedImage);
      print('here is profile image data');
      print(croppedImage.path);
      await uploadImage(croppedImage.path);
    }
  }

  Future<void> uploadImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://173.212.193.109:8080/main/api/uploadImage'),
      )

        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: 'image.webp', // Adjust the filename as needed
          ),
        );



      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
    } catch (e) {
      print('Error uploading image: $e');
    }
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
                color: Theme.of(context).backgroundColor,
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


// Edit Name
class EditNameForm extends StatefulWidget {
  final ProfileDataProvider? profileDataProvider;
  final String? name,text;
  final Function(String)? callback;
  EditNameForm({this.profileDataProvider,this.name,this.callback,this.text});
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
    nameController.text = (widget.name!);
    userName = (widget.name!);
    print('Init Run');
  }

  void toggleEdit() {
    setState(() {
      print('Toggle Run');
      isEditing = !isEditing;
      if (!isEditing) {
        if(nameController.text.length<1){
          isEditing = !isEditing;
          print('Name is too small');
        }else{
          // Save the edited name when exiting edit mode
          userName = capitalizeWords(nameController.text);
          // Here, you can send the updated name to your backend for processing
          // For demonstration, we'll just print it
          print("Updated Name: $userName");
        }
      }
    });
    if(widget.text=='edit'){
      widget.callback!(userName);
    }
    else if(widget.profileDataProvider!=null)
      widget.profileDataProvider?.updateName(userName);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: toggleEdit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: 15,),
          isEditing
            ? Container(
          width: 200,
          child: TextField(
            controller: nameController,
            enableSuggestions: true,
            clipBehavior: Clip.antiAlias,
            cursorColor: Colors.orange,
            textCapitalization: TextCapitalization.words,
            onChanged: (value){
              userName = value;
            },
            style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w500,fontFamily: 'Poppins'),
          ),
        )
            : Text(
            userName!=null?userName:'',
            style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),
          ),
            SizedBox(width: 10,),
            InkWell(
              child: Icon(isEditing ? Icons.save_as_outlined : Icons.edit_outlined,color: Colors.black),
          ),
        ],
      ),
    );
  }
}
