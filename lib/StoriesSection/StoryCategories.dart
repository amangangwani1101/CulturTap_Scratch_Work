import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../BackendStore/BackendStore.dart';
import '../widgets/hexColor.dart';


// Story Sliders
class CardSlider extends StatefulWidget {
  final List<CardItem> cards;
  final String category;
  CardSlider({required this.category,required this.cards});

  @override
  _CardSliderState createState() => _CardSliderState();
}
class _CardSliderState extends State<CardSlider> {
  int currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: currentIndex,
      viewportFraction: 0.8, // Adjust the viewportFraction for card width
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 590,
        // decoration: BoxDecoration(
        //   border: Border.all(
        //     color: Colors.black,
        //     width: 1,
        //   ),
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 370,
              height: 50,
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //     width: 1,
              //   ),
              // ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.category,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllCardsPage(cards: widget.cards),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text('View All',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: HexColor('#FB8C00')),),
                        Icon( Icons.arrow_forward_ios, size: 12,color: HexColor('#FB8C00'),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 479,
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.right,
                color: HexColor('#FB8C00'), // Set the color to your desired color
                showLeading: true, // Set to false to disable the leading glow effect
                showTrailing: true, child: ListView(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                children: widget.cards.map((card) {
                  return SizedBox(
                    width: 279,
                    child: CardItemWidget(card: card),
                  );
                }).toList(),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Single Story Loading
class CardItemWidget extends StatelessWidget {
  final CardItem card;

  CardItemWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.black,
      //     width: 1,
      //   ),
      // ),
      child: Stack(
        children: [
          Center(
            child: Image.network(
              card.image,
              height: 440, // Adjust the image height as needed.
              width: 257, // Set image width to match card width.
              fit: BoxFit.cover,
              // Make the image cover the whole space.
            ),
          ),
          Positioned(
            top: 7,
            right:20,
            child: Container(
              width: 73,
              height: 21,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: HexColor('#263238'),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/arrow.png',width: 15,height: 10,fit: BoxFit.cover,),
                  Text(' ${card.distance} KM',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white),),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 57,
            right:20,
            child: Container(
              width: 63,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: HexColor('#263238'),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/video_bar.png',width: 17,height: 17,fit: BoxFit.cover,),
                  Text('+${card.countVideos}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white),),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            child: Container(
              width: 277,
              height: 56,
              color: HexColor('#FFFFFF'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Text('Category',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${card.location}',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                      Text('${card.category}',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon( Icons.remove_red_eye_outlined,size: 15,),
                          Text('${card.viewCnt}',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset('assets/images/heart_like.png',width: 13,height: 12,fit: BoxFit.cover,),
                          Text('${card.likes}',style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// View All Trigger
class AllCardsPage extends StatelessWidget {
  final List<CardItem> cards;

  AllCardsPage({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Cards'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var card in cards) Container(
                width: 279,
                child: CardItemWidget(card: card)),
          ],
        ),
      ),
    );
  }
}


// Categories
class VisitsSection extends StatelessWidget{
  List<String>categories = ['Most recent visits','local visits','Nearby Outings',
    'Solo trips','trips with family',
    'trips with friends','Attended Festivals',
    'food and restaurants','Pubs & Bars','Fashion'];

  List<CardItem> cards = [CardItem(
    // videoUrl: 'http://techslides.com/demos/sample-videos/small.mp4',
    image: 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg',
    viewCnt:  2112,
    location: 'HSR Layout, Sector 4',
    category: 'family Visit',
    likes: 21,
    countVideos: 3,
    distance: '1.9',
  ), CardItem(
    // videoUrl: 'http://techslides.com/demos/sample-videos/small.mp4',
    image: 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg',
    viewCnt:  2112,
    location: 'HSR Layout, Sector 4',
    category: 'family Visit',
    likes: 21,
    countVideos: 4,
    distance: '2.9',
  ), CardItem(
    // videoUrl: 'http://techslides.com/demos/sample-videos/small.mp4',
    image: 'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg',
    viewCnt:  2112,
    location: 'HSR Layout, Sector 4',
    category: 'family Visit',
    likes: 21,
    countVideos: 4,
    distance: '0.7',
  ),];

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < categories.length; i++)
            Container(
              // width: 279,
              child: CardSlider(
                category: categories[i],
                cards: cards,
              ),
            ),
        ],
      ),
    );
  }
}
