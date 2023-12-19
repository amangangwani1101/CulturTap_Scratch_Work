//category_section_builder

import 'package:flutter/material.dart';
import 'package:learn_flutter/CulturTap/StoryDetailPage.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/video_story_card.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';


String previousSpecific = '';

Widget buildCategorySection( String specificCategoryName, String categoryName, List<String> storyUrls, List<String> videoCounts, List<String> storyDistance, List<String> storyLocation, List<String> storyTitle, List<String> storyCategory, List<Map<String, dynamic>> storyDetailsList,bool isLoading, ) {

  // if (isLoading) {
  //   // Show loader while the category is still loading
  //   return Container(
  //     color: Colors.white,
  //     child: Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
  // }


  if (storyUrls.isEmpty || storyDistance.isEmpty) {
    return SizedBox.shrink(); // Return an empty container if there's no data
  }

  if(previousSpecific == specificCategoryName){
    specificCategoryName = '';
  }
  else{
    previousSpecific = specificCategoryName;
  }



  return Builder(
    builder: (context) {
      return Container(
        color: Theme.of(context).backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Padding(
              padding: EdgeInsets.only(left:18.0,right:10,top:18,bottom:10),
              child: Column(
                children: [

                  if(specificCategoryName!='')
                    Column(
                      children: [
                        SizedBox(height : 10),
                        Row(

                          children: [
                            Container(
                              width : 240,
                              child: Text(
                                specificCategoryName,
                                style: Theme.of(context).textTheme.headline1,
                              ),
                            ),


                          ],
                        ),
                        SizedBox(height : 10),
                      ],
                    ),



                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        categoryName,
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoryDetailPage(
                                storyUrls: storyUrls,
                                storyDetailsList: storyDetailsList,
                                initialIndex: 07,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'View All >',
                          style: Theme.of(context).textTheme.headline4,
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
                      title : storyTitle[index],
                      storyDetails : storyDetailsList[index],



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

