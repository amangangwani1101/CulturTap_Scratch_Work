import 'package:flutter/material.dart';
import 'package:learn_flutter/widgets/hexColor.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  ConfirmationDialog({required this.message, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Alert Box',style: TextStyle(color: HexColor('#FB8C00'),fontFamily: 'Poppins',fontWeight: FontWeight.bold,fontSize: 16)),
      content: Text(message,style: TextStyle(color: HexColor('#FB8C00'),fontFamily: 'Poppins',fontWeight: FontWeight.bold,fontSize: 14)),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancel', style: TextStyle(color: HexColor('#FB8C00'),fontFamily: 'Poppins',fontWeight: FontWeight.bold,fontSize: 14)),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text('Proceed', style: TextStyle(color: HexColor('#FB8C00'),fontFamily: 'Poppins',fontWeight: FontWeight.bold,fontSize: 14)),
        ),
      ],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation Dialog Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ConfirmationDialog(
                  message: 'Are you sure you want to perform this action?',
                  onConfirm: () {
                    // Perform action on confirmation
                    Navigator.of(context).pop(); // Close the dialog
                    // Add your action here
                    print('Action confirmed');
                  },
                  onCancel: () {
                    // Perform action on cancellation
                    Navigator.of(context).pop(); // Close the dialog
                    // Add your action here
                    print('Action cancelled');
                  },
                );
              },
            );
          },
          child: Text('Show Confirmation Dialog'),
        ),
      ),
    );
  }
}
