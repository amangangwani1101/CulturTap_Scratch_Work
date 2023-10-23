import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:learn_flutter/widgets/sample.dart';
import '../BackendStore/BackendStore.dart';
import 'hexColor.dart';
import '../UserProfile/ProfileHeader.dart';



class CustomHelpOverlay extends StatelessWidget {

  final String imagePath;
  bool? serviceSettings=false;
  final ProfileDataProvider? profileDataProvider;
  CustomHelpOverlay({required this.imagePath,this.serviceSettings,this.profileDataProvider});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.grey.withOpacity(0),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              width: screenWidth*0.90,
              height: 315,
              // child: Align(
              //   alignment: Alignment.topRight,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //     child: (Icon(Icons.crop_sharp)),
              //   ),
              // ),

              child: Container(
                child: Stack(
                  children: [
                    Center(child: Image.asset(imagePath,width: 361,height: 281,fit: BoxFit.contain,),),
                    Positioned(
                      top: 15,
                      right: 15,
                      child:IconButton(
                        icon: Icon(Icons.close),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    if (serviceSettings!) Container(
                        height: 250,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> ServicePage(profileDataProvider:profileDataProvider)));
                              },
                              child: Text('Continue',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.orange,),)),
                        ),
                      ) else SizedBox(width: 0,)
                  ],
                ),
              ),


            ),
          ),
        ],
      ),
    );
  }
}
class ServicePage extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  ServicePage({this.profileDataProvider});
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage>{
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Set the preferred height to 0
        child: AppBar(
          elevation: 0, // Remove the shadow
          backgroundColor: Colors.transparent, // Make the background transparent
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(reqPage: 1),
            Container(
              height:screenHeight*0.85,
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //     width: 1,
              //   ),
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
                  Container(
                    height: 361,
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.orange,
                    //     width: 2,
                    //   )
                    // ),
                    child: Column(
                      children: [
                        Container(
                          width:318,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Timing for interaction calls',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                              Text('Select Your Time',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),)
                            ],
                          ),
                        ),
                        TimePicker(profileDataProvider:widget.profileDataProvider),
                      ],
                    ),
                  ),
                  BandWidthSelect(profileDataProvider:widget.profileDataProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimePicker extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  TimePicker({this.profileDataProvider});
  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker>{
  TimeOfDay _startTime = TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 21,minute:0);

  Future<void> _selectStartTime(BuildContext context) async{
    final pickedTime = await showTimePicker(
      context: context, initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if(pickedTime!=null){
      setState(() {
        _startTime = pickedTime;
        widget.profileDataProvider?.setStartTime(_formatTime(pickedTime));
        print(pickedTime);
        print("Start Time: ${_formatTime(_startTime)}");
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    // Format the hour to 12-hour format
    if (hour > 12) {
      hour -= 12;
    }

    String minuteStr = minute < 10 ? '0$minute' : '$minute';

    return '$hour:$minuteStr $period';
  }

  Future<void> _selectEndTime(BuildContext context) async{
    final pickedTime = await showTimePicker(
      context: context, initialTime: _endTime,builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      );
    },
    );

    if(pickedTime!=null){
      setState(() {
        _endTime = pickedTime;
        widget.profileDataProvider?.setEndTime(_formatTime(pickedTime));
        print("End Time: ${_endTime.format(context)}");
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Container(
      width: 162,
      height: 280,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 93,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('From'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,),
                    ),
                    Container(
                      width: 118,
                      height: 57,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                          onTap: (){
                            _selectStartTime(context);
                          },
                          child: Text('${_formatTime(_startTime)}',style: TextStyle(fontSize: 27,fontFamily: 'Poppins'),)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            height: 93,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('To'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,),
                    ),
                    Container(
                      width: 118,
                      height: 57,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                          onTap: (){
                            _selectEndTime(context);
                          },
                          child: Text('${_formatTime(_endTime)}',style: TextStyle(fontSize: 27,fontFamily: 'Poppins'),)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BandWidthSelect extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  BandWidthSelect({this.profileDataProvider});
  @override
  _BandWidthSelectState createState() => _BandWidthSelectState();
}

class _BandWidthSelectState extends State<BandWidthSelect>{
  String _radioValue = "choice_1";
  @override
  Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth*0.99,
      height: 275,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.grey,
          width: 0.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          Container(
            width: screenWidth*0.78,
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.black,
            //     width: 2,
            //   ),
            // ),
            child: Align(
                alignment: Alignment.topLeft,
                child: Text('Select Bandwidth',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),)),
          ),
          Column(
            children: [
              Row(
                children: [
                  SizedBox(width: screenWidth*0.06,),
                  Radio(
                    value: "choice_1",
                    groupValue: _radioValue,
                    activeColor: Colors.orange, // Change circle color to orange
                    onChanged: (String? value) {
                      setState(() {
                        _radioValue = value!;
                        print('Path is : $_radioValue');
                        widget.profileDataProvider?.setSlots(_radioValue);
                      });
                    },
                  ),
                  Text("Daily"),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: screenWidth*0.06,),
                  Radio(
                    value: "choice_2",
                    groupValue: _radioValue,
                    activeColor: Colors.orange, // Change circle color to orange
                    onChanged: (String? value) {
                      setState(() {
                        _radioValue = value!;
                        print('Path is : $_radioValue');
                        widget.profileDataProvider?.setSlots(_radioValue);
                      });
                    },
                  ),
                  Text("Only Weekends"),
                ],
              ),
            ],
          ),
          Container(
            width: 325,
            height: 63,
            child: FilledButton(
                backgroundColor: HexColor('#FB8C00'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentSection()));
                },
                child: Center(
                    child: Text('SET TIME',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,fontFamily: 'Poppins')))),
          ),
        ],
      ),
    );
  }
}

