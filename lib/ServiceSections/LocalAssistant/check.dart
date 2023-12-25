import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';
import 'package:open_file/open_file.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:share/share.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

class AttachmentButton extends StatefulWidget {
  int? option;
  AttachmentButton({this.option});
  @override
  _AttachmentButtonState createState() => _AttachmentButtonState();
}

class _AttachmentButtonState extends State<AttachmentButton> {
  File? _pickedFile;
  int _pdfPage = 0;
  TextEditingController _textController = TextEditingController();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    setState(() {
      if (result != null) {
        _pickedFile = File(result.files.single.path!);

        // Check if the selected file is not a PDF, then convert it to PDF
        if (!_pickedFile!.path.toLowerCase().endsWith('.pdf')) {
          // You may need to replace 'path/to/converted/pdf' with the actual path
          // where you want to store the converted PDF file.
          final convertedPdfPath = 'path/to/converted/pdf';

          // Assuming you have a function to convert to PDF (you need to implement this)
          convertToPdf(_pickedFile!, convertedPdfPath);

          // Set the converted PDF as the picked file
          _pickedFile = File(convertedPdfPath);
        }

        // Reset PDF page when a new file is picked
        _pdfPage = 0;
      }
    });
  }
  Future<void> _takePhoto() async {
    final imageFile = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (imageFile != null) {
        _pickedFile = File(imageFile.path);
      }
    });
  }
  void _goFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenView(imagePath: _pickedFile!.path),
      ),
    );
  }

  void func(){

  }
  Widget _buildAttachmentWidget() {
    if (_pickedFile != null) {
      final filePath = _pickedFile!.path;
      if (filePath.toLowerCase().endsWith('.jpg') ||
          filePath.toLowerCase().endsWith('.jpeg') ||
          filePath.toLowerCase().endsWith('.png')) {
        // Display image for image files using PhotoView
        return Container(
          height: 300,
          child: Stack(
            children: [
              PhotoView(
              imageProvider: FileImage(_pickedFile!),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              customSize: Size.fromHeight(300),
              ),
              Positioned(
                top: 8.0,
                right: 8.0,
                child: IconButton(
                  icon: Icon(Icons.fullscreen),color: Colors.orange,
                  onPressed: () {
                    // Open in full-screen
                    _goFullScreen(context);
                  },
                ),
              ),
            ],
          ),
        );
      } else if (filePath.toLowerCase().endsWith('.pdf')) {
        // Display PDF preview for PDF files
        return Container(
          height: 300,
          child: PDFView(
            filePath: _pickedFile!.path,
            // onPageChanged: (int page, int total) {
            //   setState(() {
            //     _pdfPage = page;
            //   });
            // },
          ),
        );
      } else {
        // Handle other file types
        return Text("Selected File: ${_pickedFile!.path}");
      }
    } else {
      return Container();
    }
  }
  void _openFileWithDefaultApp() {
    if (_pickedFile != null) {
      print(_pickedFile);
      OpenFile.open(_pickedFile!.path);
    }
  }

  void _shareFile() {
    if (_pickedFile != null) {
      Share.shareXFiles([XFile(_pickedFile!.path)]);
    }
  }

  // Function to convert a non-PDF file to PDF (you need to implement this)

  Future<void> convertToPdf(File inputFile, String outputPath) async {
    // Implement the logic to convert the inputFile to PDF and save it to outputPath
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 1,userId: '652a31f77ff9b6023a14838a',),backgroundColor: Colors.white,automaticallyImplyLeading: false,),

        body: SingleChildScrollView(
          child: Row(
            children: [
              widget.option==1?SizedBox(width: 30,):SizedBox(width: 0,),
              Column(
                children: [
                  widget.option==3?SizedBox(height: 0,):Container(
                    width: widget.option==1?293:257,
                    height: widget.option==1?549:360,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the picked attachment
                        // _buildAttachmentWidget(),
                        Container(child: widget.option==1
                              ?Text('Document')
                              :Text('Invoice')),
                        Stack(
                          children: [
                            GestureDetector(
                                onTap: (){
                                    // Show dialog to choose file manager or take a photo
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Choose an option"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                _pickFile();
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("File Manager"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _takePhoto();
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Take Photo"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                },
                                child: Align(
                                  alignment: widget.option==1?Alignment.centerLeft:Alignment.center,
                                  child: Container( width: widget.option==1?293:202, height: widget.option==1?480:274,color: Colors.grey.withOpacity(0.5),
                                  child: _pickedFile!=null
                                      ?(_pickedFile!.path.toLowerCase().endsWith('.jpg') ||
                                      _pickedFile!.path.toLowerCase().endsWith('.jpeg') ||
                                      _pickedFile!.path.toLowerCase().endsWith('.png'))
                                        ?PhotoView(
                                    imageProvider: FileImage(_pickedFile!),
                                    minScale: PhotoViewComputedScale.contained,
                                    maxScale: PhotoViewComputedScale.covered * 2,
                                  )
                                        :PDFView(
                                            filePath: _pickedFile!.path,
                                        )
                                      :Center(child: Text('Select File From Device'),),
                                  ),
                                ),
                            ),
                            _pickedFile!=null ? Positioned(top:8.0,right:widget.option==1?1:30,
                                child: Container(
                                  width: 67,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          print(_pickedFile!.path);
                                          // if(_pickedFile!.path.endsWith('.pdf')){
                                          //   print(1);
                                          //   _openFileWithDefaultApp;
                                          // }
                                          // else{_goFullScreen(context);}
                                        },
                                        child: Image.asset('assets/images/full_screen_icon.png',color:_pickedFile!=null?Colors.orange:Colors.black,errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                          return GestureDetector(
                                              onTap: (){
                                                if(_pickedFile!.path.endsWith('.pdf')){
                                                  print(1);
                                                  _openFileWithDefaultApp;
                                                }
                                                else{_goFullScreen(context);}
                                              },
                                              child: Text('[ ]',style: TextStyle(color: _pickedFile!=null?Colors.orange:Colors.black),));},),
                                      ),
                                      GestureDetector(
                                        onTap: ()async{
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Are you sure ? \n you are removing document. "),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _pickedFile= null;
                                                      });
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text("Yes"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text("No"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Image.asset('assets/images/close_icon.png',color: _pickedFile!=null?Colors.orange:Colors.black,
                                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                            return Text('X');},),
                                      ),
                                    ],
                                  ),
                                ),
                            ) : SizedBox(height: 0,),
                            _pickedFile!=null?Positioned(bottom:8.0,right:widget.option==1?1:38,
                                child:GestureDetector(
                                  onTap: (){
                                    _shareFile();
                                  },
                                  child: Image.asset('assets/images/share.png',color: _pickedFile!=null?Colors.orange:Colors.black,
                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                    return Text('Share',style:TextStyle(color: _pickedFile!=null?Colors.orange:Colors.black),);},),
                                ),
                            ):SizedBox(height: 0,),
                          ],
                        ),
                        // Buttons to pick file, open with default app, and share
                        // ElevatedButton(
                        //   onPressed: () {
                        //     // Show dialog to choose file manager or take a photo
                        //     showDialog(
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         return AlertDialog(
                        //           title: Text("Choose an option"),
                        //           actions: [
                        //             TextButton(
                        //               onPressed: () {
                        //                 _pickFile();
                        //                 Navigator.of(context).pop();
                        //               },
                        //               child: Text("File Manager"),
                        //             ),
                        //             TextButton(
                        //               onPressed: () {
                        //                 _takePhoto();
                        //                 Navigator.of(context).pop();
                        //               },
                        //               child: Text("Take Photo"),
                        //             ),
                        //           ],
                        //         );
                        //       },
                        //     );
                        //   },
                        //   child: Text("Attach"),
                        // ),
                        // ElevatedButton(
                        //   onPressed: _openFileWithDefaultApp,
                        //   child: Text("Open with Default App"),
                        // ),
                        // ElevatedButton(
                        //   onPressed: _shareFile,
                        //   child: Text("Share"),
                        // ),
                      ],
                    ),
                  ),
                  widget.option==1?SizedBox(height: 0,):SizedBox(height: 30,),
                  widget.option==1?SizedBox(height: 0,):Container(
                    width: 347,
                    height: 150,
                    child: Row(
                      children: [
                        SizedBox(width: 30,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 37,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Text('Add Payment Link',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                                  Text('You can request money from requestee',style: TextStyle(fontSize: 14,fontFamily: 'Popins'),),
                                ],
                              ),
                            ),
                            Container(
                              height: 83,
                              width: 290,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('  Amount',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                  TextField(
                                    controller: _textController,
                                    decoration: InputDecoration(
                                      hintText: 'Ex 15.32',
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20.0),  // Set border color
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                        borderSide: BorderSide(color: Colors.orange), // Set focused border color
                                      ),
                                      prefixIconColor: Colors.black,
                                      prefixIcon: Icon(Icons.currency_rupee),
                                      // Icon as a prefix
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30,),
                  _pickedFile!=null || widget.option==3
                  ? GestureDetector(
                    onTap: (){
                      if(_pickedFile!=null){
                        Navigator.of(context).pop(_pickedFile!.path);
                      }
                    },
                    child: Container(
                      width: 295,
                      height: 63,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orange,
                      ),
                      child: Center(child:Text('SEND',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18))),
                    ),
                  ) : SizedBox(height: 0,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _textController.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }
}

class FullScreenView extends StatelessWidget {
  final String imagePath;

  const FullScreenView({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Full Screen View"),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: FileImage(File(imagePath)),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
