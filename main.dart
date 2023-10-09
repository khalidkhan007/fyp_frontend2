import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

import 'HomePage.dart';
import 'current_location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RestaurantHomePage (),
    );
  }
}

