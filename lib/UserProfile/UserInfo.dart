import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:learn_flutter/UserProfile/CoverPage.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/widgets/01_helpIconCustomWidget.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:multiselect/multiselect.dart';
import '../SearchEngine/SuggestionList.dart';
import '../Settings.dart';
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

import 'MultiCheckBox.dart';

// raw data variable
typedef void SetQuote(String? image);

// Motivational Quote Section
class MotivationalQuote extends StatefulWidget{
  ProfileDataProvider? profileDataProvider;
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
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.state=='final'
                ?Container(
                width: 300,
                  child: Text('${widget.quote==null?'':'" ${capitalizeWords(widget.quote!)}"'} ' ,style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,maxLines: null,overflow: TextOverflow.visible,
                ),
                )
                :GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> EditQuote(setQuote:handleQuote,quote:setQuote=='+ Add your Motivational quote'?'':capitalizeWords(setQuote!))));
                },
                child:
                widget.quote!=null
                    ? Container(
                  width : 300,
                  // color: Colors.green,
                  child: Text('" ${capitalizeWords(widget.text=='edit'?setQuote!:widget.quote!)} "' ,style: Theme.of(context).textTheme.subtitle2,textAlign: TextAlign.center,maxLines: 10,overflow: TextOverflow.visible,
                  ),
                    )
                    : !isQuoteSet?
                Center(

                  child: Container(
                    // color: Colors.black,
                    child: Text(setQuote!,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,color: HexColor('#FB8C00'),fontFamily: 'Poppins',),textAlign: TextAlign.center,
                    ),
                  ),
                ):
                Container(
                  width: 280,
                  // color: Colors.blue,
                  child: Text(setQuote!,style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,maxLines: null,overflow: TextOverflow.visible,
                  ),
                ),
              ),
              SizedBox(width: 10,),
              widget.quote!=null || widget.state=='final'
                  ?SizedBox(width: 0,)
                  :widget.text!='edit' || widget.quote==null
                      ?!isQuoteSet
                        ? InkWell(
                          onTap: (){
                            showDialog(context: context, builder: (BuildContext context){
                              return Container(child: CustomHelpOverlay(imagePath: 'assets/images/help_motivation_icon.jpg',serviceSettings: false),);
                            },
                            );
                          },
                        child: Icon(Icons.help_outline,color: HexColor('#FB8C00')))
                       :GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> EditQuote(setQuote:handleQuote,quote:setQuote=='+ Add your Motivational quote'?'':capitalizeWords(setQuote!))));
                        },
                        child: Icon(Icons.edit_outlined,color: Theme.of(context).primaryColorDark))
                     :SizedBox(width: 0,),
            ],
          ),
          SizedBox(height: 33,),
          widget.text=='edit'
            ?GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> EditQuote(setQuote:handleQuote,quote:setQuote=='+ Add your Motivational quote'?'':capitalizeWords(setQuote!))));
              },
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 45,
                    decoration: BoxDecoration(
                      color:Colors.orange,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.edit_outlined,size: 22,color: Colors.white,),
                        Text('EDIT QUOTE',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.white),),
                      ],
                    ),
                  ),
                  SizedBox(height : 30),
                ],
              ),
            )
            :SizedBox(height: 0,),
        ],
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
  FocusNode _motivationFocus = new FocusNode();
  @override
  void initState(){
    super.initState();
    if(widget.quote!=null){
      _textEditingController.text = widget.quote!;
    }
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding:EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 50,),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text('Motivational Quote',style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.w800,fontSize: 16,color: Theme.of(context).primaryColor),),
                          ),
                          InkWell(
                              onTap: (){
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.close,size: 30,weight: 20,)),
                        ],
                      ),
                    ),
                    SizedBox(height: 40,),
                    Container(
                      height:MediaQuery.of(context).size.height-250,
                      color: HexColor('#D9D9D9').withOpacity(0.5),
                      child: TextField(
                        autofocus: true,
                        focusNode: _motivationFocus,
                        cursorColor: Colors.orange,
                        style: Theme.of(context).textTheme.subtitle2,
                        maxLines: 80,
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText:'Ex . When you have a dream, you\'ve got to grab it and never let go',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: HexColor('#FB8C00')),
                            ),
                            border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(20),
                          hintStyle:TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.grey.withOpacity(0.5),fontFamily: 'Poppind')),
                        onTapOutside: (value){
                          _motivationFocus.unfocus();
                        },
                        onSubmitted: (value){
                          _motivationFocus.unfocus();
                        },
                        onEditingComplete: (){
                          _motivationFocus.unfocus();
                        },
                      ),

                      ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width:MediaQuery.of(context).size.width,
                height: 63,
                child: FiledButton(
                    backgroundColor: Colors.orange,
                    onPressed: () async{
                      if(_textEditingController.text.length==0){
                        await Fluttertoast.showToast(
                          msg:
                          'Set Your Quote !!',
                          toastLength:
                          Toast.LENGTH_SHORT,
                          gravity:
                          ToastGravity.BOTTOM,
                          backgroundColor:
                          Theme.of(context).primaryColorDark,
                          textColor: Colors.orange,
                          fontSize: 16.0,
                        );
                      }else{
                        setState(() {
                          if(_textEditingController.text.length>0){
                            _setsQuote = capitalizeWords(_textEditingController.text);
                            widget.quote = _setsQuote!;
                          }
                        });
                        widget.setQuote(_setsQuote!);
                        Navigator.of(context).pop();

                      }
                    },
                    child: Center(
                        child: Text('SET QUOTE',
                            style: Theme.of(context).textTheme.caption))),
              ),
            ),
          ],
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
    return Container(
      padding: EdgeInsets.only(left: 25,right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      ),
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
        Icon(icon,color : Theme.of(context).primaryColor,),
        // SizedBox(height: 4.0),
        Text(text,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
      ],
    );
  }
}