class CardItem {
  final String image;
  // final String videoUrl;
  final int countVideos;
  final String location;
  final String category;
  final int viewCnt;
  final int likes;
  final String distance;

  CardItem({
    required this.image,
    required this.location,
    required this.countVideos,
    required this.category,
    required this.viewCnt,
    required this.likes,
    required this.distance,
    // required this.videoUrl,
  });
}

class PaymentSection extends StatelessWidget{
  List<CardDetails> cards = [
    // CardDetails(name: 'Aman Gangwani', cardChoosen: 1, cardNo: '49756345 349572349857'),
    // CardDetails(name: 'Aman Gangwani', cardChoosen: 1, cardNo: '49756345 349572349857'),
    // CardDetails(name: 'Aman Gangwani', cardChoosen: 1, cardNo: '49756345 349572349857'),
    // CardDetails(name: 'Aman Gangwani', cardChoosen: 1, cardNo: '49756345 349572349857')
  ];
  bool cardform=false;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 30,),
            ProfileHeader(reqPage: 2),
            Container(
                width: 357,
                height: 25,
                child: Text('Payments',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),)),
            SizedBox(height: 30,),
            PaymentCard(paymentCards:cards,cardForm: cardform,),

          ],
        ),
      ),
    );
  }
}

class CardDetails{
  final String name;
  final String cardNo;
  final int cardChoosen;

  CardDetails({
    required this.name,
    required this.cardChoosen,
    required this.cardNo,
  });
}

class PaymentCard extends StatefulWidget{
  final List<CardDetails> paymentCards;
  bool cardForm;

  PaymentCard({required this.paymentCards,required this.cardForm});

