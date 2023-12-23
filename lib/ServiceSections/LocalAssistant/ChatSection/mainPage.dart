import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/Constant.dart';
import 'ChatsPage.dart';

void main() {
  runApp(Maain());
}

class Maain extends StatefulWidget {
  const Maain({super.key});

  @override
  State<Maain> createState() => _MaainState();
}

class _MaainState extends State<Maain> {

  String ?meetId;

  Future<void> PingsAssistanceChecker(userId) async {
    try{
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final url = Uri.parse('$serverUrl/checkLocalUserPings/${userId}'); // Replace with your backend URL
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          if(data['meetId'].length>0){
            meetId = data['meetId'];
          }
        });
        print('Meet : $meetId');
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
    func();
  }
  Future<void> func()async {
    await PingsAssistanceChecker('652a31f77ff9b6023a14838a');

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
        appBar: AppBar(automaticallyImplyLeading: false,),
        body: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>ChatsPage(userId: '652a31f77ff9b6023a14838a',
                  state: 'user',
                  meetId: meetId,
                ),));
              },
              child: Center(
                child: Container(child: Text('Helklo')),
              ),
            );
          }
        ),
      ),
    );
  }
}


