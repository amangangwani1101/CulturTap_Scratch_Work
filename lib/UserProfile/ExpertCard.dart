import 'package:flutter/material.dart';
import '../widgets/hexColor.dart';


// Expert Cards -> User Experiences Section Have To Work
class ExpertCardDetails extends StatelessWidget{
  List<String> expertLocations = [];
  String profileStatus = "Out Standing";
  int visitedplace = 0,coveredLocation = 0, ratings = 0;
  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        // border: Border.all(
        //   color: Colors.white70,
        //   width: 2,
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            // offset: Offset(0.0,0.0),
            blurRadius: 5.0,
            spreadRadius: 7.9,
          ),
          BoxShadow(
            color: Colors.white,
            // offset: Offset(0.0,0.0),
            blurRadius:5,
            spreadRadius: 12.9,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),

        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Expert Cards' ,style: Theme.of(context).textTheme.subtitle1,),
                IconButton(onPressed: (){}, icon: Icon(Icons.share_outlined, color : Theme.of(context).primaryColor,)),
              ],
            ),
            SizedBox(height : 10),
            Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expert in locations -',style: Theme.of(context).textTheme.subtitle1,),

                    Container(
                      width : 170,
                      child: expertLocations.isEmpty ? Text('NA', style: Theme.of(context).textTheme.headline6,):
                      Wrap(
                        runSpacing: 8.0, // Vertical spacing between lines of items
                        children: [
                          Row(
                            children: [
                              for (int i = 0; i < expertLocations.length; i++)
                                Container(
                                  margin: EdgeInsets.only(right: 8.0),
                                  child: Row(
                                    children: [
                                      Text(expertLocations[i]),
                                      if (i < expertLocations.length - 1)
                                        Text(',', style: Theme.of(context).textTheme.headline6,),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Visited Places - ', style: Theme.of(context).textTheme.subtitle1,),

                    Container( width : 170,
                        child: Text('${visitedplace}', style: Theme.of(context).textTheme.headline6,)),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Covered Locations - ', style: Theme.of(context).textTheme.subtitle1,),

                    Container( width : 170,
                        child: Text('${coveredLocation}', style: Theme.of(context).textTheme.headline6,)),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expertise Rating - ', style: Theme.of(context).textTheme.subtitle1,),

                    Container(
                      width : 170,
                      child: ratings == 0
                          ? Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star,color: HexColor('#FB8C00'),),
                            SizedBox(width: 5),
                            Text('NA'),
                          ],
                        ),
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(ratings, (index) {
                          return Icon(Icons.star, color: HexColor('#FB8C00'));
                        }),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40,),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Culturtap Status',style: Theme.of(context).textTheme.subtitle1,),

                    Container(
                      width : 170,
                      child: visitedplace==0 || coveredLocation==0?
                      Text('NA',style: TextStyle(color: HexColor('#0A8100'),fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),):
                      Text(profileStatus,style: TextStyle(color: HexColor('#0A8100'),fontWeight: (FontWeight.w800),fontFamily: 'Poppins'),),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
