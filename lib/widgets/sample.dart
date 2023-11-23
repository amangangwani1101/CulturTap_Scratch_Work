
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learn_flutter/main.dart';

import '../UserProfile/ProfileHeader.dart';
import '../UserProfile/UserProfileEntry.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PaymentPage(),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget{
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          SizedBox(height: 20,),
          ProfileHeader(reqPage: 2),
          Container(
            width: 357,
            height: 262,
            child:Column(
              children:[
                Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.black,
                  //     width: 1,
                  //   ),
                  // ),
                  width: 320,
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Text('Payments',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Text('This payment method will help you to pay & receive money',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                    ],
                  ),
                ),
                SizedBox(height: 30,),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  width: 357,
                  height: 107,
                  padding: EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text('Add Debit/Credit/ATM Card',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CardList(),
        ],
      ),
    );
  }
}



class CardData {
  String title;
  String description;

  CardData({required this.title, required this.description});
}

class CardList extends StatefulWidget {
  @override
  _CardListState createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  List<CardData> cardDataList = [];

  @override
  void initState() {
    super.initState();
    // Add the initial card with predefined content
    cardDataList.add(CardData(title: 'Initial Card', description: 'Tap to start adding cards.'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < cardDataList.length; index++)
          CardWidget(
            title: cardDataList[index].title,
            description: cardDataList[index].description,
            onDelete: () {
              setState(() {
                cardDataList.removeAt(index);
              });
            },
          ),
        CardWidget(
          onSave: (title, description) {
            setState(() {
              cardDataList.add(CardData(title: title, description: description));
            });
          },
        ),
      ],
    );
  }
}

class CardWidget extends StatefulWidget {
  final String? title;
  final String? description;
  final Function(String, String)? onSave;
  final VoidCallback? onDelete;

  CardWidget({this.title, this.description, this.onSave, this.onDelete});

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title ?? '';
    _descriptionController.text = widget.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (widget.title == 'Initial Card') {
            // Replace content of the initial card when tapped
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.onSave?.call(_titleController.text, _descriptionController.text);
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _titleController.text = '';
                          _descriptionController.text = '';
                        },
                        child: Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
        onLongPress: () {
          if (widget.onDelete != null) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Delete Card'),
                  content: Text('Are you sure you want to delete this card?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onDelete?.call();
                        Navigator.of(context).pop();
                      },
                      child: Text('Delete'),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.title ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(widget.description ?? ''),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
