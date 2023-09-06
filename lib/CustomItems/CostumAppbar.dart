import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(


      title: Container(
        height : 48.6,
        width : 156,
        margin:EdgeInsets.only(left : 56,top : 10),
        child:Image.asset('assets/images/logo.png'),
      )
      // Customize the AppBar properties as needed
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
