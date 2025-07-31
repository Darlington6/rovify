import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/domain/entities/user.dart' as domain;
import 'package:rovify/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl(this.firebaseAuth, this.firestore);

  @override
  Future<domain.User> signUp({required String email, required String password}) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = domain.User(
      id: credential.user!.uid,
      displayName: credential.user!.displayName ?? "", // Empty for now, can be updated later
      email: credential.user!.email ?? email,
      avatarUrl: null,
      interests: [],
      walletAddress: null,
      isCreator: false,
      joinedAt: DateTime.now(),
    );

    // Save user to Firestore
    await firestore.collection('users').doc(user.id).set(user.toMap());

    return user;
  }

  @override
  Future<domain.User> signIn({required String email, required String password}) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final snapshot = await firestore.collection('users').doc(uid).get();

    if (!snapshot.exists) {
      throw Exception("User profile not found in Firestore.");
    }

    final data = snapshot.data()!;
    return domain.User.fromMap(uid, data);
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}