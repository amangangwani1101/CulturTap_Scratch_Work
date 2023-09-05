import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:learn_flutter/widgets/01_helpIconCustomWidget.dart';
import 'package:learn_flutter/widgets/02_customNavbar.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  bool reqPage = true;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: ProfilePage(reqPage:reqPage),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatelessWidget {
  final bool reqPage;
  ProfilePage({required this.reqPage});
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
            ProfileHeader(reqPage: reqPage),
            reqPage?ProfileStrengthCard():SizedBox(height: 0,),
            CoverPage(),
            UserPhoto(),
            UserInformationSection(reqPage:reqPage),
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
  final bool reqPage;

  ProfileHeader({required this.reqPage});
  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  // notification count will be made dynamic from backend
  int notificationCount = 2;
  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.red,
      //     width: 2,
      //   ),
      // ),
      height: 92,
      padding: EdgeInsets.only(top: 12.0,left: 25.0,right: 24.0,bottom:16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.reqPage?
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  // Handle profile image click
                },
                child: Container(
                  // width: 100,
                  height: 35,
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundImage: AssetImage('assets/images/profile_image.jpg'),
                  ),
                ),
              ),
              Text('Profile',style: TextStyle(fontSize: 14,color:HexColor("#FB8C00"),fontWeight: FontWeight.w900,fontFamily: 'Poppins',),),
            ],
          ):
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.black,
            //     width: 2,
            //   ),
            // ),
            width: 60,
            height: 45,
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: Image.asset('assets/images/back.png',width: 60,height: 30,),
              ),
            ),
          ),
          widget.reqPage?
          Padding(
              padding:EdgeInsets.only(top: 13.0),
              child:Align(
                alignment: Alignment.topLeft,
                child: Image.asset('assets/images/logo.png',width: 145),
            ),
          ):Padding(
            padding:EdgeInsets.only(top: 13.0,right: 12,),
            child:Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/logo.png',width: 145),
            ),
          ),
          Column(
            children: [
              Container(
                width: 55,
                height: 35,
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.orange,
                //     width: 2,
                //   ),
                // ),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top: 6.0,right: 4.0),
                        child: Image.asset('assets/images/ping_image.png',height: 28 ,fit: BoxFit.cover,
                        ),
                    ),
                    if(notificationCount>0)
                      Positioned(
                        top: -6,
                        right: 0,
                        // height: 20,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            notificationCount.toString(),
                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text('Pings',style: TextStyle(fontSize: 14,color:Colors.black,fontWeight: FontWeight.w600,fontFamily: 'Poppins'),),
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
    final screenWidth = MediaQuery.of(context).size.width;
    // return Container(
    //   height: 110,
    //   width: 46,
    //   margin: EdgeInsets.only(top: 10.0,left: 16.0,right: 16.0,),
    //   decoration: BoxDecoration(
    //     color: Colors.white, // Container background color
    //     border: Border.all(
    //       color: HexColor('#001B33'), // Border color
    //       width: 1.0, // Border width
    //     ),
    //   ),
    //   child: ListView.builder(itemBuilder: (context,index)=>
    //       ListTile(
    //         leading:Image.asset('assets/images/profile_strength.jpg',
    //         width: 80,height: 120,),
    //         title: Text('Lets Complete\nProfile Section First!',style: TextStyle(fontWeight: FontWeight.w800,fontSize: 14,fontFamily: 'Poppins'),),
    //         subtitle: RichText(
    //           text: TextSpan(
    //               style: TextStyle(color: Colors.black),
    //               children: [
    //                 TextSpan(text: 'Profile Strength\n',style: TextStyle(fontSize: 13,fontFamily: 'Poppins',shadows: <Shadow>[
    //                 Shadow(
    //                 offset: Offset(2.0, 1.0), // Specify the x and y offset of the shadow
    //                   blurRadius: 6.0, // Specify the blur radius of the shadow
    //                   color: Colors.grey, // Specify the color of the shadow
    //                 ),
    //               ],),),
    //                 TextSpan(text: '${profileStatus.toUpperCase()}',style: TextStyle(color: _getStatusColor(),fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
    //               ],
    //             ),
    //           ),
    //         trailing:Container(
    //             child: IconHover(),
    //         ),
    //       ),
    //     itemCount: 1,
    //   ),
    // );
    return Padding(
      padding: EdgeInsets.only(top: 12.0,left: 25.0,right: 24.0,bottom:0.0),
      child: Container(
        width: 400,
        height: 120,
        // padding: EdgeInsets.only(top: 12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child:Row(
          children: [
            Container(
              child: Image.asset('assets/images/profile_strength.jpg', width: 110,height: 92,fit: BoxFit.contain,),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Container(
                width: screenWidth*0.41,
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color:Colors.lightGreen,
                //     width: 2,
                //   ),
                // ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text('Lets Complete\nProfile Section First!',style: TextStyle(fontWeight: FontWeight.w900,fontSize: 14,fontFamily: 'Poppins'),),
                    SizedBox(height: 10,),
                    Text('Profile Strength',style: TextStyle(fontSize: 11,fontFamily: 'Poppins',shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2.0, 1.0), // Specify the x and y offset of the shadow
                        blurRadius: 6.0, // Specify the blur radius of the shadow
                        color: Colors.grey, // Specify the color of the shadow
                      ),
                    ],),),
                    Text('LOW',style: TextStyle(color: Colors.red,fontWeight: FontWeight.w900,fontFamily: 'Poppins',fontSize: 11),),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: screenWidth*0.01),
              child: Align(
                alignment: Alignment.topRight,
                child:  IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward,),color: Colors.orange,),
              ),
            ),
          ],
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
              height: 170,
              color: HexColor('#EDEDED'),
              child: Center(
                child: Image.asset(
                  'assets/images/video_icon.png', // Replace with the actual path to your asset image
                  width: 35, // Set the desired image width
                  height: 35, // Set the desired image height
                  fit: BoxFit.contain, // Adjust the fit as needed
                ),
              ),
            ),
          ),

        Positioned(
          child: Container(
            height:190,
            child: Stack(
              children: [
                Positioned(
                  top:120,
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
                          radius: 60,
                          backgroundImage: AssetImage('assets/images/user.png'),
                          backgroundColor: Colors.white,// Replace with user avatar image
                        ),
                      ),
                      Text(
                        'Hemant Singh', // Replace with actual user name
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                            fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),


        // Display guidance icons/messages
        Positioned(
          top: 20,
          right: 30,
          child: IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
            showDialog(context: context, builder: (BuildContext context){
              return Container(child: CustomHelpOverlay(),);
            },
            );
          },
          ),
        ),


      ],
    );

  }
}

