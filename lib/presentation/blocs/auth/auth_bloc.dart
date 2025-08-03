import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:rovify/domain/usecases/sign_in_user.dart';
import 'package:rovify/domain/usecases/sign_up_user.dart';
import 'package:rovify/domain/entities/user.dart' as domain;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUser signUpUser;
  final SignInUser signInUser;
  final firebase.FirebaseAuth firebaseAuth;

  AuthBloc({
    required this.signUpUser,
    required this.signInUser,
    required this.firebaseAuth,
  }) : super(AuthInitial()) {
    // Email/Password Sign Up
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());

      final email = event.email.trim();
      final password = event.password.trim();

      // Email Validation
      if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
        emit(AuthError("Please enter a valid email."));
        return;
      }

      // Password Validation
      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$')
          .hasMatch(password)) {
        emit(AuthError(
            "Password must be at least 8 characters and include uppercase, lowercase, number, and special character."));
        return;
      }

      try {
        // Create user with Firebase
        final credential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final firebaseUser = credential.user;

        if (firebaseUser == null) {
          emit(AuthError("Failed to create user. Try again later."));
          return;
        }

        // Update display name
        await firebaseUser.reload();
        final updatedUser = firebaseAuth.currentUser;

        // Create domain user
        final newUser = domain.User(
          id: updatedUser!.uid,
          email: updatedUser.email ?? '',
          displayName: updatedUser.displayName ?? '',
          avatarUrl: updatedUser.photoURL ?? '',
          joinedAt: updatedUser.metadata.creationTime ?? DateTime.now(),
        );

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(updatedUser.uid)
            .set(newUser.toMap());

        emit(Authenticated(newUser));
      } on firebase.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          emit(AuthError("This email is already registered. Please log in!"));
        } else if (e.code == 'weak-password') {
          emit(AuthError("Your password is too weak. Try again."));
        } else if (e.code == 'invalid-email') {
          emit(AuthError("Invalid email format."));
        } else {
          emit(AuthError("Sign up failed. ${_handleFirebaseError(e)}"));
        }
      } catch (e) {
        emit(AuthError("An unexpected error occurred. Please try again."));
      }
    });

    // Email/Password Sign In
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        final firebaseUser = firebaseAuth.currentUser;

        if (firebaseUser == null) {
          emit(AuthError("Failed to retrieve user information."));
          return;
        }

        final user = domain.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          avatarUrl: firebaseUser.photoURL ?? '',
          joinedAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        );

        emit(Authenticated(user));
      } on firebase.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          emit(AuthError('No account found for that email.'));
        } else if (e.code == 'wrong-password') {
          emit(AuthError('Incorrect password. Please try again.'));
        } else if (e.code == 'invalid-email') {
          emit(AuthError('The email address is badly formatted.'));
        } else if (e.code == 'too-many-requests') {
          emit(AuthError('Too many attempts. Try again later.'));
        } else {
          emit(AuthError('Sign in failed. Please try again.'));
        }
      } catch (_) {
        emit(AuthError('Unexpected error occurred. Please try again.'));
      }
    });

    // Sign Out
    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await firebaseAuth.signOut();
        emit(UnAuthenticated());
      } catch (_) {
        emit(AuthError("Sign out failed. Please try again."));
      }
    });

    // Google Sign In (with account picker)
    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );

        // Let user select an account
        await googleSignIn.signOut();

        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          emit(AuthError("Google Sign-In was cancelled."));
          return;
        }

        final googleAuth = await googleUser.authentication;

        final credential = firebase.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final result = await firebaseAuth.signInWithCredential(credential);
        final firebaseUser = result.user;

        if (firebaseUser == null) {
          emit(AuthError("Google Sign-In failed."));
          return;
        }

        // Check if user already exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) {
          final newUser = domain.User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? '',
            avatarUrl: firebaseUser.photoURL,
            joinedAt: DateTime.now(),
          );

          // Save user to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .set(newUser.toMap());
        }

        final user = domain.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          avatarUrl: firebaseUser.photoURL ?? '',
          joinedAt: DateTime.now(),
        );

        emit(Authenticated(user));
      } catch (e) {
        emit(AuthError("Google Sign-In failed. ${_handleFirebaseError(e)}"));
      }
    });

    // Apple Sign In (iOS/macOS only)
    on<AppleSignInRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await Future.delayed(const Duration(milliseconds: 300));
        emit(AuthError("Apple Sign-In is not yet implemented. Please continue with Google or Email/Password."));
      } catch (e) {
        emit(AuthError("Apple Sign-In failed. ${_handleFirebaseError(e)}"));
      }
    });

    // Twitter/X Sign In (placeholder)
    on<XSignInRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await Future.delayed(const Duration(milliseconds: 300), () {
          emit(AuthError("X (Twitter) Sign-In is not yet implemented. Please continue with Google or Email/Password."));
        });
      } catch (e) {
        emit(AuthError("X Sign-In failed. ${_handleFirebaseError(e)}"));
      }
    });
  }

  /// Converts Firebase error messages to user-friendly format
  String _handleFirebaseError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains("email-already-in-use")) {
      return "This email is already registered. Please log in!";
    } else if (message.contains("wrong-password")) {
      return "Incorrect password. Please try again.";
    } else if (message.contains("user-not-found")) {
      return "No account found with this email.";
    } else if (message.contains("network-request-failed")) {
      return "Network error. Please check your internet connection.";
    } else if (message.contains("too-many-requests")) {
      return "Too many attempts. Please try again later.";
    }

    return "Something went wrong. Please try again.";
  }
}