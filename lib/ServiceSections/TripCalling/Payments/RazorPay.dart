import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/cupertino.dart';
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
          'timeout': 60, // in seconds
          'prefill': {
            'contact': '8175902793',
            'email': 'culturtap@gmail.com'
          }
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
