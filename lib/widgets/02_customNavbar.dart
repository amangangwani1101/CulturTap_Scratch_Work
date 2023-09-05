// complete_profile_page.dart

import 'package:flutter/material.dart';
import 'package:learn_flutter/userProfile1.dart';

class CompleteProfilePage extends StatelessWidget {
  @override
  bool reqPage = false;
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     // title: Container(decoration:BoxDecoration(border: Border.all(color: Colors.orange,width: 2,)),child: Text('Complete Your Profile')),
    //     // Add a back button to the AppBar
    //     leading: Container(
    //       width: 200,
    //       decoration: BoxDecoration(
    //         border: Border.all(
    //           width: 2,
    //           color: Colors.orange,
    //         ),
    //       ),
    //       child: Row(
    //         children: [
    //           IconButton(
    //             icon: Icon(Icons.arrow_back),
    //             onPressed: () {
    //               // Navigate back to the previous page
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //           // Text('Back'),
    //         ],
    //       ),
    //     ),
    //   ),
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text('Complete your profile here'),
    //         // Add profile completion widgets here
    //       ],
    //     ),
    //   ),
    // );
    return ProfilePage(reqPage: reqPage,);
  }
}