// Authentication Section
class SignIn extends StatefulWidget{
  ProfileDataProvider? profileDataProvider;
  VoidCallback? googleAuth;
  SignIn({this.profileDataProvider,this.googleAuth});
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
        widget.profileDataProvider!.updateImagePath(gPhotoUrl!);
        widget.profileDataProvider!.updateName(gName!);
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
    return Container(
      height: 120,
      margin: EdgeInsets.only(left:20,right: 20),
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
                    widget.googleAuth!();
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

class UserDetailsTable extends StatefulWidget {
  final String? place, profession, age, gender,id;
  final List<dynamic>? languageList;

  UserDetailsTable({this.place, this.profession, this.age, this.gender, this.languageList,this.id});

  @override
  _UserDetailsTableState createState() => _UserDetailsTableState();
}

class _UserDetailsTableState extends State<UserDetailsTable> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).backgroundColor,
          width: MediaQuery.of(context).size.width,
           padding: EdgeInsets.only(top: 15,left: 13,right: 10),
           // color:Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Place -',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Container(
                     width: 170,
                     // color: Colors.red,
                    child: Text(
                      widget.place ?? 'NA',
                      style: Theme.of(context).textTheme.subtitle2,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profession ',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Container(
                    width: 170,
                    child: Text(
                      widget.profession ?? 'NA',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Age/Gender -',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Container(
                    width: 170,
                    child: Text(
                      widget.age == null ? 'NA' : '${widget.age} Yr / ${widget.gender ?? ''}',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language -',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  widget.languageList != null
                      ? widget.languageList!.length < 5 || _showAll
                      ? Container(
                    width: 170,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: (){
                            if(widget.languageList!.length>4){
                              setState(() {
                                _showAll = false;
                              });
                            }
                          },
                          child: Container(
                            width:140,
                            // color: Colors.orange,
                            child: Text(
                              widget.languageList!.join(' , '), // Join the list elements with a comma and space
                              style: Theme.of(context).textTheme.subtitle2,
                              maxLines: null,
                            ),
                          ),
                        ),
                        widget.languageList!.length >4 ?
                        InkWell(
                          onTap: (){
                            setState(() {
                              _showAll = false;
                            });
                          },
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            size: 25,
                            weight: 15,
                            color: Colors.orange,
                          ),
                        )
                        :SizedBox(height: 0,),
                      ],
                    ),
                  )
                      : InkWell(
                          onTap: (){
                            setState(() {
                              _showAll = true;
                            });
                          },
                        child: Container(
                    width: 170,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 140,
                            child: Text(
                              widget.languageList!.join(' , '), // Join the list elements with a comma and space
                              style: Theme.of(context).textTheme.subtitle2,
                              maxLines: 2,
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                _showAll = true;
                              });
                            },
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 25,
                              weight: 3.0,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                    ),
                  ),
                      )
                      : Text('NA'),
                ],
              ),
            ],
          ),
        ),
        userID==widget.id
          ? Positioned(
          top: 0,
          right: 15,
          child: InkWell(
            onTap: ()async{
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(fromWhichPage:'final_profile_edit'),));
            },
            child: Row(
              children:[
                Image.asset('assets/images/edit_icon.png',width: 15,height: 15,),
                SizedBox(width: 3,),
                Text('EDIT',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),),
              ],
            ),
          ),
        )
          : SizedBox(height:0),
      ],
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
  List<String> suggestions = [];
  Rx<List<String>> selectedOptionsList = Rx<List<String>>([]);
  var selectedOptions = ''.obs;
  TextEditingController _ageController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  final List<String> genders = ['Male', 'Female', 'Other'];
  bool _isListVisible = false;
  List<String> languageOptions = [];
  bool otherHome=false,otherPro=false,showLocationConfirm=false;
  TextEditingController _otherHomeController = TextEditingController();
  TextEditingController _otherProController = TextEditingController();
  FocusNode _homeFocusNode = FocusNode();
  FocusNode _ProfessionFocusNode = FocusNode();
  // FocusNode _otherHomeFocusNode = FocusNode();
  // FocusNode _otherHomeFocusNode = FocusNode();

  Future<List<String>> fetchSuggestions(String query,String list) async {
    final String serverUrl = Constant().serverUrl;
    print(query);
    print(list);
    final apiUrl = '$serverUrl/suggestions?query=$query';
    try {
      final response = await http.patch(Uri.parse(apiUrl),
        headers: {
        "Content-Type": "application/json",
        },
        body: jsonEncode({'query':query,'list':list}),
      );
      print('here is the response');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        print(jsonResponse);
        final List<String> suggestionsList =
        List<String>.from(jsonResponse['suggestions']);
        setState(() {
          suggestions = suggestionsList;
        });

        return suggestionsList;
      } else {
        print('Error fetching suggestions: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error fetching suggestions: $error');
      return [];
    }
  }


  @override
  void initState() {
    super.initState();
    if(widget.setGender!=null){
      selectedGender = widget.setGender;
    }
    if(widget.setLanguage!=null){
      selectedOptionsList.value = widget.setLanguage!;
      languageOptions = widget.setLanguage!;
    }
    if(widget.setDOB!=null){
      selectedDateOfBirth = widget.setDOB;
    }
    // Get the device width using MediaQuery and store it in deviceWidth
  }
  @override
  void dispose() {
    // _focusNode.dispose();
    // _ageController.dispose();
    // _otherHomeController.dispose();
    // _otherProController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // bool _isFocused = false;
    return Container(
      padding: EdgeInsets.all(3.0),
      color : Theme.of(context).backgroundColor,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Home City', style: Theme.of(context).textTheme.subtitle1),
          SizedBox(height: 10),

          // setHomeCity,setProfession,setGender,setLanguage
          // CustomAutoSuggestion(
          //   cityList: Constant().cityList,
          //   text: 'Home city',
          //   state: widget.text,
          //   initialText:widget.setHomeCity,
          //   onValueChanged: (selectedValue) {
          //     if(selectedValue=='Others'){
          //       setState(() {
          //         otherHome = true;
          //       });
          //     }else{
          //       setState(() {
          //         otherHome = false;
          //       });
          //       if(widget.text=='edit'){
          //         widget.homeCityCallback!(selectedValue);
          //       }else{
          //         setState(() {
          //           customHomeCity = selectedValue;
          //         });
          //         if(selectedValue.isNotEmpty)
          //           widget.profileDataProvider?.updateFieldCnt(1);
          //         print(customHomeCity);
          //         widget.profileDataProvider?.updatePlace(customHomeCity!);
          //       }
          //     }
          //     // Add your logic here
          //   },
          // ),
          otherHome
            ?WillPopScope(
            onWillPop: ()async{
              _homeFocusNode.unfocus();
              return true;
            },
              child: Container(
              height: 79,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextField(
                    cursorColor:Colors.orange,
                    focusNode: _homeFocusNode,
                    style: Theme.of(context).textTheme.subtitle2,
                    controller: _otherHomeController,

                    decoration: InputDecoration(
                      hintText: 'Type Here....',
                      hintStyle: Theme.of(context).textTheme.subtitle2,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor('#FB8C00')),
                      ),
                      suffixIcon: widget.text != 'edit'
                          ? (widget.profileDataProvider?.retUpdatePlace()!=''
                          ? Icon(Icons.check_circle, color: Colors.green)  // Green tick icon
                          : Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00')))
                          :null,
                      suffix: widget.text == 'edit'
                          ? Text('EDIT', style: Theme.of(context).textTheme.headline4)
                          : null,

                    ),
                    onChanged: (value) {
                      setState(() {
                        customHomeCity = value;
                      });
                        print(customHomeCity);
                      if(widget.text=='edit'){
                        widget.homeCityCallback!(value);
                      }else{
                        widget.profileDataProvider?.updatePlace(value);
                      }
                      // Add your onChanged logic if needed
                    },
                    onEditingComplete: (){
                      _homeFocusNode.unfocus();
                    },
                    onTapOutside: (value){
                      _homeFocusNode.unfocus();
                    },
                    onSubmitted: (value){
                      _homeFocusNode.unfocus();
                    },
                  ),
                ],
              ),
          ),
            )
            :RawAutocomplete(
            optionsBuilder: (TextEditingValue textEditingValue) async{
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }else{
                // List<String> matches = <String>[];
                // matches.addAll(Constant().cityList);
                // matches.retainWhere((s){
                //   return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                // });
                // return matches.length>0?matches:['Others'];
                await fetchSuggestions(textEditingValue.text, 'city');
                return suggestions.length>0?suggestions:['Others'];
              }
            },

            onSelected: (String selectedValue) {
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
            },

            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              if(widget.setHomeCity!=null){
                textEditingController.text = widget.setHomeCity!;
                widget.setHomeCity = null;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    cursorColor: Colors.orange,
                    decoration: InputDecoration(
                      hintText: 'Select...',
                      hintStyle: Theme.of(context).textTheme.subtitle2,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor('#FB8C00')),
                      ),
                      border: OutlineInputBorder(),
                      suffixIcon: widget.text != 'edit'
                          ? (widget.profileDataProvider?.retUpdatePlace()!=''
                          ? Icon(Icons.check_circle, color: Colors.green)  // Green tick icon
                          : Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00')))
                          :null,
                      suffix: widget.text == 'edit'
                          ? Text('EDIT', style: Theme.of(context).textTheme.headline4)
                          : null,
                    ),
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: Theme.of(context).textTheme.subtitle2,
                    onSubmitted: (String selectedValue) {
                      if(customHomeCity==''){
                        setState(() {
                          textEditingController.text = '';
                          widget.profileDataProvider?.updatePlace('');
                        });
                      }else{
                        if(selectedValue=='Others'){
                          setState(() {
                            otherHome = true;
                            widget.profileDataProvider?.updatePlace(_otherHomeController.text);
                          });
                        }
                        else{
                          setState(() {
                            otherHome = false;
                          });
                          if(widget.text=='edit'){
                            widget.homeCityCallback!(selectedValue);
                          }
                          else{
                            setState(() {
                              customHomeCity = selectedValue;
                            });
                            if(selectedValue.isNotEmpty)
                              widget.profileDataProvider?.updateFieldCnt(1);
                            print(customHomeCity);
                            widget.profileDataProvider?.updatePlace(customHomeCity!);
                          }
                        }
                      }
                      focusNode.unfocus();
                    },
                    onTapOutside: (value){
                      if(customHomeCity==''){
                        setState(() {
                          textEditingController.text = '';
                          widget.profileDataProvider?.updatePlace('');
                        });
                      }
                      focusNode.unfocus();
                    },
                    onEditingComplete: (){
                      focusNode.unfocus();
                    },
                    onChanged: (value){
                      _otherHomeController.text = value;
                      widget.profileDataProvider?.updatePlace(value);
                    },
                    onTap: (){
                      setState(() {
                        _homeFocusNode.unfocus();
                        otherHome = false;
                      });
                    },
                  ),
                ],
              );
            },

            optionsViewBuilder: (BuildContext context, void Function(String) onSelected,
                Iterable<String> options) {
              return Material(
                  child:SizedBox(
                      height: 200,
                      child:SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: options.map((opt){
                              return InkWell(
                                  onTap: (){
                                    onSelected(opt);
                                  },
                                  child:Container(
                                      width: screenWidth*0.90,
                                      height: 60,
                                      child:Card(
                                          margin: EdgeInsets.all(0),
                                          child: Center(
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(10),
                                              margin: EdgeInsets.all(0),
                                              child:Text(opt,style: Theme.of(context).textTheme.subtitle2),
                                            ),
                                          )
                                      )
                                  )
                              );
                            }).toList(),
                          )
                      )
                  )
              );
            },
          ),

          // CustomAutoSuggestion(
          //   cityList: Constant().professionList,
          //   text: 'Profession',
          //   state: widget.text,
          //   initialText: widget.setProfession,
          //   onValueChanged: (selectedValue) {
          //     if(selectedValue=='Others'){
          //       setState(() {
          //         otherPro = true;
          //       });
          //     }else{
          //       setState(() {
          //         otherPro = false;
          //       });
          //       if(widget.text=='edit'){
          //         widget.professionCallback!(selectedValue);
          //       }else{
          //         if(selectedValue.isNotEmpty)
          //           widget.profileDataProvider?.updateFieldCnt(1);
          //         widget.profileDataProvider?.updateProfession(selectedValue);
          //       }
          //     }
          //     // Add your logic here
          //   },
          // ),
          SizedBox(height: 10,),
          RawAutocomplete(
            optionsBuilder: (TextEditingValue textEditingValue)async {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }else{
                await fetchSuggestions(textEditingValue.text, 'profession');
                return suggestions.length>0?suggestions:['Others'];
              }
            },

            onSelected: (String selectedValue) {
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
            },

            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              if(widget.setProfession!=null){
                textEditingController.text = widget.setProfession!;
                widget.setProfession = null;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profession', style: Theme.of(context).textTheme.subtitle1),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Select...',
                      hintStyle: Theme.of(context).textTheme.subtitle2,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor('#FB8C00')),
                      ),
                      border: OutlineInputBorder(),
                      suffixIcon: widget.text != 'edit'
                          ? (widget.profileDataProvider?.retUpdateProfession()!='Others' && widget.profileDataProvider?.retUpdateProfession()!=''
                          ? Icon(Icons.check_circle, color: Colors.green)  // Green tick icon
                          : Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00')))
                          :null,
                      suffix: widget.text == 'edit'
                          ? Text('EDIT', style: Theme.of(context).textTheme.headline4)
                          : null,
                    ),
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: Theme.of(context).textTheme.subtitle2,
                    onSubmitted: (String value) {
                    },
                  ),
                ],
              );
            },

            optionsViewBuilder: (BuildContext context, void Function(String) onSelected,
                Iterable<String> options) {
              return Material(
                  child:SizedBox(
                      height: 200,
                      child:SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: options.map((opt){
                              return InkWell(
                                  onTap: (){
                                    onSelected(opt);
                                  },
                                  child:Container(
                                      width: screenWidth*0.90,
                                      height: 60,
                                      child:Card(
                                          margin: EdgeInsets.all(0),
                                          child: Center(
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(10),
                                              margin: EdgeInsets.all(0),
                                              child:Text(opt,style: Theme.of(context).textTheme.subtitle2),
                                            ),
                                          )
                                      )
                                  )
                              );
                            }).toList(),
                          )
                      )
                  )
              );
            },
          ),
          SizedBox(height: 10,),
          otherPro
              ?Container(
            height: 79,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                  style: Theme.of(context).textTheme.subtitle2,
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
          SizedBox(height:10),
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
              print('Selected: ${selectedDateOfBirth}');
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
          SizedBox(height: 10,),
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
              setState(() {});
            },
            selectedValue: selectedGender, // Pass the selected value to the widget
          ),
          SizedBox(height: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height : 10),
              Text(
                'Language You Know',
            style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 10),
              // Container(
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.grey), // Add a grey border
              //     borderRadius: BorderRadius.circular(8.0), // Optional: Add border radius
              //   ),
              //
              //   height : 60,
              //   alignment: Alignment.center,
              //   child: DropDownMultiSelect(
              //     hint: Text('Select...',style: Theme.of(context).textTheme.subtitle1,), // Hint text for the dropdown
              //     hintStyle: Theme.of(context).textTheme.subtitle1,
              //     isDense: true,
              //     menuItembuilder: (item) {
              //       return Container(
              //         padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              //         child: Row(
              //           children: [
              //             Icon(Icons.check_circle, // You can change the icon based on selection
              //                 color: selectedOptionsList.value.contains(item)
              //                     ? Colors.green // Change color if item is selected
              //                     : Colors.grey),
              //             SizedBox(width: 10),
              //             Text(
              //               item.toString(), // Display the item's text
              //               style: TextStyle(
              //                 fontSize: 16,
              //                 color: selectedOptionsList.value.contains(item)
              //                     ? Colors.black // Change text color if item is selected
              //                     : Colors.grey,
              //               ),
              //             ),
              //           ],
              //         ),
              //       );
              //     },
              //     childBuilder: (selected) {
              //       return Row(
              //         children: [
              //           Container(
              //
              //             padding: EdgeInsets.all(10),
              //             width: 300, // Adjust as needed
              //             child: Text(
              //               selected.join(', '),
              //               style: TextStyle(
              //                 fontSize: 14,
              //                 color : Color(0xFF001B33),
              //                 overflow: TextOverflow.ellipsis,
              //                 fontWeight: FontWeight.w400,
              //               ),
              //             ),
              //           ),
              //           SizedBox(width: 10),
              //         ],
              //       );
              //     },
              //     enabled: true,
              //     options: Constant().languageList,
              //     decoration: InputDecoration(
              //       border: InputBorder.none,
              //       contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              //       fillColor: Colors.orange,
              //       suffixIcon: widget.text == 'edit'
              //           ? Padding(
              //         padding: const EdgeInsets.only(right: 8.0, top: 10),
              //         child: Text(
              //           'EDIT',
              //           style: Theme.of(context).textTheme.headline4,
              //         ),
              //       )
              //           : selectedOptionsList.value.length>0
              //           ? Icon(Icons.check_circle, color: Colors.green)
              //           :  Icon(Icons.arrow_drop_down_circle, color: Colors.orange),
              //     ),
              //     icon: SizedBox.shrink(),
              //     onChanged: (value) {
              //       selectedOptionsList.value = value;
              //       selectedOptions.value = '';
              //       selectedOptionsList.value.forEach((item) {
              //         selectedOptions.value = selectedOptions.value + ',' + item;
              //       });
              //       if (widget.text == 'edit') {
              //         widget.languageCallback!(selectedOptionsList.value);
              //       } else {
              //         if(selectedOptionsList.value.length>0)
              //           widget.profileDataProvider?.updateFieldCnt(1);
              //         widget.profileDataProvider?.updateLanguages(selectedOptionsList.value);
              //       }
              //       setState(() {
              //
              //       });
              //     },
              //     selectedValues: selectedOptionsList.value,
              //   ),
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      // Open the selection screen and wait for the result
                      final List<String>? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectionScreen(
                              selectedOptions: widget.text=='edit'? languageOptions : widget.profileDataProvider!.retUpdatedLanguage()
                          ),
                        ),
                      );

                      // Update selected options based on the result
                      if (result != null) {
                        setState(() {
                          languageOptions = result;
                        });
                        if (widget.text == 'edit') {
                          widget.languageCallback!(languageOptions);
                        } else {
                          if(languageOptions.length>0)
                            widget.profileDataProvider?.updateFieldCnt(1);
                          widget.profileDataProvider?.updateLanguages(languageOptions);
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // Add a grey border
                        borderRadius: BorderRadius.circular(5.0), // Optional: Add border radius
                        // color: Colors.red,
                      ),
                      height : 60,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              // maxLines: 4,
                              style:Theme.of(context).textTheme.subtitle2,
                              languageOptions.isEmpty
                                  ? 'Select...'
                                  : languageOptions.join(', '),
                            ),
                          ),
                          widget.text == 'edit'
                              ? Padding(
                            padding: const EdgeInsets.only(right: 8.0, top: 10),
                            child: Text(
                              'EDIT',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          )
                              : languageOptions.length>0
                              ? Icon(Icons.check_circle, color: Colors.green)
                              :  Icon(Icons.arrow_drop_down_circle, color: Colors.orange),
                          // Icon(Icons.arrow_drop_down_circle, color: Colors.orange)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // LocationButtonConfirmation(),
          SizedBox(height: 30,),
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

class LocationButtonConfirmation extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white.withOpacity(0.1),
      bottomNavigationBar: InkWell(
        onTap: (){
          Navigator.of(context).pop();
        },
        child: Container(
          width:MediaQuery.of(context).size.width,
          padding:EdgeInsets.only(left:(MediaQuery.of(context).size.width)/3,right: 12,top:12,bottom: 12 ),
          decoration:BoxDecoration(
            color: Colors.orange,
          ),
          child: Text('Set Language',style: Theme.of(context).textTheme.headline5,),
        ),
      ),
    );
  }
}

