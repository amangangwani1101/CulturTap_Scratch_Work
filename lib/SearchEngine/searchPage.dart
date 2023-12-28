//homepage
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:learn_flutter/CulturTap/VideoFunc/categoryData.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/category_section_builder.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/data_service.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/process_fetched_stories.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';
import 'package:learn_flutter/CulturTap/searchBar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/SearchEngine/FilterButton.dart';
import 'package:learn_flutter/SearchEngine/SearchDatabaseHelper.dart';
import 'package:learn_flutter/SearchEngine/SuggestionList.dart';
import 'package:learn_flutter/SearchEngine/searchPage.dart';
import "package:learn_flutter/Utils/location_utils.dart";
import "package:learn_flutter/Utils/BackButtonHandler.dart";
import 'package:http/http.dart' as http;
import 'package:learn_flutter/check.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:learn_flutter/widgets/Constant.dart';



void main() {
  runApp(MyApp());
}


//new stuff

//inside this



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



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {
  bool _isVisible = true;
  bool isSearchInitiated = false;

  bool isLoading = true;
  String userName = '';
  String userID = '';
  ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<String> suggestions = ['Trending Stories NearMe','Exciting Trips'];
  String selectedFilter = '';
  late FocusNode _searchFocusNode;
  late SearchDatabaseHelper _databaseHelper;
  bool isSearching = true;
  String location = 'Gwalior';


  Map<int, bool> categoryLoadingStates = {};




  List<Map<String, dynamic>> categoryData = [
    ...generateCategoryData(name: 'LifeStyle', apiEndpoint: '/api/stories/best/genre/Lifestyle'),
    // ...generateCategoryData(name: 'Most Trending Visits', apiEndpoint: '/api/stories/best/selectedFilter/India'),
    // ...generateCategoryData(name: 'Historical/Heritage', apiEndpoint: '/api/stories/best/genre/Historical/Heritage/selectedFilter/India'),
    // ...generateCategoryData(name: 'Art & Culture/Museum', apiEndpoint: '/api/stories/best/genre/Art & Culture/selectedFilter/India'),
    // ...generateCategoryData(name: 'Wildlife attractions', apiEndpoint: '/api/stories/best/genre/WildLife attractions/selectedFilter/India'),
    // ...generateCategoryData(name: 'Advanture Places', apiEndpoint: '/api/stories/best/genre/Advanture Places/selectedFilter/India'),
    // ...generateCategoryData(name: 'Festival', apiEndpoint: '/api/stories/best/genre/Festival/selectedFilter/India'),
    // ...generateCategoryData(name: 'Fashion', apiEndpoint: '/api/stories/best/genre/Fashion/selectedFilter/India'),
  ];


  Future<void> updateSuggestions(String query, String selectedFilter) async {
    print('this is called');
    if (query.isEmpty) {
      print('query is empty');
      // If the search bar is empty, show suggestions from the local database
      List<String> searchHistory = await _databaseHelper.getSearchHistory();
      setState(() {
        print('search History $searchHistory');
        suggestions = searchHistory;
        isSearchInitiated = true;
      });
      return;
    }

    final apiUrl = '${Constant().serverUrl}';



    final response = await http.get(
      Uri.parse('$apiUrl?filter=$selectedFilter&query=$query'),
    );


    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        suggestions = List<String>.from(jsonResponse['suggestions']);
        isSearching = true;
      });
    } else {
      print('Error fetching suggestions: ${response.statusCode}');
    }
  }


  Future<void> fetchDataForCategory(double latitude, double longitude, int categoryIndex) async {
    try {

      final Map<String, dynamic> category = categoryData[categoryIndex];
      String apiEndpoint = category['apiEndpoint'];
      // String apiEndpoint = "$apiEndpointsmall/$selectedFilter/'India'";

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
      setState(() {
        categoryLoadingStates[categoryIndex] = false;
      });
    }
  }

  Future<void> updateLiveLocation(String userId, double liveLatitude, double liveLongitude) async {
    final String serverUrl = Constant().serverUrl;
    final Uri uri = Uri.parse('$serverUrl/updateLiveLocation');
    final Map<String, dynamic> data = {
      'userId': userId,
      'liveLatitude': liveLatitude,
      'liveLongitude': liveLongitude,
    };

    try {
      final response = await http.put(
        uri,
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Live location updated successfully');
      } else {
        print('Failed to update live location. ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating live location: $error');
    }
  }


// Inside your _SearchPageState class

  Future<void> fetchUserLocationAndData() async {
    print('I called');

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      String query = _searchController.text;

      updateLiveLocation('6572cc23e816febdac42873b', position.latitude, position.longitude);

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

    _searchFocusNode = FocusNode();
    _searchFocusNode.requestFocus();
    _databaseHelper = SearchDatabaseHelper();

    selectedFilter = 'Stories';

    fetchDataFromMongoDB();

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

      selectedFilter = 'Stories';


    });

  }

  //updated code from here

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }





  Future<void> fetchUserLocationAndDataasync() async {
    await fetchUserLocationAndData();
    print(userName);

    // Any other asynchronous initialization tasks can be added here
  }






  Future<void> _refreshHomepage() async {
    await fetchUserLocationAndData();
    fetchDataFromMongoDB();

    print(userName);
    print(userID);
  }


  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        return false; // Returning true will allow the user to pop the page
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: RefreshIndicator(
          backgroundColor: Color(0xFF263238),
          color: Colors.orange,
          onRefresh: _refreshHomepage,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                title: ProfileHeader(reqPage: 0, userId: '6572cc23e816febdac42873b', userName: userName),
                automaticallyImplyLeading: false,
                shadowColor: Colors.transparent,
                toolbarHeight: 90,
                // Adjust as needed
                floating: true,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(

                  // You can add more customization to the flexible space here
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // Your other widgets here
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [




                        SizedBox(height : 40),
                        SearchBarWithSuggestions(
                          focusNode: _searchFocusNode,
                          controller: _searchController,
                          onSearch: (query) => updateSuggestions(query, selectedFilter), // Pass the selected filter
                        ),

                        SizedBox(height: 20),
                        FiltersWithHorizontalScroll(
                          selectedFilter: selectedFilter,
                          onFilterSelected: (filter) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                        ),
                        SizedBox(height: 30),




                      ],
                    ),
                    if (!_searchController.text.isEmpty && isSearchInitiated)
                      isLoading ? Container(
      height : 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(child: CircularProgressIndicator(color : Theme.of(context).primaryColor,)),
        ],
      ),
    ) : Column(children: categoryData.asMap().entries.map((entry) {
    final int categoryIndex = entry.key;
    final Map<String, dynamic> category = entry.value;

    final bool categoryLoading = categoryLoadingStates[categoryIndex] ?? false;
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
    categoryLoading,
    );
    }).toList(),),
                    if (_searchController.text.isEmpty && !isSearchInitiated)
                      SuggestionList(
                        suggestions: suggestions,
                        searchController: _searchController,
                        onSuggestionSelected: (selectedSuggestion) {
                          // Handle the selected suggestion
                          print('Selected suggestion: $selectedSuggestion');
                          // Set the search input value
                          _searchController.text = selectedSuggestion;
                        },
                      ),


                  ],
                ),
              ),
            ],
          ),

        ),
        bottomNavigationBar: AnimatedContainer(
          duration: Duration(milliseconds: 100),


          height: _isVisible ? 70 : 0.0,
          child: CustomFooter(userName: userName, userId: userID, lode: 'home',),
        ),
      ),
    );
  }
}






class SearchBarWithSuggestions extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final Function(String) onSearch;

  SearchBarWithSuggestions({
    required this.focusNode,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Column(
        children: [
          TextFormField(
            focusNode: focusNode,
            controller: controller,
            onEditingComplete: () {
              // Hide the keyboard when the "Done" button is pressed
              requestLocationPermission();
              FocusScope.of(context).unfocus();
              onSearch(controller.text);


              // Set the flag to true when the user initiates a search

            },
            style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(30.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(30.0),
              ),
              hintText: 'Search here your Mood, Food, Places...',
              hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor), // Add search icon
            ),
          ),
        ],
      ),
    );
  }
}



class FiltersWithHorizontalScroll extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  FiltersWithHorizontalScroll({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterButton('Stories', selected: selectedFilter == 'Stories', onPressed: onFilterSelected),
            FilterButton('Location', selected: selectedFilter == 'Location', onPressed: onFilterSelected),
            FilterButton('Profiles', selected: selectedFilter == 'Profiles', onPressed: onFilterSelected),

          ],
        ),
      ),
    );
  }
}



