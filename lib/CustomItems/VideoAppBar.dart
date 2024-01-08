import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/searchBar.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/UserProfile/Settings.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';

class VideoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Function? editPressed;
  final String? exit;

  const VideoAppBar({
    this.title,
    this.editPressed,
    this.exit,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).primaryColorLight,
      shadowColor: Colors.transparent,
      titleSpacing: 0.0,
      toolbarHeight: 70,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(0),
              child: TextButton(
                onPressed: () {
                  if (exit == 'a') {
                    // _showExitConfirmationDialog(context);
                  }
                  if (exit == 'b') {
                    Navigator.of(context).pop();
                  }
                  if (exit == 'home') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }

                  if (exit == 'settings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage(userId: userID)),
                    );
                  }
                },
                child: Text(
                  '< Back',
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color : Colors.white),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (editPressed != null) {
                editPressed!();
              }
            },
            child: Text(
              title ?? '',
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color : Colors.white),
            ),
          ),
          Expanded(
            child: Container(

            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
