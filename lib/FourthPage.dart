import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_flutter/ThirdPage.dart';

class FourthPage extends StatefulWidget {
  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  var _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
    });

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationController.text = "Location permission denied forever.";
        _isLoading = false;
      });
      return;
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() {
        _locationController.text = "Location permission denied.";
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _locationController.text =
        "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationController.text = "Error fetching location: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 35),
                    height: 250,
                    child : Image.asset('assets/images/fourthPage.png'),
                    color: Colors.white,
                  ),
                  Text(
                    'CONFIRM YOUR LOCATION',
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 31),
                    child: Text(
                      'Fetched Location',
                      style: TextStyle(fontSize: 25, color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 19),
                    width: 300,
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Fetching location...',
                      ),
                      enabled: false,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _fetchLocation,
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Container(
                    width: 330,
                    height: 70,
                    child: FilledButton(
                      backgroundColor: Colors.orange,
                      onPressed: () {
                        String fetchedLocation = _locationController.text;
                        print('Location: $fetchedLocation');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ThirdPage()),
                        );
                      },
                      child: Center(
                        child: Text(
                          'DONE',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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

void main() {
  runApp(MaterialApp(
    home: FourthPage(),
  ));
}
