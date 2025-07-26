import 'package:flutter/material.dart';
import 'package:breakout1_animations/screens/implicit_animation_screen.dart';
import 'screens/marketplace_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MarketplaceScreen(), // <-- Set this!
    );
  }
}
