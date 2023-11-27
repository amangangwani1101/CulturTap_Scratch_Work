import 'package:flutter/material.dart';

class CustomRegularForm extends StatefulWidget {
  @override
  _CustomRegularFormState createState() => _CustomRegularFormState();
}

final List<String> loveAboutHereOptions = [
  'Beautiful',
  'Calm',
  'Party Place',
  'Pubs',
  'Restaurant',
  'Others',
];

class _CustomRegularFormState extends State<CustomRegularForm> {
  String selectedLabel = 'Regular Story';
  String selectedCategory = 'Category 1';
  String selectedGenre = 'Genre 1'; // Default selected genre
  String experienceDescription = '';
  List<String> selectedLoveAboutHere = []; // Initialize as an empty list
  bool showOtherLoveAboutHereInput = false;
  TextEditingController loveAboutHereInputController = TextEditingController();
  String dontLikeAboutHere = ''; // New input for "What You Don't Like About This Place"
  String selectedaCategory = "Select1";
  String reviewText = ''; // New input for "Review This Place"
  int starRating = 0; // New input for star rating
  String selectedVisibility = 'Public';
  String storyTitle = '';
  String productDescription = '';
  bool isSaveDraftClicked = false;
  bool isPublishClicked = false;
  String selectedOption = '';
  String productPrice = '';
  String transportationPricing = "";
  List<String> finalVideoPaths = [];

  // Add your methods here

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // category for regular stories
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
                ),
              ),
            ],
          ),
        ),


        SizedBox(height: 35),

        //genre for regular story
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
                child: DropdownButton<String>(
                  value: selectedGenre,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGenre = newValue!;
                    });
                  },
                  items: <String>['Genre 1', 'Lifestyle', 'Street Foods', 'Restaurants' , 'Party - Clubs & Bars',  'Fashion',  'Historical / Heritage',  'Festivals',  'Art & Culture', 'Advanture Place', 'Wild Life attraction', 'Entertainment Parks', 'National Parks', 'Cliffs & Mountains', 'Waterfalls', 'Forests',  'Beaches',   'Riverside',   'Resorts',   'Invasion Sites',   'Island',   'Haunted Places', 'Exhibitions',  'Caves',  'Aquatic Ecosystem',    ]
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
              ),
            ],
          ),
        ),
        SizedBox(height: 35),

        //story title for regular story
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
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 35),

        //experience for regular story
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
        SizedBox(height: 35),

        //what you love about here
        Padding(
          padding: EdgeInsets.only(left: 26.0),
          child: Text(
            'What You Love About Here',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 25),
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
        SizedBox(height: 35),

        //review this place
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
        SizedBox(height: 35),


// New input section for star rating
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
        SizedBox(height: 35),


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
        SizedBox(height: 35),


        Padding(
          padding: EdgeInsets.only(left: 26.0),
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
      ],

    );
  }
}
