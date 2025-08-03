import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rovify/presentation/common/profile_update.dart';
import 'package:rovify/presentation/common/settings_privacy.dart';
import 'package:rovify/presentation/screens/home/home_screen.dart';
import 'package:rovify/presentation/screens/home/tabs/explore_tab.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/become_creator.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/create_event_screen.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/creator_dashboard.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/event_details_screen.dart';
import 'package:rovify/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:rovify/presentation/screens/splash/splash_screen.dart';
import 'package:rovify/presentation/screens/auth/login_bottom_sheet.dart';
import 'package:rovify/presentation/screens/auth/signup_bottom_sheet.dart';
import 'package:rovify/presentation/screens/auth/forgotpassword_bottom_sheet.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    redirect: (BuildContext context, GoRouterState state) {
      final auth = FirebaseAuth.instance;
      final isAuthenticated = auth.currentUser != null;
      final currentPath = state.uri.toString();

      final isSplashRoute = currentPath == '/splash';
      final isAuthRoute = currentPath.startsWith('/auth');

      if (isAuthenticated && isAuthRoute) {
        return '/explore';
      }

      if (!isAuthenticated && !isSplashRoute && !isAuthRoute && currentPath != '/onboarding') {
        return '/splash';
      }

      return null;
    },

    routes: [
      /// Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      /// Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Home
      GoRoute(path: '/home', 
      name: 'home', 
      builder: (context, state) => const HomeScreen()
      ),

      /// Auth Bottom Sheet Routes
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => Scaffold(body: child, resizeToAvoidBottomInset: false),
        routes: [
          _buildBottomSheetRoute('/auth/login', const LoginBottomSheet()),
          _buildBottomSheetRoute('/auth/signup', const SignUpBottomSheet()),
          _buildBottomSheetRoute('/auth/forgot-password', const ForgotPasswordBottomSheet()),
        ],
      ),

      /// Main App Routes
      ShellRoute(
        builder: (context, state, child) => Scaffold(body: child, resizeToAvoidBottomInset: false),
        routes: [
          GoRoute(
            path: '/explore',
            name: 'explore',
            builder: (context, state) => const ExploreTab(),
          ),

          /// Creator Dashboard and Event Management Routes
          GoRoute(
            path: '/creatorDashboard',
            name: 'creatorDashboard',
            builder: (context, state) {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) {
                return _unauthenticatedScreen(
                  context,
                  message: 'Please sign in to access creator dashboard',
                );
              }
              return CreatorDashboardScreen(userId: userId);
            },
          ),

          GoRoute(
            path: '/addEvent',
            name: 'addEvent',
            builder: (context, state) {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              return userId == null
                  ? _unauthenticatedScreen(context, message: 'Please sign in to create events')
                  : CreateEventScreen(userId: userId);
            },
          ),
          GoRoute(
            name: 'creatorEventDetails',
            path: '/event/:eventId/:userId',
            builder: (context, state) {
              try {
                final eventId = state.pathParameters['eventId']!;
                final userId = state.pathParameters['userId']!;

                // Validate parameters
                if (eventId.isEmpty || userId.isEmpty) {
                  throw Exception('Invalid parameters');
                }

                return EventDetailsScreen(eventId: eventId, userId: userId);
              } catch (e) {
                // Fallback to error handling
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Invalid event details'),
                        ElevatedButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Go Home'),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),

          GoRoute(
            path: '/becomeCreator',
            name: 'becomeCreator',
            builder: (context, state) {
              final userId = state.extra as String? ?? FirebaseAuth.instance.currentUser?.uid;
              return userId == null
                  ? _unauthenticatedScreen(context)
                  : BecomeCreatorScreen(userId: userId);
            },
          ),

          GoRoute(
            path: '/updateProfile',
            name: 'updateProfile',
            builder: (context, state) {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              return userId == null
                  ? _unauthenticatedScreen(context, message: 'Please sign in to update profile')
                  : const ProfileUpdatePage();
            },
          ),

          GoRoute(
            name: 'settingsPrivacy',
            path: '/settings',
            builder: (context, state) => const SettingsPrivacyScreen(),
          ),
        ],
      ),
    ],

    /// Error Page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Route not found: ${state.uri.toString()}'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => context.go('/explore'), child: const Text('Go Home')),
          ],
        ),
      ),
    ),
  );

  /// Helper to build custom bottom sheet routes
  static GoRoute _buildBottomSheetRoute(String path, Widget child) {
    return GoRoute(
      path: path,
      name: path,
      parentNavigatorKey: _shellNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  /// Display for unauthenticated users
  static Widget _unauthenticatedScreen(
    BuildContext context, {
    String message = 'Authentication required',
  }) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/auth/login'),
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () => context.go('/auth/forgot-password'),
              child: const Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}