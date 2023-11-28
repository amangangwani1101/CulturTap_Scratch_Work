import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:learn_flutter/UserProfile/CoverPage.dart';
import 'package:learn_flutter/widgets/01_helpIconCustomWidget.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:multiselect/multiselect.dart';
import '../widgets/CustomAutoSuggestionDropDown.dart';
import '../widgets/CustomButton.dart';
import '../widgets/CustomDropDowns.dart';
import '../widgets/hexColor.dart';
import '../BackendStore/BackendStore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// raw data variable
typedef void SetQuote(String? image);

// Motivational Quote Section
class MotivationalQuote extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  final String? quote,state,text;
  final Function(String)? quoteCallback;
  MotivationalQuote({this.profileDataProvider,this.quote,this.state,this.quoteCallback,this.text});
  @override
  _MotivationalQuoteState createState() => _MotivationalQuoteState();
}
class _MotivationalQuoteState extends State<MotivationalQuote>{

  String? setQuote = '+ Add your Motivational quote';
  bool isQuoteSet = false;
  @override
  void initState(){
    if(widget.quote!=null)
        setQuote = widget.quote;
  }
  void handleQuote(String? quot) {
    setState(() {
      setQuote = quot ?? '+ Add your Motivational quote'; // Update the parameter in the main class
      isQuoteSet = true;
    });
    if(widget.text=='edit'){
      widget.quoteCallback!(quot!);
    }else if(widget.profileDataProvider!=null){
      if(quot!.length>0){
        widget.profileDataProvider?.updateFieldCnt(50);
      }
      widget.profileDataProvider?.updateQuote(quot!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Center(
        child: Container(
          width: 350,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: widget.quote!=null?350:300,
                    child: widget.state=='final'
                      ?Center(
                        child: Text('${widget.quote==null?'':'" ${capitalizeWords(widget.quote!)}"'} ' ,style: TextStyle(fontSize: 14,fontFamily: 'Poppins',),textAlign: TextAlign.justify,maxLines: 10,overflow: TextOverflow.visible,
                      ))
                      :GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> EditQuote(setQuote:handleQuote,quote:setQuote=='+ Add your Motivational quote'?'':capitalizeWords(setQuote!))));
                      },
                      child:
                      widget.quote!=null
                          ? Center(
                        child: Text('" ${capitalizeWords(widget.text=='edit'?setQuote!:widget.quote!)} "' ,style: TextStyle(fontSize: 16,fontFamily: 'Poppins',),textAlign: TextAlign.justify,maxLines: 10,overflow: TextOverflow.visible,
                        ),
                      )
                          : !isQuoteSet?
                      Text(setQuote!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w800,color: HexColor('#FB8C00'),fontFamily: 'Poppins',),
                      ):
                      Center(
                        child: Text(setQuote!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w800,fontFamily: 'Poppins',),textAlign: TextAlign.justify,maxLines: 5,overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  widget.quote!=null || widget.state=='final'
                      ?SizedBox(width: 0,)
                      :widget.text!='edit' || widget.quote==null
                          ?!isQuoteSet
                            ? IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                              showDialog(context: context, builder: (BuildContext context){
                                return Container(child: CustomHelpOverlay(imagePath: 'assets/images/help_motivation_icon.jpg',serviceSettings: false),);
                                },
                               );
                              },)
                           :SizedBox(width: 0,)
                         :SizedBox(width: 0,),
                ],
              ),
              SizedBox(height: 33,),
              widget.text=='edit'
                ?GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> EditQuote(setQuote:handleQuote,quote:setQuote=='+ Add your Motivational quote'?'':capitalizeWords(setQuote!))));
                  },
                  child: Container(
                    width: 144,
                    height: 35,
                    decoration: BoxDecoration(
                      color: HexColor('#FB8C00'),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.edit_outlined,size: 19,color: Colors.white,),
                        Text('EDIT QUOTE',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white),),
                      ],
                    ),
                  ),
                )
                :SizedBox(height: 0,),
            ],
          ),
        ),
      );
  }
}
class EditQuote extends StatefulWidget{
  final SetQuote setQuote;
  String ?quote;
  EditQuote({required this.setQuote,this.quote});

