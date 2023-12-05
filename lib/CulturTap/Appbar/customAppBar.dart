import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';

class CustomSliverAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;
  final String userId;

  CustomSliverAppBar({required this.userName, required this.userId});

  @override
  _CustomSliverAppBarState createState() => _CustomSliverAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(90.0);
}

class _CustomSliverAppBarState extends State<CustomSliverAppBar> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 90.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double top = constraints.biggest.height;
          setState(() {
            _isVisible = top == 90.0; // Adjust the height as needed
          });

          return AppBar(
            title: ProfileHeader(reqPage: 0, userId: widget.userId, userName: widget.userName),
          );
        },
      ),
    );
  }
}
