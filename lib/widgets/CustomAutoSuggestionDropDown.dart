import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'Constant.dart';
import 'hexColor.dart';

class CustomAutoSuggestion extends StatelessWidget {
  final List<String> cityList;
  final String text;
  final String? initialText, state;
  final Function(String) onValueChanged;

  const CustomAutoSuggestion({
    Key? key,
    required this.cityList,
    required this.onValueChanged,
    required this.text,
    this.initialText,
    this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus when tapped outside the text field
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: 102,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 10),
            CustomAutoComplete(
              cityList: cityList,
              onValueChanged: onValueChanged,
              initialText: initialText,
              text: state,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAutoComplete extends StatefulWidget {
  final List<String> cityList;
  final Function(String) onValueChanged;
  final String? initialText, text;

  const CustomAutoComplete({
    Key? key,
    required this.cityList,
    required this.onValueChanged,
    this.initialText,
    this.text,
  }) : super(key: key);

  @override
  _CustomAutoCompleteState createState() => _CustomAutoCompleteState();
}

class _CustomAutoCompleteState extends State<CustomAutoComplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _controller.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: TypeAheadFormField(
        suggestionsCallback: (pattern) => widget.cityList
            .where((item) => item.toLowerCase().contains(pattern.toLowerCase())),
        itemBuilder: (_, String item) => ListTile(
          title: Text(
            item,
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        onSuggestionSelected: (String val) {
          _controller.text = val;
          widget.onValueChanged(val);
        },
        getImmediateSuggestions: true,
        hideSuggestionsOnKeyboardHide: false,
        hideOnEmpty: false,
        noItemsFoundBuilder: (context) => Padding(
          padding: EdgeInsets.all(8),
          child: Text('Other', style: Theme.of(context).textTheme.subtitle2),
        ),
        textFieldConfiguration: TextFieldConfiguration(
          style: Theme.of(context).textTheme.subtitle2,
          decoration: InputDecoration(
            hintText: 'Select...',
            hintStyle: Theme.of(context).textTheme.subtitle2,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: HexColor('#FB8C00')),
            ),
            border: OutlineInputBorder(),
            suffixIcon: widget.text != 'edit'
                ? Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00'))
                : null,
            suffix: widget.text == 'edit'
                ? Text('EDIT', style: Theme.of(context).textTheme.headline4)
                : null,
          ),
          controller: _controller,
          focusNode: _focusNode,
        ),
      ),
    );
  }
}

// class CustomAutoCompleter extends StatefulWidget {
//   final String? initialText;
//   final Function(String) onValueChanged;
//   final String? state;
//
//   const CustomAutoCompleter({
//     Key? key,
//     this.initialText,
//     required this.onValueChanged,
//     this.state,
//   }) : super(key: key);
//
//   @override
//   _CustomAutoCompleterState createState() => _CustomAutoCompleterState();
// }
//
// class _CustomAutoCompleterState extends State<CustomAutoCompleter> {
//   late String inputText;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return RawAutocomplete<String>(
//       optionsBuilder: (TextEditingValue textEditingValue) async {
//         if (textEditingValue.text.isEmpty) {
//           return const Iterable<String>.empty();
//         } else {
//           await fetchSuggestions(textEditingValue.text, 'profession');
//           return suggestions.isNotEmpty ? suggestions : ['Others'];
//         }
//       },
//       onSelected: (String selectedValue) {
//         setState(() {
//           inputText = selectedValue;
//         });
//         widget.onSelected(inputText);
//       },
//       fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
//           FocusNode focusNode, VoidCallback onFieldSubmitted) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.text, style: Theme.of(context).textTheme.subtitle1),
//             SizedBox(height: 10),
//             TextField(
//               decoration: InputDecoration(
//                 hintText: 'Select...',
//                 hintStyle: Theme.of(context).textTheme.subtitle2,
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: HexColor('#FB8C00')),
//                 ),
//                 border: OutlineInputBorder(),
//                 suffixIcon: widget.text != 'edit'
//                     ? Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00'))
//                     : null,
//                 suffix: widget.text == 'edit'
//                     ? Text('EDIT', style: Theme.of(context).textTheme.headline4)
//                     : null,
//               ),
//               controller: textEditingController,
//               focusNode: focusNode,
//               style: Theme.of(context).textTheme.subtitle2,
//               onSubmitted: (String value) {},
//             ),
//           ],
//         );
//       },
//       optionsViewBuilder: (BuildContext context, void Function(String) onSelected,
//           Iterable<String> options) {
//         return Material(
//           child: SizedBox(
//             height: 200,
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: options.map((opt) {
//                   return InkWell(
//                     onTap: () {
//                       onSelected(opt);
//                     },
//                     child: Container(
//                       width: screenWidth * 0.90,
//                       height: 60,
//                       child: Card(
//                         margin: EdgeInsets.all(0),
//                         child: Center(
//                           child: Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.all(10),
//                             margin: EdgeInsets.all(0),
//                             child: Text(opt, style: Theme.of(context).textTheme.subtitle2),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
