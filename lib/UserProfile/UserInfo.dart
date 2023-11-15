import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/widgets/01_helpIconCustomWidget.dart';
import '../widgets/CustomButton.dart';
import '../widgets/CustomDropDowns.dart';
import '../widgets/hexColor.dart';
import '../BackendStore/BackendStore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// raw data variable
typedef void SetQuote(String? image);

// Motivational Quote Section
class MotivationalQuote extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  final String? quote;
  MotivationalQuote({this.profileDataProvider,this.quote});
  @override
  _MotivationalQuoteState createState() => _MotivationalQuoteState();
}
class _MotivationalQuoteState extends State<MotivationalQuote>{

  String? setQuote = '+ Add your Motivational quote';
  bool isQuoteSet = false;
  void handleQuote(String? quote) {
    setState(() {
      setQuote = quote ?? '+ Add your Motivational quote'; // Update the parameter in the main class
      widget.profileDataProvider?.updateQuote(quote!);
      isQuoteSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Center(
        child: Container(
          width: 350,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: widget.quote!=null?320:260,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> EditQuote(setQuote:handleQuote)));
                  },
                  child:
                  widget.quote!=null
                      ? Center(
                    child: Text('" ${widget.quote} "' ,style: TextStyle(fontSize: 14,fontFamily: 'Poppins',),maxLines: 2,overflow: TextOverflow.visible,
                    ),
                  )
                      : !isQuoteSet?
                  Text(setQuote!,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,color: HexColor('#FB8C00'),fontFamily: 'Poppins',),
                  ):
                  Center(
                    child: Text(setQuote!,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins',),maxLines: 2,overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              widget.quote!=null
                  ?SizedBox(width: 0,)
                  :!isQuoteSet?
              IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                showDialog(context: context, builder: (BuildContext context){
                  return Container(child: CustomHelpOverlay(imagePath: 'assets/images/help_motivation_icon.jpg',serviceSettings: false),);
                },
                );
              },
              ):SizedBox(width: 0,),
            ],
          ),
        ),
      );
  }
}
class EditQuote extends StatefulWidget{
  final SetQuote setQuote;
  EditQuote({required this.setQuote});

  @override
  _EditQuoteState createState() => _EditQuoteState();
}
class _EditQuoteState extends State<EditQuote>{
  String? _setsQuote;
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 333,
            height: 572,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 303,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text('Quote',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Poppins',),),
                      ),
                      Container(
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: 333,
                  height: 361,
                  color: HexColor('#D9D9D9'),
                  child: TextField(
                    maxLines: null,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText:'Type your quote........',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 20,left: 20, ),
                      hintStyle: TextStyle(color: Colors.black,fontSize: 16,fontFamily: 'Poppins'),
                    ),
                    style: TextStyle(color:Colors.black,fontFamily: 'Poppins',fontSize: 16,),
                  ),
                ),
                Container(
                  width: 326,
                  height: 53,
                  child: FiledButton(
                      backgroundColor: HexColor('#FB8C00'),
                      onPressed: () {
                        setState(() {
                          _setsQuote = _textEditingController.text;
                          widget.setQuote(_setsQuote!);
                        });
                        Navigator.of(context).pop();
                      },
                      child: Center(
                          child: Text('SET QUOTE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,)))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// Reach Section : followers + following
class ReachAndLocation extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  int? followers,following,locations;

  ReachAndLocation({ this.profileDataProvider,this.following,this.followers,this.locations});
  @override
  _ReachAndLocationState createState() => _ReachAndLocationState();
}
class _ReachAndLocationState extends State<ReachAndLocation>{

  @override
  Widget build(BuildContext context) {
    // func();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
            onTap: (){
              setState(() {
                widget.followers = widget.followers==null?0:widget.followers;
                widget.followers = (widget.followers! + 1);
                print('Followers : ${(widget.followers)}');
                widget.profileDataProvider?.updateFollowersCnt(widget.followers!);
              });
            },
            child: InfoWidget(icon: Icons.person_add_alt, text: widget.followers!=null?'${widget.followers} Follower':'${0} Follower')
        ),
        GestureDetector(
            onTap: (){
              setState(() {
                widget.following = widget.following==null?0:widget.following;
                widget.following = (widget.following! + 1)!;
                print('Following : ${(widget.following)}');
                widget.profileDataProvider?.updateFollowersCnt(widget.following!);
              });
            },
            child: InfoWidget(icon: Icons.person_outline, text: widget.following!=null?'${widget.following} Following':'${0} Following')
        ),
        InfoWidget(icon: Icons.add_location_outlined, text: widget.locations!=null?'${widget.locations} Location':'${1} Location'),
      ],
    );
  }
}
class InfoWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  InfoWidget({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // IconButton(padding: EdgeInsets.zero,onPressed: (){},icon: Icon(icon),),
        Icon(icon),
        // SizedBox(height: 4.0),
        Text(text,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
      ],
    );
  }
}



