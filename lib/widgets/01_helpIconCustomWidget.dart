import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_flutter/ServiceSections/TripCalling/UserCalendar/CalendarHelper.dart';
import 'package:learn_flutter/ServiceSections/PingsSection/Pings.dart';
import 'package:learn_flutter/slider.dart';
import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
import 'package:learn_flutter/widgets/sample.dart';
import '../BackendStore/BackendStore.dart';
import 'Constant.dart';
import 'package:http/http.dart' as http;
import 'CustomButton.dart';
import 'CustomDialogBox.dart';
import 'hexColor.dart';
import '../UserProfile/ProfileHeader.dart';


String? globalStartTime;
String? globalEndTime;
String? globalSlots;

class CustomHelpOverlay extends StatelessWidget {
  final VoidCallback? onButtonPressed,onBackPressed;
  final String imagePath;
  bool? serviceSettings=false;
  String?text,navigate;
  final helper,helper2;
  final ProfileDataProvider? profileDataProvider;
  CustomHelpOverlay({required this.imagePath,this.serviceSettings,this.profileDataProvider,this.text,this.navigate,this.helper,this.helper2,this.onButtonPressed,this.onBackPressed});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: ()async{
        if(navigate=='pings'){
          onBackPressed!();
        }else
          print(1);
        return true;
      },
      child: Container(
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
                        child:navigate=='pings'
                          ?SizedBox(width: 0,)
                          : IconButton(
                          icon: Icon(Icons.close),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      if (text!=null) Container(
                        height: 250,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                              onTap: (){
                                if(navigate=='calendarhelper'){
                                  print(2);
                                  onButtonPressed!();
                                }
                                else if(navigate=='pings')
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> PingsSection(userId: helper!,userName:helper2!,text:'meetingPings')));
                                else if(navigate=='pop'){
                                    print(1);
                                    onButtonPressed!();
                                }
                              },
                              child: Text(text!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.orange,),)),
                        ),
                      ) else SizedBox(width: 0,),
                      if (serviceSettings==true) Container(
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
      ),
    );
  }
}
class ServicePage extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  final ServiceTripCallingData?data;
  String?userId;
  ServicePage({this.profileDataProvider,this.userId,this.data});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage>{
  String?startTime,endTime,slots;


  @override
  Widget build(BuildContext context) {
    if(widget.data!=null){
      startTime = widget.data?.setStartTime;
      endTime = widget.data?.setEndTime;
      slots = widget.data?.slots;
      globalStartTime = startTime;
      globalEndTime = endTime;
      globalSlots = slots;
    }
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: ()async{
        if(widget.profileDataProvider==null){
          print(1);
          Navigator.of(context).pop();
        }
        else{
          print(2);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
        return true;
      },
      child: Scaffold(
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
              ProfileHeader(reqPage: 3,userId: widget.userId,text: widget.profileDataProvider==null?'':'calendar',),
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
                          TimePicker(profileDataProvider:widget.profileDataProvider,startTime:startTime,endTime:endTime),
                        ],
                      ),
                    ),
                    BandWidthSelect(profileDataProvider:widget.profileDataProvider,slots:slots,userId:widget.userId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimePicker extends StatefulWidget{
  final ProfileDataProvider? profileDataProvider;
  final String?startTime,endTime;
  TimePicker({this.profileDataProvider,this.endTime,this.startTime});
  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker>{
  TimeOfDay _startTime = TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 21,minute:0);

  TimeOfDay convertStringToTimeOfDay(String timeString) {
    final List<String> timeParts = timeString.split(' ');

    // Extract hours and minutes
    final List<String> timeDigits = timeParts[0].split(':');
    int hours = int.parse(timeDigits[0]);
    int minutes = int.parse(timeDigits[1]);

    // Adjust hours for PM
    if (timeParts[1] == 'PM' && hours < 12) {
      hours += 12;
    }

    // Create and return TimeOfDay object
    return TimeOfDay(hour: hours, minute: minutes);
  }

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
        if(widget.startTime==null)
          {
            globalStartTime = _formatTime(_startTime);
          }
        else{
          globalStartTime = _formatTime(_startTime);
        }
        print(pickedTime);
        print("Start Time: ${_startTime}");
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
        if(widget.endTime==null){
          globalEndTime = _formatTime(_endTime);
        }
        else{
          globalEndTime = _formatTime(_endTime);
        }
        print("End Time: ${_endTime.format(context)}");
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize _startTime and _endTime with values from widget
    if (widget.startTime != null) {
      _startTime = convertStringToTimeOfDay(widget.startTime!);
      globalStartTime=widget.startTime!;
    }

    if (widget.endTime != null) {
      _endTime = convertStringToTimeOfDay(widget.endTime!);
      globalEndTime = widget.endTime!;
    }

  }
  @override
  Widget build(BuildContext context){
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth*0.77,
            height: 120,
            // decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('From',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w400),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,),
                    ),
                    SizedBox(width: 6,),
                    Container(

                      padding: EdgeInsets.all(2),
                      height: 57,
                      decoration: BoxDecoration(
                        color: HexColor('#5EEBEB').withOpacity(0.2),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: GestureDetector(
                            onTap: (){
                              _selectStartTime(context);
                              print(_startTime);
                            },
                            child: Text('${_formatTime(_startTime)}',style: TextStyle(fontSize: 27,fontFamily: 'Poppins'),)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            width: screenWidth*0.77,
            height: 120,
            // decoration: BoxDecoration(border: Border.all(width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('To',style: TextStyle(fontSize: 14,fontFamily: 'Poppins',fontWeight: FontWeight.w400),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset('assets/images/clock.png',width: 35,height: 35,),
                    ),
                    SizedBox(width: 6,),
                    Container(

                      padding: EdgeInsets.all(2),
                      height: 57,
                      decoration: BoxDecoration(
                        color: HexColor('#5EEBEB').withOpacity(0.2),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: GestureDetector(
                            onTap: (){
                              _selectEndTime(context);
                              print(_endTime);

                            },
                            child: Text('${_formatTime(_endTime)}',style: TextStyle(fontSize: 27,fontFamily: 'Poppins'),)),
                      ),
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
  final String?slots,userId;
  BandWidthSelect({this.profileDataProvider,this.slots,this.userId});
  @override
  _BandWidthSelectState createState() => _BandWidthSelectState();
}

class _BandWidthSelectState extends State<BandWidthSelect>{
  String _radioValue='';

  @override
  void initState(){
    if(widget.slots!=null){
      _radioValue = widget.slots!;
    }
  }

  void updateUserTime (String userId,String startTime,String endTime,String slot) async{
    try {
      Map<String,dynamic>data = {
        "userId":userId,
        "startTime":startTime,
        "endTime":endTime,
        "slot":slot
      };
      print('User$data');
      final String serverUrl = Constant().serverUrl; // Replace with your server's URL
      final http.Response response = await http.put(
        Uri.parse('$serverUrl/updateUserTime'), // Adjust the endpoint as needed
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your Time Is Set :) '),
          ),
        );
        Navigator.of(context).pop();
        print('Data saved successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Try Again!!'),
          ),
        );
        print('Failed to update time: ${response.statusCode}');
      }
    }catch(err){
      print("Error: $err");
    }
  }

  bool isStartTimeBeforeEndTime(String startTime, String endTime) {
    // Parse time strings manually
    DateTime startDateTime = _parseTime(startTime);
    DateTime endDateTime = _parseTime(endTime);

    // Compare the DateTime objects
    return startDateTime.isBefore(endDateTime);
  }

  DateTime _parseTime(String time) {
    // Split the time string into parts
    List<String> parts = time.split(' ');
    String timePart = parts[0];
    String amPmPart = parts[1];

    // Split the time part into hours and minutes
    List<String> timeParts = timePart.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    // Adjust hours for PM
    if (amPmPart.toLowerCase() == 'pm' && hours < 12) {
      hours += 12;
    }

    return DateTime(2023, 1, 1, hours, minutes);
  }



  bool validator(){
    if((globalStartTime)==null || (globalEndTime)==null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your timing!'),
        ),
      );
      return false;
    }
    if(globalSlots==null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your slots!'),
        ),
      );
      return false;
    }
    if(isStartTimeBeforeEndTime(globalStartTime!,globalEndTime!) ==false){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Time Set Is Invalid!'),
        ),
      );
      return false;
    }
    widget.profileDataProvider?.setStartTime(globalStartTime!);
    widget.profileDataProvider?.setEndTime(globalEndTime!);
    widget.profileDataProvider?.setSlots(globalSlots!);
    widget.profileDataProvider?.setServide1();
    return true;
  }
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
                        if(widget.slots==null){
                          widget.profileDataProvider?.setSlots(_radioValue);
                          globalSlots = _radioValue;
                        }
                        else {
                          globalSlots = _radioValue;
                        }
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
                        if(widget.slots==null){
                          widget.profileDataProvider?.setSlots(_radioValue);
                          globalSlots = _radioValue;
                        }
                        else {
                          globalSlots = _radioValue;
                        }
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
                  if(validator()){
                    if(widget.userId==null){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentSection(profileDataProvider:widget.profileDataProvider)));
                    }else{
                      print(1);
                      print(widget.userId!);
                      updateUserTime(widget.userId!,globalStartTime!,globalEndTime!,globalSlots!);

                      // Navigator.of(context).pop();
                    }
                  }else{}

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
  ProfileDataProvider?profileDataProvider;
  PaymentSection({this.profileDataProvider});
  List<CardDetails> cards = [
    // CardDetails(name: 'Aman Gangwani', cardChoosen: 1, cardNo: '49756345 349572349857'),
    // CardDetails(name: 'Aman Gangwani', cardChoosen: 1, cardNo: '49756345 349572349857'),
    // CardDetails(name: 'Aman Gangwani', cardChoosen: 1, cardNo: '49756345 349572349857'),
    // CardDetails(name: 'Aman Gangwani', cardChoosen: 1, cardNo: '49756345 349572349857')
  ];
  bool cardform=false;
  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        cards.length>0
        ? showDialog(
          context: context,
          builder: (BuildContext context) {
            return ConfirmationDialog(
              message:'Cards Are Not Save.',
              onCancel: () {
                // Perform action on confirmation
                Navigator.of(context).pop(); // Close the dialog
                // Add your action here
                print('Action confirmed');
              },
              onConfirm: () {
                // Perform action on cancellation
                profileDataProvider?.removeAllCards();
                showDialog(context: context, builder: (BuildContext context){
                  return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },),);
                },
                );
                // Add your action here
                print('Action cancelled');
              },
            );
          },
        ):showDialog(context: context, builder: (BuildContext context){
          return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },),);
        },
        );
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ProfileHeader(reqPage: 4,text:'You are all set',profileDataProvider:profileDataProvider),
              Container(
                  width: 357,
                  height: 25,
                  child: Text('Payments',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),)),
              SizedBox(height: 30,),
              PaymentCard(paymentCards:cards,cardForm: cardform,profileDataProvider:profileDataProvider),

            ],
          ),
        ),
      ),
    );
  }
}

