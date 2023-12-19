//category_section_builder

import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/StoryDetailPage.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/Dummy/videoStoryCardDummy.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/video_story_card.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';


String previousSpecific = '';

Widget buildCategorySectionDummy( String specificCategoryName, String categoryName, List<String> storyUrls, List<String> videoCounts, List<String> storyDistance, List<String> storyLocation, List<String> storyTitle, List<String> storyCategory, List<Map<String, dynamic>> storyDetailsList,) {

  // if (isLoading) {
  //   // Show loader while the category is still loading
  //   return Container(
  //     color: Colors.white,
  //     child: Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
  // }



  if(previousSpecific == specificCategoryName){
    specificCategoryName = '';
  }
  previousSpecific = specificCategoryName;


  return Builder(
    builder: (context) {
      return Container(
        color: Theme.of(context).backgroundColor,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Padding(
              padding: EdgeInsets.only(left:23.0,right:20,top:18,bottom:10),
              child: Column(
                children: [

                  if(specificCategoryName!='')
                    Column(
                      children: [
                        SizedBox(height : 10),
                        Row(


                        ),
                        SizedBox(height : 10),
                      ],
                    ),



                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height : 40,
                        width : 150,

                        color: Theme.of(context).primaryColorLight,
                      ),
                      Container(
                        height : 30,
                        width : 100,

                        color: Theme.of(context).primaryColorLight,
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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => StoryDetailPage(
                      //       storyUrls: storyUrls,
                      //       storyDetailsList: storyDetailsList,
                      //       initialIndex: index,
                      //     ),
                      //   ),
                      // );

                    },
                    child: VideoStoryCardDummy(
                      videoUrl: storyUrls[index],
                      distance: storyDistance[index],
                      videoCount: videoCounts[index],
                      location : storyLocation[index],

                      category : storyCategory[index],
                      title : storyTitle[index],



                    ),
                  );
                },
              ),
            ),

          ],
        ),
      );
    }
  );
}

