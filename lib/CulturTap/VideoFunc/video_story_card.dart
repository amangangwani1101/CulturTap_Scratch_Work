// video_story_card.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoStoryCard extends StatefulWidget {
  final String videoUrl;
  final String distance;
  final String videoCount;
  final String location;
  final String category;
  final String title;

  VideoStoryCard({
    required this.videoUrl,
    required this.distance,
    required this.videoCount,
    required this.location,
    required this.category,
    required this.title,
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
    thumbnail = Image.asset('assets/images/home_back_url.png');
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
    print('fullThumbnailUrl$fullThumbnailUrl');

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
        print('Failed to fetch thumbnail: ${thumbnailResponse.statusCode}');
        setState(() {
          thumbnail = Image.asset('assets/images/home_back_url.png'); // Replace with the actual path
        });
      }
    } catch (error) {
      print('Error fetching thumbnail: $error');
      setState(() {
        thumbnail = Image.asset('assets/images/home_back_url.png'); // Replace with the actual path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 500,
          width: 280,
          margin: EdgeInsets.all(8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
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
                    children: [
                      Icon(
                        Icons.video_library,
                        color: Colors.white,
                        size: 24,
                      ),
                      Text(
                        ' +${widget.videoCount}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          height: 70,
          width: 280,
          padding: EdgeInsets.all(10),
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
