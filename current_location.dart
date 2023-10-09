//import 'dart:html';
import 'package:geocoding/geocoding.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class current_location extends StatefulWidget {
  const current_location({super.key});
  @override
  State<current_location> createState() => _current_locationState();
}

class _current_locationState extends State<current_location> {
  void getlocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Permission not given");
      LocationPermission asked = await Geolocator.requestPermission();
    } else {
      Position currentpostion = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      print("latitude :" + currentpostion.latitude.toString());
      print("longitute : " + currentpostion.longitude.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Current location"),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              getlocation();
            },
            child: Text("button"),
          ),
        ));
  }
}
