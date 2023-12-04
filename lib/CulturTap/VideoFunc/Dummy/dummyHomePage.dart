import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/Dummy/buildCategorySectionDummy.dart';





class DummyHomePage extends StatelessWidget {
  ScrollController _scrollController = ScrollController();
  @override


  List<Map<String, dynamic>> categoryData = [
    {
      'specificName': '',
      'name': 'Trending NearBy',
      'apiEndpoint': '/main/api/trending-nearby-places',
      'storyUrls': <String>['','','',''],
      'videoCounts': <String>['','','',''],
      'storyDistance' : <String>['','','',''],
      'storyLocation' : <String>['','','',''],
      'storyTitle' : <String>['','','',''],
      'storyCategory' : <String>['','','',''],

      'storyDetailsList': <Map<String, dynamic>>[],

    },
    {
      'specificName': 'Trending Visits in Nation',
      'name': '',
      'apiEndpoint': '/nation/api/trending-visits-in-nation',
      'storyUrls': <String>['','','',''],
      'videoCounts': <String>['','','',''],
      'storyDistance' : <String>['','','',''],
      'storyLocation' : <String>['','','',''],
      'storyTitle' : <String>['','','',''],
      'storyCategory' : <String>['','','',''],

      'storyDetailsList': <Map<String, dynamic>>[],
    },
    //
  ];

  Widget build(BuildContext context) {


    return  Column(
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

          return buildCategorySectionDummy(
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
      );
  }






void main() {
  runApp(MaterialApp(
    home: DummyHomePage(),
  ));
}}
