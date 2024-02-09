// video_story_card.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

class VideoStoryCard extends StatefulWidget {
  final String videoUrl;
  final String distance;
  final String videoCount;
  final String location;
  final String category;
  final String title;
  final Map<String, dynamic> storyDetails;

  VideoStoryCard({
    required this.videoUrl,
    required this.distance,
    required this.videoCount,
    required this.location,
    required this.category,
    required this.title,
    required this.storyDetails,
  });

  @override
  _VideoStoryCardState createState() => _VideoStoryCardState();
}

class _VideoStoryCardState extends State<VideoStoryCard> {
  late Image thumbnail;

  // Cache map to store fetched thumbnails
  final Map<String, Image> thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    thumbnail = Image.asset('assets/images/home_back.png');
    _fetchThumbnail(widget.videoUrl);
  }

  Future<void> _fetchThumbnail(String thumbnailPath) async {
    // Check if the thumbnail is already in the cache
    if (thumbnailCache.containsKey(thumbnailPath)) {
      setState(() {
        thumbnail = thumbnailCache[thumbnailPath]!;
      });
      return;
    }

    String fullThumbnailUrl = 'http://173.212.193.109:8080/thumbnails/$thumbnailPath';
    print('this is full thumbnail url');
    print(fullThumbnailUrl);


    try {
      var thumbnailResponse = await http.get(Uri.parse(fullThumbnailUrl));
      if (thumbnailResponse.statusCode == 200) {
        // Cache the fetched thumbnail
        final newThumbnail = Image.network(fullThumbnailUrl);
        thumbnailCache[thumbnailPath] = newThumbnail;

        setState(() {
          thumbnail = newThumbnail;
        });
      } else {
        // print('Failed to fetch thumbnail: ${thumbnailResponse.statusCode}');
        setState(() {
          thumbnail = Image.asset('assets/images/home_back.png'); // Replace with the actual path
        });
      }
    } catch (error) {
      print('Error fetching thumbnail: $error');
      setState(() {
        thumbnail = Image.asset('assets/images/home_back.png'); // Replace with the actual path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 500,
          width: 300,
          margin: EdgeInsets.only(left : 16,top:8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Image(
                      image: thumbnail.image,
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
                    color: Theme.of(context).primaryColorDark,
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
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),
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
                    color: Theme.of(context).primaryColorDark,
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
              //       color: Color(0xFF001B33),
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
                      Text('Location',style:TextStyle(color:Colors.white,fontSize: 14)),
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
          width: 300,
          margin: EdgeInsets.only(left : 12,),
          padding: EdgeInsets.only(left:10,right : 8,top:10, bottom : 5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Title ',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        ' ${widget.title}',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                  Container(
                    width: 65,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(
                          'assets/images/eyeview.svg', // Replace with the path to your SVG file
                          color : Theme.of(context).primaryColor,
                          height : 24,
                          width : 24,
                        ),
                        Text(
                         '${widget.storyDetails['views']!}',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height : 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Category ',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        ' ${widget.category}',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                  Container(
                    width: 65,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(
                          'assets/images/heart.svg', // Replace with the path to your SVG file
                          // color: Color(0xFF001B33),
                          height : 20,
                          width : 24,
                        ),
                        Text(
                          '${widget.storyDetails['likes']!}',
                          style:Theme.of(context).textTheme.bodyText2,
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
