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
import 'package:learn_flutter/fetchDataFromMongodb.dart';

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

import '../All_Notifications/customizeNotification.dart';

Map<String, List<VideoInfo>> videoData = {};

class VideoInfo {
  final String videoUrl;
  final double latitude;
  final double longitude;

  VideoInfo({
    required this.videoUrl,
    required this.latitude,
    required this.longitude,
  });
}

class ComposePage extends StatefulWidget {
  VideoDatabaseHelper myDatabaseHelper = VideoDatabaseHelper();
  final List<String> videoPaths;
  final double latitude;
  final double longitude;
  final Map<String, List<VideoInfo>> videoData;
  String? userLocation;


  ComposePage({
    required this.latitude,
    required this.longitude,
    required this.videoPaths,
    required this.videoData,
    this.userLocation,
  });

  @override
  _ComposePageState createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, List<VideoInfo>> videoData = {};



  String userName = '';
  String userID = '';
  double firstVideoLatitude = 0.0;
  double firstVideoLongitude = 0.0;

  bool isLoading = true;

  late VideoPlayerController _thumbnailController;
  late int randomIndex;

  String selectedLabel = 'Regular Story';
  String selectedCategory = 'Select';
  String selectedGenre = 'Select'; // Default selected genre
  String experienceDescription = '';
  List<String> selectedLoveAboutHere = []; // Initialize as an empty list
  bool showOtherLoveAboutHereInput = false;
  TextEditingController loveAboutHereInputController = TextEditingController();
  String dontLikeAboutHere = ''; // New input for "What You Don't Like About This Place"
  String selectedaCategory = "Select";
  String reviewText = ''; // New input for "Review This Place"
  int starRating = 0; // New input for star rating
  String selectedVisibility = 'Public';
  String liveLocation = "";
  String storyTitle = '';
  String productDescription = '';
  bool isSaveDraftClicked = false;
  bool isPublishClicked = false;
  String selectedOption = '';
  String productPrice = '';
  String transportationPricing = "";
  List<String> finalVideoPaths = [];


  bool Otherselectedforloveabouthere = false;
  bool starRatingIsRequired = false;


  bool isPublishingVideo = false; // Set this based on your condition

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _textFormFieldFocusNode = FocusNode();
  final FocusNode _experienceTextFormFieldFocusNode = FocusNode();

  List<String> currencyCode = [
    '₪', // Israeli New Shekel
    '¥', // Japanese Yen
    '€', // Euro
    '£', // British Pound Sterling
    '₹', // Indian Rupee
    '₣', // Swiss Franc
    '₱', // Philippine Peso
    '₩', // South Korean Won
    '₺', // Turkish Lira
    '฿', // Thai Baht

  ];

  String _selectedCurrencyCode = '₹'; // Default country code

   List<String> loveAboutHereOptions = [
     'Location','Calm','Nature',

  ];


  bool isFoodFamous = false;
  bool isFashionFamous = false;
  bool isRestaurantFamous = false;

  String foodType = '';
  String fashionType = '';
  String restaurantType = '';
  String festivalName = '';
  String otherGenre = '';
  String otherCategory = '';
  double userLatitude = 0.0;
  double userLongitude = 0.0;


  bool _isVisible = true;




  bool isWithinRadius(double firstLatitude, double firstLongitude, double newLatitude, double newLongitude, double radius) {
    double distance = Geolocator.distanceBetween(firstLatitude, firstLongitude, newLatitude, newLongitude);
    return distance <= radius;
  }


