import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.'
    'dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';


class MapNavigatorScreen extends StatefulWidget {
  double latitude,longitude;
  MapNavigatorScreen({required this.latitude,required this.longitude});

  @override
  State<MapNavigatorScreen> createState() => _MapNavigatorScreenState();
}

class _MapNavigatorScreenState extends State<MapNavigatorScreen> {
  final Completer<GoogleMapController?> _controller = Completer();
  Map<PolylineId,Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Location location = Location();
  Marker?sourcePosition,destinationPosition;
  loc.LocationData?_currentPosition;
  LatLng curLocation = LatLng(23.0525,72.5667);
  StreamSubscription<loc.LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    getNavigation();
    addMarker();
  }

  @override
  void dispose(){
    locationSubscription?.cancel();
    super.dispose();
  }

  addMarker(){
    setState(() {
      sourcePosition = Marker(
      markerId: MarkerId('source'),
      position: curLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      destinationPosition = Marker(
        markerId: MarkerId('destination'),
        position: LatLng(widget.longitude,widget.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      );
    });
  }

  getNavigation() async{
    bool _serviceEnable;
    PermissionStatus _permissonGranted;
    final GoogleMapController? controller = await _controller.future;
    location.changeSettings(accuracy: loc.LocationAccuracy.high);
    _serviceEnable = await location.serviceEnabled();

    if(!_serviceEnable){
      _serviceEnable = await location.requestService();
      if(!_serviceEnable){ return; }
    }

    _permissonGranted = await location.hasPermission();
    if(_permissonGranted == PermissionStatus.denied){
      _permissonGranted = await location.requestPermission();
      if(_permissonGranted!=PermissionStatus.granted){
        return;
      }
    }

    if(_permissonGranted == loc.PermissionStatus.granted){
      _currentPosition = await location.getLocation();
      curLocation = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
      location.onLocationChanged.listen((LocationData currentLocation) {
        controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(currentLocation.latitude!,currentLocation.longitude!),
        zoom: 16,
      )));
      if(mounted){
        controller?.showMarkerInfoWindow(MarkerId(sourcePosition!.markerId.value));
        setState(() {
          curLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          sourcePosition = Marker(
            markerId: MarkerId(currentLocation.toString()),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue),
            position: LatLng(currentLocation.latitude!,currentLocation.longitude!),
            infoWindow: InfoWindow(
              title: double.parse(
                  (getDistance(LatLng(widget.latitude, widget.longitude))
                  .toStringAsFixed(2))).toString()),
            onTap: (){
              print('Marker is Clicked');
            },
          );
        });
        getDirections(LatLng(widget.latitude, widget.longitude));
      }
      });
    }
  }

  getDirections(LatLng dst)async{
    List<LatLng>polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyCDSwc_lbmjRj0BWHkZfPgyAPYgIPDxxTI',
        PointLatLng(curLocation.latitude, curLocation.longitude),
        PointLatLng(dst.longitude,dst.longitude),
        travelMode: TravelMode.driving
    );
    if(result.points.isNotEmpty){
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat':point.latitude,'lng':point.longitude});
      });
    }else{
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng>polylineCoordinates){
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points:polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistance(lat1,lon1,lat2,lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5-c((lat2-lat1)*p)/2 + c(lat1*p) * c(lat2*p) * (1-c((lon2-lon1)*p))/2;
    return 12742 * asin(sqrt(a));
  }

  double getDistance(LatLng destposition){
    return calculateDistance(curLocation.latitude, curLocation.longitude, destposition.latitude, destposition.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sourcePosition==null
        ? Center(child: CircularProgressIndicator(),)
        : Stack(
        children: [
          GoogleMap(initialCameraPosition: CameraPosition(
              target: curLocation,
              zoom:16,
            ),
            markers: {sourcePosition!,destinationPosition!},
            onTap: (latLng){
                print(latLng);
            },
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: 30,
            left: 15,
            child: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,color: Colors.blue
            ),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.navigation_outlined,
                color: Colors.white,
                ),
                onPressed: ()async{
                  String mapsUrl =
                      'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}';
                  if (await canLaunch(mapsUrl)) {
                    await launch(mapsUrl);
                  } else {
                    throw 'Could not launch $mapsUrl';
                  }
                },
              ),
            ),
          ))
        ],
      ),
    );
  }
}
