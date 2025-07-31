import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rovify/domain/usecases/sign_in_user.dart';
import 'package:rovify/domain/usecases/sign_up_user.dart';
import 'package:rovify/domain/entities/user.dart' as domain;
import 'package:rovify/presentation/blocs/auth/auth_event.dart';
import 'package:rovify/presentation/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUser _signUpUser;
  final SignInUser _signInUser;
  final firebase.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthBloc({
    required SignUpUser signUpUser,
    required SignInUser signInUser,
    required firebase.FirebaseAuth firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _signUpUser = signUpUser,
        _signInUser = signInUser,
        _firebaseAuth = firebaseAuth,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    // Disabled Apple and Twitter sign-in by removing their handlers
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final email = event.email.trim();
      final password = event.password.trim();

      if (!_isValidEmail(email)) {
        emit(AuthError('Please enter a valid email address'));
        return;
      }

      if (!_isValidPassword(password)) {
        emit(AuthError(
            'Password must be 8+ chars with uppercase, lowercase, number and special char'));
        return;
      }

      final user = await _signUpUser(email: email, password: password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_handleAuthError(e)));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _signInUser(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_handleAuthError(e)));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signOut();
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthError('Failed to sign out. Please try again.'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      await googleSignIn.signOut(); // Clear any existing session

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        emit(UnAuthenticated()); // User cancelled sign-in
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        throw Exception('Google authentication failed');
      }

      final user = await _getOrCreateUser(firebaseUser);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_handleAuthError(e)));
    }
  }

  // Removed _onAppleSignInRequested and _onXSignInRequested methods

  Future<domain.User> _getOrCreateUser(firebase.User firebaseUser) async {
    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!userDoc.exists) {
      final newUser = domain.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
        avatarUrl: firebaseUser.photoURL,
        joinedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
      return newUser;
    }

    return domain.User.fromMap(firebaseUser.uid, userDoc.data()!);
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$')
        .hasMatch(password);
  }

  String _handleAuthError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('email-already-in-use')) {
      return 'This email is already registered.';
    } else if (message.contains('wrong-password') || message.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    } else if (message.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (message.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (message.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (message.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (message.contains('operation-not-allowed')) {
      return 'This sign-in method is not enabled.';
    } else if (message.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('account-exists-with-different-credential')) {
      return 'An account already exists with this email but different sign-in method.';
    } else if (message.contains('cancelled') || message.contains('canceled')) {
      return 'Sign-in cancelled.';
    }

    return 'Authentication failed. Please try again.';
  }
}