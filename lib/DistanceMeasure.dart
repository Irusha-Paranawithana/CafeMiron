import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:miron/model/colors.dart';

class Distance extends StatefulWidget {
  const Distance({Key? key});

  @override
  State<Distance> createState() => _DistanceState();
}

class _DistanceState extends State<Distance> {
  Position? _currentUserPosition;
  double? distanceInMeter = 0.0;

  Future<void> _getTheDistance() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      if (await Geolocator.checkPermission() == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      _currentUserPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print(_currentUserPosition!.latitude);
    }
    double mironlat = 6.329167109863599;
    double mironlng = 80.85799613887737;

    distanceInMeter = await Geolocator.distanceBetween(
        _currentUserPosition!.latitude,
        _currentUserPosition!.longitude,
        mironlat,
        mironlng);

    double finaldistance = (distanceInMeter ?? 0) / 1000;
  }

  @override
  void initState() {
    _getTheDistance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivery"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),
      body: Center(
        child: Text("hello"),
      ),
    );
  }
}
