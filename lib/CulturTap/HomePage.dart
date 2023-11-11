import 'package:flutter/material.dart';
import 'package:learn_flutter/CustomItems/CostumAppbar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import "package:learn_flutter/Utils/location_utils.dart";
import "package:learn_flutter/Utils/BackButtonHandler.dart";
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

Future<List<dynamic>> fetchDataForStories(double latitude, double longitude, String apiEndpoint) async {
  final uri = Uri.http('192.168.223.23:8080', apiEndpoint, {
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);

    // Calculate distances for each story


    print('Fetched data: $data');
    return data;
  } else {
    print('failure');
    throw Exception('Failed to load data');
  }
}

double calculateDistance(double userLat, double userLng, double storyLat, double storyLng) {
  const double earthRadius = 6371; // Radius of the Earth in kilometers

  // Convert latitude and longitude from degrees to radians
  final double userLatRad = userLat * pi / 180.0;
  final double userLngRad = userLng * pi / 180.0;
  final double storyLatRad = storyLat * pi / 180.0;
  final double storyLngRad = storyLng * pi / 180.0;

  // Calculate the differences
  final double latDiff = storyLatRad - userLatRad;
  final double lngDiff = storyLngRad - userLngRad;

  // Haversine formula to calculate distance
  final double a = pow(sin(latDiff / 2), 2) +
      cos(userLatRad) * cos(storyLatRad) * pow(sin(lngDiff / 2), 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // Distance in kilometers
  final double distance = earthRadius * c;

  return distance;
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
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    fetchUserLocationAndData();
  }

  Future<void> fetchDataForCategory(double latitude, double longitude, int categoryIndex) async {
    try {

      final Map<String, dynamic> category = categoryData[categoryIndex];
      final String apiEndpoint = category['apiEndpoint'];

      final fetchedStoryList = await fetchDataForStories(latitude, longitude, apiEndpoint);


      List<String> totalVideoPaths = [];
      List<String> totalVideoCounts = [];
      List<String> storyDistances = [];



      for (var story in fetchedStoryList) {
        dynamic videoPathData = story['videoPath'];
        double storyLat = story['latitude'];
        double storyLng = story['longitude'];

        double douDistance = calculateDistance(latitude, longitude, storyLat, storyLng);
        String distance = '${douDistance.toStringAsFixed(2)}';
        print(distance);

        print('Distance to story: $distance km');


        if (videoPathData is List) {
          List<String> videoPaths = videoPathData
              .whereType<String>() // Filter out non-string elements
              .toList();

          totalVideoCounts.add('${videoPaths.length}');
          totalVideoPaths.addAll(videoPaths);
          storyDistances.add(distance);

        } else {
          print('Unsupported videoPath format');
          // Handle unsupported format as needed
        }
      }

      // Update the 'storyUrls' property of the current category
      categoryData[categoryIndex]['storyUrls'] = totalVideoPaths;
      categoryData[categoryIndex]['videoCounts'] = totalVideoCounts;
      categoryData[categoryIndex]['storyDistance'] = storyDistances;

      // Refresh the UI to reflect the changes
      setState(() {
        isLoading = false;
      });
      print('Video counts per story in category $categoryIndex: $totalVideoCounts');
      print('All video paths in category $categoryIndex: $totalVideoPaths');
    } catch (error) {
      print('Error fetching stories for category $categoryIndex: $error');
    }
  }


// Inside your _HomePageState class

  Future<void> fetchUserLocationAndData() async {
    print('I called');

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      print('Latitude is: $latitude');

      // Fetch stories for each category
      for (int i = 0; i < categoryData.length; i++) {
        await fetchDataForCategory(latitude, longitude, i);
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }





  Widget buildCategorySection(String categoryName, List<String> storyUrls, List<String> videoCounts, List<String> storyDistance) {
    // Check if the category has videos
    if (storyUrls.isEmpty || storyDistance.isEmpty) {
      // Don't display anything for categories with no videos
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                categoryName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Handle button press for "View All" in the specific category
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
          height: 550,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: storyUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Handle tapping on a story in the sfpecific category
                },
                child: VideoStoryCard(
                  videoUrl: storyUrls[index],
                  distance: storyDistance[index], // Pass the calculated distance
                  videoCount: videoCounts[index], // You can customize this as needed
                ),
              );
            },
          ),
        ),
      ],
    );
  }





  List<Map<String, dynamic>> categoryData = [
    {
      'name': 'Trending NearBy',
      'apiEndpoint': '/main/api/trending-nearby-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
    },
    {
      'name': 'Street Foods Nearby',
      'apiEndpoint': '/food/api/nearby-street-foods',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
    },
    // Add more categories as needed
  ];


  BackButtonHandler backButtonHandler1 = BackButtonHandler(
    imagePath: 'assets/images/exit.svg',
    textField: 'Do you want to exit?',
    what: 'exit',
  );

  Future<void> _refreshHomepage() async {
      await fetchUserLocationAndData();
  }



  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => backButtonHandler1.onWillPop(context, true),
      child: Scaffold(
        appBar: VideoAppBar(),
        body: RefreshIndicator(
          backgroundColor: Color(0xFF263238),
          color: Colors.orange,
          onRefresh: _refreshHomepage,

          child: isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              Column(
              children: categoryData.asMap().entries.map((entry) {
                final int categoryIndex = entry.key;
                final Map<String, dynamic> category = entry.value;

                final String categoryName = category['name'];
                final List<String> storyUrls = category['storyUrls'];
                final List<String> videoCounts = category['videoCounts'];
                final List<String> storyDistance = category['storyDistance'];

                return buildCategorySection(categoryName, storyUrls, videoCounts, storyDistance);
              }).toList(),
            ),
            ]

          ),
        ),
        bottomNavigationBar: CustomFooter(),
      ),
    );
  }

}









class VideoStoryCard extends StatelessWidget {
  final String videoUrl;
  final String distance; // Change the type to String for distance
  final String videoCount;


  VideoStoryCard({required this.videoUrl, required this.distance, required this.videoCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 280,
      margin: EdgeInsets.all(8),
      child: Stack(
        clipBehavior: Clip.none, // Allow children to overflow the container
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(
                  image: AssetImage('assets/images/homeimage.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: -8, // Adjust this value to control vertical positioning
            right: 10, // Adjust this value to control horizontal positioning
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF263238),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fork_right_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  Text(
                    '${distance} km',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -5, // Adjust this value to control vertical positioning
            right: 10, // Adjust this value to control horizontal positioning
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF263238),
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
                    ' +$videoCount',
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




