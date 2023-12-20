import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
// import 'package:http/http.dart'as http;

void main(){
  runApp(PhonePePayment());
}


class PhonePePayment extends StatefulWidget {
  const PhonePePayment({super.key});

  @override
  State<PhonePePayment> createState() => _PhonePePaymentState();
}

class _PhonePePaymentState extends State<PhonePePayment> {
  // for testing its UAT_SIM in future change it
  String environment = 'UAT_SIM';
  String appId = '';
  String merchantId = 'PGTESTPAYUAT';
  bool enableLogging = true;
  String checkSum = '';
  // for authentication
  String saltKey = '099eb0cd-02cf-4e2a-8aca-3e6c6aff0399';
  String saltIndex = '1';
  String callBAckUrl = 'https://webhook.site/4f42d019-bd0b-41d1-a7e6-43161d8eee4c';
  String body = "";
  String apiEndPoint = "/pg/v1/pay";
  Object ? result;

  getCheckSum(){
    final data = {
        "merchantId": merchantId,
        "merchantTransactionId": "transaction_123",
        "merchantUserId": "90223250",
        "amount": 100,
        "mobileNumber": "9999999999",
        "callbackUrl": callBAckUrl,
        "paymentInstrument": {
          "type": "PAY_PAGE",
        },
    };
    String base64Body = base64.encode(utf8.encode(json.encode(data)));

    checkSum = '${sha256.convert(utf8.encode(base64Body+apiEndPoint+saltKey)).toString()}###${saltIndex}';

    return base64Body;
  }

  @override
  void initState() {
    super.initState();
    phonePeInit();
    body = getCheckSum().toString();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title:Text('Flutter App')),
        body: Column(
          children: [
            Container(
              child: ElevatedButton(
                onPressed: (){
                  startTransaction();
                },
                child: Text('Proceed To Pay'),
              ),
            ),
            SizedBox(height: 20,),
            Text('Result is $result'),
          ],
        ),
      ),
    );
  }

  void phonePeInit() {
    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) => {
      setState(() {
        result = 'PhonePe SDK Initialized - $val';
      })
    }).catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }



  void startTransaction()async{
    try {
      var response = PhonePePaymentSdk.startPGTransaction(
          body, callBAckUrl, checkSum, {}, apiEndPoint, '');
      response
          .then((val) => {
        setState(() {
          if(val!=null){
            String status = val['status'].toString();
            String error = val['error'].toString();

            if(status == 'SUCCESS'){
              result = 'UPI Loaded - And Success';
            }else{
              result = 'UPI Loaded - But Error $error';
            }

          }else{
            result = 'A Problem Occur';
          }
        })
      })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError(error);
    }
  }

  void handleError(error) {
    setState(() {
      result = {'error':error};
    });
  }
}
