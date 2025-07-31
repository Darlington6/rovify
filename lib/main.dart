import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/core/theme/app_theme.dart';
import 'package:rovify/data/firebase/firebase_initializer.dart';
import 'package:rovify/data/datasources/event_remote_datasource.dart';
import 'package:rovify/data/repositories/auth_repository_impl.dart';
import 'package:rovify/data/repositories/event_repository_impl.dart';
import 'package:rovify/domain/usecases/sign_in_user.dart';
import 'package:rovify/domain/usecases/sign_up_user.dart';
import 'package:rovify/domain/usecases/events/get_upcoming_events.dart';
import 'package:rovify/domain/usecases/events/toggle_event_favorite.dart';
import 'package:rovify/presentation/blocs/auth/auth_bloc.dart';
import 'package:rovify/presentation/blocs/auth/auth_state.dart';
import 'package:rovify/presentation/blocs/events/event_bloc.dart';
import 'package:rovify/presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final authRepository = AuthRepositoryImpl(firebaseAuth, firestore);
  final eventRemoteDataSource = EventRemoteDataSource(firestore);
  final eventRepository = EventRepositoryImpl(eventRemoteDataSource);

  final signUpUser = SignUpUser(authRepository);
  final signInUser = SignInUser(authRepository);

  final getUpcomingEvents = GetUpcomingEvents(eventRepository);
  final toggleEventFavorite = ToggleEventFavorite(eventRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            signUpUser: signUpUser,
            signInUser: signInUser,
            firebaseAuth: firebaseAuth,
          ),
        ),
        BlocProvider(
          create: (_) => EventBloc(
            getUpcomingEvents: getUpcomingEvents,
            toggleEventFavorite: toggleEventFavorite,
            userId: firebaseAuth.currentUser?.uid ?? '',
          ),
        ),
      ],
      child: const RovifyApp(),
    ),
  );
}

class RovifyApp extends StatelessWidget {
  const RovifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rovify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Handle navigation when auth state changes
            if (state is Authenticated) {
              // Redirect to events page after successful login
              AppRouter.router.go('/explore');
            }
          },
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // Initial route handling
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return child!;
            },
          ),
        );
      },
    );
  }
}