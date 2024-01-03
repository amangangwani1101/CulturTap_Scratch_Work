// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:learn_flutter/CulturTap/appbar.dart';
// import 'package:learn_flutter/ServiceSections/TripCalling/Payments/PhonePePayment.dart';
// import 'package:learn_flutter/ServiceSections/TripCalling/Payments/RazorPay.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:upi_india/upi_india.dart';
// import 'package:upi_india/upi_response.dart';
// import 'package:http/http.dart' as http;
// import '../../../widgets/Constant.dart';
// import 'Paypal_checkout.dart';
//
// class UpiPayments extends StatefulWidget {
// String? name,merchant,phoneNo;
// dynamic amount;
// UpiPayments({this.name,this.merchant,this.amount,this.phoneNo});
//   @override
//   State<UpiPayments> createState() => _UpiPaymentsState();
// }
//
// void main(){
//   runApp(UpiPayments());
// }
// class _UpiPaymentsState extends State<UpiPayments> {
//   Future<UpiResponse>? _transaction;
//   final UpiIndia _upiIndia = UpiIndia();
//   List<UpiApp>?apps;
//
//   @override
//   void initState() {
//
//     print('Comming');
//     _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value){
//       setState(() {
//         apps = value;
//       });
//     }).catchError((err){
//       print('Upi Error $err');
//       apps = [];
//     });
//     super.initState();
//   }
//
//   Future<UpiResponse> initiateTransaction(UpiApp app) async{
//     return _upiIndia.startTransaction(app: app,
//         receiverUpiId: '8175902793@paytm',
//         receiverName: 'Aman',
//         transactionRefId: 'Testing Upi',
//         transactionNote: 'Working On It',
//         amount: 1,
//     );
//   }
//
//   // stripe apps
//   Future<bool> paymentHandler(String name,String merchantName,double amount,String phone) async {
//     print('Phone is:$phone');
//     try {
//       // 1. Create a payment intent on the server
//       final response = await http.post(Uri.parse('${Constant().serverUrl}/customerPayment'),
//           body: {
//             'phone':phone,
//             'amount': amount.toString(),
//             'name':name
//           });
//
//       final jsonResponse = jsonDecode(response.body);
//       print('Res1 : $jsonResponse');
//       // 2. Initialize the payment sheet
//       final res2 = await Stripe.instance.initPaymentSheet(
//           paymentSheetParameters: SetupPaymentSheetParameters(
//             primaryButtonLabel: 'CULTURTAP',
//             intentConfiguration: IntentConfiguration(
//               mode: IntentMode(
//                 currencyCode: 'INR',
//                 amount: 50000,
//                 setupFutureUsage: IntentFutureUsage.OnSession,
//               ),
//             ),
//             billingDetails:BillingDetails(
//               name: 'aman',
//               phone: '8175902793',
//               email: 'aman@gmail.com',
//               address: Address(
//                 city: 'Kanpur',
//                 country: 'India',
//                 line1: '11',
//                 line2: '11',
//                 postalCode: '208006',
//                 state: 'UP',
//               ),
//             ) ,
//             billingDetailsCollectionConfiguration: BillingDetailsCollectionConfiguration(
//               // name: CollectionMode.automatic,
//               phone: CollectionMode.automatic,
//               email: CollectionMode.automatic,
//               address: AddressCollectionMode.automatic,
//               attachDefaultsToPaymentMethod: true,
//               // name:CollectBankAccountParams(
//               // ),
//               // phone: '8175902793',
//               // email: 'aman@gamil.com',
//
//             ),
//             paymentIntentClientSecret: jsonResponse['paymentIntent'],
//             merchantDisplayName: merchantName,
//             customerId: jsonResponse['customer'],
//             customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
//             googlePay: const PaymentSheetGooglePay(
//               merchantCountryCode: 'US',
//               testEnv: true,
//             ),
//           ));
//       print('Res2 : $res2');
//       final res3 = await Stripe.instance.presentPaymentSheet(
//         options: PaymentSheetPresentOptions(
//           timeout:  120000,
//         ),
//       );
//       print('Res3  $res3');
//       if(res3 != null){
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An error occured ${res3}'),
//           ),
//         );
//       }else{
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Payment is successful'),
//           ),
//         );
//       }
//       return true;
//     } catch (errorr) {
//       print(errorr);
//       if (errorr is StripeException) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An error occured ${errorr.error.localizedMessage}'),
//           ),
//         );
//         return false;
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An error occured $errorr'),
//           ),
//         );
//         return false;
//       }
//     }
//   }
//
//   // upi apps
//   Widget displayUpiApps(){
//     if(apps == null){
//       return const Center(child:CircularProgressIndicator());
//     }else if(apps!.isEmpty){
//       return Center(
//         child: Text('No Apps Are There To show',
//           style: TextStyle(fontFamily: 'Poppins'),
//         ),
//       );
//     }else{
//       return Align(
//         alignment: Alignment.topLeft,
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Wrap(
//             children: apps!.map((UpiApp app){
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   GestureDetector(
//                     onTap:(){
//                       _transaction  = initiateTransaction(app);
//                       setState(() {});
//                     },
//                     child: Container(
//                       height: 100,
//                       width: 100,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.memory(
//                             app.icon,
//                             height: 40,
//                             width: 40,
//                           ),
//                           Text(app.name),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       );
//     }
//   }
//   void _upiErrorHandler(err){}
//   void _checkTxnStatus(String status){
//     switch(status){
//       case UpiPaymentStatus.SUCCESS:
//         print('Txn Success');
//         break;
//       case UpiPaymentStatus.SUBMITTED:
//         print('Txn Submitted');
//         break;
//       case UpiPaymentStatus.FAILURE:
//         print('Txn failed');
//         break;
//       default:
//         print('Umknown id');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: ProfileHeader(reqPage: 2,),backgroundColor: Colors.white,automaticallyImplyLeading: false,),
//         body: SingleChildScrollView(
//           child: Row(
//             children: [
//               SizedBox(width: screenWidth*0.09,),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 26,),
//                   Container(
//                     width: screenWidth*0.80,
//                     height: 170,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Cost of local Assistance ',style:
//                                   TextStyle(fontFamily: 'Poppins',fontSize: 14),),
//                                 Text('${widget.amount} INR/Event',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.green),),
//                               ],
//                             ),
//                            Image.asset('assets/images/help-icon.png',color: Colors.orange,)
//                           ],
//                         ),
//                         Text('Emergency trip assistance is free for public reasons & safety purpose.',
//                         style: TextStyle(fontFamily: 'Poppins',fontSize: 13),),
//                         Text('You have to pay other cost of items directly to the person , who will helps you there.',
//                           style: TextStyle(fontFamily: 'Poppins',fontSize: 13),)
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 33,),
//                   Container(
//                     width: screenWidth*0.80,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Select a payment method',style: TextStyle(fontSize: 20,fontFamily: 'Poppins',fontWeight: FontWeight.bold),),
//                         SizedBox(height: 20,),
//                         Container(
//                           padding: EdgeInsets.all(20),
//                           width: 330,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5), // Shadow color
//                                 spreadRadius: 4, // Spread radius
//                                 blurRadius: 7, // Blur radius
//                                 offset: Offset(0, 3), // Changes the position of the shadow
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Pay with UPI',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',fontSize: 12),),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Expanded(child: displayUpiApps()),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 20,),
//                         Container(
//                           padding: EdgeInsets.all(20),
//                           width: 330,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5), // Shadow color
//                                 spreadRadius: 4, // Spread radius
//                                 blurRadius: 7, // Blur radius
//                                 offset: Offset(0, 3), // Changes the position of the shadow
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Pay with Cards',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',fontSize: 12),),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   GestureDetector(
//                                       onTap:()async{
//                                         bool res =  await paymentHandler(widget.name!,widget.merchant!,1000.0,widget.phoneNo!);
//                                         Navigator.of(context).pop(res);
//                                       },
//                                       child: Image.asset('assets/images/stripe_logo.png',width: 50,height: 70,)
//                                   ),
//                                   SizedBox(width: 30,),
//                                   GestureDetector(
//                                       onTap: ()async{
//                                         bool res = await Navigator.push(context, MaterialPageRoute(builder: (context) =>PhonePePayment()
//                                         ));
//                                         print('Resultttt $res');
//                                         Navigator.of(context).pop(res);
//                                         },
//                                       child: Image.asset('assets/images/phonepe_logo_1.webp',width: 35,height: 60,)),
//                                   SizedBox(width: 30,),
//                                   GestureDetector(
//                                       onTap: ()async{
//                                         bool res = await Navigator.push(context, MaterialPageRoute(builder: (context) =>PaypalCheckouts()
//                                         ));
//                                         Navigator.of(context).pop(res);
//                                       },
//                                       child: Image.asset('assets/images/paypal_logo.png',width: 50,height: 70,)),
//                                   SizedBox(width: 20,),
//                                   GestureDetector(
//                                     onTap:()async{
//                                       bool res = await Navigator.push(context, MaterialPageRoute(builder: (context) =>RazorPayIntegration()
//                                       ));
//                                       print('Resultttt $res');
//                                       Navigator.of(context).pop(res);
//                                     },
//                                     child: Image.asset('assets/images/net_banking_logo.png',width: 60,height: 70,),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 20,),
//                         Container(
//                           padding: EdgeInsets.all(20),
//                           width: 330,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5), // Shadow color
//                                 spreadRadius: 4, // Spread radius
//                                 blurRadius: 7, // Blur radius
//                                 offset: Offset(0, 3), // Changes the position of the shadow
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('NetBanking',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',fontSize: 12),),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   GestureDetector(
//                                       onTap:()async{
//                                         bool res = await Navigator.push(context, MaterialPageRoute(builder: (context) =>PhonePePayment()
//                                         ));
//                                         print('Resultttt $res');
//                                         Navigator.of(context).pop(res);
//                                       },
//                                       child: Image.asset('assets/images/net_banking_logo.png',width: 60,height: 70,)),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 20,),
//                         Container(
//                           padding: EdgeInsets.all(20),
//                           width: 330,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5), // Shadow color
//                                 spreadRadius: 4, // Spread radius
//                                 blurRadius: 7, // Blur radius
//                                 offset: Offset(0, 3), // Changes the position of the shadow
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Pay Later',style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',fontSize: 12),),
//                               GestureDetector(
//                                 onTap: ()async{
//                                   bool res = await Navigator.push(context, MaterialPageRoute(builder: (context) =>PhonePePayment()
//                                   ));
//                                   print('Resultttt $res');
//                                   Navigator.of(context).pop(res);
//                                 },
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Image.asset('assets/images/pay-later_logo.png',width: 60,height: 70,),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // GestureDetector(
//                   //   onTap: (){
//                   //     paymentHandler(widget.name!, widget.merchant!, widget.amount, widget.phoneNo!);
//                   //   },
//                   //   child: SvgPicture.asset(
//                   //     'assets/images/stripe_logo.svg', // Replace with the path to your SVG icon
//                   //     height: 60,
//                   //     width: 60,
//                   //   ),
//                   // ),
//                   // // GestureDetector(
//                   //   onTap: (){
//                   //     Navigator.of(context).push(MaterialPageRoute(
//                   //       builder: (BuildContext context) => PaypalCheckout(
//                   //         sandboxMode: true,
//                   //         clientId: "AUFy2J4GmEGTVrrul-7TaRLlERKB6qLvcotF95b5UIfQgeXcGhQNApYwtwHXV2HoO7rpFzM8Xdb7Vxw9",
//                   //         secretKey: "EAhUcMa6EPzuApgDBBl51-dOiAwsxHay6jOdUpbLyz1LkU-RHtDwXCrKkPQnGBmY9ejwU3XymP8a6vnf",
//                   //         returnURL: "success.snippetcoder.com",
//                   //         cancelURL: "cancel.snippetcoder.com",
//                   //         transactions: const [
//                   //           {
//                   //             "amount": {
//                   //               "total": '70',
//                   //               "currency": "USD",
//                   //               "details": {
//                   //                 "subtotal": '70',
//                   //                 "shipping": '0',
//                   //                 "shipping_discount": 0
//                   //               }
//                   //             },
//                   //             "description": "The payment transaction description.",
//                   //             // "payment_options": {
//                   //             //   "allowed_payment_method":
//                   //             //       "INSTANT_FUNDING_SOURCE"
//                   //             // },
//                   //             "item_list": {
//                   //               "items": [
//                   //                 {
//                   //                   "name": "Apple",
//                   //                   "quantity": 4,
//                   //                   "price": '5',
//                   //                   "currency": "USD"
//                   //                 },
//                   //                 {
//                   //                   "name": "Pineapple",
//                   //                   "quantity": 5,
//                   //                   "price": '10',
//                   //                   "currency": "USD"
//                   //                 }
//                   //               ],
//                   //
//                   //               // shipping address is not required though
//                   //               //   "shipping_address": {
//                   //               //     "recipient_name": "Raman Singh",
//                   //               //     "line1": "Delhi",
//                   //               //     "line2": "",
//                   //               //     "city": "Delhi",
//                   //               //     "country_code": "IN",
//                   //               //     "postal_code": "11001",
//                   //               //     "phone": "+00000000",
//                   //               //     "state": "Texas"
//                   //               //  },
//                   //             }
//                   //           }
//                   //         ],
//                   //         note: "Contact us for any questions on your order.",
//                   //         onSuccess: (Map params) async {
//                   //           print("onSuccess: $params");
//                   //         },
//                   //         onError: (error) {
//                   //           print("onError: $error");
//                   //           Navigator.pop(context);
//                   //         },
//                   //         onCancel: () {
//                   //           print('cancelled:');
//                   //         },
//                   //       ),
//                   //     ));
//                   //   },
//                   //   child: SvgPicture.asset(
//                   //     'assets/images/paypal_logo.svg', // Replace with the path to your SVG icon
//                   //     height: 80,
//                   //     width: 80,
//                   //   ),
//                   // ),
//
//                   // Expanded(child: FutureBuilder(
//                   //   future: _transaction,
//                   //   builder: (BuildContext context,AsyncSnapshot<UpiResponse> snapshot){
//                   //     if(snapshot.connectionState==ConnectionState.done){
//                   //       if(snapshot.hasError){
//                   //         return Center(
//                   //           child: Text(
//                   //             // _upiErrorHandler(snapshot.error.runtimeType),
//                   //             'Error'
//                   //           ),
//                   //         );
//                   //       }
//                   //       UpiResponse _upiResponse = snapshot.data!;
//                   //       print(_upiResponse);
//                   //       return Text('done');
//                   //     }else{
//                   //       return Center(child:Text(''));
//                   //     }
//                   //   },
//                   // ))
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
