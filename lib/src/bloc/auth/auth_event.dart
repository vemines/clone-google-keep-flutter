part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthInitialEvent extends AuthEvent {}

class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  SignInWithEmailEvent({
    required this.email,
    required this.password,
  });
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  SignUpWithEmailEvent({
    required this.email,
    required this.password,
  });
}

class SignInAsGuestEvent extends AuthEvent {}

class SignInWithGoogleEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}

class ResetPassEvent extends AuthEvent {
  final String email;
  ResetPassEvent({
    required this.email,
  });
}
