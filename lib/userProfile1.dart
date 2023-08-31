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
            CoverPage(),
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


// profile header section -- state1
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


// profile strength card -- state2
class IconHover extends StatefulWidget {
  @override
  _IconHoverState createState() => _IconHoverState();
}

class _IconHoverState extends State<IconHover> {
  bool isClicked = false;

  void _toggleClick() {
    setState(() {
      isClicked = !isClicked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleClick,
      child: Icon(
        Icons.arrow_forward,
        size: 30,
        color: (!isClicked) ? HexColor("#FB8C00") : Colors.black,
      ),
    );
  }
}

class ProfileStrengthCard extends StatefulWidget {
  @override
  _ProfileStrengthCardState createState() => _ProfileStrengthCardState();
}

class _ProfileStrengthCardState extends State<ProfileStrengthCard> {
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
        height: 110,
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
                  height: 150,
                  child: Image.asset('assets/images/profile_strength.jpg',
                  ),
                ),
                title: Text('Lets Complete\nProfile Section First!',style: TextStyle(fontWeight: FontWeight.w800,fontSize: 14),),
                subtitle: RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: 'Profile Strength\n',style: TextStyle(fontSize: 13)),
                        TextSpan(text: '${profileStatus.toUpperCase()}',style: TextStyle(color: _getStatusColor()),),
                      ],
                    ),
                  ),
                trailing:Container(
                    child: IconHover(),
                ),
              ),
            ),
          itemCount: 1,
        ),
      ),
    );
  }
}

class CoverPage extends StatelessWidget {
  final bool hasVideoUploaded = false; // Replace with backend logic

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Display the video if available
        if (hasVideoUploaded)
          Center(
            child: Container(
              width: 300, // Set the desired video width
              height: 200, // Set the desired video height
              color: Colors.grey, // Replace with your video player or widget
            ),
          ),

        // Display the video upload icon if no video is available
        if (!hasVideoUploaded)
          Padding(
            padding: const EdgeInsets.only(top: 17.0,left: 8.0,right: 8.0),
            child: Container(
              height: 180,
              color: HexColor('#EDEDED'),
              child: Center(
                child: Image.asset(
                  'assets/images/video_icon.png', // Replace with the actual path to your asset image
                  width: 50, // Set the desired image width
                  height: 50, // Set the desired image height
                  fit: BoxFit.contain, // Adjust the fit as needed
                ),
              ),
            ),
          ),

        // Display guidance icons/messages
        Positioned(
          bottom: -160,
          left: 0,
          right: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, // Border color
                    width: 15.0, // Border width
                  ),
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage('assets/images/user.png'),
                  backgroundColor: Colors.white,// Replace with user avatar image
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Hemant Singh', // Replace with actual user name
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: 40,
          right: 40,
          child: GestureDetector(
            onTap: () {
              // Handle tap on help icon
            },
            child: Icon(Icons.help_outline, size: 30, color: HexColor('#FB8C0A')),
          ),
        ),


      ],
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
