import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileForm(),
    );
  }
}

class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  String selectedProfession = 'Engineer'; // Initialize with a default value
  DateTime? selectedDateOfBirth; // Initialize with null
  String selectedGender = 'Male'; // Initialize with a default value
  String selectedLanguage = 'English'; // Initialize with a default value


  // List of profession options for the dropdown
  final List<String> professions = [
    'Engineer',
    'Doctor',
    'Teacher',
    'Artist',
    // Add more professions as needed
  ];

  // List of gender options for the dropdown
  final List<String> genders = <String>['Male', 'Female', 'Other'];

  // List of language options for the dropdown
  final List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
    // Add more languages as needed
  ];

  @override
  void initState() {
    super.initState();
    // Print the selected values when the widget is initialized
    print('Selected Profession: $selectedProfession');
    print('Selected Date of Birth: $selectedDateOfBirth');
    print('Selected Gender: $selectedGender');
    print('Selected Language: $selectedLanguage');
  }
  @override
  Widget build(BuildContext context) {
    print('Selected Profession: $selectedProfession');
    print('Selected Date of Birth: $selectedDateOfBirth');
    print('Selected Gender: $selectedGender');
    print('Selected Language: $selectedLanguage');
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Profession Dropdown
            Text('Profession'),
            // DropdownButton<String>(
            //   value: selectedProfession,
            //   items: professions.map((profession) {
            //     return DropdownMenuItem(
            //       value: profession, // Make sure each value is unique
            //       child: new Text(profession),
            //     );
            //   }).toList(),
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       selectedProfession = newValue!;
            //     });
            //   },
            // ),

            SizedBox(height: 20),

            // Date of Birth
            Text('Date of Birth'),
            InkWell(
              onTap: () async {
                final DateTime picked = (await showDatePicker(
                  context: context,
                  initialDate: selectedDateOfBirth ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2101),
                ))!;
                if (picked != null && picked != selectedDateOfBirth) {
                  setState(() {
                    selectedDateOfBirth = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: selectedDateOfBirth == null
                      ? 'Select Date of Birth'
                      : selectedDateOfBirth.toString(),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Gender Dropdown
            Text('Gender'),
            // DropdownButton<String>(
            //   value: selectedGender,
            //   items: genders.map((String gender) {
            //     return DropdownMenuItem<String>(
            //       value: gender,
            //       child: Text(gender),
            //     );
            //   }).toList(),
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       selectedGender = newValue!;
            //     });
            //   },
            // ),
            Text('Gender:$selectedGender'),
            Text('Profession is :$selectedProfession'),

            SizedBox(height: 20),

            // Language Dropdown
            Text('Language'),
            // DropdownButton<String>(
            //   value: selectedLanguage,
            //   items: languages.map((String language) {
            //     return DropdownMenuItem<String>(
            //       value: language,
            //       child: Text(language),
            //     );
            //   }).toList(),
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       selectedLanguage = newValue!;
            //     });
            //   },
            // ),

            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Use the selected values as needed
                print('Selected Profession: $selectedProfession');
                print('Selected Date of Birth: $selectedDateOfBirth');
                print('Selected Gender: $selectedGender');
                print('Selected Language: $selectedLanguage');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
