import 'package:flutter/material.dart';
import 'package:learn_flutter/CustomItems/imagePopUpWithOK.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/database_helper.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';
import 'package:flutter_svg/flutter_svg.dart';


class EditDraftPage extends StatefulWidget {
  final Draft draft;

  EditDraftPage({required this.draft});

  @override
  _EditDraftPageState createState() => _EditDraftPageState();
}

class _EditDraftPageState extends State<EditDraftPage> {
  late VideoPlayerController _thumbnailController;

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



  TextEditingController storyTitleController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController experienceDescriptionController = TextEditingController();
  TextEditingController dontLikeAboutHereController = TextEditingController();
  TextEditingController reviewTextController = TextEditingController();
  TextEditingController loveAboutHereInputController = TextEditingController();
  TextEditingController selectedOptionController = TextEditingController();
  TextEditingController transportationPricingController = TextEditingController();


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





    // Initialize the draft copy with the values from the provided draft

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
    );

    final rowsUpdated = await database.update('drafts', updatedDraft.toMap(),
        where: 'id = ?', whereArgs: [updatedDraft.id]);
    print('Updated $rowsUpdated row(s): ID ${draft.id}');

    showDialog(
      context: context,
      builder: (context) {
        return ImagePopUpWithOK(
            imagePath: 'assets/images/done.svg',
            textField: 'Your draft has been updated successfully 👌',
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
    return Scaffold(
      appBar: VideoAppBar(
        title: 'Compose Story',
      ),
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
                      SizedBox(height: 35),
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
                                      items: <String>['Category 1','Solo trip', 'Trip With Friends', 'Trip With Family', 'Office Trip', 'School Trip', 'Picnic']
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

                        SizedBox(height: 35),

                       //genre dropdown here
                        Padding(
                          padding: EdgeInsets.only(left: 26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Genre',
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
                                      value: selectedGenre,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedGenre = newValue!;
                                        });
                                      },
                                      items: <String>['Genre 1', 'Lifestyle', 'Street Foods', 'Restaurants' ,  'Party - Clubs & Bars',  'Fashion',  'Historical / Heritage',  'Festivals',  'Art & Culture', 'Advanture Place', 'Wild Life attraction', 'Entertainment Parks', 'National Parks', 'Cliffs & Mountains', 'Waterfalls', 'Forests',  'Beaches',   'Riverside',   'Resorts',   'Invasion Sites',   'Island',   'Haunted Places', 'Exhibitions',  'Caves',  'Aquatic Ecosystem',    ]
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

                        SizedBox(height: 35),

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
                                        storyTitle = text;
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
                        SizedBox(height: 35),




                        //Describe your experience
                        Padding(
                          padding: EdgeInsets.only(left: 26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Describe your Experience ',
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
                                  controller: experienceDescriptionController,
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


                        SizedBox(height: 35),

                        Padding(
                          padding: EdgeInsets.only(left: 26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                              'What You Love Here ?',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                            ],
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



                        SizedBox(height: 35),

                        //what you dont like about this place
                        Padding(
                          padding: EdgeInsets.only(left: 26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What you dont like about this place',
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
                                  controller: dontLikeAboutHereController,
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


                        SizedBox(height: 35),

                        //Review this place
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
                                  controller: reviewTextController,
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


                        SizedBox(height: 35),

                        //RATE YOUR EXPERIENCE HERE
                        Padding(
                          padding: EdgeInsets.only(left: 26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              Text(
                                'Rate your experience here :',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                        SizedBox(height: 35),

                        Padding(
                          padding: EdgeInsets.only(left: 26.0),
                          child: Column(
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
                                                Text(value, style: TextStyle(color: Colors.white)),
                                                SizedBox(width: 10),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),

                                      ),
                                    ),
                                  ],
                                ),
                              ),


                              SizedBox(height: 35),


                            ],
                          ),
                        ),




                        SizedBox(height: 20),






                      ],

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
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                                    'Select1', // Ensure there's exactly one 'Select' item
                                    'Furniture',
                                    'Handicraft',
                                    'Other',
                                  ].map<DropdownMenuItem<String>>((String value) {
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
                                      storyTitle = text;
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
                        SizedBox(height: 35),

                        //product description here
                        Padding(
                          padding: EdgeInsets.only(left: 26.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Describe your product or service ',
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
                                  controller: productDescriptionController,
                                  onChanged: (text) {
                                    setState(() {
                                      productDescription = text;
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


                        SizedBox(height : 35),
                        // Do you provide service at local's doorstep
                        Padding(
                          padding: EdgeInsets.only(left : 26.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Do you provide service / product at local’s door steps ?',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.orange),
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

                                    fillColor: MaterialStateColor.resolveWith((states) => Colors.orange),// Background color when selected
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
                                  keyboardType: TextInputType.phone,
                                    controller: transportationPricingController,
                                  onChanged: (text) {
                                    setState(() {
                                      transportationPricing = text;
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
                                'Save Draft',
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
