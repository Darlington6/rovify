abstract class AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final bool acceptedTerms;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.acceptedTerms,
  });
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({
    required this.email,
    required this.password,
  });
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  ForgotPasswordRequested(this.email);
}


class SignOutRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class AppleSignInRequested extends AuthEvent {}

class XSignInRequested extends AuthEvent {}