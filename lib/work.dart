import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Edit Name Example'),
        ),
        body: EditNameForm(),
      ),
    );
  }
}

class EditNameForm extends StatefulWidget {
  @override
  _EditNameFormState createState() => _EditNameFormState();
}

class _EditNameFormState extends State<EditNameForm> {
  TextEditingController nameController = TextEditingController();
  String userName = "Hemant Singh"; // Initial static name
  // String editedName = ""; // Stores the edited name
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController.text = userName;
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;

      if (!isEditing) {
        if(nameController.text.length<1){
          isEditing = !isEditing;
          print('Name is too small');
        }else{
          // Save the edited name when exiting edit mode
          userName = nameController.text;
          // Here, you can send the updated name to your backend for processing
          // For demonstration, we'll just print it
          print("Updated Name: $userName");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      // height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isEditing
              ? Container(
                width: 200,
                child: TextField(
                  controller: nameController,
                  onChanged: (value){
                    userName = value;
                  },
                  style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,fontFamily: 'Poppins'),
                ),
              )
              : Text(
                userName,
                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),
              ),
          IconButton(
            icon: Icon(isEditing ? Icons.save_outlined : Icons.edit_outlined),
            onPressed: toggleEdit,
          ),
        ],
      ),
    );
  }
}
