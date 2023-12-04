// video_story_card.dart
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

class VideoStoryCardDummy extends StatefulWidget {
  final String videoUrl;
  final String distance;
  final String videoCount;
  final String location;
  final String category;
  final String title;

  VideoStoryCardDummy({
    required this.videoUrl,
    required this.distance,
    required this.videoCount,
    required this.location,
    required this.category,
    required this.title,
  });

  @override
  _VideoStoryCardDummyState createState() => _VideoStoryCardDummyState();
}

class _VideoStoryCardDummyState extends State<VideoStoryCardDummy> {


  @override
  void initState() {
    super.initState();

    
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 500,
          width: 280,
          margin: EdgeInsets.only(left : 16,top:8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/home_back.png',
                      fit: BoxFit.fill, // Change BoxFit.cover to BoxFit.fill
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle,
                      color: Colors.white70,
                      size: 64,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -8,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF263238),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.turn_right,
                        color: Colors.white,
                        size: 18,
                      ),
                      Text(
                        '${widget.distance} km',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                right: 15,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF263238),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/images/videoasset.svg', // Replace with the path to your SVG icon

                        width: 24,
                        height: 24,


                      ),
                      SizedBox(width :2),
                      Text(
                        ' +${widget.videoCount}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   bottom: -5,
              //   right: -10,
              //   child: Container(
              //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              //     decoration: BoxDecoration(
              //       color: Color(0xFF263238),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Row(
              //       children: [
              //         Icon(
              //           Icons.video_library,
              //           color: Colors.white,
              //           size: 24,
              //         ),
              //         Text(
              //           ' +${widget.videoCount}',
              //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Positioned(
                top: 35,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Local',style:TextStyle(color:Colors.white,fontSize: 14)),
                      Text(
                        '${widget.location}',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold,fontSize: 16,),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(    border: Border(
            left: BorderSide(width: 0.1, color: Colors.blueGrey),   // Border on the left side
            right: BorderSide(width: 0.1, color: Colors.blueGrey),  // Border on the right side
            bottom: BorderSide(width: 0.1, color: Colors.blueGrey), // Border on the bottom side
          ),),
          height: 70,
          width: 280,
          padding: EdgeInsets.only(left:10,right : 10,top:10, bottom : 5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Title ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                      ),
                      Text(
                        ' ${widget.title}',
                        style: TextStyle(color: Color(0xFF263238)),
                      ),
                    ],
                  ),
                  Container(
                    width: 65,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.remove_red_eye_sharp,
                          color: Colors.grey,
                          size: 24,
                        ),
                        Text(
                          '89.0K',
                          style: TextStyle(color: Color(0xFF263238)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Category ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                      ),
                      Text(
                        ' ${widget.category}',
                        style: TextStyle(color: Color(0xFF263238)),
                      ),
                    ],
                  ),
                  Container(
                    width: 65,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.heart_broken,
                          color: Colors.grey,
                          size: 24,
                        ),
                        Text(
                          '700.5k',
                          style: TextStyle(color: Color(0xFF263238)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
