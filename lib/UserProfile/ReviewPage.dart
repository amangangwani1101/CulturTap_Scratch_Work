import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../BackendStore/BackendStore.dart';
import '../widgets/hexColor.dart';


// Ratings If Available Else Default
class RatingSection extends StatefulWidget {
  final List<RatingEntry> ratings;
  final reviewCnt;
  final String? name;
  final ProfileDataProvider? profileDataProvider;
  RatingSection({required this.ratings,required this.reviewCnt,this.profileDataProvider,this.name});

  @override
  _RatingSectionState createState() => _RatingSectionState();
}
class _RatingSectionState extends State<RatingSection> {
  bool showAllRatings = false;

  @override
  Widget build(BuildContext context) {
    List<RatingEntry> displayedRatings =
    showAllRatings ? widget.ratings : widget.ratings.take(2).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth,
      padding: EdgeInsets.only(left: 15,right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            // color: Colors.orange,
            child: Text(
              'Reviews About ${widget.name==null?'you':widget.name} ( ${widget.reviewCnt} )',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          SizedBox(height: 9),
          widget.reviewCnt==0?
          Text('You did’t receive any review or feedback yet. ',
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins'
            ),)
              :Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: displayedRatings.map((rating) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 19,),
                      Text(
                        rating.name!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 14,fontFamily: 'Poppins'
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          if(index<rating.count!)
                            return Icon(Icons.star, color: HexColor('#FB8C00'),size: 17,);
                          else
                            return Icon(Icons.star, color: Colors.grey,size: 17,);
                        }),
                      ),
                      Text(rating.comment!,style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                    ],
                  );
                }).toList(),
              ),
          if (widget.reviewCnt!=0 && widget.ratings.length > 2)
            GestureDetector(
              onTap: (){
                setState(() {
                  showAllRatings = !showAllRatings;
                });
              },
              child: Text(showAllRatings ? 'Show Less' : 'View All',style: TextStyle(fontSize: 14,fontFamily:'Poppins',color: HexColor('#FB8C00'),fontWeight: FontWeight.bold),),
            ),
        ],
      ),
    );
  }
}
