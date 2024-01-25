import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'hexColor.dart';

class CustomDropdown {
  static Widget build({
    required String label,
    String? text,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Function(String?) setSelectedValue,
    String? selectedValue,
    required double deviceWidth,
  }) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              label,
                style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10),
            Container(
              width: deviceWidth,
              height: 60,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedValue,
                    icon: SizedBox.shrink(),
                    hint: Text('Select',   style: Theme.of(context).textTheme.subtitle2,),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: HexColor('#FB8C00'),
                        ),
                      ),
                      suffixIcon: text!='edit'?selectedValue!=null?Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.arrow_drop_down_circle, color: HexColor('#FB8C00')):null,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setSelectedValue(newValue);
                      selectedValue = newValue;
                      onChanged(newValue);
                    },
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item,   style: Theme.of(context).textTheme.subtitle2,),
                      );
                    }).toList(),
                  ),
                  if (text == 'edit')
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        'EDIT',
                          style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}

// specially for DOB
class CustomDOBDropDown extends StatelessWidget{
  final String label;
  String?text;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  double deviceWidth;

  CustomDOBDropDown({
    required this.label,
    required this.onDateSelected,
    required this.selectedDate,
    required this.deviceWidth,
    this.text,
  });

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10,),
        Text(label,  style: Theme.of(context).textTheme.subtitle1,),
        SizedBox(height: 10,),
        InkWell(
          onTap: () async {
            DateTime? selected = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            onDateSelected(selected);

          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color:Colors.grey), // Border style
              borderRadius: BorderRadius.circular(5.0), // Rounded corners
            ),
            width: deviceWidth,
            height: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 11.0,right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? "${selectedDate!.toLocal()}".split(' ')[0]
                        : 'Select Date',
                   style: Theme.of(context).textTheme.subtitle2,),
                    text=='edit'
                    ? Text('EDIT',  style: Theme.of(context).textTheme.headline4,)
                    :selectedDate!=null?Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.calendar_today_rounded,color: Colors.orange,),
                  // Calendar icon
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}



// // rest fields of user
// class CustomMultiDropdown extends StatefulWidget {
//   final String label;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;
//   final Function(String?) setSelectedValue;
//   final String? selectedValue;
//   final List<String>? selectedFields;
//   final double deviceWidth;
//
//   CustomMultiDropdown({
//     required this.label,
//     required this.items,
//     required this.onChanged,
//     required this.setSelectedValue,
//     required this.selectedValue,
//     required this.selectedFields,
//     required this.deviceWidth,
//   });
//
//   @override
//   _CustomMultiDropdownState createState() => _CustomMultiDropdownState();
// }
//
// class _CustomMultiDropdownState extends State<CustomMultiDropdown> {
//   String? _selectedValue;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.label,
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Poppins'),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: widget.deviceWidth * 0.90,
//           height: 60,
//           child: DropdownButtonFormField<String>(
//             value: _selectedValue,
//             icon: Icon(Icons.arrow_drop_down_circle, color: Colors.orange),
//             hint: Text('Select'),
//             decoration: InputDecoration(
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.orange),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.grey),
//               ),
//             ),
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedValue = null; // Clear the selected value
//                 widget.selectedFields!.add(newValue!);
//                 widget.items.remove(newValue);
//                 widget.onChanged(newValue);
//               });
//               widget.setSelectedValue(newValue);
//             },
//             items: (widget.items + [_selectedValue!]).map((String field) {
//               return DropdownMenuItem<String>(
//                 value: field,
//                 child: Text(field),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }



class CustomMultiDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Function(String?) setSelectedValue;
  final String? selectedValue;
  final List<String>? selectedFields;
  final double deviceWidth;

  CustomMultiDropdown({
    required this.label,
    required this.items,
    required this.onChanged,
    required this.setSelectedValue,
    required this.selectedValue,
    required this.selectedFields,
    required this.deviceWidth,
  });

  @override
  _CustomMultiDropdownState createState() => _CustomMultiDropdownState();
}

class _CustomMultiDropdownState extends State<CustomMultiDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          widget.label,
            style: Theme.of(context).textTheme.subtitle2,
        ),
        SizedBox(height: 10),
        Container(
          width: widget.deviceWidth * 0.90,
          height: 60,
          child: DropdownButtonFormField<String>(
            value: widget.selectedValue,
            icon: Icon(Icons.arrow_drop_down_circle, color: Colors.orange),
            hint: Text('Select'),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            onChanged: (String? newValue) {
              setState(() {
                if (newValue != null && !widget.selectedFields!.contains(newValue)) {
                  if (widget.selectedFields!.isNotEmpty) {
                    widget.selectedFields!.add(',');
                  }
                  widget.selectedFields!.add(newValue);
                }
                widget.onChanged(newValue);
                widget.setSelectedValue(widget.selectedFields!.join(''));
              });
            },
            items: widget.items.map((String field) {
              return DropdownMenuItem<String>(
                value: field,
                child: Text(field),

              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
