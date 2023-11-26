import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/StoryDetailPage.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/category_section_builder.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/video_story_card.dart';
import 'package:learn_flutter/CulturTap/searchBar.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/Calendar.dart';
import 'package:learn_flutter/SignUp/FirstPage.dart';
import 'package:learn_flutter/UserProfile/FinalUserProfile.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:learn_flutter/widgets/hexColor.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'BackendStore/BackendStore.dart';
import 'UserProfile/ProfileHeader.dart';
import 'UserProfile/UserProfileEntry.dart';

void main() {
  runApp(MyApp());
}


//new stuff

//inside this

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

Future<List<dynamic>> fetchSearchResults(String query, String apiEndpoint) async {
  try {
    // Modify the search API endpoint based on your backend implementation
    final Map<String, dynamic> queryParams = {'query': query};
    final uri = Uri.http('173.212.193.109:8080', apiEndpoint, queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> searchResults = json.decode(response.body);
      print('Search results: $searchResults');

      return searchResults;
      // Process and update the UI with the search results

    } else {
      print('Failure');
      throw Exception('Failed to load search results');
    }
  } catch (error) {
    print('Error fetching search results: $error');
    throw error; // Add this line to explicitly return an error
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
  bool _isVisible = true;
  bool isLoading = true;
  String userName = '';
  String userID = '';
  ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();






  Map<String, dynamic> processFetchedStories(List<dynamic> fetchedStoryList, double latitude, double longitude) {
    List<Map<String, dynamic>> storyDetailsList = [];
    List<String> totalVideoPaths = [];
    List<String> totalVideoCounts = [];
    List<String> storyDistances = [];
    List<String> storyLocations = [];
    List<String> storyTitles = [];
    List<String> storyCategories = [];


    for (var story in fetchedStoryList) {
      dynamic videoPathData = story['videoPath'];

      double storyLat = story['latitude'];
      double storyLng = story['longitude'];

      String location = story['location'];
      String storyTitle = story['storyTitle'];
      String storyLocation = location?.split(',')?.first ?? '';
      String expDescription = story['expDescription'];
      List<String> placeLoveDesc = List.from(story['placeLoveDesc'] ?? []);
      String dontLikeDesc = story['dontLikeDesc'];
      String review = story['review'];
      int starRating = story['starRating'];
      String selectedVisibility = story['selectedVisibility'];

      String productDescription = story['productDescription'];
      String category = story['category'];
      String genre = story['genre'];

      String storyCategory = story['category'];

      double douDistance = calculateDistance(latitude, longitude, storyLat, storyLng);
      String distance = '${douDistance.toStringAsFixed(2)}';

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
        };

        totalVideoCounts.add('${videoPaths.length}');
        String thumbnailurl = 'thumbnail-' + videoPaths[0].replaceAll('.mp4', '.webp');
        totalVideoPaths.add('$thumbnailurl');
        storyDistances.add(distance);
        storyLocations.add(storyLocation);
        storyTitles.add(storyTitle);

        storyCategories.add(storyCategory);


        storyDetailsList.add(storyDetails);
      } else {
        print('Unsupported videoPath format');
      }
    }

    return {
      'storyDetailsList': storyDetailsList,
      'totalVideoPaths': totalVideoPaths,
      'totalVideoCounts': totalVideoCounts,
      'storyDistances': storyDistances,
      'storyLocations': storyLocations,
      'storyTitles': storyTitles,
      'storyCategories': storyCategories,
    };
  }

  Future<void> fetchDataForCategory(double latitude, double longitude, int categoryIndex) async {
    try {
      final Map<String, dynamic> category = categoryData[categoryIndex];
      String apiEndpoint = category['apiEndpoint'];

      final fetchedStoryList = await fetchDataForStories(latitude, longitude, apiEndpoint);

      Map<String, dynamic> processedData = processFetchedStories(fetchedStoryList, latitude, longitude);

      categoryData[categoryIndex]['storyUrls'] = processedData['totalVideoPaths'];
      categoryData[categoryIndex]['videoCounts'] = processedData['totalVideoCounts'];
      categoryData[categoryIndex]['storyDistance'] = processedData['storyDistances'];
      categoryData[categoryIndex]['storyLocation'] = processedData['storyLocations'];
      categoryData[categoryIndex]['storyTitle'] = processedData['storyTitles'];
      categoryData[categoryIndex]['storyCategory'] = processedData['storyCategories'];
      categoryData[categoryIndex]['thumbnail_url'] = processedData['thumbnail_urls'];
      categoryData[categoryIndex]['storyDetailsList'] = processedData['storyDetailsList'];

      setState(() {
        isLoading = false;
      });

      print('Video counts per story in category $categoryIndex: ${processedData['totalVideoCounts']}');
      print('All video paths in category $categoryIndex: ${processedData['totalVideoPaths']}');
      print('storyurls');
      print(categoryData[categoryIndex]['storyUrls']);
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
      String query = _searchController.text;

      print('Latitude is: $latitude');

      // Fetch stories for each category

      if(query.isNotEmpty){
        print('wow');

      }
      else{
        for (int i = 0; i < categoryData.length; i++) {
          await fetchDataForCategory(latitude, longitude, i);
        }
      }



    } catch (e) {
      print('Error fetching location: $e');
    }
  }


  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    fetchDataFromMongoDB();

    requestLocationPermission();
    fetchUserLocationAndData();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        setState(() {
          _isVisible = true;
        });
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        setState(() {
          _isVisible = false;
        });
      }
    });
    setState(() {

    });

  }

  //updated code from here

  Future<void> fetchDataFromMongoDB() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // User is already signed in, navigate to the desired screen
      var userQuery = await firestore.collection('users').where('uid',isEqualTo:user.uid).limit(1).get();

      var userData = userQuery.docs.first.data();
      String uName = userData['name'];
      String uId = userData['userMongoId'];
      userName = uName;
      print('userName: $userName');
      userID =uId;
      print('userID$userID');
    }
  }


  Future<void> fetchUserLocationAndDataasync() async {
    await fetchUserLocationAndData();
    print(userName);
    // Any other asynchronous initialization tasks can be added here
  }





  List<Map<String, dynamic>> categoryData = [
    {
      'specificName': '',
      'name': 'Trending NearBy',
      'apiEndpoint': '/main/api/trending-nearby-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],

    },
    {
      'specificName': 'Trending Visits in Nation',
      'name': 'Festivals Around You',
      'apiEndpoint': '/nation/api/trending-visits-in-nation',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': '',
      'name': 'Festivals Around You',
      'apiEndpoint': '/festival/api/trending-nearby-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': '',
      'name': 'International Trendings',
      'apiEndpoint': '/international/trending-international',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': '',
      'name': 'Festivals Around You',
      'apiEndpoint': 'api/nearby-places/Festivals',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': 'Are you feeling hungry ?',
      'name': 'Street Foods Nearby',
      'apiEndpoint': 'api/nearby-places/Street Foods',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': 'Are you feeling hungry ?',
      'name': 'Restaurants Near you',
      'apiEndpoint': 'api/nearby-places/Restaurants',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': 'Are you feeling hungry ?',
      'name': 'Popular & Trending here in foods',
      'apiEndpoint': 'popular/api/popular-foods',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],
      'storyDetailsList': <Map<String, dynamic>>[],
    },


    {
      'specificName': 'Local Fashion for you !',
      'name': 'Local Stores Near you',
      'apiEndpoint': 'api/nearby-places/Fashion',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },


    {
      'specificName': 'Local Fashion for you !',
      'name': 'Popular & Trending Here',
      'apiEndpoint': '/fashion/api/nearby-fashion-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': 'Local Fashion for you !',
      'name': 'Popular & Trending here',
      'apiEndpoint': '/popularFashion/api/popular-fashion-places',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': 'Party Tonight ?',
      'name': 'Popular & Trending Clubs Here',
      'apiEndpoint': 'api/nearby-places/Party-Clubs & Bars',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': 'Party Tonight ?',
      'name': 'Nearby Hotels & Resorts',
      'apiEndpoint': 'api/nearby-places/Resorts',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': 'Other Outlets',
      'name': 'Local Furniture',
      'apiEndpoint': '/furniture/api/local-furniture',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': '',
      'name': 'Handy-Crafts',
      'apiEndpoint': '/handy-crafts/api/handyCrafts',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': '',
      'name': 'Forests Near you',
      'apiEndpoint': 'api/nearby-places/Forests',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': '',
      'name': 'Famous RiverSides Here',
      'apiEndpoint': 'api/nearby-places/Riverside',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': '',
      'name': 'Islands Here',
      'apiEndpoint': 'api/nearby-places/Island',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
      'storyCategory' : <String>[],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    {
      'specificName': '',
      'name': 'EcoSystem NearBy',
      'apiEndpoint': 'api/nearby-places/Aquatic Ecosystem',
      'storyUrls': <String>[],
      'videoCounts': <String>[],
      'storyDistance' : <String>[],
      'storyLocation' : <String>[],
      'storyTitle' : <String>[],
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
      fetchDataFromMongoDB();

      print(userName);
      print(userID);
  }



  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () => backButtonHandler1.onWillPop(context, true),
      child: Scaffold(
        appBar: AppBar(
          title: ProfileHeader(reqPage: 0, userId: userID, userName: userName),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
        ),
        body: RefreshIndicator(
          backgroundColor: Color(0xFF263238),
          color: Colors.orange,
          onRefresh: _refreshHomepage,
          child: isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: <Widget>[
                StoryBar(
                  controller: _searchController,
                  onSubmitted: (value) {
                    fetchUserLocationAndData();
                  },
                ),
                // Your other widgets here
                Column(
                  children: categoryData.asMap().entries.map((entry) {
                    final int categoryIndex = entry.key;
                    final Map<String, dynamic> category = entry.value;

                    final String specificCategoryName = category['specificName'];
                    final String categoryName = category['name'];
                    final List<String> storyUrls = category['storyUrls'];
                    final List<String> videoCounts = category['videoCounts'];
                    final List<String> storyDistance = category['storyDistance'];
                    final List<String> storyLocation = category['storyLocation'];
                    final List<String> storyCategory = category['storyCategory'];
                    final List<String> storyTitle = category['storyTitle'];

                    List<Map<String, dynamic>> storyDetailsList = category['storyDetailsList'];

                    return buildCategorySection(
                      specificCategoryName,
                      categoryName,
                      storyUrls,
                      videoCounts,
                      storyDistance,
                      storyLocation,
                      storyTitle,
                      storyCategory,
                      storyDetailsList,


                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          height: _isVisible ? kBottomNavigationBarHeight + 25 : 0.0,
          child: CustomFooter(userName: userName, userId: userID),
        ),
      ),
    );
  }


}