// Authentication Section
class SignIn extends StatefulWidget{
  @override
  _SignInState createState() => _SignInState();
}
class _SignInState extends State<SignIn>{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  TextEditingController _namecontroller = TextEditingController();
  bool isSignedIn = false;

  Future<User?> handleSignIn() async{
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      print('User$user');
      if (user != null) {
        setState(() {
          isSignedIn = true;
          _namecontroller.text = user.displayName ?? "";
        });
        return user;
      }
    }catch(e){
      print('Error SignIn With Google: $e');
      return null;
    }
  }

  @override
  void handleManualEntry(){
    setState(() {
      isSignedIn = false;
      _namecontroller.text = "";
    });
  }


  @override
  void dispose(){
    _namecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Container(
          width: 360,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Fetch Details From',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
              Container(
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.black,
                //     width: 1,
                //   ),
                // ),
                // width: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap:(){
                        print('Do it');
                        handleSignIn();
                      },
                      child: Column(
                        children: [
                          Container(
                            child: Image.asset('assets/images/gmail_icon.png',width: 27,height: 20,),
                          ),
                          SizedBox(height: 10,),
                          Text('Google',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),)
                        ],
                      ),
                    ),
                    SizedBox(width: 25,),
                    InkWell(
                      onTap:(){print('Do it');},
                      child: Column(
                        children: [
                          Container(
                            child: Image.asset('assets/images/facebook_icon.jpg',width: 22,height: 22,),
                          ),
                          SizedBox(height: 10,),
                          Text('Facebook',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}


//  Current hometown location fetcher
class LocationEditor extends StatefulWidget {
  final ProfileDataProvider? profileDataProvider;
  LocationEditor({this.profileDataProvider});
  @override
  _LocationEditorState createState() => _LocationEditorState();
}
class _LocationEditorState extends State<LocationEditor> {
  TextEditingController _locationController = TextEditingController();
  String _currentLocation = "Bengaluru"; // Default location

  @override
  void initState() {
    super.initState();
    _locationController.text = _currentLocation;
  }

  Future<void> _editLocation() async {
    LocationPermission permission; permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String city = placemarks.first.locality ?? "Unknown City";
    String state = placemarks.first.administrativeArea ?? "Bengaluru";

    setState(() {
      _currentLocation = "$city";
      widget.profileDataProvider?.updatePlace(city);
      _locationController.text = _currentLocation;
    });

    print("Latitude: ${position.latitude}");
    print("Longitude: ${position.longitude}");
    print("State: $state");
    print("City: $city");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 360,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 140,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Icon(Icons.location_on),
                ),
                Text('Location',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                Text(_currentLocation,style: TextStyle(fontSize: 12),),
              ],
            ),
          ),
          GestureDetector(
            onTap: (){
              _editLocation();
            },
            child: Container(
              width: 62,
              height: 61,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text('Autio-Locate',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.orange),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}


// ReqPage : 0 -> User Details : shows all saved data of user during profile form filling
class UserDetailsTable extends StatelessWidget {
  String? place = null,profession = null,age = null,gender = null;
  List<String>? languageList = [];
  UserDetailsTable({this.place,this.profession,this.age,
    this.gender,this.languageList});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.red,
      //     width: 2.0,
      //   )
      // ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Text('Place - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 96,),

              Text(place==null?'NA':'${place}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Profession - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 58,),
              Text(profession==null?'NA':'${profession}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Age/Gender - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 42,),
              Text(age ==null?'NA':'${age} Yr / ${gender}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Language - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 60,),
              Container(
                child: languageList==null ? Text('NA', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')):
                Wrap(
                  runSpacing: 8.0, // Vertical spacing between lines of items
                  children: [
                    Row(
                      children: [
                        for (int i = 0; i < languageList!.length; i++)
                          Container(
                            margin: EdgeInsets.only(right: 8.0),
                            child: Row(
                              children: [
                                Text(languageList![i]),
                                if (i < languageList!.length - 1)
                                  Text(',', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ReqPage : 1 -> Profile Form For User Details : input data of user
class ProfileForm extends StatefulWidget {
  final ProfileDataProvider? profileDataProvider;
  ProfileForm({this.profileDataProvider});
  @override
  _ProfileFormState createState() => _ProfileFormState();
}
class _ProfileFormState extends State<ProfileForm> {
  String? selectedProfession;
  DateTime? selectedDateOfBirth;
  String? selectedGender;
  String? selectedLanguage;
  late String save;
  String? age;
  TextEditingController _ageController = TextEditingController();
  final List<String> professions = [
    'Engineer',
    'Doctor',
    'Teacher',
    'Artist',
    // Add more professions as needed
  ];

  final List<String> genders = ['Male', 'Female', 'Other'];

  final List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
    // Add more languages as needed
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    @override
    void initState() {
      super.initState();
      // Get the device width using MediaQuery and store it in deviceWidth
      screenWidth = MediaQuery.of(context).size.width;
    }

    return Container(
      padding: EdgeInsets.all(10.0),

      child: Column(

        children: [
          CustomDropdown.build(
            label: 'Profession',
            items: professions,
            deviceWidth:screenWidth,
            onChanged: (String? newValue) {
              // Handle the selected value here, if needed
              print('Selected: $newValue');
            },
            setSelectedValue: (String? newValue) {
              // Set the selected value outside the widget
              selectedProfession = newValue!;
              if(newValue!=null)
                widget.profileDataProvider?.updateProfession(newValue!);
            },
            selectedValue: selectedProfession, // Pass the selected value to the widget
          ),
          SizedBox(height: 10,),
          CustomDOBDropDown(
            label: 'Date of Birth',
            selectedDate: selectedDateOfBirth,
            deviceWidth: screenWidth,
            onDateSelected: (DateTime? newDate) {
              setState(() {
                String age = (DateTime.now().year - (newDate!.year)).toString();
                widget.profileDataProvider?.updateAge(age);
                print('Path : ${age}');
                selectedDateOfBirth = newDate;
                print('Selected: ${newDate}');
              });
            },
          ),
          SizedBox(height: 10,),
          CustomDropdown.build(
            label: 'Gender',
            items: genders,
            deviceWidth:screenWidth,
            onChanged: (String? newValue) {
              // Handle the selected value here, if needed
              print('Selected: $newValue');
              widget.profileDataProvider?.updateGender(newValue!);
            },
            setSelectedValue: (String? newValue) {
              // Set the selected value outside the widget
              selectedGender = newValue!;
              if(newValue!=null)
                widget.profileDataProvider?.updateGender(newValue!);
            },
            selectedValue: selectedGender, // Pass the selected value to the widget
          ),
          SizedBox(height: 10,),
          CustomDropdown.build(
            label: 'Language You Know!',
            items: languages,
            deviceWidth:screenWidth,
            onChanged: (String? newValue) {
              // Handle the selected value here, if needed
              print('Selected: $newValue');
              // widget.profileDataProvider?.updateLanguages(newValue!);
            },
            setSelectedValue: (String? newValue) {
              // Set the selected value outside the widget
              selectedLanguage = newValue!;
              print('Path:$selectedLanguage');
            },
            selectedValue: selectedLanguage, // Pass the selected value to the widget
          ),
        ],
      ),
    );
  }
}

