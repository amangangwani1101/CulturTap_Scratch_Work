import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/searchBar.dart';
import 'package:learn_flutter/HomePage.dart';

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
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: EdgeInsets.all(0),
                child: TextButton(
                  onPressed: () {
                    if(exit == 'a'){
                      _showExitConfirmationDialog(context);
                    }
                    if(exit=='b'){

                      Navigator.of(context).pop();
                    }
                    if(exit=='home'){
                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                    }
                     // Show the exit confirmation dialog
                  },
                  child: Text(
                    '< back',
                    style: Theme.of(context).textTheme.caption,
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
                  style:Theme.of(context).textTheme.caption,
                ),
              ),
              Container(
                width: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF263238),

          content: Container(
            height : 269,
            width : 300,
            child: Column(

              children: [
                SizedBox(height : 30),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Image.asset('assets/images/saveDraftLogo.png'),
                  ),
                ),
                SizedBox(height : 30),
                Text(
                  'Are You Sure?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(),
                    child: Column(
                      children: [
                        Text(
                          'Before going back,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'you need to save your story as a draft.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    // Add your save to draft functionality here
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Draft',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 20,

                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Close the screen
                  },
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height : 20),
          ],
        );
      },
    );
  }


  @override
  Size get preferredSize => AppBar().preferredSize;
}