class UserPhoto extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      height:120,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.black,width: 2,
      //   ),
      // ),
      // dec
      child: Stack(
        children: [
          Positioned(
            top: -70,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/user.png'),
                    backgroundColor: Colors.white,// Replace with user avatar image
                  ),
                ),
                Text(
                    'Hemant Singh', // Replace with actual user name
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}


class UserInformationSection extends StatelessWidget {
  final bool reqPage;

  UserInformationSection({required this.reqPage});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16.0,left: 16.0,right: 16.0 , bottom: 16.00),
      child: Column(
        children: [
          SizedBox(height: 10,),
          MotivationalQuote(),
          SizedBox(height: 20.0),
          ReachAndLocation(),
          SizedBox(height: 45.0),
          reqPage?UserDetailsTable():Text('Hello'),
          SizedBox(height: 45.0),
          ExpertCardDetails(),
          SizedBox(height: 35.0),
          ProfielStatusAndButton(),
        ],
      ),
    );
  }
}


class MotivationalQuote extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
              Text('+ Add your Motivational quote',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,color: HexColor('#FB8C00'),fontFamily: 'Poppins',),
              ),
              IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                    showDialog(context: context, builder: (BuildContext context){
                      return Container(child: CustomHelpOverlay(),);
                    },
                  );
                },
              ),
          ],
      ),
    );
  }
}

class ReachAndLocation extends StatelessWidget{
  int followers = 0,following = 0,locations=1;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InfoWidget(icon: Icons.person_add_alt, text: '${followers} Follower'),
        InfoWidget(icon: Icons.person_outline, text: '${following} Following'),
        InfoWidget(icon: Icons.add_location_outlined, text: '${locations} Location'),
      ],
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
        // IconButton(padding: EdgeInsets.zero,onPressed: (){},icon: Icon(icon),),
        Icon(icon),
        // SizedBox(height: 4.0),
        Text(text,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
      ],
    );
  }
}

