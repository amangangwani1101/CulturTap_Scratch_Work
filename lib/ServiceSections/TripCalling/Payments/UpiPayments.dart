import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:upi_india/upi_india.dart';
import 'package:upi_india/upi_response.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/Constant.dart';
import 'Paypal_checkout.dart';

class UpiPayments extends StatefulWidget {
String? name,merchant,phoneNo;
dynamic amount;
UpiPayments({this.name,this.merchant,this.amount,this.phoneNo});
  @override
  State<UpiPayments> createState() => _UpiPaymentsState();
}

void main(){
  runApp(UpiPayments());
}
class _UpiPaymentsState extends State<UpiPayments> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>?apps;

  @override
  void initState() {
    print('Comming');
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value){
      setState(() {
        apps = value;
      });
    }).catchError((err){
      print('Upi Error $err');
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async{
    return _upiIndia.startTransaction(app: app,
        receiverUpiId: '8175902793@paytm',
        receiverName: 'Aman',
        transactionRefId: 'Testing Upi',
        transactionNote: 'Working On It',
        amount: 1,
    );
  }

  Future<void> paymentHandler(String name,String merchantName,double amount,String phone) async {
    try {
      // 1. Create a payment intent on the server
      final response = await http.post(Uri.parse('${Constant().serverUrl}/customerPayment'),
          body: {
            'phone':'6971833439',
            'amount': amount.toString(),
            'name':name
          });

      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            merchantDisplayName: merchantName,
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
          ));
      final res = await Stripe.instance.presentPaymentSheet();
      print('wlhfaui $res');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment is successful'),
        ),
      );
    } catch (errorr) {
      print(errorr);
      if (errorr is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured ${errorr.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured $errorr'),
          ),
        );
      }
    }
  }

  Widget displayUpiApps(){
    if(apps == null){
      return const Center(child:CircularProgressIndicator());
    }else if(apps!.isEmpty){
      return Center(
        child: Text('No Apps Are There To show',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      );
    }else{
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map((UpiApp app){
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 40,),
                  // Image.asset('assets/images/settings.svg',width: 200,height: 200,),
                  GestureDetector(
                    onTap: (){
                      paymentHandler(widget.name!, widget.merchant!, widget.amount, widget.phoneNo!);
                    },
                    child: SvgPicture.asset(
                      'assets/images/stripe_logo.svg', // Replace with the path to your SVG icon
                      height: 60,
                      width: 60,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => PaypalCheckout(
                          sandboxMode: true,
                          clientId: "AUFy2J4GmEGTVrrul-7TaRLlERKB6qLvcotF95b5UIfQgeXcGhQNApYwtwHXV2HoO7rpFzM8Xdb7Vxw9",
                          secretKey: "EAhUcMa6EPzuApgDBBl51-dOiAwsxHay6jOdUpbLyz1LkU-RHtDwXCrKkPQnGBmY9ejwU3XymP8a6vnf",
                          returnURL: "success.snippetcoder.com",
                          cancelURL: "cancel.snippetcoder.com",
                          transactions: const [
                            {
                              "amount": {
                                "total": '70',
                                "currency": "USD",
                                "details": {
                                  "subtotal": '70',
                                  "shipping": '0',
                                  "shipping_discount": 0
                                }
                              },
                              "description": "The payment transaction description.",
                              // "payment_options": {
                              //   "allowed_payment_method":
                              //       "INSTANT_FUNDING_SOURCE"
                              // },
                              "item_list": {
                                "items": [
                                  {
                                    "name": "Apple",
                                    "quantity": 4,
                                    "price": '5',
                                    "currency": "USD"
                                  },
                                  {
                                    "name": "Pineapple",
                                    "quantity": 5,
                                    "price": '10',
                                    "currency": "USD"
                                  }
                                ],

                                // shipping address is not required though
                                //   "shipping_address": {
                                //     "recipient_name": "Raman Singh",
                                //     "line1": "Delhi",
                                //     "line2": "",
                                //     "city": "Delhi",
                                //     "country_code": "IN",
                                //     "postal_code": "11001",
                                //     "phone": "+00000000",
                                //     "state": "Texas"
                                //  },
                              }
                            }
                          ],
                          note: "Contact us for any questions on your order.",
                          onSuccess: (Map params) async {
                            print("onSuccess: $params");
                          },
                          onError: (error) {
                            print("onError: $error");
                            Navigator.pop(context);
                          },
                          onCancel: () {
                            print('cancelled:');
                          },
                        ),
                      ));
                    },
                    child: SvgPicture.asset(
                      'assets/images/paypal_logo.svg', // Replace with the path to your SVG icon
                      height: 80,
                      width: 80,
                    ),
                  ),
                  GestureDetector(
                    onTap:(){
                      _transaction  = initiateTransaction(app);
                      setState(() {});
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.memory(
                            app.icon,
                            height: 60,
                            width: 60,
                          ),
                          Text(app.name),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }
  }
  void _upiErrorHandler(err){}

  void _checkTxnStatus(String status){
    switch(status){
      case UpiPaymentStatus.SUCCESS:
        print('Txn Success');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Txn Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Txn failed');
        break;
      default:
        print('Umknown id');
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(child: displayUpiApps()),
            Expanded(child: FutureBuilder(
              future: _transaction,
              builder: (BuildContext context,AsyncSnapshot<UpiResponse> snapshot){
                if(snapshot.connectionState==ConnectionState.done){
                  if(snapshot.hasError){
                    return Center(
                      child: Text(
                        // _upiErrorHandler(snapshot.error.runtimeType),
                        'Error'
                      ),
                    );
                  }
                  UpiResponse _upiResponse = snapshot.data!;
                  print(_upiResponse);
                  return Text('done');
                }else{
                  return Center(child:Text(''));
                }
              },
            ))
          ],
        ),
      ),
    );
  }
}
