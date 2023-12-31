import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomerCardForm(),
    );
  }
}

class CustomerCardForm extends StatefulWidget {
  @override
  _CustomerCardFormState createState() => _CustomerCardFormState();
}

class _CustomerCardFormState extends State<CustomerCardForm> {
  void _init() {
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey = 'pk_test_51O1mwsSBFjpzQSTJYIRROzWlVlSlOL4ysCytD2icFn57ISGbDUDaVLyLgFJABlFaHDPgMmmOpvRKxE99x3w90HRf00ZwzrVv0R';
    Stripe.instance.applySettings();
  }

  Future<void> _createCustomerAndAttachCard() async {
    _init();
    final _customer = await _createCustomer();
    print('11::: ${_customer}');
    final _paymentMethod = await _createPaymentMethod(number: '4242424242424242', expMonth: '03', expYear: '23', cvc: '123');
    print('11::: ${_customer}');
    await _attachPaymentMethod(_paymentMethod['id'], _customer['id']);
    await _updateCustomer(_paymentMethod['id'], _customer['id']);
    // await _createSubscriptions(_customer['id']);
  }

  final client = http.Client();
  static Map<String, String> headers = {
    'Authorization': 'Bearer sk_test_51O1mwsSBFjpzQSTJcZbPFYDAWpuV5idzEE62s6n7QHEswXShSp8rJqmWZcejO5jvcTZWcBZHh063PDu2AgTKpneT00sISTulAG',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  Future<Map<String, dynamic>> _createCustomer() async {
    final String url = 'https://api.stripe.com/v1/customers';
    var response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'description': 'new customer'
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to register as a customer.';
    }
  }
  Future<Map<String, dynamic>> _updateCustomer(
      String paymentMethodId, String customerId) async {
    final String url = 'https://api.stripe.com/v1/customers/$customerId';

    var response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'invoice_settings[default_payment_method]': paymentMethodId,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to update Customer.';
    }
  }

  Future<Map<String, dynamic>> _attachPaymentMethod(String paymentMethodId, String customerId) async {
    final String url = 'https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach';
    var response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'customer': customerId,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to attach PaymentMethod.';
    }
  }

  Future<Map<String, dynamic>> _createPaymentMethod(
      {required String number,
        required String expMonth,
        required String expYear,
        required String cvc}) async {
    final String url = 'https://api.stripe.com/v1/payment_methods';
    var response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'type': 'card',
        'card[number]': '$number',
        'card[exp_month]': '$expMonth',
        'card[exp_year]': '$expYear',
        'card[cvc]': '$cvc',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to create PaymentMethod.';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Card Form'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _createCustomerAndAttachCard,
          child: Text('Create Customer and Attach Card'),
        ),
      ),
    );
  }
}
