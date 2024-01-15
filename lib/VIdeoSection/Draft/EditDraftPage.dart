import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/CustomItems/imagePopUpWithOK.dart';
import 'package:learn_flutter/Settings.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:learn_flutter/VIdeoSection/ComposePage.dart';
import 'package:learn_flutter/VIdeoSection/Draft/AddCamera.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/VideoPreviewPage.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/database_helper.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/CustomItems/loading_dialog.dart';
import 'package:learn_flutter/CustomItems/pulseUpload.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/VideoPreviewPage.dart';

import 'package:video_player/video_player.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/database_helper.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:learn_flutter/CustomItems/imagePopUpWithOK.dart';
import 'dart:convert';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/video_database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class VideoGridItem extends StatefulWidget {
  final int videoNumber;
  final VideoPlayerController controller;
  final Function()? onRemovePressed;

  VideoGridItem({
    required this.videoNumber,
    required this.controller,
    this.onRemovePressed,
  });
  @override
  _VideoGridItemState createState() => _VideoGridItemState();
}

class _VideoGridItemState extends State<VideoGridItem> {
  late VideoPlayerController _videoController;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _videoController = widget.controller;
    _isPlaying = false;
    setState(() {

    });

    // Add listener to toggle play/pause on video controller state changes
    // _videoController.addListener(() {
    //   setState(() {
    //     _isPlaying = _videoController.value.isPlaying;
    //   });
    // });

  }





  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleFullScreen() {
    // Implement code to toggle fullscreen here
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _togglePlayPause();
        },
        onLongPress: () {
          _toggleFullScreen();
        },
        child : Container(
          width: 250,
          height: 300,
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                VideoPlayer(_videoController),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: _togglePlayPause,

                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 40.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Text(
                        widget.videoNumber.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 2.0,
                  right: 2.0,
                  child: IconButton(
                    onPressed:(){},
                    icon: Icon(
                      Icons.highlight_remove_rounded,
                      size: 30.0,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )



    );
  }

}

class EditDraftPage extends StatefulWidget {
  final Draft draft;

  EditDraftPage({required this.draft});

  @override
  _EditDraftPageState createState() => _EditDraftPageState();
}

class _EditDraftPageState extends State<EditDraftPage> {
  late VideoPlayerController _thumbnailController;
  List<VideoPlayerController> videoPathsEditCompose = [];
  String liveLocation = '';

  String selectedLabel = '';
  String selectedCategory = '';
  String selectedaCategory = '';
  String selectedGenre = '';
  String storyTitle = '';
  String productDescription = '';
  String experienceDescription = '';
  String dontLikeAboutHere = '';
  String reviewText = '';
  int starRating = 0;
  String selectedVisibility = '';

  List<String> selectedLoveAboutHere = [];
  bool showOtherLoveAboutHereInput = false;
  String selectedOption = '';
  String transportationPricing = '';
  String productPricing = '';
  String festivalName = '';
  String fashionType = '';
  String foodType = '';
  String restaurantType = '';
  String otherGenre = '';
  String otherCategory = '';
  bool isFoodFamous = false;
  bool isRestaurantFamous = false;
  bool isFashionFamous = false;



  TextEditingController storyTitleController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController experienceDescriptionController = TextEditingController();
  TextEditingController dontLikeAboutHereController = TextEditingController();
  TextEditingController reviewTextController = TextEditingController();
  TextEditingController loveAboutHereInputController = TextEditingController();
  TextEditingController selectedOptionController = TextEditingController();
  TextEditingController transportationPricingController = TextEditingController();
  TextEditingController festivalNameController = TextEditingController();
  TextEditingController restaurantTypeController = TextEditingController();
  TextEditingController otherGenreController = TextEditingController();
  TextEditingController otherCategoryController = TextEditingController();
  TextEditingController foodTypeController = TextEditingController();
  TextEditingController fashionTypeController = TextEditingController();


  bool isSaveDraftClicked = false;
  bool isPublishClicked = false;

  final List<String> loveAboutHereOptions = [
    'Beautiful',
    'Calm',
    'Party Place',
    'Pubs',
    'Restaurant',
    'Others',
  ];


  double firstVideoLatitude = 0.0;
  double firstVideoLongitude = 0.0;


  double userLatitude = 0.0;
  double userLongitude = 0.0;
  List<String> finalVideoPaths = [];




