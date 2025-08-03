// lib/domain/repositories/auth_repository.dart

import 'package:rovify/domain/entities/user.dart' as domain;

abstract class AuthRepository {
  Future<domain.User> signUp({required String email, required String password});
  Future<domain.User> signIn({required String email, required String password});
  Future<void> signOut();
}