  @override
  _EditQuoteState createState() => _EditQuoteState();
}
class _EditQuoteState extends State<EditQuote>{
  String? _setsQuote;
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState(){
    super.initState();
    if(widget.quote!=null){
      _textEditingController.text = widget.quote!;
    }
  }
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
                          _setsQuote = capitalizeWords(_textEditingController.text);
                          widget.quote = _setsQuote!;
                        });
                        widget.setQuote(_setsQuote!);
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
              // setState(() {
                // widget.followers = widget.followers==null?0:widget.followers;
                // widget.followers = (widget.followers! + 1);
                // print('Followers : ${(widget.followers)}');
                // widget.profileDataProvider?.updateFollowersCnt(widget.followers!);
              // });
            },
            child: InfoWidget(icon: Icons.person_add_alt, text: widget.followers!=null?'${widget.followers} Follower':'${0} Follower')
        ),
        GestureDetector(
            onTap: (){
              // setState(() {
                // widget.following = widget.following==null?0:widget.following;
                // widget.following = (widget.following! + 1)!;
                // print('Following : ${(widget.following)}');
                // widget.profileDataProvider?.updateFollowersCnt(widget.following!);
              // });
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
  ProfileDataProvider? profileDataProvider;
  SignIn({this.profileDataProvider});
  @override
  _SignInState createState() => _SignInState();
}
class _SignInState extends State<SignIn>{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  TextEditingController _namecontroller = TextEditingController();
  bool isSignedIn = false;
  String? emailId,gName,gPhotoUrl;
  // void Function(String,String) onDataChanged;
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
          emailId = user.email;
          gPhotoUrl = user.photoURL;
          gName = user.displayName;
          isSignedIn = true;
        });
        // working on auto updation from google
        // CoverPage(reqPage: 1,imagePath: gPhotoUrl,name: gName,profileDataProvider: widget.profileDataProvider,image:'network');
        widget.profileDataProvider!.updateEmail(emailId!);
        // onDataChanged(gPhotoUrl!,gName!);
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
    widget.profileDataProvider?.updatePlace(city);
    setState(() {
      _currentLocation = "$city";
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
  String? place,profession,age,gender;
  List<dynamic>? languageList;
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
              Text('Place -',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 94,),
              Text(place==null?'NA':'${place}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Profession -',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 58,),
              Text(profession==null?'NA':'${profession}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Age/Gender -',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 42,),
              Text(age ==null?'NA':'${age} Yr / ${gender==null?'':gender}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Language -',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 60,),
              // Container(
              //   child: languageList==null ? Text('NA', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')):
              //   Wrap(
              //     runSpacing: 8.0, // Vertical spacing between lines of items
              //     children: [
              //       Row(
              //         children: [
              //           for (int i = 0; i < languageList!.length; i++)
              //             Container(
              //               margin: EdgeInsets.only(right: 8.0),
              //               child: Row(
              //                 children: [
              //                   Text(languageList![i]),
              //                   if (i < languageList!.length - 1)
              //                     Text(',', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')),
              //                 ],
              //               ),
              //             ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              languageList!=null?
              Text(
                overflow:TextOverflow.ellipsis,
                languageList!.join(', '), // Join the list elements with a comma and space
                style: TextStyle(fontSize: 14, fontFamily: 'Poppins',overflow: TextOverflow.ellipsis),
                maxLines: 5,
              ):Text('NA'),
            ],
          ),
        ],
      ),
    );
  }
}


// ReqPage : 1 -> Profile Form For User Details : input data of user


