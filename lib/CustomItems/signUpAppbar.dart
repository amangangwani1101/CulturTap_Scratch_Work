import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/searchBar.dart';
import 'package:learn_flutter/HomePage.dart';

class signUpAppbar extends StatelessWidget implements PreferredSizeWidget {


  const signUpAppbar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).backgroundColor,
      shadowColor: Colors.transparent,
      titleSpacing: 0.0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          Container(
            width : 50,
            child: Text('<Back',style: Theme.of(context).textTheme.bodyText1),
          ),
          Container(
              width : 156,
              child: Image.asset('assets/images/logo.png')
          ),

          Container(
              width : 50,

          ),
        ],
      ),
    );
  }


  @override
  Size get preferredSize => AppBar().preferredSize;
}
