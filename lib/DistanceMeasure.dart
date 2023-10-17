import 'package:flutter/material.dart';

class distance extends StatefulWidget {
  const distance({super.key});

  @override
  State<distance> createState() => _allStoresState();
}

class _allStoresState extends State<distance> {
  Positioned? _currentUserPosition;
  double? distanceInMeter = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivery"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text("hello"),
      ),
    );
  }
}
