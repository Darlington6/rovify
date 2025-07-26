import 'package:flutter/material.dart';

class ImplicitAnimationScreen extends StatefulWidget {
  const ImplicitAnimationScreen({super.key});

  @override
  State<ImplicitAnimationScreen> createState() => _ImplicitAnimationScreenState();
}

class _ImplicitAnimationScreenState extends State<ImplicitAnimationScreen> {
  // Variables to animate
  double _width = 100;
  double _height = 100;
  Color _color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
        title: const Text('Implicit Animation', style: TextStyle(color: Colors.white),),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _width = _width == 100 ? 200 : 100;
              _height = _height == 100 ? 200 : 100;
              _color = _color == Colors.blue ? Colors.red : Colors.blue;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            width: _width,
            height: _height,
            color: _color,
            child: const Center(
              child: Text(
                'Tap Me!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
