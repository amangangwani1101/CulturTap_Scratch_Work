import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/CustomItems/CustomPopUp.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/LocalAssistance/EmergenceAssist.dart';
import 'package:learn_flutter/LocalAssistance/LocalAssist2.dart';
import 'package:learn_flutter/LocalAssistance/ChatsPage.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:learn_flutter/userLocation.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ServiceSections/PingsSection/Pings.dart';
import '../widgets/CustomDialogBox.dart';

class LocalAssist extends StatefulWidget {
  @override
  _LocalAssistState createState() => _LocalAssistState();
}

class _LocalAssistState extends State<LocalAssist> {

  String ?meetId,state,meetStatus;
  bool? eligible;

  bool loaded = false;
  bool _meetingsChecked = false;



  @override
  void initState() {
    super.initState();
    // Your initialization code goes here
    localAssistOperation();
  }


  Future<void> localAssistOperation() async{

    await checkIsMeetOngoing();
    setState(() {
      loaded = true;
    });
  }


  Future<Map<String, double>> getUserIdsAndDistances(String providedLatitude, String providedLongitude) async {
    final String serverUrl = Constant().serverUrl;
    final Uri uri = Uri.parse('$serverUrl/findUserIdsAndDistancesWithin10Km?providedLatitude=$providedLatitude&providedLongitude=$providedLongitude');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['allUserIdsAndDistances'];

        final Map<String, double> userIdsAndDistances = {};

        data.forEach((item) {
          userIdsAndDistances[item['userId']] = item['distance'].toDouble();
        });
        print('helping hands');
        print(userIdsAndDistances);
        return userIdsAndDistances;
      } else {
        throw Exception('Failed to load data for helping hands');
      }
    } catch (error) {
      print('Error fetching user IDs and distances: $error');
      throw error; // Rethrow the error to propagate it to the calling code
    }
  }




  // check is meeting ongoing
  Future<void> checkIsMeetOngoing()async {
    await PingsAssistanceChecker(userID);
  }

  Future<void> checkIsEligible() async{
    await PingsAssistanceEligible(userID);
  }

  Future<void> PingsAssistanceChecker(userId) async {
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final url = Uri.parse('$serverUrl/checkLocalUserPings/${userId}'); // Replace with your backend URL
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {

        _meetingsChecked = true;

        final data = json.decode(response.body);
        print('this is the daa');
        print(data);
        setState(() {
          if(data['meetId']!=null){
            meetId = data['meetId'];
          }
          if(data['state']!=null){
            state = data['state'];
          }
          if(data['eligible']!=null){
            eligible = data['eligible'];
          }
          print('what is this');
          final  rare = (data['data']);
          final meetStatus1 = rare['meetStatus'];
          print(meetStatus1);


          if(meetStatus1!=null){
            meetStatus = meetStatus1;
          }

          _meetingsChecked = true;


        });
        print('Meeting Ongoing : $meetId');

      } else {
        // Handle error
        print('Failed to fetch dataset: ${response.statusCode}');
      }
    }
    catch(err){
      print('Error $err');
    }
  }

  Future<void> PingsAssistanceEligible(userId) async {
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final url = Uri.parse('$serverUrl/checkLocalUserEligible/${userId}'); // Replace with your backend URL
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('checking for eligibility');
        print(data);

      } else {
        // Handle error
        print('Failed to fetch dataset: ${response.statusCode}');
      }
    }
    catch(err){
      print('Error $err');
    }
  }

  Future<bool> showConfirmationDialog(BuildContext context, String receiverName) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          message: 'Are You Sure To Cancel Meet With $receiverName',
          onCancel: () {
            Navigator.of(context).pop(false); // Return false when canceled
          },
          onConfirm: () {
            Navigator.of(context).pop(true); // Return true when confirmed
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        return false;
      },
      child: Scaffold(

        appBar: AppBar(title : ProfileHeader(reqPage: 0,userId: userID,),  automaticallyImplyLeading:false, toolbarHeight: 90, shadowColor: Colors.transparent,),


        body: SingleChildScrollView(

          child:   _meetingsChecked ?
          Container(
            color : Theme.of(context).backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // SizedBox(height: 20,),
                  state!=null && state!='ongoing'
                      ?Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PingsSection(userId: userID,selectedService: 'Local Assistant',state: 'Scheduled')));
                          },
                          child: Container(

                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange),
                            ),
                            padding: EdgeInsets.only(left: 5,right: 20),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24.0,right : 22),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [

                                          Text('Check Ongoing Services ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.orange),),
                                          Text('(4)',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.orange),),


                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text('You can also create multiple requests !',style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300,fontFamily: 'Poppins',color: Colors.orange),),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward_ios,size: 14,color: Colors.orange,),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  )
                      :SizedBox(height: 0,),
                  state!=null && state!='ongoing'
                      ? SizedBox(height : 20)
                      : SizedBox(height: 0,),
                  SizedBox(height : 10),


                  InkWell(
                    onTap: ()async{
                      bool userConfirmed = true;
                      if(eligible!=null && eligible==false){
                        userConfirmed = await showConfirmationDialog(context, userName!);
                        if(userConfirmed){
                          await checkIsEligible();
                        }
                      }
                      if(userConfirmed){
                        if(meetId!=null){
                          print('meet id print krwa rhe hian $meetId');
                          if(state=='user' || state=='ongoing'){
                            await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: userID,
                              state: 'user',
                              meetId: meetId,
                              where: 'local_assist',

                            ),));
                            await checkIsMeetOngoing();
                          }
                          else if(state=='helper'){
                            // toast
                            Fluttertoast.showToast(
                              msg: "Finish Ongoing Services",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                            );
                            await Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: userID,
                              state: 'helper',
                              meetId: meetId,
                              where: 'local_assist',
                            ),));
                            await checkIsMeetOngoing();
                          }
                        }
                        else {
                          await Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>
                                ChatsPage(userId: userID,
                                  state: 'user',
                                ),));
                          await checkIsMeetOngoing();
                        }
                      }
                    },
                    child: Container(

                      height : 150,

                      decoration: BoxDecoration(
                        color : Theme.of(context).backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 0.5,
                            blurRadius: 3,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.white30), // Optional: Add border for visual clarity
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24.0,right : 22),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,


                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.help_outline,color : Colors.orange),
                                      onPressed: () {

                                        showDialog(context: context, builder: (BuildContext context){
                                          return Container(child : CustomPopUp(
                                            imagePath: "assets/images/turnOff.svg",
                                            textField: "Be the saviour of your nearby needy tourists. Saving life is the work of God. These customised requests and orders need your physical presence to the needy.Sometimes requests may be normal help but sometimes they may be critical like an accident." ,
                                            extraText:'You will earn dynamically in future, for now You will earn 400 INR for your presence. ' ,
                                            what:'OK',
                                            button: 'OK, Get it',));


                                        });



                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Immediate Local Assistance',
                                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Easy help by locals !',
                                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                                      onPressed: () {
                                        // Handle bottom icon press
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ) ,

                  SizedBox(height : 30),

                  InkWell(
                    onTap: (){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => EmergenceAssist()),
                      );
                    },
                    child: Container(

                      height : 150,

                      decoration: BoxDecoration(
                        color : Theme.of(context).backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 0.5,
                            blurRadius: 3,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        // border: Border.all(color: Colors.white30), // Optional: Add border for visual clarity
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left : 24.0,right : 22),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,


                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.help_outline,color : Colors.orange),
                                      onPressed: () {

                                        showDialog(context: context, builder: (BuildContext context){
                                          return Container(child : CustomPopUp(
                                            imagePath: "assets/images/emergenceAssistance.svg",
                                            textField: "You can create a SOS call from here, you can connect with the Police, Ambulance & Fire Rescue etc." ,
                                            extraText:'This service is free of cost. ' ,
                                            what:'OK',
                                            button: 'OK, Get it',));


                                        });


                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Emergency trip assistance',
                                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Police & Ambulence !',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_circle_right,color : Colors.orange),
                                      onPressed: () {
                                        // Handle bottom icon press
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height : 60),

                  Container(




                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,


                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left : 28.0),
                                child: Row(

                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cost of Trip Assistance ',
                                          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                                        ),

                                        Text(
                                          CountryName =='India' ? '500 INR/Event' : '\$10 Dollar/Event',
                                          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color : Colors.green),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),

                              Container(

                                child: Padding(
                                  padding: const EdgeInsets.only(left : 28.0, top : 10, right : 28),
                                  child: Column(
                                    children: [
                                      SizedBox(height : 20),
                                      Text(
                                        'This cost is for only for physical presence of Saviour.',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height : 10),
                                      Text(
                                          'You have to pay other cost of Services directly to the saviour, who will help you there. \n\nSaviour can create the payment link with extra services bill.',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height : 10),
                                      Text(
                                        'Emergency trip assistance is free for public reasons & safety purpose.',
                                        style: TextStyle(fontSize: 14),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height : 50),


                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ) :
          Container(
            color : Theme.of(context).backgroundColor,
            height : 800,
            child: Center(
              child: Container(child: CircularProgressIndicator(color : Theme.of(context).primaryColorDark,)),
            ),
          )
        ),
        bottomNavigationBar: AnimatedContainer(
            duration: Duration(milliseconds: 100),


            height:  70 ,
            child: CustomFooter(addButtonAdd: 'add',)
        ),
      ),
    );
  }
}
