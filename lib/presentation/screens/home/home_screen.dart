// lib/presentation/screens/home/home_screen.dart

// Import packages/modules
import 'package:flutter/material.dart';

/// Home screen shown after onboarding.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Rovify Home',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}