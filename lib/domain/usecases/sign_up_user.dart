import 'package:rovify/domain/entities/user.dart' as domain;
import '../repositories/auth_repository.dart';

class SignInUser {
  final AuthRepository repository;
  SignInUser(this.repository);

  Future<domain.User> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}