// lib/presentation/screens/splash/splash_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/core/constants/colors.dart';
import 'package:rovify/presentation/blocs/auth/auth_bloc.dart';
import 'package:rovify/presentation/blocs/auth/auth_state.dart';
import 'package:rovify/presentation/screens/auth/signup_bottom_sheet.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentIndex = 0;
  Timer? _timer;
  bool _isHeldDown = false;
  double _opacity = 1.0;

  /// A helper widget to display a single image used in the splash collage.
  /// It wraps the image in a rounded rectangle and allows for a larger variant.
  Widget _collageImage(BuildContext context, path, {bool large = false}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 3), // white border
      ),
      child: ClipRRect(
        // Apply rounded corners to the image
        borderRadius: BorderRadius.circular(12),
        // Set size based on whether the image should be large or standard
        child: Image.asset(
          path,
          height: large ? screenWidth * 0.50 : screenWidth * 0.35,
          width: large ? screenWidth * 0.40 : screenWidth * 0.28,
          fit: BoxFit.cover, // Ensure the image fills its container proportionally
        ),
      ),
    );
  }

  // Splash content data
  final List<Map<String, dynamic>> splashData = [
    {
      "title": "WELCOME TO YOUR EVENT UNIVERSE",
      "description":
          "Discover, attend, and own your favorite events with fraud-proof NFT tickets",
      "backgroundColor": AppColors.splashBackground1,
      "textColor": AppColors.splash1,
      "buttonColor": AppColors.splash1,
      "isStacked": true,
    },
    {
      "title": "DISCOVER ANYWHERE",
      "description":
          "Find events worldwide on your real-time discovery map. From local concerts to global premieres",
      "image": "assets/splash-images/image10.png",
      "overlay": "assets/splash-images/overlay1.png",
      "backgroundColor": AppColors.splashBackground2,
      "textColor": AppColors.splash2,
      "buttonColor": AppColors.splash2,
      "isStacked": false,
    },
    {
      "title": "EXPERIENCE TOGETHER",
      "description":
          "Join live event rooms, chat with friends, and experience every moment as a community",
      "image": "assets/splash-images/image4.png",
      "overlay": "assets/splash-images/overlay2.png",
      "backgroundColor": AppColors.splashBackground3,
      "textColor": AppColors.splash3,
      "buttonColor": AppColors.splash3,
      "isStacked": false,
    },
    {
      "title": "OWN YOUR MEMORIES",
      "description":
          "Collect exclusive NFT memorabilia, badges, and memory reels that prove you were there",
      "image": "assets/splash-images/image16.png",
      "overlay": "assets/splash-images/overlay3.png",
      "backgroundColor": AppColors.splashBackground4,
      "textColor": AppColors.splash4,
      "buttonColor": AppColors.splash4,
      "isStacked": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait for splash screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _startAutoFade();
  }

  void _startAutoFade() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isHeldDown) return;

      setState(() => _opacity = 0.0);
      Future.delayed(const Duration(milliseconds: 400), () {
        setState(() {
          _currentIndex = (_currentIndex + 1) % splashData.length;
          _opacity = 1.0;
        });
      });
    });
  }

  Future <void> _goToSignUpSheet() async{
    _timer?.cancel(); // Stop splash screen animation
    // Wait for bottom sheet to close
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SignUpBottomSheet(),
    );
    // Restart animation once user closes the sheet
    _startAutoFade();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Reset orientation settings
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = splashData[_currentIndex];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          Future.delayed(Duration(milliseconds: 100), () {
            // Use context safely by checking if widget is still mounted
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Colors.white,
                  title: Row(
                    children: const [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Oops!"),
                    ],
                  ),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
            }
          });
        }
      },
     
    child: GestureDetector(
      onTapDown: (_) => setState(() => _isHeldDown = true),
      onTapUp: (_) => setState(() => _isHeldDown = false),
      onTapCancel: () => setState(() => _isHeldDown = false),
      child: Scaffold(
        backgroundColor: current["backgroundColor"],
        body: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: _opacity,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 16), // Top padding + small spacing
          
                  // For responsive UI on different screen sizes
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final imageSize = screenWidth * 0.55;
          
                      return Column(
                        children: [
                          if (current["isStacked"])
                            SizedBox(
                              height: imageSize + 100,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
          
                                  // Layered collage of stacked images
                                  // Row 1
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top - 80,
                                    left: screenWidth * -0.05,
                                    child: Transform.rotate(
                                      angle: -0.3,
                                      child: _collageImage(context, "assets/stack-images/image6.png", large: true),
                                    ),
                                  ),
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top -35,
                                    left: screenWidth * 0.60,
                                    child: Transform.rotate(
                                      angle: 0.5,
                                      child: _collageImage(context, "assets/stack-images/image10.png", large: true),
                                    ),
                                  ),
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top -70,
                                    left: screenWidth * 0.30,
                                    child: Transform.rotate(
                                      angle: 0.02,
                                      child: _collageImage(context, "assets/stack-images/image5.png", large: true),
                                    ),
                                  ),
          
                                  // Row 2
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top + 60,
                                    left: screenWidth * -0.05,
                                    child: Transform.rotate(
                                      angle: -0.4,
                                      child: _collageImage(context, "assets/stack-images/image1.png", large: true),
                                    ),
                                  ),
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top + 30,
                                    left: screenWidth * 0.30,
                                    child: Transform.rotate(
                                      angle: 0,
                                      child: _collageImage(context, "assets/stack-images/image4.png", large: true),
                                    ),
                                  ),
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top + 55,
                                    left: screenWidth * 0.65,
                                    child: Transform.rotate(
                                      angle: 0.50,
                                      child: _collageImage(context, "assets/stack-images/image2.png", large: true),
                                    ),
                                  ),
          
                                  // Bottom row
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top + 110,
                                    left: screenWidth * 0.16,
                                    child: Transform.rotate(
                                      angle: 0.1,
                                      child: _collageImage(context, "assets/stack-images/image8.png"),
                                    ),
                                  ),
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top + 110,
                                    left: screenWidth * 0.45,
                                    child: Transform.rotate(
                                      angle: 0.50,
                                      child: _collageImage(context, "assets/stack-images/image9.png"),
                                    ),
                                  ),
          
                                  // Final middle-top images (hero focus)
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top + 170,
                                    left: screenWidth * 0.20,
                                    child: Transform.rotate(
                                      angle: -0.30,
                                      child: _collageImage(context, "assets/stack-images/image3.png"),
                                    ),
                                  ),
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top + 170,
                                    left: screenWidth * 0.50,
                                    child: Transform.rotate(
                                      angle: 0.20,
                                      child: _collageImage(context, "assets/stack-images/image7.png"),
                                    ),
                                  ),

                                  // Logo at the center bottom of the collage
                                  Positioned(
                                    top: -MediaQuery.of(context).padding.top + 260,
                                    left: (screenWidth / 2) - 40, // Centering based on 80px width
                                    child: Image.asset(
                                      'assets/splash-images/logo-yellow.png',
                                      width: 80,
                                      height: 75,
                                    ),
                                  ),
                                ],
                              ),
                          )
          
                          else
                            SizedBox(
                              height: imageSize + 100,
                              child: Center(
                                child: SizedBox(
                                  width: imageSize + 60,
                                  height: imageSize + 100,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      // Logo
                                      Positioned(
                                        top: 0,
                                        child: Opacity(
                                          opacity: 0.73,
                                          child: Transform.scale(
                                            scale: 1.5,
                                            child: Image.asset(
                                              'assets/splash-images/logo-black.png',
                                              width: 74,
                                              height: 51,
                                            ),
                                          ),
                                        ),
                                      ),
          
                                      // Main image
                                      Positioned(
                                        top: 100,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(13),
                                          child: Container(
                                            width: imageSize,
                                            height: imageSize,
                                            color: Colors.white,
                                            child: Image.asset(
                                              current["image"],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
          
                                      // Overlay image
                                      if (current["overlay"] != null)
                                        Positioned(
                                          top: imageSize + 40,
                                          right: -6,
                                          child: Transform.rotate(
                                            angle: 12.83 * pi / 300,
                                            child: Image.asset(
                                              current["overlay"],
                                              width: imageSize * 0.5,
                                              height: imageSize * 0.5,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
          
                          const SizedBox(height: 32),
          
                          // Title text
                          SizedBox(
                            width: 270,
                            child: Text(
                              current["title"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _currentIndex == 0 ? 36 : 44, // Reduce font size if the indext of the title is zero
                                // fontSize: 44,
                                height: _currentIndex == 0 ? 1.0 : 1.2, // Reduce line height if the indext of the title is zero
                                color: current["textColor"],
                              ),
                            ),
                          ),
          
                          const SizedBox(height: 12),
          
                          // Description text
                          SizedBox(
                            width: 270,
                            child: Text(
                              current["description"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: current["textColor"],
                              ),
                            ),
                          ),
          
                          const SizedBox(height: 40),
                        ],
                      );
                    },
                  ),
          
                  // Dot Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      splashData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 10,
                        width: _currentIndex == index ? 20 : 10,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.activeTranslucentBlack
                              : AppColors.inactiveTranslucentBlack,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
          
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 40), // Enough buffer for bottom gestures
          
                  // Get Started button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      height: 56,
                      width: 331,
                      child: ElevatedButton(
                        onPressed: _goToSignUpSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: current["buttonColor"],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Stack(
                          children: const [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Get Started",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.arrow_forward, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      )
      ),
    );
  }
}