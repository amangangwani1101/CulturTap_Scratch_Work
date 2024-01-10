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

import 'package:flutter/rendering.dart';
import 'package:learn_flutter/widgets/Constant.dart';

void main() {
  runApp(MyApp());
}

//new stuff

//inside this

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
  List<String> suggestions = [];
  String selectedFilter = '';
  late FocusNode _searchFocusNode;
  late SearchDatabaseHelper _databaseHelper;
  bool isSearching = true;
  String location = 'Gwalior';

  Map<int, bool> categoryLoadingStates = {};

  List<Map<String, dynamic>> categoryData = [
    ...generateCategoryData(name: 'Near You', apiEndpoint: '/api/search'),
    ...generateCategoryData(
        name: 'LifeStyle', apiEndpoint: '/api/stories/best/genre/Lifestyle'),
    ...generateCategoryData(
        name: 'Most Trending Visits', apiEndpoint: '/api/stories/best'),
    ...generateCategoryData(
        name: 'Historical/Heritage',
        apiEndpoint: '/api/stories/best/genre/Historical/Heritage'),
    ...generateCategoryData(
        name: 'Art & Culture/Museum',
        apiEndpoint: '/api/stories/best/genre/Art & Culture'),
    ...generateCategoryData(
        name: 'Wildlife attractions',
        apiEndpoint: '/api/stories/best/genre/WildLife attractions'),
    ...generateCategoryData(
        name: 'Advanture Places',
        apiEndpoint: '/api/stories/best/genre/Advanture Places'),
    ...generateCategoryData(
        name: 'Festival', apiEndpoint: '/api/stories/best/genre/Festival'),
    ...generateCategoryData(
        name: 'Fashion', apiEndpoint: '/api/stories/best/genre/Fashion'),
    ...generateCategoryData(
        name: 'Market', apiEndpoint: '/api/stories/best/genre/Market'),
  ];

  Future<List<String>> fetchSuggestions(String query) async {
    final String serverUrl = Constant().serverUrl;
    final apiUrl = '$serverUrl/api/suggestions?query=$query';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('here is the response');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        print(jsonResponse);
        final List<String> suggestionsList =
            List<String>.from(jsonResponse['suggestions']);
        setState(() {
          suggestions = suggestionsList;
        });

        return suggestionsList;
      } else {
        print('Error fetching suggestions: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error fetching suggestions: $error');
      return [];
    }
  }

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
        isLoading = false;
      });
    } else {
      print('Error fetching suggestions: ${response.statusCode}');
    }
  }

  Future<void> fetchDataForCategory(double latitude, double longitude,
      int categoryIndex, String searchQuery) async {
    try {
      final Map<String, dynamic> category = categoryData[categoryIndex];
      String apiEndpointsmall = category['apiEndpoint'];

      String apiEndpoint = "$apiEndpointsmall/$selectedFilter/$searchQuery";

      print('apiENdpoint hai yeh');
      print(apiEndpointsmall);
      print(apiEndpoint);

      final fetchedStoryList =
          await fetchDataForStories(latitude, longitude, apiEndpoint);

      Map<String, dynamic> processedData =
          processFetchedStories(fetchedStoryList, latitude, longitude);

      // Update the category data with the fetched information
      categoryData[categoryIndex]['storyUrls'] =
          processedData['totalVideoPaths'];
      categoryData[categoryIndex]['videoCounts'] =
          processedData['totalVideoCounts'];
      categoryData[categoryIndex]['storyDistance'] =
          processedData['storyDistances'];
      categoryData[categoryIndex]['storyLocation'] =
          processedData['storyLocations'];
      categoryData[categoryIndex]['storyTitle'] = processedData['storyTitles'];
      categoryData[categoryIndex]['storyCategory'] =
          processedData['storyCategories'];
      categoryData[categoryIndex]['thumbnail_url'] =
          processedData['thumbnail_urls'];
      categoryData[categoryIndex]['storyDetailsList'] =
          processedData['storyDetailsList'];

      setState(() {
        isLoading = false;
      });

      print(
          'Video counts per story in category $categoryIndex: ${processedData['totalVideoCounts']}');
      print(
          'All video paths in category $categoryIndex: ${processedData['totalVideoPaths']}');
      print('storyurls');
      print(categoryData[categoryIndex]['storyUrls']);
    } catch (error) {
      print('Error fetching stories for category $categoryIndex: $error');
      setState(() {
        categoryLoadingStates[categoryIndex] = false;
      });
    }
  }

  Future<void> updateLiveLocation(
      String userId, double liveLatitude, double liveLongitude) async {
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

  Future<void> fetchUserLocationAndData() async {
    setState(() {
      isLoading = false;
      categoryData.clear();
    });

    categoryData = [
      ...generateCategoryData(name: 'NearBy You', apiEndpoint: '/api/search'),
      ...generateCategoryData(
          name: 'LifeStyle', apiEndpoint: '/api/stories/best/genre/Lifestyle'),
      ...generateCategoryData(
          name: 'Most Trending Visits', apiEndpoint: '/api/stories/best'),
      ...generateCategoryData(
          name: 'Historical/Heritage',
          apiEndpoint: '/api/stories/best/genre/Historical/Heritage'),
      ...generateCategoryData(
          name: 'Art & Culture/Museum',
          apiEndpoint: '/api/stories/best/genre/Art & Culture'),
      ...generateCategoryData(
          name: 'Wildlife attractions',
          apiEndpoint: '/api/stories/best/genre/WildLife attractions'),
      ...generateCategoryData(
          name: 'Advanture Places',
          apiEndpoint: '/api/stories/best/genre/Advanture Places'),
      ...generateCategoryData(
          name: 'Festival', apiEndpoint: '/api/stories/best/genre/Festival'),
      ...generateCategoryData(
          name: 'Fashion', apiEndpoint: '/api/stories/best/genre/Fashion'),
      ...generateCategoryData(
          name: 'Market', apiEndpoint: '/api/stories/best/genre/Market'),
    ];

    print('I called');

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      String query = _searchController.text;

      updateLiveLocation(userID, position.latitude, position.longitude);

      print('Latitude is: $latitude');

      // Fetch stories for each category

      if (!query.isNotEmpty) {
        print('wow');
      } else {
        for (int i = 0; i < categoryData.length; i++) {
          await fetchDataForCategory(
              latitude, longitude, i, _searchController.text);
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
    print('suggestions fetched');

    print('here is iss');
    _searchFocusNode = FocusNode();
    _searchFocusNode.requestFocus();
    _databaseHelper = SearchDatabaseHelper();

    fetchDataFromMongoDB();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isVisible = true;
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isVisible = false;
        });
      }
    });
    setState(() {
      selectedFilter = 'Location';
    });
  }

  Future<void> onSuggestionSearch(String suggestion) async {


    // Perform the search based on the selected suggestion
    await updateSuggestions(suggestion, selectedFilter);



  }


  //updated code from here

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshSearchPage() async {
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
          onRefresh: _refreshSearchPage,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SliverAppBar(
              //   title: ProfileHeader(reqPage: 0, userId: userID, userName: userName),
              //   automaticallyImplyLeading: false,
              //   shadowColor: Colors.transparent,
              //   toolbarHeight: 90,
              //   // Adjust as needed
              //   floating: true,
              //   pinned: false,
              //   flexibleSpace: FlexibleSpaceBar(
              //
              //     // You can add more customization to the flexible space here
              //   ),
              // ),

              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // Your other widgets here
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),
                        Container(
                          margin: EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: Column(
                            children: [
                              TextFormField(
                                focusNode: _searchFocusNode,
                                controller: _searchController,
                                onChanged: (query) {
                                  fetchSuggestions(_searchController.text);
                                  isLoading = true;
                                },
                                onEditingComplete: () {
                                  requestLocationPermission();
                                  FocusScope.of(context).unfocus();
                                  fetchUserLocationAndData();

                                  setState(() {
                                    isSearchInitiated = true;

                                  });
                                },
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
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
                                  hintText:
                                      'Search here your Mood, Food, Places...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Icon(Icons.search,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        FiltersWithHorizontalScroll(
                          selectedFilter: selectedFilter,
                          onFilterSelected: (filter) {
                            setState(() {
                              selectedFilter = filter;
                              isLoading = true;
                              // Set loading state when changing the filter
                            });
                            fetchUserLocationAndData(); // Fetch data based on the new filter
                          },
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                    if (!_searchController.text.isEmpty)
                      isLoading
                          ? SuggestionList(
                        suggestions: suggestions,
                        searchController: _searchController,
                        onSuggestionSelected: (selectedSuggestion) async {
                          // Handle the selected suggestion
                          print('Selected suggestion: $selectedSuggestion');

                          // Set the search input value
                          _searchController.text = selectedSuggestion;


                          await onSuggestionSearch(selectedSuggestion);

                        },
                        onSuggestionSearch: (query) async {

                          print('Performing search for: $query');

                          setState(() {

                            isLoading = true;

                          });
                          fetchUserLocationAndData();


                          // Add your search logic here
                        },
                      )
                          : Column(
                              children:
                                  categoryData.asMap().entries.map((entry) {
                                final int categoryIndex = entry.key;
                                final Map<String, dynamic> category =
                                    entry.value;

                                final bool categoryLoading =
                                    categoryLoadingStates[categoryIndex] ??
                                        false;
                                final String specificCategoryName =
                                    category['specificName'];

                                final String categoryName = category['name'];
                                final String whereTo = 'search';
                                final List<String> storyUrls =
                                    category['storyUrls'];
                                final List<String> videoCounts =
                                    category['videoCounts'];
                                final List<String> storyDistance =
                                    category['storyDistance'];
                                final List<String> storyLocation =
                                    category['storyLocation'];
                                final List<String> storyCategory =
                                    category['storyCategory'];
                                final List<String> storyTitle =
                                    category['storyTitle'];
                                List<Map<String, dynamic>> storyDetailsList =
                                    category['storyDetailsList'];

                                return buildCategorySection(
                                  specificCategoryName,
                                  categoryName,
                                  whereTo,
                                  storyUrls,
                                  videoCounts,
                                  storyDistance,
                                  storyLocation,
                                  storyTitle,
                                  storyCategory,
                                  storyDetailsList,
                                  categoryLoading,
                                );
                              }).toList(),
                            ),
                    if (_searchController.text.isEmpty)
                      SuggestionList(
                        suggestions: suggestions,
                        searchController: _searchController,
                        onSuggestionSearch: (sugg){

                        },
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
          child: CustomFooter(
            userName: userName,
            userId: userID,
            lode: 'home',
          ),
        ),
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
            FilterButton('Location',
                selected: selectedFilter == 'Location',
                onPressed: onFilterSelected),
            FilterButton('Stories',
                selected: selectedFilter == 'Stories',
                onPressed: onFilterSelected),
            FilterButton('Profiles',
                selected: selectedFilter == 'Profiles',
                onPressed: onFilterSelected),
          ],
        ),
      ),
    );
  }
}
