import 'package:flutter/material.dart';
import 'package:learn_flutter/CustomItems/CostumAppbar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import "package:learn_flutter/Utils/location_utils.dart";
import "package:learn_flutter/Utils/BackButtonHandler.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Colors.orange, // Set your primary color
      ),



    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {



  final List<List<String>> videoUrlsList = [
    ["video_url_1", "video_url_2", "video_url_3"],
    ["video_url_4", "video_url_5", "video_url_6"],
    ["video_url_7", "video_url_8", "video_url_9","video"],
    ["video_url_7", "video_url_8", "video_url_9","video"],

    // Add more rows of video URLs here
  ];

  final List<String> rowHeadings = [
    'Trending NearBy',
    'Trending Outskirts',
    'Row 3 Heading',
    'row 4 heading',
    // Add more headings as needed
  ];

  @override
  void initState() {
    super.initState();
    requestLocationPermission();

    // Perform initialization tasks here
  }

  BackButtonHandler backButtonHandler1 = BackButtonHandler(
    imagePath: 'assets/images/exit.svg',
    textField: 'Do you want to exit?',
    what: 'exit',
  );

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => backButtonHandler1.onWillPop(context, true),
      child: Scaffold(
        appBar: VideoAppBar(),
        body: Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: videoUrlsList.asMap().entries.map((entry) {
                  final int rowIndex = entry.key;
                  final List<String> rowUrls = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              rowHeadings[rowIndex],
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle button press
                              },
                              child: Text(
                                'View All >',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 500,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: rowUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Navigate to the video viewing page with the selected story's data
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => VideoViewingPage(
                                //       videoUrls: rowUrls, // Pass the video URLs for the selected row
                                //     ),
                                //   ),
                                // );
                              },
                              child: VideoStoryCard(
                                videoUrl: rowUrls[index],
                                videoCount: rowUrls.length,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(
                height: 105, // Same height as the footer
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomFooter(),
        ),


        SizedBox(
          height: 85, // Same height as the footer
        ),




      ],
        ),
      ),
    );
  }
}














class VideoStoryCard extends StatelessWidget {
  final String videoUrl;
  final int videoCount;

  VideoStoryCard({required this.videoUrl, required this.videoCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(


        height: 500,
        width: 280,
        margin: EdgeInsets.all(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(
                    image: AssetImage('assets/images/homeimage.png'), // Replace with your image path
                    fit: BoxFit.cover, // Adjust how the image fits within the container
                  ),
                ),
              ),
            ),
            Positioned(
              top: -4,
              right: 8,
              child: Text(
                'Distance',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 12,
              child: Container(
                padding: EdgeInsets.only(top: 6, left: 16, right: 16, bottom: 6 ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 24,
                    ),
                    Text(
                      '+$videoCount',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


