import 'package:flutter/material.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Set the preferred height to 0
        child: AppBar(
          elevation: 0, // Remove the shadow
          backgroundColor: Colors.transparent, // Make the background transparent
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(),
            ProfileStrengthCard(),
            // CoverPage(),
            // UserInformationSection(),
            // ShareButton(),
            // CompleteProfileButton(),
          ],
        ),
      ),
    );
  }
}

// Converts hex string to color
class HexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex =  "FF" + hex.toUpperCase().replaceAll("#", "");
    return int.parse(formattedHex, radix: 16);
  }
  HexColor(final String hex) : super(_getColor(hex));
}


// profile header section -- start 1
class ProfileHeader extends StatefulWidget {
  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  // notification count will be made dynamic from backend
  int notificationCount = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  // Handle profile image click
                },
                child: Container(
                  // width: 100,
                  height: 50,
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage('assets/images/profile_image.jpg'),
                  ),
                ),
              ),

              Container(height: 2,),
              Text('Profile',style: TextStyle(fontSize: 16,color:HexColor("#FB8C00"),fontWeight: FontWeight.w900),),
            ],
          ),
          Image.asset('assets/images/logo.png', width: 180.0),

          Column(

            children: [
              Container(
                width: 70,
                height: 45,
                child: Stack(

                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/images/profile_image.jpg',height: 32 ,fit: BoxFit.cover,
                    ),
                    if(notificationCount>0)
                      Positioned(
                        top: -6,
                        right: 13,
                        // height: 20,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            notificationCount.toString(),
                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(height: 2,),
              Text('Pings',style: TextStyle(fontSize: 16,color:Colors.black,fontWeight: FontWeight.w900),),
            ],
          ),

        ],
      ),
    );
  }
}

class ProfileStrengthCard extends StatelessWidget {
  final String profileStatus = 'low'; // Replace this with the actual profile status

  Color _getStatusColor() {
    switch (profileStatus) {
      case 'low':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Container(
        height: 120,
        // width:300,
        margin: EdgeInsets.only(left: 16.0,right: 16.0,),
        decoration: BoxDecoration(
          color: Colors.white, // Container background color
          border: Border.all(
            color: HexColor('#001B33'), // Border color
            width: 1.0, // Border width
          ),
        ),
        child: ListView.builder(itemBuilder: (context,index)=>
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading:Container(
                  height: 200,
                    child: Image.asset('assets/images/profile_strength.jpg',fit: BoxFit.cover,width: 60,
                    ),
                ),
                title: Text('Lets Complete\nProfile Section First!',style: TextStyle(fontWeight: FontWeight.w800  ),),
                subtitle: RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: 'Profile Strength\n'),
                        TextSpan(text: '${profileStatus.toUpperCase()}',style: TextStyle(color: _getStatusColor()),),
                      ],
                    ),
                  ),
                trailing:Icon( Icons.arrow_forward,),
              ),
            ),
          itemCount: 1,
        ),
      ),
    );
  }
}

class CoverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: Placeholder(), // Replace with VideoPlayer widget
    );
  }
}

class UserInformationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.0,
            backgroundImage: AssetImage('assets/profile_image.jpg'),
          ),
          SizedBox(height: 10.0),
          Text('User Name'),
          SizedBox(height: 10.0),
          Text('Motivational Quote'),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InfoWidget(icon: Icons.people, text: 'Follower'),
              InfoWidget(icon: Icons.people_outline, text: 'Following'),
              InfoWidget(icon: Icons.location_on, text: 'Location'),
            ],
          ),
          SizedBox(height: 20.0),
          UserDetailsTable(),
        ],
      ),
    );
  }
}

class InfoWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  InfoWidget({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        SizedBox(height: 4.0),
        Text(text),
      ],
    );
  }
}

class UserDetailsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: [
        DataColumn(label: Text('Field')),
        DataColumn(label: Text('Value')),
      ],
      rows: [
        DataRow(cells: [
          DataCell(Text('Place')),
          DataCell(Text('N/A')),
        ]),
        DataRow(cells: [
          DataCell(Text('Profession')),
          DataCell(Text('N/A')),
        ]),
        DataRow(cells: [
          DataCell(Text('Age/Gender')),
          DataCell(Text('N/A')),
        ]),
        DataRow(cells: [
          DataCell(Text('Languages')),
          DataCell(Text('N/A')),
        ]),
      ],
    );
  }
}

class ShareButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: IconButton(
        onPressed: () {
          // Handle share button click
        },
        icon: Icon(Icons.share),
      ),
    );
  }
}

class CompleteProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          // Handle complete profile button click
        },
        child: Text('Complete Profile'),
      ),
    );
  }
}