class UserDetailsTable extends StatelessWidget {
  String place = 'NA',profession = 'NA',age = 'NA',gender = 'NA';
  List<String> languageList = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.red,
      //     width: 2.0,
      //   )
      // ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Text('Place - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 96,),
              Text('${place}',style: TextStyle(fontSize: 14),),
            ],
          ),
          Row(
            children: [
              Text('Profession - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 62,),
              Text('${profession}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Age/Gender - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 55,),
              Text(age=='NA'?age:'${age} Yr/ ${gender}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
            ],
          ),
          Row(
            children: [
              Text('Language - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,fontFamily: 'Poppins'),),
              SizedBox(width: 69,),
              Container(
                  child: languageList.isEmpty ? Text('NA', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')):
                  Wrap(
                    runSpacing: 8.0, // Vertical spacing between lines of items
                    children: [
                      Row(
                        children: [
                          for (int i = 0; i < languageList.length; i++)
                            Container(
                              margin: EdgeInsets.only(right: 8.0),
                              child: Row(
                                children: [
                                  Text(languageList[i]),
                                  if (i < languageList.length - 1)
                                    Text(',', style: TextStyle(fontSize: 16,fontFamily: 'Poppins')),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpertCardDetails extends StatelessWidget{
  List<String> expertLocations = [];
  String profileStatus = "Out Standing";
  int visitedplace = 0,coveredLocation = 0, ratings = 0;
  @override
  Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          // border: Border.all(
          //   color: Colors.black,
          //   width: 2,
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              // offset: Offset(0.0,0.0),
              blurRadius: 5.0,
              spreadRadius: 7.9,
            ),
            BoxShadow(
              color: Colors.white,
              // offset: Offset(0.0,0.0),
              blurRadius:5,
              spreadRadius: 12.9,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20.0,top: 5.0,bottom: 9.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Expert Cards' ,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                  IconButton(onPressed: (){}, icon: Icon(Icons.share_outlined)),
                ],
              ),
              Column(
                // crossAxisAlignment: CrossAxisAlignment.end,
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text('Expert in locations -',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 31,),
                      Container(
                        child: expertLocations.isEmpty ? Text('NA', style: TextStyle(fontSize: 14,fontFamily: 'Poppins')):
                        Wrap(
                          runSpacing: 8.0, // Vertical spacing between lines of items
                          children: [
                            Row(
                              children: [
                                for (int i = 0; i < expertLocations.length; i++)
                                  Container(
                                    margin: EdgeInsets.only(right: 8.0),
                                    child: Row(
                                      children: [
                                        Text(expertLocations[i]),
                                        if (i < expertLocations.length - 1)
                                          Text(',', style: TextStyle(fontSize: 16,fontFamily: 'Poppins')),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Text('Visited Places - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 58,),
                      Text('${visitedplace}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Covered Locations - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 30,),
                      Text('${coveredLocation}',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Expertise Rating - ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 35,),
                      Container(
                        child: ratings == 0
                            ? Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,color: HexColor('#FB8C00'),),
                              SizedBox(width: 5),
                              Text('N/A'),
                            ],
                          ),
                        )
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(ratings, (index) {
                            return Icon(Icons.star, color: HexColor('#FB8C00'));
                          }),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40,),
                  Row(
                    children: [
                      Text('Your Culturtap Status',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,fontFamily: 'Poppins'),),
                      SizedBox(width: 30,),
                      Container(
                        child: profileStatus=='Out Standing'?
                        Text(profileStatus,style: TextStyle(color: HexColor('#0A8100'),fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),):
                        Text('Working',style: TextStyle(color: Colors.red,fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}

class ProfielStatusAndButton  extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Container(
            width: 400,
            height: 70,
            child: FilledButton(
                backgroundColor: HexColor('#FB8C00'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteProfilePage(),));
                },
                child: Center(
                    child: Text('COMPLETE PROFILE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 25)))),
                ),
              ],
            ),
        );
  }

}

class FilledButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  final Color backgroundColor;

  const FilledButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: backgroundColor,
      ),
      child: child,
    );
  }
}

