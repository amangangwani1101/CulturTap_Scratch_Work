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
            padding: EdgeInsets.only(left: 16.0), // Adjust margin as needed
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
              // Add your edit button functionality here
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
            width: 80,
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

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.asset('your_image_path_here'), // Replace with your image path
              ),
              SizedBox(height: 16),
              Text('Are You Sure?'),
              Text('Before going back you need to save your story as draft..'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add your save to draft functionality here
                Navigator.of(context).pop();
              },
              child: Text('Save to Draft'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the screen
              },
              child: Text('Back'),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
