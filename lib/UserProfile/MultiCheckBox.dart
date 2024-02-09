import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/widgets/Constant.dart';

class SelectionScreen extends StatefulWidget {
  List<String> selectedOptions=[];
  SelectionScreen({required this.selectedOptions});
  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  List<String> options = Constant().languageList;
  List<String> selectedOptions=[];

  @override
  void initState() {
    // TODO: implement initState
    selectedOptions = widget.selectedOptions;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Container(
          padding:EdgeInsets.only(left: 22),
        child: Text('Select Languages ',style: Theme.of(context).textTheme.subtitle1,)),automaticallyImplyLeading: false,),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = selectedOptions.contains(option);

          return Container(
            padding: EdgeInsets.only(left: 22,right:22),
            child: CheckboxListTile(
              activeColor: Colors.orange,
              title: Text(option,style: Theme.of(context).textTheme.subtitle2,),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    if (value) {
                      selectedOptions.add(option);
                    } else {
                      selectedOptions.remove(option);
                    }
                  }
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Return the selected options to the calling screen
          Navigator.pop(context, selectedOptions);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}