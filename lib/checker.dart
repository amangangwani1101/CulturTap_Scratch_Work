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
          title: Text('Multi-select Dropdown'),
        ),
        body: MyDropdown(),
      ),
    );
  }
}

class MyDropdown extends StatefulWidget {
  @override
  _MyDropdownState createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  List<String> options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
  List<String> selectedOptions = [];
  bool showOption = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){
              print(1);
              setState(() {
                showOption = true;
              });
            },
            child: TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: selectedOptions.isNotEmpty
                    ? selectedOptions.join(', ')
                    : 'Select options',
              ),
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          showOption
          ? Container(
            height: 150.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return CheckboxListTile(
                  title: Text(option),
                  value: selectedOptions.contains(option),
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        selectedOptions.add(option);
                      } else {
                        selectedOptions.remove(option);
                      }
                    });
                  },
                );
              },
            ),
          )
          : SizedBox(width: 0,),
        ],
      ),
    );
  }

  void _showDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150.0, // Adjust the height as needed
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return CheckboxListTile(
                title: Text(option),
                value: selectedOptions.contains(option),
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    if (value!) {
                      selectedOptions.add(option);
                    } else {
                      selectedOptions.remove(option);
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}
