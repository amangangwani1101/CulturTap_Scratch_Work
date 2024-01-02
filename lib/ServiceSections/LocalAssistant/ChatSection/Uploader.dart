import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn_flutter/ServiceSections/LocalAssistant/check.dart';
import 'package:learn_flutter/widgets/03_imageUpoad_Crop.dart';

class UploadMethod extends StatefulWidget{
  @override
  State<UploadMethod> createState() => _UploadMethodState();
}
class _UploadMethodState extends State<UploadMethod> {

  File? _userProfileImage;
  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _userProfileImage = File(pickedFile.path);
      });
    }
  }
  // upload from gallery
  Future<void> _updateProfileImage() async{
    final croppedImage = await ImageUtil.pickAndCropImage();

    if(croppedImage!=null){
      setState(() {
        _userProfileImage = croppedImage;
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
                color: Colors.grey.withOpacity(0.1),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 411,
                height: 400,
                color: Theme.of(context).backgroundColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.83,
                        child: Container(
                          child: Text('Attach document and create payment link',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.black,decoration: TextDecoration.none),),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.82,
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                height: 90,
                                child: GestureDetector(
                                  onTap: ()async{
                                    String ?path = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AttachmentButton(option:1),
                                      ),
                                    );
                                    Navigator.of(context).pop(path!);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Container(child: Text('Upload & send document, bill, prescription etc',
                                        style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.normal,color: Colors.black,decoration: TextDecoration.none,),))),
                                      Image.asset('assets/images/arrow_fwd.png',color: Colors.black,width: 13,height: 13,),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black, // Set the border color
                                      width: 1.0, // Set the border width
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 90,
                                child: GestureDetector(
                                  onTap: ()async{
                                    String ? path = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AttachmentButton(option:2),
                                      ),
                                    );
                                    Navigator.of(context).pop(path!);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Container(child: Text('Upload Invoice & Create payment link',style: TextStyle(fontSize: 16,fontFamily: 'Poppins',fontWeight: FontWeight.normal,color: Colors.black,decoration: TextDecoration.none,),))),
                                      Image.asset('assets/images/arrow_fwd.png',color: Colors.black,width: 13,height: 13,),
                                    ],
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
                              Container(
                                height: 90,
                                width: 300,
                                child: GestureDetector(
                                  onTap: ()async{
                                    String ?path = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AttachmentButton(option:3),
                                      ),
                                    );
                                    Navigator.of(context).pop(path!);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Container(child: Text('Create payment link directly',style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,fontFamily: 'Poppins',color: Colors.black,decoration: TextDecoration.none,),))),
                                      Image.asset('assets/images/arrow_fwd.png',color: Colors.black,width: 13,height: 13,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
