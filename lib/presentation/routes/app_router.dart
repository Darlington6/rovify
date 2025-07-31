import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../pages/explore/explore_page.dart';
import '../pages/echo/echo_screen.dart';
import '../pages/explore/widgets/creator_dashboard screen.dart';
import '../pages/event_form_screen.dart';
import '../pages/explore/widgets/become_creator.dart';
import '../pages/explore/widgets/profile_update.dart';

/// Handles all app navigation routes using GoRouter.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (context, state) => const ExplorePage(),
      ),
      GoRoute(
        path: '/echo',
        name: 'echo',
        builder: (context, state) => const EchoScreen(),
      ),
      GoRoute(
        path: '/stream',
        name: 'stream',
        builder: (context, state) =>
            _placeholderScreen(context, 'Stream', 'Coming Soon!'),
      ),
      GoRoute(
        path: '/marketplace',
        name: 'marketplace',
        builder: (context, state) =>
            _placeholderScreen(context, 'Marketplace', 'Coming Soon!'),
      ),
      GoRoute(
        path: '/addEvent',
        name: 'addEvent',
        builder: (context, state) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            return _unauthenticatedScreen(
              context,
              message: 'Please sign in to create events',
            );
          }
          return EventFormScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/creatorDashboard',
        name: 'creatorDashboard',
        builder: (context, state) {
          final userId =
              state.extra as String? ?? FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            return _unauthenticatedScreen(context);
          }
          return CreatorDashboardScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/becomeCreator',
        name: 'becomeCreator',
        builder: (context, state) {
          final userId =
              state.extra as String? ?? FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            return _unauthenticatedScreen(context);
          }
          return BecomeCreatorScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/updateProfile',
        name: 'updateProfile',
        builder: (context, state) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            return _unauthenticatedScreen(
              context,
              message: 'Please sign in to update profile',
            );
          }
          return const ProfileUpdatePage(); // Update if your widget needs userId
        },
      ),
    ],
  );

  static Widget _unauthenticatedScreen(
    BuildContext context, {
    String message = 'User authentication required',
  }) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _placeholderScreen(
    BuildContext context,
    String title,
    String message,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$title feature is under development',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/explore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Back to Explore'),
            ),
          ],
        ),
      ),
    );
  }
}