class CardDetails{
  final String name;
  final String cardNo;
  final int cardChoosen;
  final String month,year,cvv;
  bool options;

  CardDetails({
    required this.name,
    required this.cardChoosen,
    required this.cardNo,
    required this.month,
    required this.year,
    required this.cvv,
    required this.options
  });
}

class PaymentCard extends StatefulWidget{
  final List<CardDetails> paymentCards;
  ProfileDataProvider? profileDataProvider;
  bool cardForm;

  PaymentCard({required this.paymentCards,required this.cardForm,this.profileDataProvider});

  @override
  _PaymentCardState createState() => _PaymentCardState();
}


class _PaymentCardState extends State<PaymentCard> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cardNoController = TextEditingController();
  TextEditingController expMonthController = TextEditingController();
  TextEditingController expYearController = TextEditingController();
  TextEditingController cvvController = TextEditingController();



  bool isCreditCardNumberValid(String creditCardNumber) {
    // Remove any spaces or non-digit characters
    creditCardNumber = creditCardNumber.replaceAll(RegExp(r'\D'), '');

    if (creditCardNumber.isEmpty) {
      return false; // Invalid if the number is empty after removing non-digits
    }

    int sum = 0;
    bool alternate = false;

    for (int i = creditCardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(creditCardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  bool cardValidator(){
    if((nameController.text.length==0)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name Field Is Empty!'),
        ),
      );
      return false;
    }
    if(!(int.parse(expMonthController.text)>=1 && int.parse(expMonthController.text)<=12)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Month Is Invalid! Kindly Choose Value Between 1 to 12'),
        ),
      );
      return false;
    }
    if(!(int.parse(expYearController.text)>=1 && int.parse(expYearController.text)<=99)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Year Is Invalid!'),
        ),
      );
      return false;
    }
    if(!(cvvController.text.length==3 || cvvController.text.length==4)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CVV Number Is Invalid'),
        ),
      );
      return false;
    }
    if(!isCreditCardNumberValid(cardNoController.text)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card Number Is Invalid!'),
        ),
      );
      return false;
    }
    return true;
  }

  String formatNumber(String number) {
    if (number.length != 16) {
      // Ensure that the number has 16 digits
      return 'Invalid number';
    }

    // Split the number into chunks of 4 digits
    List<String> chunks = [];
    for (int i = 0; i < number.length; i += 4) {
      int endIndex = i + 4;
      chunks.add(number.substring(i, endIndex));
    }

    // Join the chunks with spaces
    return chunks.join(' ');
  }
  @override
  Widget build (BuildContext context){
    List<CardDetails> cards = widget.paymentCards;
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
                children:List.generate(cards.length, (index) {
                  return GestureDetector(
                    onTap: (){
                      print('1');
                      setState(() {
                        cards[index].options = !cards[index].options;
                      });
                    },
                    child: Container(
                      width: 357,
                      height: cards[index].options?192:102,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border:Border.all(
                          color: HexColor('#F5F5F5'),width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width:215,
                                height: 50,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formatNumber(cards[index].cardNo),style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),),
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
                          cards[index].options
                              ?Container(
                                  height: 27,
                                width: 357,
                                child: Row(
                                  mainAxisAlignment:MainAxisAlignment.spaceEvenly ,
                            children: [
                                GestureDetector(
                                  child: Text('Edit',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: HexColor('#FB8C00')),),
                                  onTap: (){
                                    setState(() {
                                      nameController.text = cards[index].name;
                                      cardNoController.text = cards[index].cardNo;
                                      expMonthController.text = cards[index].month;
                                      expYearController.text = cards[index].year;
                                      cvvController.text = cards[index].cvv;
                                      widget.cardForm = !widget.cardForm;
                                    });
                                    widget.profileDataProvider!.removeCard(index);
                                    widget.paymentCards.removeAt(index);
                                  },
                                ),
                                Text('|',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: HexColor('#FB8C00'))),
                                GestureDetector(
                                    onTap: (){
                                      widget.profileDataProvider!.removeCard(index);
                                      setState(() {
                                        widget.paymentCards.removeAt(index);
                                      });
                                    },
                                    child: Text('Remove',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: HexColor('#FB8C00')))),
                            ],
                          ),
                              )
                              :SizedBox(width: 0,),
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
                              inputFormatters: [
                                CreditCardFormatter(),
                              ],
                              keyboardType: TextInputType.number,
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
                                      keyboardType: TextInputType.number,
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
                                      keyboardType: TextInputType.number,
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
                                keyboardType: TextInputType.number,
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
                                if(cardValidator()){
                                  PaymentDetails newPayment = PaymentDetails(
                                    name: nameController.text, // Get this from user input
                                    month: expMonthController.text, // Get this from user input
                                    year: expYearController.text, // Get this from user input
                                    cardNo: cardNoController.text, // Get this from user input
                                    cvv: cvvController.text, // Get this from user input
                                  );
                                  widget.profileDataProvider!.addCardDetails(newPayment);
                                  setState(() {
                                    widget.paymentCards.add(CardDetails(name: nameController.text, cardChoosen: 1, cardNo: cardNoController.text,month:expMonthController.text,year: expYearController.text,cvv:cvvController.text,options: false));
                                    nameController.text = '';
                                    cardNoController.text = '';
                                    expMonthController.text = '';
                                    expYearController.text = '';
                                    cvvController.text = '';
                                    widget.cardForm = !widget.cardForm;
                                  });
                                }

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
          widget.paymentCards.length>0
          ? Container(
              width: 326,
              height: 53,
              margin: EdgeInsets.only(top: screenHeight * 0.7),
              child: FiledButton(
              backgroundColor: HexColor('#FB8C00'),
              onPressed: () {
                  showDialog(context: context, builder: (BuildContext context){
                    return Container(child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,text: 'You are all set',navigate: 'pop',onButtonPressed: (){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },),);
                  },
                );
              },
              child: Center(
                child: Text('Set Cards',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18)))),
            )
          :SizedBox(height: 0,),
        ],
      ),
    );
  }
}


class CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any non-digit characters
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Insert a space after every 4 digits
    if (newText.length > 4 && newText.length % 4 == 1) {
      newText = newText.substring(0, newText.length - 1) + ' ' + newText.substring(newText.length - 1);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
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
