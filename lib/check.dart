import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/CulturTap/VideoFunc/categoryData.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/category_section_builder.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/data_service.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/process_fetched_stories.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/HomePage.dart';
import 'package:learn_flutter/SearchEngine/SearchDatabaseHelper.dart';
import 'package:learn_flutter/widgets/Constant.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  late List<Map<String, dynamic>> categoryData;
  late FocusNode _searchFocusNode;
  TextEditingController _searchController = TextEditingController();
  List<String> suggestions = [];
  String selectedFilter = 'Location';
  late SearchDatabaseHelper _databaseHelper;
  bool isSearching = true;
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchFocusNode.requestFocus();
    _databaseHelper = SearchDatabaseHelper();
    updateSuggestions('','');
    fetchingStoriesForLocation('india');

  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
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
      setState(() {

      });
    }
  }




  void fetchingStoriesForLocation(String location){
    print('printitng story user ID hahahaha');

    print(location);
    categoryData = [
      ...generateCategoryData(name: 'Most Recent Visits', apiEndpoint: 'api/stories/best/location/$location'),
      // ...generateCategoryData(name: 'Solo Trips', apiEndpoint: 'api/stories/user/$location/category/Solo trip'),
      // ...generateCategoryData(name: 'Trip With Friends', apiEndpoint: 'api/stories/user/$location/category/Trip With Friends'),
      // ...generateCategoryData(name: 'Trip With Family', apiEndpoint: 'api/stories/user/$location/category/Trip With Family'),
      // ...generateCategoryData(name: 'Food And Restaurants', apiEndpoint: 'api/stories/user/$location/genres/Street Foods,Restaurants'),
      // ...generateCategoryData(name: 'Fashion', apiEndpoint: 'api/stories/user/$location/genres/Fashion'),

    ];

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


  Future<void> _refreshHomepage() async {



  }


  @override
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


              SliverList(
                delegate: SliverChildListDelegate(
                  [

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
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: suggestions.map((suggestion) {
                                return Container(
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.watch_later_outlined, size: 25, color: Theme.of(context).primaryColor),
                                            onPressed: () {},
                                          ),
                                          Text(
                                            suggestion,
                                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.watch_later_outlined, size: 25, color: Theme.of(context).primaryColor),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),





                      ],
                    ),

                    isLoading ? Container(
                      height : 500,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(child: CircularProgressIndicator(color : Theme.of(context).primaryColor,)),
                        ],
                      ),
                    ) :
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
                          true,

                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

        ),
        bottomNavigationBar: AnimatedContainer(
          duration: Duration(milliseconds: 100),


          height : 70,
          child: CustomFooter(),
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
              onSearch(controller.text);
            },
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.black),
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
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

            FilterButton('Location', selected: selectedFilter == 'Location', onPressed: onFilterSelected),
            FilterButton('Profiles', selected: selectedFilter == 'Profiles', onPressed: onFilterSelected),
            FilterButton('Stories', selected: selectedFilter == 'Stories', onPressed: onFilterSelected),
          ],
        ),
      ),
    );
  }
}




class FilterButton extends StatelessWidget {
  final String filterName;
  final bool selected;
  final Function(String) onPressed;

  FilterButton(this.filterName, {required this.selected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left : 16),
      child: ElevatedButton(
        onPressed: () {
          onPressed(filterName);
        },
        style: ElevatedButton.styleFrom(
          primary: selected ? Colors.orange : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.0),
            side: BorderSide(
              color : selected ? Colors.transparent : Colors.black, // Set the border color
              width: 0.5,          // Set the border width
            ),
            // Adjust the value as needed
          ),
          elevation: 0.0,
        ),
        child: Row(
          children: [
            Icon(
              Icons.sports_baseball_sharp, // Use the Icons class for Material Design icons
              size: 10.0, // Set the size of the icon
              color: Colors.yellow, // Set the color of the icon
            ),

            Text(
              filterName,
              style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}