// class MultiLanguageSelector extends StatelessWidget{
//   Rx<List<String>> selectedOptionsList = Rx<List<String>>([]);
//   var selectedOptions = ''.obs;
//
//
//   @override
//   Widget build(BuildContext context){
//     return Center(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Languages',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),),
//           SizedBox(height: 10,),
//           DropDownMultiSelect(
//             isDense: true,
//             enabled: true,
//             options: Constant().languageList,
//             whenEmpty: 'Select',
//             decoration: InputDecoration(
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: HexColor('#FB8C00')),
//               ),
//               border: OutlineInputBorder(),
//             ),
//             icon:Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00'),),
//             onChanged: (value){
//               selectedOptionsList.value = value;
//               selectedOptions.value = '';
//               selectedOptionsList.value.forEach((item) {
//                 selectedOptions.value = selectedOptions.value+',' + item;
//               });
//
//             },
//             selectedValues: selectedOptionsList.value,
//           ),
//         ],
//       ),
//     );
//   }
//
// }
class ProfileForm extends StatefulWidget {
  final Function(String)? homeCityCallback,professionCallback,genderCallback,ageCallBack;
  Function(DateTime)?dobCallback;
  Function(List<String>)?languageCallback;
  final ProfileDataProvider? profileDataProvider;
  String?text,setHomeCity,setProfession,setGender,setAge;
  DateTime?setDOB;
  List<String>?setLanguage;
  ProfileForm({this.setAge,this.ageCallBack,this.profileDataProvider,this.setDOB,this.setGender,this.setHomeCity,this.setLanguage,this.setProfession,this.text,this.homeCityCallback,this.dobCallback,this.genderCallback,this.languageCallback,this.professionCallback});
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

String customHomeCity='';
class _ProfileFormState extends State<ProfileForm> {
  String? selectedProfession;
  DateTime? selectedDateOfBirth;
  String? selectedGender;
  String? selectedLanguage;
  late String save;
  String? age;
  Rx<List<String>> selectedOptionsList = Rx<List<String>>([]);
  var selectedOptions = ''.obs;
  TextEditingController _ageController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  final List<String> genders = ['Male', 'Female', 'Other'];


