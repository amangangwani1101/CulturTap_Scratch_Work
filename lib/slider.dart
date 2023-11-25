  import 'dart:convert';
  
  import 'package:flutter/material.dart';
  import 'package:flutter_stripe/flutter_stripe.dart';
  import 'package:learn_flutter/UserProfile/UserProfileEntry.dart';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:learn_flutter/widgets/Constant.dart';
  import 'UserProfile/ProfileHeader.dart';
  import './widgets/hexColor.dart';
import 'widgets/01_helpIconCustomWidget.dart';
  // import 'package:video_player/video_player.dart';
  
  
  // class HexColor extends Color {
  //   static int _getColor(String hex) {
  //     String formattedHex =  "FF" + hex.toUpperCase().replaceAll("#", "");
  //     return int.parse(formattedHex, radix: 16);
  //   }
  //   HexColor(final String hex) : super(_getColor(hex));
  // }
  
  
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
  
  void main() async{
    runApp(MyApp());
  }
  
  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('My App'),
          ),
          body: PaymentSection(), // Your custom widget here
        ),
      );
    }
  }
  class PaymentSection extends StatelessWidget{
    List<CardDetailss> cards = [
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
              IconButton(icon:Icon(Icons.help_outline),color: HexColor('#FB8C00'),onPressed: (){
                showDialog(context: context, builder: (BuildContext context){
                  return Container(child: CustomHelpOverlay(imagePath: 'assets/images/help_motivation_icon.jpg',serviceSettings: false),);
                },
                );
              },
              ),
              Container(
                width: 60,
                height: 40,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: (){
                      showDialog(context: context, builder: (BuildContext context){
                        return Container( child: CustomHelpOverlay(imagePath: 'assets/images/profile_set_completed_icon.png',serviceSettings: false,),);
                      },
                      );
                    },
                    child: Image.asset('assets/images/skip.png',width: 60,height: 30,),
                  ),
                ),
              ),
              ProfileHeader(reqPage: 4),
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
  
  // void main() {
  //   runApp(MaterialApp(
  //     home: Scaffold(
  //       body: SingleChildScrollView(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             SizedBox(height: 30,),
  //             ProfileHeader(reqPage: 2),
  //             Container(
  //                 width: 357,
  //                 height: 25,
  //                 child: Text('Payments',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins'),)),
  //             SizedBox(height: 30,),
  //             PaymentCard(paymentCards:cards,cardForm: cardform,),
  //
  //           ],
  //         ),
  //       ),
  //     ),
  //   ));
  // }
  
  class CardDetailss{
    final String name;
    final String cardNo;
    final int cardChoosen;
  
    CardDetailss({
      required this.name,
      required this.cardChoosen,
      required this.cardNo,
    });
  }
  
  class PaymentCard extends StatefulWidget{
    final List<CardDetailss> paymentCards;
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
    void initState() {
      super.initState();
  
      // Initialize the Stripe SDK with your publishable key
      Stripe.publishableKey = 'pk_test_51O1mwsSBFjpzQSTJYIRROzWlVlSlOL4ysCytD2icFn57ISGbDUDaVLyLgFJABlFaHDPgMmmOpvRKxE99x3w90HRf00ZwzrVv0R';
    }
  
    // Future<void> _handlePayment() async {
    //   final card = PaymentMethodParams.cardFromMethod(PaymentMethod.card);
    //
    //   // Replace with your actual card details
    //   card.number = '4242424242424242';
    //   card.expMonth = 12;
    //   card.expYear = 25;
    //   card.cvc = '123';
    //
    //   final token = await Stripe.instance.createToken(card);
    //
    //   // Handle the token, you can send it to your server for processing
    //   if (token != null) {
    //     print('Token ID: ${token.tokenId}');
    //     // You can now send this token to your backend for further processing.
    //   } else {
    //     print('Token creation failed.');
    //     // Handle the error
    //   }
    // }
  
    // Future<void> _createToken(String number,int month,int year,dynamic cvv) async {
    //   final CardDetails card = CardDetails(
    //     number: number,
    //     expirationYear: year,
    //     expirationMonth: month,
    //     cvc: cvv,
    //   );
    //
    //   final TokenData token = await Stripe.instance.createToken(card as CreateTokenParams);
    //   // Send the token to your backend
    //   // sendTokenToBackend(token);
    //   print('Token $token');
    // }

    // Future<void> tokenizeCard(BuildContext context) async {
    //   try {
    //     final token = await Stripe.instance.createToken(
    //       Card(
    //         number: '4242424242424242',
    //         expMonth: 12,
    //         expYear: 25,
    //         cvc: '123',
    //       ),
    //     );
    //
    //     // Send the token to your backend for further processing
    //     print('Token: ${token.id}');
    //   } catch (e) {
    //     // Handle errors
    //     print('Error: $e');
    //   }
    // }


    void tokenizeDealerCard(String cardNumber, String expMonth, String expYear, String cvc, String cardholderName) async {
      // try {
      //   final paymentMethodCard = stripe.PaymentMethodCard(
      //     card: stripe.Card(
      //       number: cardNumber,
      //       expMonth: int.parse(expMonth),
      //       expYear: int.parse(expYear),
      //       cvc: cvc,
      //       name: cardholderName,
      //     ),
      //   );
      //
      //   final paymentMethod = await Stripe.instance.createToken(paymentMethodCard);
      //   return paymentMethod.id;
      // } catch (err) {
      //   print('Error tokenizing dealer card: ${err}');
      //   throw err;
      // }

      try {
        final String serverUrl = Constant().serverUrl; // Replace with your server's URL
        final Map<String,dynamic> details = {
          'card':{
            'number': cardNumber,
            'exp_month': expMonth,
            'exp_year': expYear,
            'cvc': cvc,
          }
        };
        print('PPPPP::$details');
        final http.Response response = await http.post(
          Uri.parse('https://api.stripe.com/v2/tokens'), // Adjust the endpoint as needed
          headers: {
            "Content-Type": "application/x-www-form-urlendcoded",
            "Authorization":"Bearer sk_test_51O1mwsSBFjpzQSTJcZbPFYDAWpuV5idzEE62s6n7QHEswXShSp8rJqmWZcejO5jvcTZWcBZHh063PDu2AgTKpneT00sISTulAG"
          },
          body: jsonEncode(details),
        );
        print(json.decode(response.body));
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print(responseData);
        } else {
          print('Failed to save data: ${response.statusCode}');
        }
      }catch(err){
        print("Error: $err");
      }
    }
  
    void sendCardDetailsToBackend(Map<String, String> cardDetails) async {
      final response = await http.post(Uri.parse('${Constant().serverUrl}/createDealer'),
        body: json.encode(cardDetails),
        headers: {'Content-Type': 'application/json'},
      );
  
      if (response.statusCode == 200) {
        print('Card details sent to backend successfully');
      } else {
        print('Failed to send card details to backend');
      }
    }
  
    late Map<String,String> card;
    Widget build (BuildContext context){
      List<CardDetailss> cards = widget.paymentCards;
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
                                        widget.paymentCards.add(CardDetailss(name: nameController.text, cardChoosen: 1, cardNo: cardNoController.text));
                                        sendCardDetailsToBackend(card);
                                        // tokenizeDealerCard(cardNoController.text,expMonthController.text,expYearController.text,cvvController.text,nameController.text);
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
  