  Future<void> uploadCompressedVideos(List<File> videoPaths, BuildContext context) async {
    try {





      List<String> compressedPaths = [];

      // Compress videos
      for (int i = 0; i < videoPaths.length; i++) {
        String compressedVideoPath = await compressVideo(videoPaths[i]);
        compressedPaths.add(compressedVideoPath);
        print('videopaths after compression $compressedPaths');
      }

      // Upload compressed videos
      final String serverUrl = 'http://173.212.193.109:8080/main/api/uploadVideos';
      final request = http.MultipartRequest('POST', Uri.parse(serverUrl));

      print('compressedPaths.length ${compressedPaths.length}');
      for (int i = 0; i < compressedPaths.length; i++) {
        // Extract filename and extension from the path
        String filename = 'culturTap.com_${path.basename(compressedPaths[i])}';
        String extension = path.extension(compressedPaths[i]);
        finalVideoPaths.add(filename);
        print('filename is : $filename');
        print('extension is : $extension');

        // Append filename and extension to the request
        request.files.add(
          await http.MultipartFile.fromPath('videos', compressedPaths[i],
              filename: filename, contentType: MediaType('video', extension)),
        );
      }

      final response = await request.send();

      // Close loading popup


      if (response.statusCode == 201) {
        // Successfully uploaded all compressed videos.
        // You can now save their URLs to MongoDB.
        // Add the logic to save video URLs to your MongoDB database here.
        print('Compressed videos successfully uploaded to the server');
        showDialog(
          context: context,
          builder: (context) {
            return ImagePopUpWithOK(
              imagePath: "assets/images/storyUploaded.svg",
              textField: "Your Story is Successfully Uploaded",
              what:"home",
              isDarkMode:"dark",



            );
          },
        );

      } else {
        print('Failed to upload compressed videos. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> compressVideo(File videoFile) async {
    String outputDirectory = '/root/videos';
    String outputFileName = 'video.mp4';

    String outputPath = '$outputDirectory/$outputFileName';

    FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();

    // Run FFmpeg command to compress the video
    int rc = await flutterFFmpeg.execute(
        '-i ${videoFile.path} -b:v 1500k -max_muxing_queue_size 1024 $outputPath');

    if (rc == 0) {
      // Compression successful
      return outputPath;
    } else {
      print('compression failed');
      // Compression failed
      return videoFile.path;
    }
  }


  List<File> convertPathsToFiles(List<String> videoPaths) {
    List<File> videoFiles = [];
    for (String path in videoPaths) {
      videoFiles.add(File(path));
    }
    return videoFiles;
  }



  Future<void> sendDataToBackend() async {


    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );

    var videoPaths = widget.draft.videoPaths.split(',');
    List<File> videoFiles = convertPathsToFiles(videoPaths);
    await uploadCompressedVideos(videoFiles,context);


    print('final video paths $videoPathsEditCompose');
    print('publish button clicked');
    try{
      VideoDatabaseHelper myDatabaseHelper = VideoDatabaseHelper();

      await myDatabaseHelper.deleteAllVideos();


      final data = {
        "singleStoryData": {
          "videoPath": videoFiles,
          "latitude": firstVideoLatitude,
          "longitude": firstVideoLongitude,
          "location": liveLocation,
          "expDescription": experienceDescription,
          "placeLoveDesc": selectedLoveAboutHere.join(','),
          "dontLikeDesc": dontLikeAboutHere,
          "review": reviewText,
          "starRating": starRating,
          "selectedVisibility": selectedVisibility,
          "storyTitle": storyTitle,
          "productDescription": productDescription,
          "liveLocation" : liveLocation,
          "selectedOption": selectedOption,
          "productPrice": productPricing,
          "transportationPricing": transportationPricing,
          "label": selectedLabel,
          "category": selectedCategory,
          "businessCategory":selectedaCategory,
          "genre": selectedGenre,
          "userID" : userID,
          "userName" : userName,
        },
        "label": selectedLabel,
        "category": selectedCategory,
        "genre": selectedGenre,
        "userID" : userID,
      };


      print('printing data $data');

      final String serverUrl = 'http://173.212.193.109:8080/main/api/publish';

      final http.Response response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode(data),
      );

      print('Response: ${response.statusCode} ${response.reasonPhrase}');

      if (response.statusCode == 201) {
        print('Data sent successfully yes yes');
        print('Response Data: ${response.body}');




      } else {
        print('Failed to send data. Error: ${response.reasonPhrase}');
      }
    }catch(error){
      print("Error: $error");
    }

  }





  @override
  void initState() {

    super.initState();
    // Initialize the VideoPlayerController with the first video of the draft

    var videoPaths = widget.draft.videoPaths.split(',');
    for (var path in videoPaths) {
      final controller = VideoPlayerController.network(path)
        ..initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      videoPathsEditCompose.add(controller);
    }

    // Populate the fields with data from the draft
    selectedLabel = widget.draft.selectedLabel;
    selectedGenre = widget.draft.selectedGenre;
    selectedCategory = widget.draft.selectedCategory;
    storyTitleController.text = widget.draft.storyTitle;
    productDescriptionController.text = widget.draft.productDescription;
    experienceDescriptionController.text = widget.draft.experienceDescription;
    dontLikeAboutHereController.text = widget.draft.dontLikeAboutHere;
    reviewTextController.text = widget.draft.reviewText;
    starRating = widget.draft.starRating;
    selectedLoveAboutHere = widget.draft.selectedLoveAboutHere.split(',');
    selectedOption = widget.draft.selectedOption;
    selectedaCategory = widget.draft.selectedaCategory;
    transportationPricingController.text = widget.draft.transportationPricing;
    selectedVisibility = widget.draft.selectedVisibility;


    liveLocation = widget.draft.liveLocation;
    festivalNameController.text = widget.draft.festivalName;
    foodTypeController.text = widget.draft.foodType;
    restaurantTypeController.text = widget.draft.restaurantType;
    otherGenreController.text = widget.draft.otherGenre;
    otherCategoryController.text = widget.draft.otherCategory;




    // Initialize the draft copy with the values from the provided draft

  }


  // EditDraftPage.dart

  void navigateToAddCamera() async {
    // Pass draft information to AddCamera
    var newVideoPath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCamera(
          draft: widget.draft, // Pass your draft information
        ),
      ),
    );