  void handleAddNewVideoButton() async{
    if (userLatitude != 0.0 && userLongitude != 0.0) {
      double radiusInMeters = 300.0;

      print(userLatitude);
      print('user longitude ${userLongitude}');
      print('hm yha calculation kr rhe hain ');
      print(widget.latitude);
      print(widget.longitude);
      double distance = Geolocator.distanceBetween(
        userLatitude!,
        userLongitude!,
        widget.latitude,
        widget.longitude,
      );
      print('distance');
      print(distance);


      if (distance <= radiusInMeters) {
        // User is within the radius; they can proceed to create a new video
        print('Location checked - User is within 500 meters.');
        bool hasVideos = await VideoDatabaseHelper().hasVideos();



        if(hasVideos){

          print('has Videos');
          Navigator.push(context, MaterialPageRoute(builder: (context) => CameraApp()));

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
        print(widget.latitude);
        print(widget.longitude);
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





  Future<void> fetchDataFromMongoDB() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // User is already signed in, navigate to the desired screen
      var userQuery = await firestore.collection('users').where('uid',isEqualTo:user.uid).limit(1).get();

      var userData = userQuery.docs.first.data();
      String uName = userData['name'];
      String uId = userData['userMongoId'];
      userName = uName;
      print('userName: $userName');
      userID =uId;
      print('userID$userID');
    }
  }

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

  Future<void> removeVideo(String videoPath) async {

    // _handleRefresh();

    setState(() {
      isLoading = true;
      // Find the location associated with the videoPath
      // String location = widget.userLocation;
      String location = '';

      if (videoData.containsKey(location)) {
        // Find the index of the video with the given path within the location
        int index = videoData[location]!.indexWhere((videoInfo) => videoInfo.videoUrl == videoPath);

        if (index != -1) {
          // Remove the video info from videoData
          videoData[location]!.removeAt(index);

          // If there are no videos left for that location, remove the location key
          if (videoData[location]!.isEmpty) {
            videoData.remove(location);
          }
        }
      }

      // Remove the video path from widget.videoPaths
      int pathIndex = widget.videoPaths.indexOf(videoPath);
      if (pathIndex != -1) {
        // Remove the video file from local storage asynchronously
        VideoDatabaseHelper().deleteVideoByPath(videoPath);
        // Remove the video path from the list
        widget.videoPaths.removeAt(pathIndex);
      }
    });


    if (widget.videoPaths.isEmpty) {
      Navigator.pop(context);

    } else {
      // _handleRefresh();
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


    List<File> videoFiles = convertPathsToFiles(widget.videoPaths);
    await uploadCompressedVideos(videoFiles,context);


    print('final video paths $finalVideoPaths');
    print('publish button clicked');

    try{
      VideoDatabaseHelper myDatabaseHelper = VideoDatabaseHelper();

      await myDatabaseHelper.deleteAllVideos();

      final data = {
        "singleStoryData": {
          "videoPath": finalVideoPaths,
          "latitude": widget.latitude,
          "longitude": widget.longitude,
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
          "productPrice": productPrice,
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

        sendCustomNotificationToOneUser(
            userToken,
            'Story Published Successfully ✔️',
            'Story Published Successfully ✔️','$userName',
            '','story published',userID,''
        );




      } else {
        print('Failed to send data. Error: ${response.reasonPhrase}');
      }
    }catch(error){
      print("Error: $error");
    }

  }








  void addVideo(String location, String videoUrl, double latitude, double longitude) {
    final videoInfo = VideoInfo(
      videoUrl: videoUrl,
      latitude: latitude,
      longitude: longitude,
    );

    videoData[location] = [videoInfo];


  }






  late DatabaseHelper _databaseHelper;

  Future<void> saveDraft() async {
    await Permission.storage.request();
    print('userIDindraft$userID');
    final status = await Permission.storage.request();
    if(status.isGranted){
      print('status granted');
      final database = await DatabaseHelper.instance.database;
      final draft = Draft(
        latitude: widget.latitude,
        longitude: widget.longitude,
        liveLocation : liveLocation,
        videoPaths: widget.videoPaths.join(','),
        selectedLabel: selectedLabel,
        selectedCategory: selectedCategory,
        selectedGenre: selectedGenre,
        experienceDescription: experienceDescription,
        selectedLoveAboutHere: selectedLoveAboutHere.join(','),
        dontLikeAboutHere: dontLikeAboutHere,
        selectedaCategory: selectedaCategory,
        reviewText: reviewText,
        starRating: starRating,
        selectedVisibility: selectedVisibility,
        storyTitle: storyTitle,
        productDescription: productDescription,
        selectedOption: selectedOption,
        transportationPricing: transportationPricing,
        productPrice: productPrice,
        festivalName: festivalName,
        foodType : foodType,
        restaurantType : restaurantType,
        otherGenre : otherGenre,
        otherCategory : otherCategory,



      );

      final id = await database.insert('drafts', draft.toMap());
      print('Saved draft with ID: $id');

      // Save video files to local storage
      for (final videoPath in widget.videoPaths) {
        await _saveVideoToLocalStorage(videoPath);
      }

      sendCustomNotificationToOneUser(
        userToken,
        'Saved Draft',
        'Video Saved To Draft','View Story In Draft',
        '','draft',userID,'',
      );


      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ImagePopUpWithOK(
            imagePath: "assets/images/savedraft.svg",
            textField: "Your Draft is saved , you can check your drafts on settings." ,
            what:'camera',


          );
        },
      );
    }
    else {
      // Permission not granted, request it
      print('Storage permission not granted, requesting...');
      final newStatus = await Permission.storage.request();
      if (newStatus.isGranted) {
        // Permission granted after the request, proceed with your logic
        print('Storage permission granted after request');
        // ... rest of your code ...
      } else {
        // Permission denied after the request
        print('Storage permission denied after request');
      }}
  }



  Future<void> _saveVideoToLocalStorage(String videoPath) async {
    VideoDatabaseHelper myDatabaseHelper = VideoDatabaseHelper();

    final localPath = (await getApplicationDocumentsDirectory()).path;
    final fileName = videoPath.split('/').last; // Extract the filename from the videoPath
    final localFilePath = '$localPath/$fileName';

    File videoFile = File(videoPath);
    await videoFile.copy(localFilePath);


    print('Video file copied to local storage: $localFilePath');
    await myDatabaseHelper.deleteAllVideos();
  }





  Future<void> getAndPrintLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark first = placemarks.first;
        String locationName = "${first.name}, ${first.locality}, ${first.administrativeArea}, ${first.country}";
        setState(() {
          liveLocation = locationName;
        });
      } else {
        // Return latitude and longitude if location not found
        setState(() {
          liveLocation = '$latitude, $longitude';
        });
      }
    } catch (e) {
      print("Error: $e");
      // Return latitude and longitude in case of an error fetching location
      setState(() {
        liveLocation = '$latitude, $longitude';
      });
    }
  }



  @override
  void initState() {
    super.initState();

    fetchDataFromMongoDB();

    _databaseHelper = DatabaseHelper.instance;



    print("Video Data in initState: ${widget.videoData}");

    if (videoData.isNotEmpty) {
      final location = videoData.keys.first; // Get the first location in the map
      final firstVideoInfo = videoData[location]![0];
      print('first Video Info ');
      print(firstVideoInfo);
// Get the first VideoInfo in the list

      print("Video Data in initState: ${firstVideoInfo.videoUrl}");

      for (int i = 0; i < widget.videoPaths.length; i++) {
        addVideo(widget.userLocation!, widget.videoPaths[i], widget.latitude, widget.longitude);

        // Save the latitude and longitude of the first video
        if (i == 0) {
          setState(() {

            firstVideoLatitude = widget.latitude;
            firstVideoLongitude = widget.longitude;
          });

        }




      }




    }



    getAndPrintLocationName(widget.latitude, widget.longitude);
    randomIndex = Random().nextInt(widget.videoPaths.length);
    _thumbnailController = VideoPlayerController.file(File(widget.videoPaths[randomIndex]))
      ..initialize().then((_) {
        setState(() {});
      });

    print('userIDwalahai${userID}');
    print('userName${userName}');


  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If you want to prevent the user from going back, return false
        // return false;

        // If you want to navigate directly to the homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        return false; // Returning true will allow the user to pop the page
      },
      child: Scaffold(
        appBar: VideoAppBar(
          title : 'Compose Story',
          exit : 'home',
        ),
        body: Container(
          color:Theme.of(context).primaryColorDark,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [


                Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height : 20),
                    Container(
                        width : double.infinity,
                        padding: EdgeInsets.only(left : 22),
                        child: Text('Shooted Films',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color : Colors.white))),
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
                                  widget.videoPaths.length,
                                      (index) => Container(
                                    width: 200,
                                    margin: EdgeInsets.all(2),
                                    child: VideoItem(
                                      videoPath: widget.videoPaths[index],
                                      videoNumber: index + 1,
                                      onClosePressed: () {
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
                                                        // Remove video logic here
                                                        removeVideo(widget.videoPaths[index]);
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
                      ],
                    ),



                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          // ... (your existing code)
                        ],
                      ),
                    ),
                  ],
                ),




                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 30),

                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Location',
                            style:Theme.of(context).textTheme.headline5,
                          ),



                        ],

                      ),
                    ),

                    Padding(

                      padding: const EdgeInsets.only(left : 20.0),
                      child: Container(

                        width : 300,

                        child: Text(
                          liveLocation.isNotEmpty ? liveLocation : 'Fetching Location...',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Differentiate this experience as ',
                            style:Theme.of(context).textTheme.headline5,
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
                                    child: Text(value,style: Theme.of(context).textTheme.headline4),
                                  );
                                }).toList(),
                                icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFB8C00)),
                                underline: Container(
                                  height: 2,
                                  color: Color(0xFFFB8C00),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height : 20),
                        ],
                      ),
                    ),

                    Padding(
                      padding : EdgeInsets.all(20.0),
                      child : Container(
                        height : 0.5,
                        decoration: BoxDecoration(
                          color : Colors.grey,
                        ),
                      ),

                    ),

                  ],),


                //for regular story

                Form(
                  key: _formKey,
                  child: Visibility(
                    visible: selectedLabel == 'Regular Story',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [


                        // category for regular stories
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height : 20),
                              Text(
                                'Category',
                                style:Theme.of(context).textTheme.headline5,
                              ),


                              Container(
                                width : 200,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedCategory,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCategory = newValue!;
                                        _formKey.currentState!.validate();
                                      });
                                    },
                                    items: <String>['Select','Solo trip', 'Trip With Friends','Romantic Trip', 'Trip With Family', 'Hangouts' , 'Office Trip', 'School Trip', 'Picnic', 'Others']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,style: Theme.of(context).textTheme.headline4),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFB8C00)),
                                    decoration: InputDecoration(
                                      hintText: 'type here ...',
                                      hintStyle: TextStyle(color: Colors.white),
                                      errorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red, width: 2.0), // Customize the error bottom border
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.orange, width: 2.0), // Customize the enabled bottom border
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.orange, width: 2.0), // Customize the focused bottom border
                                      ),
                                      errorStyle: TextStyle(
                                        color: Colors.red, // Customize the error text color
                                        fontSize: 12.0,    // Customize the error text font size
                                        // Customize the error text font style
                                        // Add other text style properties as needed
                                      ),

                                    ),

                                    validator: (value) {
                                      if (value == 'Select') {
                                        return 'Please select a Category !';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 35),

                        if (selectedCategory == 'Others')
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

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


                                        onChanged: (text) {
                                          setState(() {
                                            otherCategory = text;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: ' ',
                                          hintStyle: TextStyle(color: Colors.white),
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        style: Theme.of(context).textTheme.headline4,
                                        maxLines: null,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 35),
                              ],
                            ),
                          ),




                        //genre for regular story
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Genre',
                                style:Theme.of(context).textTheme.headline5,
                              ),
                              Container(
                                width : 200,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedGenre,
                                    onChanged: (String? newValue) {
                                      setState(() {

                                        selectedGenre = newValue!;

                                        if(selectedGenre == 'Restaurants')
                                          setState(() {
                                            loveAboutHereOptions = ['Food','Staff','Pricing','Hygiene','Location','FastFood','Party Place'];
                                          });

                                        if(selectedGenre == 'Street Foods')
                                          setState(() {
                                            loveAboutHereOptions = ['Taste','Staff','Pricing','Hygiene','Location','FastFood'];
                                          });

                                        if(selectedGenre == 'Fashion')
                                          setState(() {
                                            loveAboutHereOptions = ['Good Quality','Staff','Pricing','Trending Clothes','Branded Clothes','Location','Discounts'];
                                          });

                                        if(selectedGenre == 'Market')
                                          setState(() {
                                            loveAboutHereOptions = ['Location','Uncrowded','Highly Negotiable','Parking Facility','Branded Clothes','Discounts','communal Market'];
                                          });

                                        _formKey.currentState!.validate();

                                      });
                                    },
                                    items: <String>['Select', 'Lifestyle', 'Street Foods', 'Restaurants' , 'Party - Clubs & Bars',  'Fashion', 'Handicraft',  'Historical / Heritage',  'Festivals', 'Market',  'Art & Culture', 'Museum', 'Advanture Place', 'Wild Life attraction', 'Entertainment Parks', 'National Parks', 'Cliffs & Mountains', 'Waterfalls', 'Forests',  'Beaches',   'Riverside',   'Resorts',   'Invasion Sites',   'Island',   'Haunted Places', 'Exhibitions',  'Caves',  'Aquatic Ecosystem','Others']

                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,style: Theme.of(context).textTheme.headline4),
                                      );
                                    }).toList(),
                                    icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFB8C00)),
                                    decoration: InputDecoration(
                                      hintText: 'type here ...',
                                      hintStyle: TextStyle(color: Colors.white),
                                      errorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.red, width: 2.0), // Customize the error bottom border
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.orange, width: 2.0), // Customize the enabled bottom border
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.orange, width: 2.0), // Customize the focused bottom border
                                      ),
                                      errorStyle: TextStyle(
                                        color: Colors.red, // Customize the error text color
                                        fontSize: 12.0,    // Customize the error text font size
                                        // Customize the error text font style
                                        // Add other text style properties as needed
                                      ),

                                    ),

                                    validator: (value) {
                                      if (value == 'Select') {
                                        return 'Please select a Genre !';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 35),

                        if (selectedGenre == 'Others')
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

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

                                        onChanged: (text) {
                                          setState(() {
                                            otherGenre = text;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: '',
                                          hintStyle: TextStyle(color: Colors.white),
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        style: Theme.of(context).textTheme.headline4,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height : 35),
                              ],
                            ),
                          ),

                        // Additional field for famous food if genre is 'Food'
                        if (selectedGenre == 'Festivals')
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Column(
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

                                        onChanged: (text) {
                                          setState(() {
                                            festivalName = text;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'e.g., HOLI',
                                          hintStyle: TextStyle(color: Colors.white),
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
                          ),

                        // Additional field for famous food if genre is 'Food'
                        if (selectedGenre == 'Street Foods')
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                          isFoodFamous = true;
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
                                          onChanged: (text) {
                                            setState(() {
                                              foodType = text;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'e.g., Samosa',
                                            hintStyle: TextStyle(color: Colors.white),
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
                          ),

                        // Additional field for famous fashion if genre is 'Fashion'
                        if (selectedGenre == 'Fashion')
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                          onChanged: (text) {
                                            setState(() {
                                              fashionType = text;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'e.g., Traditional attire',
                                            hintStyle: TextStyle(color: Colors.white),
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
                          ),


                        // Additional field for famous Restaurant if genre is 'Restaurant'



                        if (selectedGenre == 'Restaurants')

                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                          onChanged: (text) {
                                            setState(() {
                                              restaurantType = text;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'e.g., Traditional Serving',
                                            hintStyle: TextStyle(color: Colors.white),
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
                          ),


                        //story title for regular story
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Story Title ',
                                style:Theme.of(context).textTheme.headline5,
                              ),
                              Row(
                                children: [
                                  Container(

                                    width: 300,

                                    child: TextFormField(

                                      focusNode: _textFormFieldFocusNode,

                                      onChanged: (text) {
                                        setState(() {
                                          storyTitle = text;
                                          _formKey.currentState!.validate();


                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'type here ...',
                                        hintStyle: TextStyle(color: Colors.white),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red, width: 2.0), // Customize the error bottom border
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.orange, width: 2.0), // Customize the enabled bottom border
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.orange, width: 2.0), // Customize the focused bottom border
                                        ),
                                        errorStyle: TextStyle(
                                          color: Colors.red, // Customize the error text color
                                          fontSize: 12.0,    // Customize the error text font size
                                            // Customize the error text font style
                                          // Add other text style properties as needed
                                        ),

                                      ),
                                      style: Theme.of(context).textTheme.headline4,

                                      validator: (value) {

                                          {
                                          // Only enforce validation when publishing videos
                                          if (value == null || value.isEmpty!) {

                                            return 'Please enter story title !';
                                          } else if ( value.length > 30) {
                                            return 'Maximum length exceeded (30 characters) !';
                                          }
                                        }
                                          return null;
                                      },
                                      maxLines: 1,
                                    ),
                                  ),
                                  Text('${storyTitle.length}/30',style:TextStyle(color:storyTitle.length<=30?Colors.white70:Colors.red,fontSize:14,fontWeight: FontWeight.bold,))
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 35),

                        //experience for regular story
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Describe Your Experience : ',
                                style:Theme.of(context).textTheme.headline5,
                              ),
                              Container(
                                width: 300,

                                child: TextFormField(
                                  focusNode: _experienceTextFormFieldFocusNode,
                                  onChanged: (text) {
                                    setState(() {
                                      experienceDescription = text;
                                      _formKey.currentState!.validate();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'type here ...',
                                    hintStyle: TextStyle(color: Colors.white),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red, width: 2.0), // Customize the error bottom border
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.orange, width: 2.0), // Customize the enabled bottom border
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.orange, width: 2.0), // Customize the focused bottom border
                                    ),
                                    errorStyle: TextStyle(
                                      color: Colors.red, // Customize the error text color
                                      fontSize: 12.0,    // Customize the error text font size
                                      // Customize the error text font style
                                      // Add other text style properties as needed
                                    ),

                                  ),
                                  style: Theme.of(context).textTheme.headline4,

                                  validator: (value) {
                                     {
                                      // Only enforce validation when publishing videos
                                      if (value == null || value.isEmpty!) {

                                        return 'Please enter your experience !';
                                      }
                                    }
                                    return null;
                                  },

                                  maxLines: null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 35),

                        //what you love about here
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            'What You Love About Here ?',
                            style:Theme.of(context).textTheme.headline5,
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: EdgeInsets.only(left: 20.0,right : 20),
                          child: Wrap(
                            spacing: 10.0, // Horizontal spacing between buttons
                            runSpacing: 5.0, // Vertical spacing between rows of buttons
                            children: loveAboutHereOptions.map((option) {
                              return ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (selectedLoveAboutHere.contains(option)) {
                                      selectedLoveAboutHere.remove(option);
                                    } else {
                                      selectedLoveAboutHere.add(option);
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
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left : 22.0,top : 10),
                          child: ElevatedButton(onPressed: (){
                            setState((){
                              Otherselectedforloveabouthere = !Otherselectedforloveabouthere;
                            });

                          },
                              style: ElevatedButton.styleFrom(
                                primary: Otherselectedforloveabouthere ?Colors.orange : Color(0xFF263238),
                                elevation: 0, // No shadow
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                                ),
                              ),
                              child: Text('other',style: Theme.of(context).textTheme.headline4,)),
                        ),

                        if (Otherselectedforloveabouthere == true)
                          Padding(
                            padding: EdgeInsets.only(left: 20.0,top:10),
                            child: Row(
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
                                      hintText: 'type here ...',
                                      hintStyle: TextStyle(color: Colors.white70),
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style: Theme.of(context).textTheme.headline4,
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
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 35),

                        //review this place
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What you don’t like about this place? ',
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
                                  onChanged: (text) {
                                    setState(() {
                                      dontLikeAboutHere = text;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'type here ...',
                                    hintStyle: TextStyle(color: Colors.white),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  style: Theme.of(context).textTheme.headline4,
                                  maxLines: null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 35),


                        // New input section for star rating
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review This Place',
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
                                  onChanged: (text) {
                                    setState(() {
                                      reviewText = text;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'type here ...',
                                    hintStyle: TextStyle(color: Colors.white),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  style: Theme.of(context).textTheme.headline4,
                                  maxLines: null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 35),


                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              Text(
                                'Rate your experience here :',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              SizedBox( height: 13,),
                              // Display stars based on the selected starRating
                              Row(
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    onPressed: () {
                                      setState(() {
                                        // Set the starRating to the current index + 1
                                        starRatingIsRequired = false;
                                        starRating = index + 1;
                                      });
                                    },
                                    icon: Icon(
                                      index < starRating ? Icons.star : Icons.star_border,
                                      color: starRatingIsRequired ? Colors.red : Color(0xFFFB8C00),
                                      size: 35,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 35),


                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Make this story' , style: TextStyle(fontSize: 18, color : Colors.white),),
                              SizedBox(height : 10),
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
                                                Text(value,style: Theme.of(context).textTheme.headline4),
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


                              SizedBox(height: 0),


                            ],
                          ),
                        ),
                      ],

                    ),
                  ),
                ),

                //for business development


                //save draft or publish button


                SizedBox(height : 35),
                //for business development


              ],

            ),
          ),

        ),
        bottomNavigationBar: AnimatedContainer(
          color:Theme.of(context).primaryColorDark,
          duration: Duration(milliseconds: 10),
          height: _isVisible ? kBottomNavigationBarHeight + 25 : 0.0,
          padding : EdgeInsets.only(left : 18, right : 20),
          child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                SizedBox(height : 10),

                Row(

                  children: [
                    Expanded(
                      child: Container(
                      
                        height: 63,
                        child: ElevatedButton(
                          onPressed: () async{
                            await saveDraft();
                            setState(() {
                              isSaveDraftClicked = !isSaveDraftClicked;
                              isPublishClicked = false; // Reset the other button's state
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: isSaveDraftClicked ? Color(0xFFFB8C00) : Colors.transparent, // Change background color
                            elevation: 0, // No shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          ),
                          child: Text(
                            'Save Draft',
                            style:Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width : 10),
                    Expanded(
                      child: Container(
                      
                        height: 63,
                        child: ElevatedButton(


                          onPressed: () {


                            setState(() {
                              if(starRating == 0){
                                starRatingIsRequired = true;
                              }
                            });







                      if (_formKey.currentState!.validate() && starRatingIsRequired == false) {
                        setState(() {

                          isPublishClicked = !isPublishClicked;
                          isSaveDraftClicked = false; // Reset the other button's state
                        });
                              // Your logic when the form is valid
                        sendDataToBackend();
                              print('Form is valid: $storyTitle');
                            }
                      


                            sendCustomNotificationToOneUser(
                                userToken,
                                'Uploading Your Story 📽️',
                                '$userName','uploading',
                                '','publishing story',userID,''
                            );



                            // Implement the functionality for publishing here

                          },
                          style: ElevatedButton.styleFrom(
                            primary: isPublishClicked ? Color(0xFFFB8C00) : Colors.transparent, // Change background color
                            elevation: 0, // No shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: BorderSide(color: Color(0xFFFB8C00), width: 2.0),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          ),
                          child: Text(
                            'Publish',
                            style:TextStyle(color : Colors.white30, fontWeight : FontWeight.bold,fontSize : 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


              ]
          ),
        ),

      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _thumbnailController.dispose();
    loveAboutHereInputController.dispose();
  }
}







