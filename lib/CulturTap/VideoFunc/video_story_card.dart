// video_story_card.dart

import 'package:flutter/material.dart';

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