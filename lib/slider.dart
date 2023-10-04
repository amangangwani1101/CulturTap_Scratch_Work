import 'package:flutter/material.dart';
import 'package:learn_flutter/userProfile1.dart';
// import 'package:video_player/video_player.dart';


class HexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex =  "FF" + hex.toUpperCase().replaceAll("#", "");
    return int.parse(formattedHex, radix: 16);
  }
  HexColor(final String hex) : super(_getColor(hex));
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

// class _PaymentCardState extends State<PaymentCard>{
//   TextEditingController nameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   bool isFormVisible = false;
//   bool isEditing = false;
//   String savedName = '';
//   String savedEmail = '';
//
//   void saveForm() {
//     // Handle form submission and save responses
//     // You can store these responses in variables or a data structure
//     // For simplicity, we'll print them to the console
//     setState(() {
//       savedName = nameController.text;
//       savedEmail = emailController.text;
//       isFormVisible = false;
//       isEditing = false;
//     });
//   }
//
//   void editForm() {
//     // Allow the user to edit the form
//     setState(() {
//       isEditing = true;
//       isFormVisible = true;
//     });
//   }
//
//   void resetForm() {
//     // Reset all form fields
//     nameController.clear();
//     emailController.clear();
//     setState(() {
//       isEditing = false;
//       isFormVisible = false;
//       savedName = '';
//       savedEmail = '';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             if (!isEditing) {
//               editForm();
//             }
//           },
//           child: isFormVisible
//               ? AnimatedContainer(
//             // Slide down animation properties
//             duration: Duration(milliseconds: 300),
//             height: isFormVisible ? 200 : 0,
//             child: Column(
//               children: [
//                 TextField(
//                   controller: nameController,
//                   decoration: InputDecoration(labelText: 'Name'),
//                 ),
//                 TextField(
//                   controller: emailController,
//                   decoration: InputDecoration(labelText: 'Email'),
//                 ),
//                 ElevatedButton(
//                   onPressed: saveForm,
//                   child: Text('Save'),
//                 ),
//               ],
//             ),
//           )
//               : savedName.isNotEmpty || savedEmail.isNotEmpty
//               ? Card(
//             // Display concise card with entered details
//             child: Column(
//               children: [
//                 Text('Name: $savedName'),
//                 Text('Email: $savedEmail'),
//                 ElevatedButton(
//                   onPressed: editForm,
//                   child: Text('Edit'),
//                 ),
//               ],
//             ),
//           )
//               : Card(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Payments',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),),
//                 Text('This payment method will help you to pay & receive money',style: TextStyle(fontSize: 14,),),
//               ],
//             ),
//           ),
//         ),
//         if (isEditing)
//           ElevatedButton(
//             onPressed: resetForm,
//             child: Text('Reset'),
//           ),
//       ],
//     );
//   }
// }

