import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'hexColor.dart';

class ImageUtil{
  static Future<File?> pickAndCropImage() async{
    final pickedFile = await ImagePicker().pickImage(source :ImageSource.gallery);
    if(pickedFile != null){
      return _cropImage(File(pickedFile.path));
    }
    return null;
  }

  static Future<File?> _cropImage(File imageFile) async{
    try{
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 2),
        cropStyle: CropStyle.circle,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        maxHeight:132,
        maxWidth: 132,
        compressFormat:ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: HexColor('#FB8C00'),
            toolbarTitle: 'Crop Image',
            statusBarColor: HexColor('#FB8C00'),
            backgroundColor: HexColor('#FB8C00'),
          ),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path); // Convert CroppedFile to File
      }
    }catch (e) {
      print('Error cropping image: $e');
    }
    return null;
  }
}
