import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

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
        maxHeight:132,
        maxWidth: 132,
        compressFormat:ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: Color(0xFF42A5F5),
            toolbarTitle: 'Crop Image',
            statusBarColor: Color(0xFF42A5F5),
            backgroundColor: Color(0xFF42A5F5),
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