  @override
  _PaymentCardState createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cardNoController = TextEditingController();
  TextEditingController expMonthController = TextEditingController();
  TextEditingController expYearController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  @override
  Widget build (BuildContext context){
    List<CardDetails> cards = widget.paymentCards;
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
                children:List.generate(cards.length, (index) {
                  return GestureDetector(
                    onLongPress: (){
                      print('1');
                      widget.paymentCards.removeAt(index);
                      setState(() {
                      });
                    },
                    child: Container(
                      width: 357,
                      height: 102,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border:Border.all(
                          color: Colors.white60,width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width:215,
                            height: 50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cards[index].cardNo,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                                Text(cards[index].name,style: TextStyle(fontSize: 12,fontFamily: 'Poppins'),),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 59,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:[
                                cards[index].cardChoosen==1?
                                Image.asset('assets/images/mastercard.png',width: 40,height: 30,)
                                    :cards[index].cardChoosen==2?
                                Image.asset('assets/images/visa.png',width: 40,height: 30,)
                                    :Image.asset('assets/images/visa.png',width: 40,height: 30,),
                                index==0?
                                Text('Primary',style: TextStyle(fontSize: 12,fontFamily: 'Poppnis'),)
                                    :Icon(Icons.arrow_forward_ios,color:HexColor('#00559B'),size: 12,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
            ),
          ),
          widget.cardForm
              ? Container(
            width: 357,
            height: 683,
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.black,width: 1,
            //   ),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height:20,),
                Container(
                  width: 218,
                  height: 58,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Debit/Credit/ATM Card',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Container(
                        width: 126,
                        height: 22,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/mastercard.png',width: 40,height: 30,),
                            Image.asset('assets/images/visa.png',width: 40,height: 30,),
                            Image.asset('assets/images/american_express.jpg',width: 40,height: 30,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height:20,),
                Container(
                  width: 324,
                  height: 497,
                  // decoration: BoxDecoration(
                  //     border: Border.all(
                  //       color: Colors.black,
                  //       width: 1,
                  //     )
                  // ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width:323,
                        height:90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cardholder Name'),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: 'Name On Card',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                ), // Add an outline border
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 323,
                        height: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Card Number'),
                            TextFormField(
                              controller: cardNoController,
                              decoration: InputDecoration(
                                hintText: '0000 0000 0000 0000',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                ), // Add an outline border
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 323,
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Expiration date'),
                            Container(
                              width: 189,
                              height: 53,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:72,
                                    height: 53,
                                    child: TextFormField(
                                      controller: expMonthController,
                                      decoration: InputDecoration(
                                        hintText: 'MM',
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                        ), // Add an outline border
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(height: 15,),
                                      Text('/',style: TextStyle(fontSize: 14,fontFamily: 'Poppins'),),
                                    ],
                                  ),
                                  Container(
                                    width: 72,
                                    height: 53,
                                    child: TextFormField(
                                      controller: expYearController,
                                      decoration: InputDecoration(
                                        hintText: 'YY',
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                        ), // Add an outline border
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 323,
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('CVV'),
                            Container(
                              width:143,
                              height:53,
                              child: TextFormField(
                                controller: cvvController,
                                decoration: InputDecoration(
                                  hintText: '000   or   0000',
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: HexColor('#FB8C00'),), // Change the border color here
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey), // Change the border color here
                                  ), // Add an outline border
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 322,
                        height: 63,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  widget.cardForm = !widget.cardForm;
                                  print(widget.cardForm);
                                });
                              },
                              child: Container(
                                  width: 156,
                                  height: 63,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: HexColor('#FB8C00'),
                                    ),
                                  ),
                                  child: Center(child: Text('Cancel',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: HexColor('#FB8C00'),fontFamily: 'Poppins'),))
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  widget.paymentCards.add(CardDetails(name: nameController.text, cardChoosen: 1, cardNo: cardNoController.text));
                                  nameController.text = '';
                                  cardNoController.text = '';
                                  expMonthController.text = '';
                                  expYearController.text = '';
                                  cvvController.text = '';
                                });
                              },
                              child: Container(
                                  width: 156,
                                  height: 63,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: HexColor('#FB8C00'),
                                  ),
                                  child: Center(child: Text('SAVE',style: TextStyle(fontSize: 16,fontFamily: 'Popppins',fontWeight: FontWeight.bold,color: Colors.white),))
                              ),
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ],
            ),
          )
              : GestureDetector(
            onTap: (){
              setState(() {
                widget.cardForm = !widget.cardForm;
              });
            },
            child: Container(
              width: 357,
              height: 140,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  )
              ),
              child: Row(
                children: [
                  SizedBox(width: 30,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Add Debit/Credit/ATM Card',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
                      Text('You can save your cards as per new RBI \nguidelines.',style: TextStyle(fontFamily: 'Poppins',fontSize: 14,),),
                      Row(
                        children: [
                          Text('Learn More',style: TextStyle(fontSize: 12,fontWeight:FontWeight.bold,color:HexColor('#00559B')),),
                          Icon(Icons.arrow_forward_ios_outlined,size:14,color: HexColor('#00559B'),),
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

class FilledButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  final Color backgroundColor;

  const FilledButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape:RoundedRectangleBorder(),
        primary: backgroundColor,
      ),
      child: child,
    );
  }
}
