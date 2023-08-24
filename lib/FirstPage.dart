import 'package:flutter/material.dart';
import 'package:learn_flutter/SecondPage.dart';

void main() {
  runApp(const FirstPage());
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Center(
        child: const MyHomePage(title: 'LogIn'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var nameText = TextEditingController();
  bool validate = false;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'CULTURTAP',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Container(
            width: double.infinity,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 35),
                      height: 300,
                      color: Colors.white54,
                    ),
                    Text('FirstPage',
                        style: TextStyle(
                            fontSize: 35,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    Container(
                        margin: EdgeInsets.only(bottom: 31),
                        child: Text('Explore, Update, Guide & Earn !',
                            style: TextStyle(fontSize: 25, color: Colors.black))),
                    Text('Please Enter Your Name',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    Container(
                      margin: EdgeInsets.only(bottom: 19),
                      width: 300,
                      child: TextField(
                        controller: nameText,
                        decoration: InputDecoration(
                          hintText: 'Ex : Kishor Kumar',
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 21),
                      child: Row(
                        children: [
                          Text('Already User ?',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w100)),
                          TextButton(
                            onPressed: () {
                              // TODO: Add navigation to Sign In page
                            },
                            child: Text('Sign In',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 25,
                                )),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 330,
                      height: 70,
                      child: FilledButton(
                          backgroundColor: Colors.orange,
                          onPressed: () {
                            String Name = nameText.text.toString();
                            print('Name  : ${Name} ');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SecondPage(
                                  phoneNumberController: TextEditingController(),
                                ),
                              ),
                            );
                          },
                          child: Center(
                              child: Text('Next',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 25)))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilledButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  final Color backgroundColor;

  const FilledButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: backgroundColor,
      ),
      child: child,
    );
  }
}
