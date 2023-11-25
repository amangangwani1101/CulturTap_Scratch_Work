import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                color: Colors.orange,
                size: 36.0,
              ),
              SizedBox(width: 16.0),
              Text(
                'Uploading Story...',
                style: TextStyle(fontSize: 18.0,color: Color(0xFF263238) ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
