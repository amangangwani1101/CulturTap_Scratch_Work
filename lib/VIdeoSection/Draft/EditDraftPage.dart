import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/CustomItems/imagePopUpWithOK.dart';
import 'package:learn_flutter/Settings.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:learn_flutter/VIdeoSection/Draft/AddCamera.dart';
import 'package:learn_flutter/VIdeoSection/VideoPreviewStory/VideoPreviewPage.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/database_helper.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';
import 'package:flutter_svg/flutter_svg.dart';



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










              ],
            ),
          ),
        ),
      ),
    );
  }
}





