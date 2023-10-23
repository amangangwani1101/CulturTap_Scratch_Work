import 'package:flutter/material.dart';

class VideoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VideoAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor:  Color(0xFF263238),
      titleSpacing: 0.0, // Remove default title spacing
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button with margin
          Padding(
            padding: EdgeInsets.only( left:5.0), // Adjust margin as needed
            child: TextButton(

              onPressed: () {
                _showExitConfirmationDialog(context); // Show the exit confirmation dialog
              },
              child: Text(
                '< back',
                style: TextStyle(
                  color: Colors.white, // Change text color to white for better visibility
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          // Edit Button in the center
          TextButton(
            onPressed: () {
              
            },
            child: Text(
              'Edit',
              style: TextStyle(
                color: Colors.white, // Change text color to white for better visibility
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            width: 50,
          ),
          // You can add more buttons or widgets here
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


          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 56),
              Center(
                child: Image.asset('assets/images/remove.png'), // Replace with your image path

              ),
              SizedBox(height: 36),
              Text('Are You Sure?', style : TextStyle(fontWeight: FontWeight.bold, color:Colors.white, fontSize:30)),
              SizedBox(height : 5),
              Text('Before going back you need to save your story as draft..',style : TextStyle(fontWeight: FontWeight.bold,fontSize:15, color:Colors.white) ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add your save to draft functionality here
                Navigator.of(context).pop();
              },
              child: Text('Draft',style:TextStyle(fontWeight: FontWeight.bold, color : Colors.orange)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the screen
              },
              child: Text('Back',style:TextStyle(fontWeight: FontWeight.bold, color : Colors.orange,) ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
