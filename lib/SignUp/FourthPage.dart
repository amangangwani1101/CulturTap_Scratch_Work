import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


import '../CustomItems/CostumAppbar.dart';

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

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      setState(() {
        _locationController.text =
        "Location: ${place.locality}, ${place.administrativeArea}, ${place.country}";
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
      appBar: CustomAppBar(title:""),
      body: Container(
        height : double.infinity,
        width: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width : 325,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 35),
                    height: 248,
                    width : 389,
                    child : Image.asset('assets/images/fourthPage.png'),
                    color: Colors.white,
                  ),
                  Container(
                    child : Image.asset('assets/images/SignUp4.png'),
                  ),
                  Container(
                    height : 20,
                  ),
                  Text(
                    'CONFIRM YOUR LOCATION',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      fontWeight: FontWeight.w600,),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 31),
                    child: Text(
                      'Fetched Location',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 19),
                    width: 325,
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
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    width: 325,
                    height: 63,
                    child: FilledButton(
                      backgroundColor: Colors.orange,
                      onPressed: () {
                        String fetchedLocation = _locationController.text;
                        print('Location: $fetchedLocation');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FourthPage()),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Updated border radius
        ),
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
