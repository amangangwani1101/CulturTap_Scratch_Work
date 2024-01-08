import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/CulturTap/appbar.dart';
import '../../../fetchDataFromMongodb.dart';
import '../../../widgets/Constant.dart';
import '../../../widgets/CustomDialogBox.dart';
import '../../PingsSection/Pings.dart';
import '../../../LocalAssistance/ChatsPage.dart';

void main() {
  runApp(Maain());
}

class Maain extends StatefulWidget {
  const Maain({super.key});

  @override
  State<Maain> createState() => _MaainState();
}

class _MaainState extends State<Maain>  {

  String ?meetId,state;

  Future<void> PingsAssistanceChecker(userId) async {
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final url = Uri.parse('$serverUrl/checkLocalUserPings/${userId}'); // Replace with your backend URL
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          if(data['meetId']!=null){
            meetId = data['meetId'];
            state = data['state'];
          }
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


  @override
  void initState() {
    super.initState();
    checkIsMeetOngoing();
  }


  Future<void> checkIsMeetOngoing()async {
    await PingsAssistanceChecker(userID);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 0,userId: userID,),automaticallyImplyLeading: false,),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50,),
            state!=null
              ?Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>PingsSection(userId: userID,selectedService: 'Local Assistant',)));
                    },
                    child: Container(
                    width: 328,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.orange),
                    ),
                    padding: EdgeInsets.only(left: 20,right: 20,top: 2),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ongoing Services',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.orange),),
                          Icon(Icons.arrow_forward_ios,size: 14,color: Colors.orange,),
                        ],
                    ),
            ),
                  );
                }
              )
              :SizedBox(height: 0,),
            SizedBox(height: 50,),
            Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: ()async{
                    await checkIsMeetOngoing();
                    if(meetId!=null){
                      if(state=='user'){
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: '652a31f77ff9b6023a14838a',
                          state: 'user',
                          meetId: meetId,
                        ),));
                      }
                      else if(state=='helper'){
                        // toast
                        Fluttertoast.showToast(
                          msg: "Finish Ongoing Services",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    }
                    else{
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: '652a31f77ff9b6023a14838a',
                        state: 'user',
                      ),));
                    }
                  },
                  child: Center(
                    child: Container(child: Text('Local Assistant')),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}


