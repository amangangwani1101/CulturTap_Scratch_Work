import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import 'package:upi_india/upi_response.dart';

class UpiPayments extends StatefulWidget {

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
        flexibleAmount: true
    );
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
              return GestureDetector(
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