  bool otherHome=false,otherPro=false;
  TextEditingController _otherHomeController = TextEditingController();
  TextEditingController _otherProController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    @override
    void initState() {
      super.initState();
      // Get the device width using MediaQuery and store it in deviceWidth
      screenWidth = MediaQuery.of(context).size.width;
    }
    // bool _isFocused = false;
    if(widget.setGender!=null){
      selectedGender = widget.setGender;
    }
    if(widget.setLanguage!=null){
      selectedOptionsList.value = widget.setLanguage!;
    }
    if(widget.setDOB!=null){
      selectedDateOfBirth = widget.setDOB;
    }
    final FocusNode _focusNode = FocusNode();
    return Container(
      padding: EdgeInsets.all(10.0),

      child: Column(

        children: [
          // setHomeCity,setProfession,setGender,setLanguage
          CustomAutoSuggestion(
            cityList: Constant().cityList,
            text: 'Home city',
            state: widget.text,
            initialText:widget.setHomeCity,
            onValueChanged: (selectedValue) {
              if(selectedValue=='Others'){
                setState(() {
                  otherHome = true;
                });
              }else{
                setState(() {
                  otherHome = false;
                });
                if(widget.text=='edit'){
                  widget.homeCityCallback!(selectedValue);
                }else{
                  setState(() {
                    customHomeCity = selectedValue;
                  });
                  if(selectedValue.isNotEmpty)
                    widget.profileDataProvider?.updateFieldCnt(1);
                  print(customHomeCity);
                  widget.profileDataProvider?.updatePlace(customHomeCity!);
                }
              }
              // Add your logic here
            },
          ),
          SizedBox(height: 10,),
          otherHome
            ?Container(
            height: 79,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                  focusNode: _focusNode,
                  controller: _otherHomeController,
                  decoration: InputDecoration(
                    hintText: 'Type Here....',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor('#FB8C00')),
                    ),
                  ),

                  onChanged: (value) {
                    setState(() {
                      customHomeCity = customHomeCity+value;
                    });
                      print(customHomeCity);
                    if(widget.text=='edit'){
                      widget.homeCityCallback!(value);
                    }else{
                      widget.profileDataProvider?.updatePlace(value);
                    }
                    // Add your onChanged logic if needed
                  },
                ),
              ],
            ),
          )
            :SizedBox(height: 0,),
          CustomAutoSuggestion(
            cityList: Constant().professionList,
            text: 'Profession',
            state: widget.text,
            initialText: widget.setProfession,
            onValueChanged: (selectedValue) {
              if(selectedValue=='Others'){
                setState(() {
                  otherPro = true;
                });
              }else{
                setState(() {
                  otherPro = false;
                });
                if(widget.text=='edit'){
                  widget.professionCallback!(selectedValue);
                }else{
                  if(selectedValue.isNotEmpty)
                    widget.profileDataProvider?.updateFieldCnt(1);
                  widget.profileDataProvider?.updateProfession(selectedValue);
                }
              }
              // Add your logic here
            },
          ),
          otherPro
              ?Container(
            height: 79,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                  focusNode: _focusNode,
                  controller: _otherProController,
                  decoration: InputDecoration(
                    hintText: 'Type Here....',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor('#FB8C00')),
                    ),
                  ),
                  onChanged: (value) {
                    if(widget.text=='edit'){
                      widget.professionCallback!(value);
                    }else{
                      widget.profileDataProvider?.updateProfession(value);
                    }
                    // Add your onChanged logic if needed
                  },
                ),
              ],
            ),
          )
              :SizedBox(height: 0,),
          SizedBox(height: 10,),
          CustomDOBDropDown(
            label: 'Date of Birth',
            text: widget.text,
            selectedDate: selectedDateOfBirth,
            deviceWidth: screenWidth,
            onDateSelected: (DateTime? newDate) {
              String age = (DateTime.now().year - (newDate!.year)).toString();
              setState(() {
                print('Path : ${age}');
                selectedDateOfBirth = newDate;
                print('Selected: ${newDate}');
              });
              if(widget.text=='edit'){
                widget.dobCallback!(newDate);
                widget.ageCallBack!(age);
              }else{
                if(int.parse(age)>0)
                  widget.profileDataProvider?.updateFieldCnt(1);
                widget.profileDataProvider?.updateDOb(newDate);
                widget.profileDataProvider?.updateAge(age);
              }
            },
          ),
          SizedBox(height: 20,),
          CustomDropdown.build(
            label: 'Gender',
            items: genders,
            text: widget.text,
            deviceWidth:screenWidth,
            onChanged: (String? newValue) {
              // Handle the selected value here, if needed
              print('Selected: $newValue');
              widget.profileDataProvider?.updateGender(newValue!);
            },
            setSelectedValue: (String? newValue) {
              // Set the selected value outside the widget
              selectedGender = newValue!;
              if(widget.text=='edit'){
                widget.genderCallback!(newValue!);
              }else{
                if(newValue.isNotEmpty)
                  widget.profileDataProvider?.updateFieldCnt(1);
                widget.profileDataProvider?.updateGender(newValue!);
              }
            },
            selectedValue: selectedGender, // Pass the selected value to the widget
          ),
          SizedBox(height: 20,),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language You Know',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropDownMultiSelect(
                          isDense: true,
                          childBuilder: (selected) {
                            return Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  width: 310, // Adjust as needed
                                  child: Text(
                                    selected.join(', '),
                                    style: TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            );
                          },
                          enabled: true,
                          options: Constant().languageList,
                          whenEmpty: 'Select', // Placeholder text when no option is chosen
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: HexColor('#FB8C00')),
                            ),
                            border: OutlineInputBorder(),
                            suffixIcon: widget.text == 'edit'
                                ? Padding(
                              padding: const EdgeInsets.only(right: 8.0, top: 10),
                              child: Text(
                                'EDIT',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: HexColor('#FB8C00'),
                                ),
                              ),
                            )
                                : Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00')),
                          ),
                          icon: SizedBox.shrink(),
                          onChanged: (value) {
                            selectedOptionsList.value = value;
                            selectedOptions.value = '';
                            selectedOptionsList.value.forEach((item) {
                              selectedOptions.value = selectedOptions.value + ',' + item;
                            });
                            if (widget.text == 'edit') {
                              widget.languageCallback!(selectedOptionsList.value);
                            } else {
                              if(selectedOptionsList.value.length>0)
                                widget.profileDataProvider?.updateFieldCnt(1);
                              widget.profileDataProvider?.updateLanguages(selectedOptionsList.value);
                            }
                          },
                          selectedValues: selectedOptionsList.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10,),
      // Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Column(
      //     children: [
      //       DropdownButtonFormField(
      //         isDense: true,
      //         isExpanded: true,
      //         hint: Text('Select Fields'),
      //         value: val,
      //         items: allFields.map((field) {
      //           return DropdownMenuItem(
      //             value: field,
      //             child: Text(field),
      //           );
      //         }).toList(),
      //         onChanged: (String ?newValue) {
      //           print('NN::$newValue');
      //             selectedFields!.add(newValue!);
      //             allFields.remove(newValue);
      //             val = newValue!;
      //         },
      //       ),
      //       SizedBox(height: 10),
      //       Text('Selected Fields: ${selectedFields!.join(', ')}'),
      //     ],
      //     ),
      //   ),
        ],
      ),
    );
  }
}

