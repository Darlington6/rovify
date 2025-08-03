import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/core/theme/app_theme.dart';
import 'package:rovify/core/theme/theme_cubit.dart';
import 'package:rovify/data/datasources/event_remote_datasource.dart';
import 'package:rovify/data/firebase/firebase_initializer.dart';
import 'package:rovify/data/repositories/auth_repository_impl.dart';
import 'package:rovify/data/repositories/event_repository_impl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rovify/domain/repositories/nft_repository.dart';
import 'package:rovify/domain/usecases/create_event.dart';
import 'package:rovify/domain/usecases/fetch_events.dart';
import 'package:rovify/domain/usecases/get_upcoming_events.dart';
import 'package:rovify/domain/usecases/sign_in_user.dart';
import 'package:rovify/domain/usecases/sign_up_user.dart';
import 'package:rovify/domain/usecases/toggle_event_favorite.dart';
import 'package:rovify/presentation/blocs/auth/auth_bloc.dart';
import 'package:rovify/presentation/blocs/auth/auth_state.dart';
import 'package:rovify/presentation/blocs/event/event_bloc.dart';
import 'package:rovify/presentation/blocs/event/event_event.dart';
import 'package:rovify/presentation/blocs/event/event_form_bloc.dart';
import 'package:rovify/presentation/blocs/nft/nft_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences first with error handling
  SharedPreferences? sharedPreferences;
  try {
    sharedPreferences = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('Error initializing SharedPreferences: $e');
  }

  // Then initialize Firebase
  await FirebaseInitializer.initialize();

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final authRepository = AuthRepositoryImpl(firebaseAuth, firestore);
  
  final eventRemoteDataSource = EventRemoteDataSourceImpl(
    firestore: firestore,
    storage: storage,
  );

  final eventRepository = EventRepositoryImpl(
    firestore,
    remoteDataSource: eventRemoteDataSource,
  );

  final signUpUser = SignUpUser(authRepository);
  final signInUser = SignInUser(authRepository);

  final createEvent = CreateEvent(eventRepository);
  final fetchEvents = FetchEvents(eventRepository);
  final getUpcomingEvents = GetUpcomingEvents(eventRepository);
  final toggleEventFavorite = ToggleEventFavorite(eventRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TrendingNftBloc(nftRepository: NftRepository())),
        BlocProvider(
          create: (_) => AuthBloc(
            signUpUser: signUpUser,
            signInUser: signInUser,
            firebaseAuth: firebaseAuth,
          ),
        ),
        BlocProvider(
          create: (_) => EventBloc(
            createEventUseCase: createEvent,
            fetchEventsUseCase: fetchEvents,
            getUpcomingEvents: getUpcomingEvents,
            toggleEventFavorite: toggleEventFavorite,
            userId: firebaseAuth.currentUser?.uid ?? '',
          )..add(FetchEventsRequested()),
        ),
        BlocProvider(
          create: (_) => EventFormBloc(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(sharedPreferences),
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
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: 'Rovify',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  AppRouter.router.go('/explore');
                } else if (state is UnAuthenticated) {
                  AppRouter.router.go('/auth/login');
                }
              },
              child: child,
            );
          },
        );
      },
    );
  }
}