import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/StoryDetailPage.dart';
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


class ImageScroll extends StatelessWidget {
  final List<String> imageUrls = [
    'assets/images/home_one.png',
    'assets/images/home_two.png',
    'assets/images/home_three.png',
    'assets/images/home_four.png',
    'assets/images/home_five.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.network(
              imageUrls[index],
              width: 150.0, // Adjust the width as needed
              height: 150.0, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

Future<List<dynamic>> fetchDataForStories(double latitude, double longitude, String apiEndpoint) async {
  final uri = Uri.http('173.212.193.109:8080', apiEndpoint, {
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);

    // Calculate distances for each story


    // print('Fetched data: $data');
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




  Future<void> fetchDataForCategory(double latitude, double longitude, int categoryIndex) async {
    try {





      final Map<String, dynamic> category = categoryData[categoryIndex];
      final String apiEndpoint = category['apiEndpoint'];

      final fetchedStoryList = await fetchDataForStories(latitude, longitude, apiEndpoint);


      List<Map<String, dynamic>> storyDetailsList = [];
      List<String> totalVideoPaths = [];
      List<String> totalVideoCounts = [];
      List<String> storyDistances = [];
      List<String> storyLocations = [];
      List<String> storyCategories = [];





      for (var story in fetchedStoryList) {
        dynamic videoPathData = story['videoPath'];
        double storyLat = story['latitude'];
        double storyLng = story['longitude'];

        String location = story['location'];
        String storyLocation = location?.split(',')?.first ?? '';
        String expDescription = story['expDescription'];
        List<String> placeLoveDesc = List.from(story['placeLoveDesc'] ?? []);
        String dontLikeDesc = story['dontLikeDesc'];
        String review = story['review'];
        int starRating = story['starRating'];
        String selectedVisibility = story['selectedVisibility'];
        String storyTitle = story['storyTitle'];
        String productDescription = story['productDescription'];
        String category = story['category'];
        String genre = story['genre'];
        // Add more details as needed


        String storyCategory = story['category'];

        double douDistance = calculateDistance(latitude, longitude, storyLat, storyLng);
        String distance = '${douDistance.toStringAsFixed(2)}';
        print(distance);

        // print('Distance to story: $distance km');


        if (videoPathData is List) {
          List<String> videoPaths = videoPathData
              .whereType<String>() // Filter out non-string elements
              .toList();

          Map<String, dynamic> storyDetails = {
            'videoPaths': videoPaths,
            'storyDistance': distance,
            'storyLocation': storyLocation,
            'storyCategory': storyCategory,
            'expDescription': expDescription,
            'placeLoveDesc': placeLoveDesc,
            'dontLikeDesc': dontLikeDesc,
            'review': review,
            'starRating': starRating,
            'selectedVisibility': selectedVisibility,
            'storyTitle': storyTitle,
            'productDescription': productDescription,
            'category': category,
            'genre': genre,
            // Add more details to the map
          };

          // print(storyDetails);
          totalVideoCounts.add('${videoPaths.length}');
          totalVideoPaths.add(genre);
          storyDistances.add(distance);
          storyLocations.add(storyLocation);
          storyCategories.add(storyCategory);


          storyDetailsList.add(storyDetails);
          print('storyDetailsList $storyDetailsList');
          // print('printing story details');
          // print(categoryData[categoryIndex]['storyDetailsList']);

        } else {
          print('Unsupported videoPath format');
          // Handle unsupported format as needed
        }
      }

      // Update the 'storyUrls' property of the current category
      categoryData[categoryIndex]['storyUrls'] = totalVideoPaths;
      categoryData[categoryIndex]['videoCounts'] = totalVideoCounts;
      categoryData[categoryIndex]['storyDistance'] = storyDistances;
      categoryData[categoryIndex]['storyLocation'] = storyLocations;
      categoryData[categoryIndex]['storyCategory'] = storyCategories;
      categoryData[categoryIndex]['storyDetailsList'] = storyDetailsList;


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





  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    fetchUserLocationAndData();
  }

  Future<void> fetchUserLocationAndDataasync() async {
    await fetchUserLocationAndData();
    // Any other asynchronous initialization tasks can be added here
  }



  Widget buildCategorySection( String specificCategoryName, String categoryName, List<String> storyUrls, List<String> videoCounts, List<String> storyDistance, List<String> storyLocation, List<String> storyCategory, List<Map<String, dynamic>> storyDetailsList) {
    // Check if the category has videos
    if (storyUrls.isEmpty || storyDistance.isEmpty) {
      // Don't display anything for categories with no videos
      return Column(children: [


      ],);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left:18.0,right:18,top:18,bottom:10),
          child: Column(
            children: [
              if (specificCategoryName != null && specificCategoryName.isNotEmpty)
              Text(
                specificCategoryName,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF263238),),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    categoryName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,  color: Color(0xFF263238),),
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
            ],
          ),
        ),
        Container(
          height: 590,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: storyUrls.length,
            itemBuilder: (context, index) {

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryDetailPage(
                        storyUrls: storyUrls,
                        storyDetailsList: storyDetailsList,
                        initialIndex: index,
                      ),
                    ),
                  );

                },
                child: VideoStoryCard(
                  videoUrl: storyUrls[index],
                  distance: storyDistance[index],
                  videoCount: videoCounts[index],
                  location : storyLocation[index],
                  category : storyCategory[index],

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
      'specificCategoryName': '',
      'name': 'Trending NearBy',
      'apiEndpoint': '/main/api/trending-nearby-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificCategoryName': 'vTrending NearBy',
      'name': 'Festivals Around You',
      'apiEndpoint': '/festival/api/trending-nearby-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificCategoryName': '',
      'name': 'Street Foods Nearby',
      'apiEndpoint': '/food/api/nearby-street-foods',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificCategoryName': '',
      'name': 'Fashion Nearby',
      'apiEndpoint': '/fashion/api/nearby-fashion-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificCategoryName': '',
      'name': 'National Parks Here',
      'apiEndpoint': '/parks/api/nearby-national-parks',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificCategoryName': '',
      'name': 'Forests Here',
      'apiEndpoint': '/forest/api/nearby-forests',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificCategoryName': '',
      'name': 'Famous RiverSides Here',
      'apiEndpoint': '/riverside/api/nearby-riverside-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificCategoryName': '',
      'name': 'Islands Here',
      'apiEndpoint': '/island/api/nearby-island-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificCategoryName': '',
      'name': 'EcoSystem NearBy',
      'apiEndpoint': '/ecosystem/api/nearby-aquatic-ecosystem-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },

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
        appBar:CustomAppBar(title: ""),
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

                final String specificCategoryName = category['specificCategoryName'];
                final String categoryName = category['name'];
                final List<String> storyUrls = category['storyUrls'];
                final List<String> videoCounts = category['videoCounts'];
                final List<String> storyDistance = category['storyDistance'];
                final List<String> storyLocation = category['storyLocation'];
                final List<String> storyCategory = category['storyCategory'];
                List<Map<String, dynamic>> storyDetailsList = category['storyDetailsList'];



                return buildCategorySection(specificCategoryName, categoryName, storyUrls, videoCounts, storyDistance, storyLocation, storyCategory, storyDetailsList);
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
  final String location;
  final String category;


  VideoStoryCard({required this.videoUrl, required this.distance, required this.videoCount, required this.location, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
        ),
        Container(
          height:70,
          width:280,
          padding:EdgeInsets.all(10),
          child:Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Row(
                  children: [
                    Text('Location ',style: TextStyle(fontWeight: FontWeight.bold,  color: Color(0xFF263238),),),
                    Text(' ${location}',style: TextStyle(color: Color(0xFF263238),),),

                  ],
                ),
                Container(
                  width : 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.remove_red_eye_sharp,
                        color: Colors.grey,
                        size: 24,
                      ),
                      Text('89.0K',style: TextStyle(color: Color(0xFF263238),),),
                    ],
                  ),
                ),


            ],),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Row(
                  children: [
                    Text('Category ',style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF263238),),),
                    Text(' ${category}',style: TextStyle(color: Color(0xFF263238),),),
                  ],
                ),
                Container(
                  width:65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Icon(
                        Icons.heart_broken,
                        color : Colors.grey,
                        size: 24,
                      ),
                      Text('700.5k',style: TextStyle(color: Color(0xFF263238),),),
                    ],
                  ),
                ),


              ],),
          ],)
        ),
      ],
    );
  }
}