    print('new Video path is ');

    print(newVideoPath);

    // Handle the returned data (newVideoPath) and update the draft in the database

  }



  bool isWithinRadius(double firstLatitude, double firstLongitude, double newLatitude, double newLongitude, double radius) {
    double distance = Geolocator.distanceBetween(firstLatitude, firstLongitude, newLatitude, newLongitude);
    return distance <= radius;
  }


  void handleAddNewVideoButton() async{
    if (userLatitude != 0.0 && userLongitude != 0.0) {
      double radiusInMeters = 20.0;

      print(userLatitude);
      print('user longitude ${userLongitude}');
      print('hm yha calculation kr rhe hain ');

      double distance = Geolocator.distanceBetween(
        userLatitude!,
        userLongitude!,
        widget.draft.latitude,
        widget.draft.longitude,


      );
      print('distance');
      print(distance);


      if (distance <= radiusInMeters) {
        // User is within the radius; they can proceed to create a new video
        print('Location checked - User is within 500 meters.');




        if(true){

          print('has Videos');
          navigateToAddCamera();

        }
        else{
          Navigator.pop(context);
        }

        print('location checked');
        print(radiusInMeters);
        print("firstVideoLatitude");
        print(firstVideoLatitude);
        print(firstVideoLongitude);
        print('location right now');

        print('distance');
        print(distance);
      } else {
        // User is outside the radius; show a dialog
        showDialog(
          context: context,
          builder: (context) {
            return ImagePopUpWithOK(
                imagePath: 'assets/images/range.svg',
                textField: 'Your range is getting extended Please upload or save your last recordings before the next shoot, ',
                extraText:'*Your draft will be available under thesettings option.',
                what:'ok');
          },
        );
      }
    }
  }


  void removeVideo(int index) {
    setState(() {
      // Remove the video from the list of controllers
      // VideoPlayerController[index].dispose();
      // VideoPlayerController.removeAt(index);

      // Update the draft's videoPaths by removing the video URL at the specified index
      var updatedVideoPaths = widget.draft.videoPaths.split(',');
      updatedVideoPaths.removeAt(index);
      widget.draft.videoPaths = updatedVideoPaths.join(',');

      // Update the database
      if (updatedVideoPaths.isEmpty) {
        // If there are no video paths left, delete the entire draft
        DatabaseHelper.instance.deleteDraft(widget.draft.id);
      } else {
        // Otherwise, update the draft in the database
        DatabaseHelper.instance.updateDraft(widget.draft);
      }
    });
  }


  Future<void> fetchUserLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );





    setState(() {

      userLatitude = position.latitude;
      userLongitude = position.longitude;
    });

    print('user latitude : $userLatitude');

    handleAddNewVideoButton();
  }




  Future<void> updateDraft(Draft draft) async {
    final database = await DatabaseHelper.instance.database;
    draft.selectedLabel = selectedLabel;
    draft.selectedCategory = selectedCategory;
    draft.selectedaCategory = selectedaCategory;
    draft.selectedGenre = selectedGenre;
    draft.storyTitle = storyTitleController.text;
    draft.productDescription = productDescriptionController.text;
    draft.experienceDescription = experienceDescriptionController.text;
    draft.dontLikeAboutHere = dontLikeAboutHereController.text;
    draft.selectedLoveAboutHere = selectedLoveAboutHere.join(',');
    draft.selectedOption = selectedOption;
    draft.transportationPricing = transportationPricing;
    draft.selectedVisibility = selectedVisibility;
    draft.restaurantType = restaurantTypeController.text;
    draft.foodType = foodTypeController.text;
    draft.festivalName = festivalNameController.text;
    draft.otherCategory = otherCategoryController.text;
    draft.otherGenre = otherGenreController.text;





    final updatedDraft = Draft(

      id: draft.id,
      latitude: draft.latitude,
      longitude: draft.longitude,
      liveLocation: draft.liveLocation,
      videoPaths: draft.videoPaths,
      selectedLabel: draft.selectedLabel,
      selectedCategory: draft.selectedCategory,
      selectedGenre: draft.selectedGenre,
      experienceDescription: draft.experienceDescription,
      selectedLoveAboutHere: draft.selectedLoveAboutHere,
      dontLikeAboutHere: draft.dontLikeAboutHere,
      selectedaCategory: draft.selectedaCategory,
      reviewText: draft.reviewText,
      starRating: draft.starRating,
      selectedVisibility: draft.selectedVisibility,
      storyTitle: draft.storyTitle,
      productDescription: draft.productDescription,
      selectedOption: draft.selectedOption,
      productPrice: draft.productPrice,
      transportationPricing: draft.transportationPricing,
      festivalName: draft.festivalName,
      foodType: draft.foodType,
      restaurantType: draft.restaurantType,
      otherGenre: draft.otherGenre,
      otherCategory: draft.otherCategory,

    );

    final rowsUpdated = await database.update('drafts', updatedDraft.toMap(),
        where: 'id = ?', whereArgs: [updatedDraft.id]);
    print('Updated $rowsUpdated row(s): ID ${draft.id}');

    showDialog(
      context: context,
      builder: (context) {
        return ImagePopUpWithOK(
            imagePath: 'assets/images/done.svg',
            textField: 'Your draft has been updated successfully',
            what:'drafts');
      },
    );

  }

  @override
  void dispose() {
    super.dispose();
    _thumbnailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsPage(userId: userID),
          ),
        );
        return true;
      },
      child: Scaffold(
        appBar: VideoAppBar(
          title: 'Compose Story',
          exit : 'settings',

        ),
        body: Container(
          color:Theme.of(context).primaryColorLight,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [





                SizedBox(height : 20),
                Container(
                    width : double.infinity,
                    padding: EdgeInsets.only(left : 26),
                    child: Text('Shooted Films',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color : Colors.white),)),
                SizedBox(height : 16),




                Column(
                  children: [
                    Container(
                      height: 300,

                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true, // Set reverse to true to start at the right end
                        child: Row(
                          children: [
                            ...List.generate(
                              videoPathsEditCompose.length,
                                  (index) => Container(
                                width: 200,
                                margin: EdgeInsets.all(2),
                                child: VideoGridItem(
                                  controller: videoPathsEditCompose[index],
                                  videoNumber: index + 1,
                                  onRemovePressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Color(0xFF263238),
                                          content: Container(
                                            height: 269,
                                            width: 300,
                                            child: Column(
                                              children: [
                                                SizedBox(height: 30),
                                                Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: Center(
                                                    child: Image.asset('assets/images/remove.png'),
                                                  ),
                                                ),
                                                SizedBox(height: 30),
                                                Text(
                                                  'Are You Sure?',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'You are removing a shoot',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [

                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFFFB8C00),
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {

                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'Remove',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFFFB8C00),
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Add the button at the end
                            Center(
                              child: Container(

                                height : 300,
                                width: 150,
                                margin: EdgeInsets.all(2),
                                child: Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,

                                      children: [
                                        GestureDetector(
                                          child: Container(

                                            margin: EdgeInsets.all(5.0),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: CircularProgressIndicator(
                                                    value: 1,
                                                    backgroundColor: Colors.transparent,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Color(0xFFFB8C00),
                                                    ),
                                                    strokeWidth: 5.0,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 90,
                                                  height: 90,
                                                  child: IconButton(
                                                    icon: SvgPicture.asset("assets/images/addNewVideoIcon.svg"),
                                                    onPressed:(){
                                                      fetchUserLocation();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Add \nNew Film',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height : 30),


                  ],
                ),


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 26.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Location',
                            style:Theme.of(context).textTheme.headline5,
                          ),



                        ],

                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Row(
                        children: [

                          SizedBox(width: 18),
                          Text(
                            liveLocation.isNotEmpty ? liveLocation : 'Fetching Location...',
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15),


                    // ...
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 35),
                        Padding(
                          padding: EdgeInsets.only(left: 26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Differentiate this experience as ',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                ),

                                child: Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                    ),
                                    child: DropdownButton<String>(
                                      key: UniqueKey(),
                                      value: selectedLabel,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedLabel = newValue!;
                                        });
                                      },
                                      items: <String>['Regular Story', 'Business Product']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value, style: Theme.of(context).textTheme.headline4),
                                        );
                                      }).toList(),
                                      icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFB8C00)),
                                      underline: Container(
                                        height: 2,
                                        color: Color(0xFFFB8C00),
                                      ),
                                    )

                                ),
                              ),
                            ],
                          ),
                        ),


                        Padding(
                          padding : EdgeInsets.all(26.0),
                          child : Container(
                            height : 0.5,
                            decoration: BoxDecoration(
                              color : Colors.grey,
                            ),
                          ),

                        ),
                      ],
                    ),

                    //for regular story

                    Visibility(
                      visible: selectedLabel == 'Regular Story',
                      child: Padding(
                        padding: const EdgeInsets.all(26.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [



                            // category dropdown here
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                  ),

                                  child: Theme(
                                      data: Theme.of(context).copyWith(
                                        canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                      ),
                                      child: DropdownButton<String>(
                                        key: UniqueKey(),
                                        value: selectedCategory,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedCategory = newValue!;
                                          });
                                        },
                                        items: <String>['Select','Solo trip','Romantic Trip', 'Trip With Friends', 'Trip With Family', 'Office Trip','Hangouts', 'School Trip', 'Picnic','Others']
                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value,style: Theme.of(context).textTheme.headline4),
                                          );
                                        }).toList(),
                                        icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFB8C00)),
                                        underline: Container(
                                          height: 2,
                                          color: Color(0xFFFB8C00),
                                        ),
                                      )

                                  ),
                                ),

                                if (selectedCategory == 'Others')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 35),

                                          Text(
                                            'Name This Category ?',
                                            style:Theme.of(context).textTheme.headline5,
                                          ),
                                          Container(
                                            width: 300,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                              ),
                                            ),
                                            child: TextField(
                                              controller: otherCategoryController,
                                              onChanged: (text) {
                                                setState(() {
                                                  otherCategory = text;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'type here ...',
                                                hintStyle:Theme.of(context).textTheme.headline4,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                              style: Theme.of(context).textTheme.headline4,
                                              maxLines: null,
                                            ),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),


                              ],
                            ),

                            SizedBox(height: 35),

                            //genre dropdown here
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Genre',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                  ),

                                  child: Theme(
                                      data: Theme.of(context).copyWith(
                                        canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                      ),
                                      child: DropdownButton<String>(
                                        key: UniqueKey(),
                                        value: selectedGenre,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedGenre = newValue!;
                                          });
                                        },
                                        items: <String>['Select', 'Lifestyle', 'Street Foods', 'Restaurants' , 'Party - Clubs & Bars',  'Fashion', 'Handicraft',  'Historical / Heritage',  'Festivals', 'Market',  'Art & Culture', 'Museum', 'Advanture Place', 'Wild Life attraction', 'Entertainment Parks', 'National Parks', 'Cliffs & Mountains', 'Waterfalls', 'Forests',  'Beaches',   'Riverside',   'Resorts',   'Invasion Sites',   'Island',   'Haunted Places', 'Exhibitions',  'Caves',  'Aquatic Ecosystem', 'Others'   ]

                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value, style:Theme.of(context).textTheme.headline4),
                                          );
                                        }).toList(),
                                        icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFB8C00)),
                                        underline: Container(
                                          height: 2,
                                          color: Color(0xFFFB8C00),
                                        ),
                                      )

                                  ),
                                ),


                                if (selectedGenre == 'Others')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 35),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            'Name This Genre ?',
                                            style:Theme.of(context).textTheme.headline5,
                                          ),
                                          Container(
                                            width: 300,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                              ),
                                            ),
                                            child: TextField(
                                              controller: otherGenreController,
                                              onChanged: (text) {
                                                setState(() {
                                                  otherGenre = text;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'type here ...',
                                                hintStyle:Theme.of(context).textTheme.headline4,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                              style: Theme.of(context).textTheme.headline4,
                                              maxLines: null,
                                            ),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),

                                // Additional field for famous food if genre is 'Food'
                                if (selectedGenre == 'Festivals')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            'What Festival is Going On ?',
                                            style:Theme.of(context).textTheme.headline5,
                                          ),
                                          Container(
                                            width: 300,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                              ),
                                            ),
                                            child: TextField(
                                              controller: festivalNameController,
                                              onChanged: (text) {
                                                setState(() {
                                                  festivalName = text;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'e.g., HOLI',
                                                hintStyle:Theme.of(context).textTheme.headline4,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                              style: Theme.of(context).textTheme.headline4,
                                              maxLines: null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height : 35),
                                    ],
                                  ),

                                // Additional field for famous food if genre is 'Food'
                                if (selectedGenre == 'Street Foods')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height : 35),
                                      Text(
                                        'Is this food famous for this place?',
                                        style:Theme.of(context).textTheme.headline5,
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isFoodFamous = isFoodFamous;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: isFoodFamous ? Color(0xFFFB8C00) : Color(0xFF263238),
                                              elevation: 0, // No shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                                side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                              ),
                                            ),
                                            child: Text(
                                              'Yes',
                                              style: Theme.of(context).textTheme.headline4,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isFoodFamous = false;
                                                foodType = ''; // Reset the food type if not famous
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: !isFoodFamous ? Color(0xFFFB8C00) : Color(0xFF263238),
                                              elevation: 0, // No shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                                side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                              ),
                                            ),
                                            child: Text(
                                              'No',
                                              style: Theme.of(context).textTheme.headline4,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isFoodFamous)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 20),
                                            Text(
                                              'What food is it famous for?',
                                              style:Theme.of(context).textTheme.headline5,
                                            ),
                                            Container(
                                              width: 300,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                                ),
                                              ),
                                              child: TextField(
                                                controller: foodTypeController,
                                                onChanged: (text) {
                                                  setState(() {
                                                    foodType = text;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'e.g., Samosa',
                                                  hintStyle:Theme.of(context).textTheme.headline4,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                ),
                                                style: Theme.of(context).textTheme.headline4,
                                                maxLines: null,
                                              ),
                                            ),
                                          ],
                                        ),

                                    ],
                                  ),

                                // Additional field for famous fashion if genre is 'Fashion'
                                if (selectedGenre == 'Fashion')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height : 35),
                                      Text(
                                        'Is this clothing famous for this place ?',
                                        style:Theme.of(context).textTheme.headline5,
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isFashionFamous = true;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: isFashionFamous ? Color(0xFFFB8C00) : Color(0xFF263238),
                                              elevation: 0, // No shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                                side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                              ),
                                            ),
                                            child: Text(
                                              'Yes',
                                              style: Theme.of(context).textTheme.headline4,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isFashionFamous = false;
                                                fashionType = ''; // Reset the fashion type if not famous
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: !isFashionFamous ? Color(0xFFFB8C00) : Color(0xFF263238),
                                              elevation: 0, // No shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                                side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                              ),
                                            ),
                                            child: Text(
                                              'No',
                                              style: Theme.of(context).textTheme.headline4,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height : 0),
                                      if (isFashionFamous)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 35),
                                            Text(
                                              'What Exactly its Famous For ?',
                                              style:Theme.of(context).textTheme.headline5,
                                            ),
                                            SizedBox(height : 10),
                                            Container(
                                              width: 300,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                                ),
                                              ),
                                              child: TextField(
                                                controller: fashionTypeController,
                                                onChanged: (text) {
                                                  setState(() {
                                                    fashionType = text;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'e.g., Traditional attire',
                                                  hintStyle:Theme.of(context).textTheme.headline4,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                ),
                                                style: Theme.of(context).textTheme.headline4,
                                                maxLines: null,
                                              ),
                                            ),
                                          ],
                                        ),

                                    ],
                                  ),


                                // Additional field for famous Restaurant if genre is 'Restaurant'
                                if (selectedGenre == 'Restaurants')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height : 35),
                                      Text(
                                        'Is This Restaurant Famous For This Place ?',
                                        style:Theme.of(context).textTheme.headline5,
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isRestaurantFamous = true;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: isRestaurantFamous ? Color(0xFFFB8C00) : Color(0xFF263238),
                                              elevation: 0, // No shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                                side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                              ),
                                            ),
                                            child: Text(
                                              'Yes',
                                              style: Theme.of(context).textTheme.headline4,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isRestaurantFamous = false;
                                                restaurantType = ''; // Reset the fashion type if not famous
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: !isRestaurantFamous ? Color(0xFFFB8C00) : Color(0xFF263238),
                                              elevation: 0, // No shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                                side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                              ),
                                            ),
                                            child: Text(
                                              'No',
                                              style: Theme.of(context).textTheme.headline4,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height : 0),
                                      if (isRestaurantFamous)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 25),
                                            Text(
                                              'What Exactly its Famous For ?',
                                              style:Theme.of(context).textTheme.headline5,
                                            ),
                                            SizedBox(height : 10),
                                            Container(
                                              width: 300,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                                ),
                                              ),
                                              child: TextField(
                                                controller: restaurantTypeController,
                                                onChanged: (text) {
                                                  setState(() {
                                                    restaurantType = text;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'e.g., Traditional Serving',
                                                  hintStyle:Theme.of(context).textTheme.headline4,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                ),
                                                style: Theme.of(context).textTheme.headline4,
                                                maxLines: null,
                                              ),
                                            ),
                                          ],
                                        ),

                                    ],
                                  ),

                              ],
                            ),

                            SizedBox(height: 35),

                            //story title here
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Story Title ',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Container(
                                    width: 300,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: storyTitleController,
                                      onChanged: (text) {
                                        setState(() {
                                          storyTitle = text;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'type here ...',
                                        hintStyle:Theme.of(context).textTheme.headline4,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      style:Theme.of(context).textTheme.headline4,
                                      maxLines: null,
                                    )

                                ),
                              ],
                            ),

                            SizedBox(height: 35),




                            //Describe your experience
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Describe your Experience ',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: experienceDescriptionController,
                                    onChanged: (text) {
                                      setState(() {
                                        experienceDescription = text;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'type here ...',
                                      hintStyle:Theme.of(context).textTheme.headline4,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style:Theme.of(context).textTheme.headline4,
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),


                            SizedBox(height: 35),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What You Love Here ?',
                                  style: Theme.of(context).textTheme.headline5,
                                ),

                                SizedBox(height : 20),
                                Wrap(
                                  spacing: 16.0, // Horizontal spacing between buttons
                                  runSpacing: 8.0, // Vertical spacing between rows of buttons
                                  children: loveAboutHereOptions.map((option) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (selectedLoveAboutHere.contains(option)) {
                                            selectedLoveAboutHere.remove(option);
                                          } else {
                                            selectedLoveAboutHere.add(option);
                                          }
                                          if (option == 'Others') {
                                            showOtherLoveAboutHereInput = true;
                                          } else {
                                            showOtherLoveAboutHereInput = false;
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: selectedLoveAboutHere.contains(option) ? Color(0xFFFB8C00) : Color(0xFF263238),
                                        elevation: 0, // No shadow
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                          side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                        ),
                                      ),
                                      child: Text(
                                        option,
                                        style:Theme.of(context).textTheme.headline4,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            if (showOtherLoveAboutHereInput)
                              Row(
                                children: [
                                  Container(
                                    width: 200,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: loveAboutHereInputController,
                                      onChanged: (text) {
                                        setState(() {
                                          // No need to update experienceDescription in this case
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Other Reasons',
                                        hintStyle:Theme.of(context).textTheme.headline4,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      style:Theme.of(context).textTheme.headline4,
                                      maxLines: null,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final newReason = loveAboutHereInputController.text;
                                      if (newReason.isNotEmpty) {
                                        setState(() {
                                          // Append the new option to loveAboutHereOptions
                                          loveAboutHereOptions.add(newReason);
                                          // Update the selected option to the newly added one
                                          selectedLoveAboutHere.add(newReason);
                                          loveAboutHereInputController.clear();
                                          showOtherLoveAboutHereInput = false; // Hide the input field
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFFFB8C00),
                                      elevation: 0, // No shadow
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                    ),
                                    child: Text(
                                      'Add',
                                      style:Theme.of(context).textTheme.headline4,
                                    ),
                                  ),
                                ],
                              ),



                            SizedBox(height: 35),

                            //what you dont like about this place
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What you dont like about this place',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: dontLikeAboutHereController,
                                    onChanged: (text) {
                                      setState(() {
                                        dontLikeAboutHere = text;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'type here ...',
                                      hintStyle:Theme.of(context).textTheme.headline4,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style:Theme.of(context).textTheme.headline4,
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),


                            SizedBox(height: 35),

                            //Review this place
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Review This Place',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: reviewTextController,
                                    onChanged: (text) {
                                      setState(() {
                                        reviewText = text;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'type here ...',
                                      hintStyle:Theme.of(context).textTheme.headline4,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style:Theme.of(context).textTheme.headline4,
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),


                            SizedBox(height: 35),

                            //RATE YOUR EXPERIENCE HERE
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [


                                Text(
                                  'Rate your experience here :',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                SizedBox( height: 13,),
                                // Display stars based on the selected starRating
                                Row(
                                  children: List.generate(5, (index) {
                                    return IconButton(
                                      onPressed: () {
                                        setState(() {
                                          // Set the starRating to the current index + 1
                                          starRating = index + 1;
                                        });
                                      },
                                      icon: Icon(
                                        index < starRating ? Icons.star : Icons.star_border,
                                        color: Color(0xFFFB8C00),
                                        size: 35,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                            SizedBox(height: 35),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Make this story' , style: TextStyle(fontSize: 18, color : Colors.white),),
                                Container(


                                  child: Row(
                                    children: [
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                        ),
                                        child: DropdownButton<String>(
                                          value: selectedVisibility,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedVisibility = newValue!;
                                            });
                                          },
                                          items: <String>['Public', 'Private']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Row(
                                                children: [
                                                  // Icons for "Public" and "Private"
                                                  value == 'Public'
                                                      ? Icon(Icons.public, color: Colors.white)
                                                      : Icon(Icons.lock, color: Colors.white),
                                                  SizedBox(width: 5),
                                                  Text(value, style:Theme.of(context).textTheme.headline4),
                                                  SizedBox(width: 10),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFB8C00)),

                                        ),
                                      ),
                                    ],
                                  ),
                                ),


                                SizedBox(height: 35),


                              ],
                            ),




                            SizedBox(height: 20),






                          ],

                        ),
                      ),
                    ),






                    //for business products
                    Visibility(
                      visible: selectedLabel == 'Business Product',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [



                          // category dropdown here

                          Padding(
                            padding: EdgeInsets.only(left: 26.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedaCategory,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedaCategory = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'Select', // Ensure there's exactly one 'Select' item
                                      'Furniture',
                                      'Handicraft',
                                      'Other',
                                    ].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style:Theme.of(context).textTheme.headline4),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFB8C00)),
                                    underline: Container(
                                      height: 2,
                                      color: Color(0xFFFB8C00),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 35),

                          //story title here
                          Padding(
                            padding: EdgeInsets.only(left: 26.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Story Title ',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Container(
                                    width: 300,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: storyTitleController,
                                      onChanged: (text) {
                                        setState(() {
                                          storyTitle = text;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'type here ...',
                                        hintStyle:Theme.of(context).textTheme.headline4,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      style:Theme.of(context).textTheme.headline4,
                                      maxLines: null,
                                    )

                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 35),

                          //product description here
                          Padding(
                            padding: EdgeInsets.only(left: 26.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Describe your product or service ',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: productDescriptionController,
                                    onChanged: (text) {
                                      setState(() {
                                        productDescription = text;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'type here ...',
                                      hintStyle:Theme.of(context).textTheme.headline4,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style:Theme.of(context).textTheme.headline4,
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),
                          ),


                          SizedBox(height : 35),
                          // Do you provide service at local's doorstep
                          Padding(
                            padding: EdgeInsets.only(left : 26.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Do you provide service / product at local’s door steps ?',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                SizedBox(height : 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Radio button for "Yes"
                                    Radio<String>(
                                      value: 'Yes',
                                      groupValue: selectedOption,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedOption = value!;
                                        });
                                      },
                                      fillColor: MaterialStateColor.resolveWith((states) => Color(0xFFFB8C00)),
                                      // Background color when selected
                                    ),
                                    Text('Yes',style : TextStyle(color : Colors.white)),
                                    Radio<String>(
                                      value: 'No',
                                      groupValue: selectedOption,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedOption = value!;
                                        });
                                      },

                                      fillColor: MaterialStateColor.resolveWith((states) => Color(0xFFFB8C00)),// Background color when selected
                                    ),
                                    Text('No',style : TextStyle(color : Colors.white)),
                                  ],
                                ),

                              ],
                            ),
                          ),






                          SizedBox(height : 35),

                          Padding(
                            padding: EdgeInsets.only(left: 26.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery / transport Charges',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                    ),
                                  ),
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    controller: transportationPricingController,
                                    onChanged: (text) {
                                      setState(() {
                                        transportationPricing = text;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'type here ...',
                                      hintStyle:Theme.of(context).textTheme.headline4,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style:Theme.of(context).textTheme.headline4,
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),
                          ),








                        ],

                      ),
                    ),

                    SizedBox(height : 40),
                    // Save draft or update draft button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 156,
                              height: 63,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Update the draft's selectedLabel in the database
                                  widget.draft.selectedLabel = selectedLabel;
                                  widget.draft.selectedCategory = selectedCategory;
                                  widget.draft.selectedaCategory = selectedaCategory;
                                  widget.draft.selectedGenre = selectedGenre;
                                  widget.draft.storyTitle = storyTitleController.text;
                                  widget.draft.productDescription = productDescriptionController.text;
                                  widget.draft.experienceDescription = experienceDescriptionController.text;
                                  widget.draft.dontLikeAboutHere = dontLikeAboutHereController.text;
                                  widget.draft.reviewText = reviewTextController.text;
                                  widget.draft.starRating = starRating;
                                  widget.draft.selectedLoveAboutHere = selectedLoveAboutHere.join(',');
                                  widget.draft.selectedOption = selectedOption;
                                  widget.draft.transportationPricing = transportationPricingController.text;
                                  widget.draft.selectedVisibility = selectedVisibility;
                                  widget.draft.festivalName = festivalNameController.text;
                                  widget.draft.foodType = foodTypeController.text;
                                  widget.draft.restaurantType = restaurantTypeController.text;
                                  widget.draft.otherCategory = otherCategoryController.text;
                                  widget.draft.otherGenre = otherGenreController.text;

                                  await updateDraft(widget.draft);
                                  setState(() {
                                    isSaveDraftClicked = !isSaveDraftClicked;
                                    isPublishClicked = false; // Reset the other button's state
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: isSaveDraftClicked
                                      ? Color(0xFFFB8C00)
                                      : Colors.transparent, // Change background color
                                  elevation: 0, // No shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(
                                        color: Color(0xFFFB8C00), width: 2.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 10.0),
                                ),
                                child: Text(
                                  'Save Draft',
                                  style: TextStyle(
                                    color: isSaveDraftClicked
                                        ? Colors.white
                                        : Color(0xFFFB8C00), // Change text color
                                    fontWeight:
                                    FontWeight.bold, // Change font weight
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            // Add a button for discarding changes
                            Container(
                              width: 156,
                              height: 63,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Implement the functionality for discarding changes
                                  // You can navigate back to the previous page or show a confirmation dialog
                                  sendDataToBackend();
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: isPublishClicked
                                      ? Color(0xFFFB8C00)
                                      : Colors.transparent, // Change background color
                                  elevation: 0, // No shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(
                                        color: Color(0xFFFB8C00), width: 2.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 10.0),
                                ),
                                child: Text(
                                  'Publish',
                                  style: TextStyle(
                                    color: isPublishClicked
                                        ? Colors.white
                                        : Color(0xFFFB8C00), // Change text color
                                    fontWeight:
                                    FontWeight.bold, // Change font weight
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height : 20),
                  ],
                ),










              ],
            ),
          ),
        ),
      ),
    );
  }
}