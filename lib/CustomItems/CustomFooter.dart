import 'package:flutter/material.dart';
import 'package:learn_flutter/Utils/location_utils.dart';
import 'package:learn_flutter/VIdeoSection/CameraApp.dart';
import 'package:learn_flutter/VIdeoSection/Draft/SavedDraftsPage.dart';
import 'package:learn_flutter/Utils/location_utils.dart';

class CustomFooter extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomFooterState createState() => _CustomFooterState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _CustomFooterState extends State<CustomFooter> {
  Color homeIconColor = Color(0xFF263238);
  Color searchIconColor = Color(0xFF263238);
  Color airplaneIconColor = Color(0xFF263238);
  Color settingsIconColor = Color(0xFF263238);
  Color addIconColor = Color(0xFF263238);

  void _changeIconColor(String iconName) {
    setState(() {
      homeIconColor = Color(0xFF263238);
      searchIconColor = Color(0xFF263238);
      airplaneIconColor = Color(0xFF263238);
      settingsIconColor = Color(0xFF263238);
      addIconColor = Color(0xFF263238);

      switch (iconName) {
        case 'home':
          homeIconColor = Colors.orange;
          break;
        case 'search':
          searchIconColor = Colors.orange;
          break;
        case 'airplane':
          airplaneIconColor = Colors.orange;
          break;
        case 'settings':
          settingsIconColor = Colors.orange;
          break;
        case 'add':
          addIconColor = Colors.orange;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Set the background color to white
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left:10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {

                        _changeIconColor('home');
                      },
                      icon: Icon(Icons.home, color: homeIconColor, size: 30),
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Color(0xFF263238),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _changeIconColor('search');
                      },
                      icon: Icon(Icons.search, color: searchIconColor, size: 30),
                    ),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: Color(0xFF263238),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment(0.0, 1.0), // Align to the bottom center
                  child: Transform.translate(
                    offset: Offset(5, -30.0), // Half of the button's height (60 / 2 = 30)
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: ElevatedButton(

                        onPressed: () {


                          Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraApp()));
                          _changeIconColor('add');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: CircleBorder(),
                        ),
                        child: Icon(Icons.add, color: addIconColor, size:42,),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _changeIconColor('airplane');
                      },
                      icon: Icon(Icons.airplanemode_active, color: airplaneIconColor, size: 30),
                    ),
                    Text(
                      'Airplane',
                      style: TextStyle(
                        color: Color(0xFF263238),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SavedDraftsPage(),
                          ),
                        );
                        _changeIconColor('settings');
                      },
                      icon: Icon(Icons.settings, color: settingsIconColor, size: 30),
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Color(0xFF263238),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 0, // Adjust the height as needed
          ),
        ],
      ),
    );
  }
}
