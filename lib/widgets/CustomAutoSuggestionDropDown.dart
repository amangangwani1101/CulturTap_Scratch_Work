import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'hexColor.dart';

class CustomAutoSuggestion extends StatelessWidget {
  final List<String> cityList;
  String text;
  String?initialText;
  final Function(String) onValueChanged;

  CustomAutoSuggestion({required this.cityList, required this.onValueChanged,required this.text,this.initialText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 102,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          SizedBox(height: 10,),
          CustomAutoComplete(cityList: cityList, onValueChanged: onValueChanged,initialText:initialText),
        ],
      ),
    );
  }
}

class CustomAutoComplete extends StatefulWidget {
  final List<String> cityList;
  final Function(String) onValueChanged;
  String?initialText;
  CustomAutoComplete({required this.cityList, required this.onValueChanged,this.initialText});

  @override
  _CustomAutoCompleteState createState() => _CustomAutoCompleteState();
}

class _CustomAutoCompleteState extends State<CustomAutoComplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _focusNode.requestFocus();
      },
      child: Container(
        height: 70,
        child: TypeAheadFormField(
          initialValue: widget.initialText,
          suggestionsCallback: (pattern) => widget.cityList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()),
          ),
          itemBuilder: (_, String item) => ListTile(title: Text(item)),
          onSuggestionSelected: (String val) {
            _controller.text = val;
            widget.onValueChanged(val); // Invoke the callback when value changes
          },
          getImmediateSuggestions: true,
          hideSuggestionsOnKeyboardHide: false,
          hideOnEmpty: false,
          noItemsFoundBuilder: (context) => Padding(
            padding: EdgeInsets.all(8),
            child: Text('Not Present', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ),
          textFieldConfiguration: TextFieldConfiguration(
            decoration: InputDecoration(
              hintText: 'Select...',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: HexColor('#FB8C00')),
              ),
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00'),),
            ),
            controller: _controller,
            focusNode: _focusNode,
          ),
        ),
      ),
    );
  }
}
