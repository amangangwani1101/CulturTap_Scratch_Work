import 'package:flutter/material.dart';

class CustomBusinessForm extends StatefulWidget {
  @override
  _CustomBusinessFormState createState() => _CustomBusinessFormState();
}

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

String _selectedCurrencyCode = '₹';

class _CustomBusinessFormState extends State<CustomBusinessForm> {
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
        SizedBox(height: 30),

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
        SizedBox(height: 30),

        // New input section for "What You Don't Like About This Place"
        Padding(
          padding: EdgeInsets.only(left : 26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Do you provide service / product at local’s door steps ?',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height : 35),
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
        SizedBox(height: 30),

        //offered prices of your product
        Padding(
          padding: EdgeInsets.only(left: 26.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offered price of your product or Service',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),


              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                child: Row(
                  children: [
                    // Country code dropdown
                    SizedBox(width : 5),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Color(0xFF263238), // Set the background color of the dropdown here
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCurrencyCode,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCurrencyCode = newValue!;
                          });
                        },
                        items: currencyCode.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(

                              value,
                              style: TextStyle(color: Colors.white), // Set text color to white
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(width: 5), // Add spacing between the dropdown and input field
                    // Phone number input field
                    Expanded(
                      child: Container(
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent, // Remove background color
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 10.0,
                            ),
                            hintText: 'Ex : 2250',
                            hintStyle: TextStyle(color: Colors.white), // Set hint text color to white
                          ),
                          style: TextStyle(color: Colors.white), // Set text color to white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height  : 30),

        //Delivery / transport Charges
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
        SizedBox(height: 30),

        //make this story public or private
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
        SizedBox(height  : 30),






      ],

    );
  }
}
