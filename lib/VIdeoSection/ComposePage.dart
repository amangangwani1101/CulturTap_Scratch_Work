import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:math';

class ComposePage extends StatefulWidget {
  final List<String> videoPaths;

  ComposePage({required this.videoPaths});

  @override
  _ComposePageState createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  late VideoPlayerController _thumbnailController;
  late int randomIndex;
  String selectedLabel = 'Regular Story';
  String selectedCategory = 'Category 1';
  String selectedGenre = 'Genre 1'; // Default selected genre
  String experienceDescription = '';
  List<String> selectedLoveAboutHere = []; // Initialize as an empty list
  bool showOtherLoveAboutHereInput = false;
  TextEditingController loveAboutHereInputController = TextEditingController();
  String dontLikeAboutHere = ''; // New input for "What You Don't Like About This Place"
  String reviewText = ''; // New input for "Review This Place"
  int starRating = 0; // New input for star rating
  String selectedVisibility = 'Public';
  String liveLocation = '';

  final List<String> loveAboutHereOptions = [
    'Beautiful',
    'Calm',
    'Party Place',
    'Pubs',
    'Restaurant',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    randomIndex = Random().nextInt(widget.videoPaths.length);
    _thumbnailController = VideoPlayerController.file(File(widget.videoPaths[randomIndex]))
      ..initialize().then((_) {
        setState(() {});
      });

    fetchUserLocation();
  }




  // Function to fetch the user's location and update liveLocation
  Future<void> fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // Format the user's location into a string
      String location = 'Lat: ${position.latitude}, Long: ${position.longitude}';

      setState(() {
        liveLocation = location;
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VideoAppBar(),
      body: Container(
        color: Color(0xFF263238),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    constraints: BoxConstraints(
                      maxWidth: 300,
                      maxHeight: 300,
                    ),
                    child: AspectRatio(
                      aspectRatio: _thumbnailController.value.aspectRatio,
                      child: Stack(
                        children: [
                          VideoPlayer(_thumbnailController),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 4.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),



                      ],

                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Row(
                      children: [

                        SizedBox(width: 18),
                        Text(
                          liveLocation.isNotEmpty ? liveLocation : 'Fetching Location...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Differentiate this experience as ',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
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
                              child: Text(value, style: TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                          underline: Container(
                            height: 2,
                            color: Colors.orange,
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



                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                            });
                          },
                          items: <String>['Category 1', 'Category 2', 'Category 3']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                          underline: Container(
                            height: 2,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genre',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: selectedGenre,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGenre = newValue!;
                            });
                          },
                          items: <String>['Genre 1', 'Genre 2', 'Genre 3']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                          underline: Container(
                            height: 2,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Describe Your Experience : ',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.orange, width: 2.0),
                            ),
                          ),
                          child: TextField(
                            onChanged: (text) {
                              setState(() {
                                experienceDescription = text;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'type here ...',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.white),
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
                    child: Text(
                      'What You Love About Here',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
                    child: Wrap(
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
                            primary: selectedLoveAboutHere.contains(option) ? Colors.orange : Color(0xFF263238),
                            elevation: 0, // No shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.orange, width: 2.0),
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (showOtherLoveAboutHereInput)
                    Padding(
                      padding: EdgeInsets.only(left: 26.0),
                      child: Row(
                        children: [
                          Container(
                            width: 200,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.orange, width: 2.0),
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
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              style: TextStyle(color: Colors.white),
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
                              primary: Colors.orange,
                              elevation: 0, // No shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            child: Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // New input section for "What You Don't Like About This Place"
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What you don’t like about this place? ',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.orange, width: 2.0),
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
                            style: TextStyle(color: Colors.white),
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // New input section for "Review This Place"

                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review This Place',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.orange, width: 2.0),
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
                            style: TextStyle(color: Colors.white),
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // New input section for star rating
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
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
                                  starRating = index + 1;
                                });
                              },
                              icon: Icon(
                                index < starRating ? Icons.star : Icons.star_border,
                                color: Colors.orange,
                                size: 35,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.only(left: 26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Make this story' , style: TextStyle(fontSize: 18, color : Colors.white),),
                        Container(


                          child: Row(
                            children: [
                              DropdownButton<String>(
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
                                            ? Icon(Icons.public, color: Colors.black)
                                            : Icon(Icons.lock, color: Colors.black),
                                        SizedBox(width: 5),
                                        Text(value, style: TextStyle(color: Colors.black)),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),

                              ),
                            ],
                          ),
                        ),


                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width : 156,
                              height : 63,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Implement the functionality for saving draft here
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.transparent, // Transparent background
                                  elevation: 0, // No shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0), // Increase the border radius
                                    side: BorderSide(color: Colors.orange, width: 2.0),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Increase padding here
                                ),
                                child: Text(
                                  'Save Draft',
                                  style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold, fontSize: 22)
                                  ,
                                ),
                              ),
                            ),
                            Container(
                              width : 156,
                              height : 63,

                              child: ElevatedButton(
                                onPressed: () {
                                  // Implement the functionality for publishing here
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.transparent, // Orange background
                                  elevation: 0, // No shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.orange, width: 2.0),// Increase the border radius
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Increase padding here
                                ),
                                child: Text(
                                  'Publish',
                                  style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold, fontSize: 22),
                                ),
                              ),
                            ),

                          ],

                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
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
    super.dispose();
    _thumbnailController.dispose();
    loveAboutHereInputController.dispose();
  }
}



void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: ComposePage(videoPaths: ['video1.mp4', 'video2.mp4']),
    ),
  ));
}
