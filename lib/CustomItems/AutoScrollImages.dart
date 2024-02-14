import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AutoScrollImages extends StatefulWidget {
  final List<String> imageUrls;
  String? format = '';

  AutoScrollImages({required this.imageUrls,this.format});

  @override
  _AutoScrollImagesState createState() => _AutoScrollImagesState();
}

class _AutoScrollImagesState extends State<AutoScrollImages> {
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_pageController.page == widget.imageUrls.length - 1) {
        _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 000),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: Duration(milliseconds: 2000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      height: 500,
      color:Colors.transparent,


      child: GestureDetector(
        onTap: () {
          // Stop auto-scrolling on user interaction
          _timer?.cancel();
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            return

            Container(padding:EdgeInsets.only(left:22,right:22,top:20,bottom:30),


              child: Container(
                decoration: BoxDecoration(

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      spreadRadius: 0.2, // Spread radius
                      blurRadius: 0.3, // Blur radius
                      offset: Offset(0, 0.4), // Offset (horizontal, vertical)
                    ),
                  ],

                ),
                child: Container(
                  color: widget.format == 'black'?Colors.transparent:Colors.white,
                  child: Image.network(

                    widget.imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ));






          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}