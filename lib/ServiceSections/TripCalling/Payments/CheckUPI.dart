import 'package:flutter/material.dart';
import 'package:quantupi/quantupi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Upi pay'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var amount=TextEditingController();

  var descrip=TextEditingController();
  var name=TextEditingController();
  var upiID=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: upiID,
                decoration: InputDecoration(
                    hintText: "Upi Id",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!)
                    )
                ),
              ),
              TextField(
                controller: name,
                decoration: InputDecoration(
                    hintText: "Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!)
                    )
                ),
              ),
              TextField(
                controller: descrip,
                decoration: InputDecoration(
                    hintText: "Description",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!)
                    )
                ),
              ),
              TextField(
                controller: amount,
                decoration: InputDecoration(
                    hintText: "Amount",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!)
                    )
                ),
              ),
              SizedBox(height: 20,),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.green)),
                      onPressed: (){
                        paymentStart();
                      }, child: Text("Pay",style: TextStyle(color: Colors.white,fontSize: 20),)))
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void paymentStart()async {
    // try{
    Quantupi upi = Quantupi(
      receiverUpiId: upiID.text,//my upi id
      receiverName: name.text,
      transactionRefId: 'kdskd',
      transactionNote: descrip.text,
      amount: double.parse(amount.text),
    );
    final response = await upi.startTransaction();
    print(response);

    showDialog(context: context, builder: (BuildContext context) {
      return  AlertDialog(
        title: Text("${response}"),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("ok"))
        ],
      );
    });
    // } catch (e) {
    //   print(e);
    //   showDialog(context: context, builder: (BuildContext context) {
    //     return  AlertDialog(
    //       title: Text("Payment Failed"),
    //       actions: [
    //         TextButton(onPressed: (){
    //           Navigator.pop(context);
    //         }, child: Text("ok"))
    //       ],
    //     );
    //   });
    // }
  }
}