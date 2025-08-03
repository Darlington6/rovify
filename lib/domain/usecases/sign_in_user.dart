import 'package:rovify/domain/entities/user.dart' as domain; // Custom user model
import '../repositories/auth_repository.dart';

class SignUpUser {
  final AuthRepository repository;
  SignUpUser(this.repository);
  Future<domain.User> call({required String email, required String password}) {
    return repository.signUp(email: email, password: password);
  }
}