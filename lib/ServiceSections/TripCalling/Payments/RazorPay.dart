import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/cupertino.dart';
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayIntegration extends StatefulWidget {
  const RazorPayIntegration({super.key});

  @override
  State<RazorPayIntegration> createState() => _RazorPayIntegrationState();
}

class _RazorPayIntegrationState extends State<RazorPayIntegration> {

  var razorPay = Razorpay();
  final razorPayKey = 'rzp_test_QjYe0NMTmgIj40';
  final razorPaySecret = 'jz3ylZooulpNRt6v5gbvuF63';

  @override
  void initState() {
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    openCheckout();
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    Fluttertoast.showToast(
      msg: 'Payment Success!',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    Navigator.of(context).pop(true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    Fluttertoast.showToast(
      msg: 'Payment Error!',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    Navigator.of(context).pop(false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    Fluttertoast.showToast(
      msg: 'Payment Wallets!',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    Navigator.of(context).pop(false);
  }

  void openCheckout()async{
    // Future<String?> razorPayApi(num amount, String receiptId) async {
    //
    //     var auth =
    //         'Basic ' + base64Encode(utf8.encode('$razorPayKey:$razorPaySecret'));
    //     print(auth);
    //     var headers = {'content-type': 'application/json', 'Authorization': auth};
    //     var request =
    //     http.Request('POST', Uri.parse('https://api.razorpay.com/v1/orders'));
    //     request.body = json.encode({
    //       "amount": amount * 100,
    //       "currency": "INR",
    //     });
    //     request.headers.addAll(headers);
    //
    //     http.StreamedResponse response = await request.send();
    //     print(response.statusCode);
    //     if (response.statusCode == 200) {
    //       dynamic data= jsonDecode(await response.stream.bytesToString());
    //       String orderId = data['id'];
    //       print('Data us $data');
    //       return orderId;
    //     } else {
    //       print('whats problme');
    //       throw('error');
    //       return null;
    //     }
    //   }
    try{

      if(true){
        var options = {
          'key': 'rzp_live_GmFI5alUgs6ny1',
          'amount': 100, //in the smallest currency sub-unit.
          'name': 'CulturTap',
          'description': 'Local Assistant',

          'prefill': {
            'contact': userPhoneNumber,
            'email': 'culturtap@gmail.com'
          },
          'external' : {
            'wallets' : ['paytm'],

          },
          'theme' : {'color' : '#FB8C00'},
          'image' : 'data:image/png;base64,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',
          'currency' : 'INR',
        };
        razorPay.open(options);
      }else{
        print('Order Not Made');
      }
    }catch(err){
      print('Error in payments,$err');
    }
  }

  @override
  void dispose() {
    razorPay.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class ApiServices {
  final razorPayKey = 'rzp_test_QjYe0NMTmgIj40';
  final razorPaySecret = 'jz3ylZooulpNRt6v5gbvuF63';

  razorPayApi(num amount, String receiptId) async {
    var auth =
        'Basic ' + base64Encode(utf8.encode('$razorPayKey:$razorPaySecret'));
    var headers = {'content-type': 'application/json', 'Authorization': auth};
    var request =
    http.Request('POST', Uri.parse('https://api.razorpay.com/v1/orders'));
    request.body = json.encode({
      // Amount in smallest unit
      // like in paise for INR
      "amount": amount * 100,
      // Currency
      "currency": "INR",
      // Receipt Id
      "receipt": receiptId
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      return {
        "status": "success",
        "body": jsonDecode(await response.stream.bytesToString())
      };
    } else {
      return {"status": "fail", "message": (response.reasonPhrase)};
    }
  }
}
