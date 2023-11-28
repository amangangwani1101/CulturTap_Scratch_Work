import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'Constant.dart';
import 'hexColor.dart';

class CustomAutoSuggestion extends StatelessWidget {
  final List<String> cityList;
  String text;
  String?initialText,state;
  final Function(String) onValueChanged;

  CustomAutoSuggestion({required this.cityList, required this.onValueChanged,required this.text,this.initialText,this.state});

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
          CustomAutoComplete(cityList: cityList, onValueChanged: onValueChanged,initialText:initialText,text: state,),
        ],
      ),
    );
  }
}

class CustomAutoComplete extends StatefulWidget {
  final List<String> cityList;
  final Function(String) onValueChanged;
  String?initialText,text;
  CustomAutoComplete({required this.cityList, required this.onValueChanged,this.initialText,this.text});

  @override
  _CustomAutoCompleteState createState() => _CustomAutoCompleteState();
}

class _CustomAutoCompleteState extends State<CustomAutoComplete> {
  final TextEditingController _controller = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  @override
  void initState(){
    super.initState();
    if(widget.initialText!=null){
      _controller.text = widget.initialText!;
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _focusNode.unfocus();
      },
      child: Container(
        height: 70,
        child: TypeAheadFormField(
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
              suffixIcon: widget.text!='edit'?Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00'),):null,
              suffix: widget.text=='edit'?Text('EDIT',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: HexColor('#FB8C00'),),):null,
            ),
            controller: _controller,
            focusNode: _focusNode,
          ),
        ),
      ),
    );
  }
}
