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
      backgroundColor: Theme.of(context).primaryColorLight,
      title: Text('Alert Box',style: Theme.of(context).textTheme.headline2),
      content: Text(message,style:Theme.of(context).textTheme.subtitle1),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancel', style: TextStyle(color: Colors.orange,fontFamily: 'Poppins',fontWeight: FontWeight.bold,fontSize: 16)),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text('Ok', style: TextStyle(color: Colors.orange,fontFamily: 'Poppins',fontWeight: FontWeight.bold,fontSize: 16)),
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
