import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/database_helper.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';

class EditDraftPage extends StatefulWidget {
  final Draft draft;

  EditDraftPage({required this.draft});

  @override
  _EditDraftPageState createState() => _EditDraftPageState();
}

class _EditDraftPageState extends State<EditDraftPage> {
  late VideoPlayerController _thumbnailController;

  String selectedLabel = '';
  String storyTitle = '';
  TextEditingController storyTitleController = TextEditingController();

  bool isSaveDraftClicked = false;
  bool isPublishClicked = false;

  @override
  void initState() {
    super.initState();
    // Initialize the VideoPlayerController with the first video of the draft

    if (widget.draft.videoPaths.isNotEmpty) {
      _thumbnailController = VideoPlayerController.network(
        widget.draft.videoPaths.split(',')[0],
      )..initialize().then((_) {
        setState(() {});
      });
    }

    // Populate the fields with data from the draft
    selectedLabel = widget.draft.selectedLabel;
    storyTitle = widget.draft.storyTitle;

    // selectedCategory = widget.draft.selectedCategory;
    // selectedGenre = widget.draft.selectedGenre;
    // experienceDescription = widget.draft.experienceDescription;
    // selectedLoveAboutHere = widget.draft.selectedLoveAboutHere;
    // dontLikeAboutHere = widget.dontLikeAboutHere;
    // selectedaCategory = widget.draft.selectedaCategory;
    // reviewText = widget.draft.reviewText;
    // starRating = widget.draft.starRating;
    // selectedVisibility = widget.draft.selectedVisibility;

    // productDescription = widget.draft.productDescription;

    // Initialize the draft copy with the values from the provided draft

  }

  Future<void> updateDraft(Draft draft) async {
    final database = await DatabaseHelper.instance.database;
    draft.selectedLabel = selectedLabel;
    draft.storyTitle = storyTitleController.text;

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
    );

    final rowsUpdated = await database.update('drafts', updatedDraft.toMap(),
        where: 'id = ?', whereArgs: [updatedDraft.id]);
    print('Updated $rowsUpdated row(s): ID ${draft.id}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Draft Updated'),
          content: Text('Your draft has been updated.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
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

              SizedBox(height : 100),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  // ...
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      Padding(
                        padding: EdgeInsets.only(left: 26.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Differentiate this experience as ',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                                      child: Text(value, style: TextStyle(color: Colors.white)),
                                    );
                                  }).toList(),
                                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.orange,
                                  ),
                                )

                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),


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
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              // Theme(
                              //   data: Theme.of(context).copyWith(
                              //     canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                              //   ),
                              //   child: DropdownButton<String>(
                              //     value: selectedaCategory,
                              //     onChanged: (String? newValue) {
                              //       setState(() {
                              //         selectedaCategory = newValue!;
                              //       });
                              //     },
                              //     items: <String>[
                              //       'Select', // Ensure there's exactly one 'Select' item
                              //       'Option 1',
                              //       'Option 2',
                              //       'Option 3',
                              //     ].map<DropdownMenuItem<String>>((String value) {
                              //       return DropdownMenuItem<String>(
                              //         value: value,
                              //         child: Text(value, style: TextStyle(color: Colors.white)),
                              //       );
                              //     }).toList(),
                              //     icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                              //     underline: Container(
                              //       height: 2,
                              //       color: Colors.orange,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),

                        //story title here
                        Padding(
                          padding: EdgeInsets.only(left: 26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Story Title ',
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
                                  controller: storyTitleController,
                                  onChanged: (text) {
                                    setState(() {
                                      storyTitle = storyTitle;
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
                                )

                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),

                        //product description here






                      ],

                    ),
                  ),

                  SizedBox(height : 100),
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
                                widget.draft.storyTitle = storyTitleController.text;
                                await updateDraft(widget.draft);
                                setState(() {
                                  isSaveDraftClicked = !isSaveDraftClicked;
                                  isPublishClicked = false; // Reset the other button's state
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                primary: isSaveDraftClicked
                                    ? Colors.orange
                                    : Colors.transparent, // Change background color
                                elevation: 0, // No shadow
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(
                                      color: Colors.orange, width: 2.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                              ),
                              child: Text(
                                'Update Draft',
                                style: TextStyle(
                                  color: isSaveDraftClicked
                                      ? Colors.white
                                      : Colors.orange, // Change text color
                                  fontWeight:
                                  FontWeight.bold, // Change font weight
                                  fontSize: 22,
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
                              },
                              style: ElevatedButton.styleFrom(
                                primary: isPublishClicked
                                    ? Colors.orange
                                    : Colors.transparent, // Change background color
                                elevation: 0, // No shadow
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(
                                      color: Colors.orange, width: 2.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                              ),
                              child: Text(
                                'Publish',
                                style: TextStyle(
                                  color: isPublishClicked
                                      ? Colors.white
                                      : Colors.orange, // Change text color
                                  fontWeight:
                                  FontWeight.bold, // Change font weight
                                  fontSize: 22,
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
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       body: EditDraftPage(
//         draft: Draft(
//           id: 1,
//           // Populate the draft fields with your database values
//           // ...
//         ),
//       ),
//     ),
//   ));
// }
