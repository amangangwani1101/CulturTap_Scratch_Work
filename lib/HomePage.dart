import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/widgets/hexColor.dart';
import 'package:provider/provider.dart';

import 'BackendStore/BackendStore.dart';
import 'UserProfile/ProfileHeader.dart';
import 'UserProfile/UserProfileEntry.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: HexColor('#FB8C00')),
        useMaterial3: true,
      ),
      home: HomePageWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: ProfileHeader(reqPage: 0),),
      body: Container(
        width: double.infinity,
        height: 800,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
                    create:(context) => ProfileDataProvider(),
                    child: ProfileApp(),
                  ),),
                );
              },
                child: Text('Create Profile')
            ),
            InkWell(
              onTap: (){

              },
                child: Text('Home Screen')
            ),
            InkWell(
              onTap: (){

              },
                child: Text('Trip Calling Services')
            ),
          ],
        ),
      ),
    );
  }
}