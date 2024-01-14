import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';

void main() {
  runApp(PaypalCheckouts());
}

class PaypalCheckouts extends StatelessWidget {
  const PaypalCheckouts({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(

      builder: (BuildContext context) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: CheckoutPage(),
        );
      }
    );
  }
}

class CheckoutPage extends StatefulWidget {
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}


class _CheckoutPageState extends State<CheckoutPage> {

  @override
  void initState() {
    super.initState();
    startPayment();
  }
  @override
  void startPayment(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckout(
        sandboxMode: true,
        clientId: "AfWVDwN3FkjEDEeEWmiPxeKHQWocPLIHa-Tnu9IrgGb3qVOg3jvht3ri555-tAy8W4c_qGaSaxNajrH3",
        secretKey: "EDOSA_BElNYzgVi3Y1QNOGw7yc3pfXks8wKN1KHgZUEU7qe1l4qTJ9jIcvYc8qX9_Q7WnN-rSAeqTLE6",
        returnURL: "success.snippetcoder.com",
        cancelURL: "cancel.snippetcoder.com",
        transactions: const [
          {
            "amount": {
              "total": '700',
              "currency": "INR",
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
          Navigator.of(context).pop(true);
        },
        onError: (error) {
          print("onError: $error");
          Navigator.of(context).pop(false);
        },
        onCancel: () {
          print('cancelled:');
          Navigator.of(context).pop(false);
        },
      ),
    ));
  }
  Widget build(BuildContext context) {
    return Scaffold();
  }
}