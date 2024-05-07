part of 'auth_bloc.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
}

abstract class AuthState {
  final AuthStatus authStatus;
  const AuthState(this.authStatus);
}

class AuthStateInitial extends AuthState {
  AuthStateInitial() : super(AuthStatus.unauthenticated);
}

class AuthStateLoading extends AuthState {
  AuthStateLoading() : super(AuthStatus.unauthenticated);
}

class AuthStateAuthenticated extends AuthState {
  final Stream<AuthModel?> authStream;
  final String uid;

  AuthStateAuthenticated({required this.authStream, required this.uid})
      : super(AuthStatus.authenticated);
}

class SignInSuccessState extends AuthState {
  SignInSuccessState() : super(AuthStatus.unauthenticated);
}

class SignInErrorState extends AuthState {
  final String error;

  SignInErrorState(this.error) : super(AuthStatus.unauthenticated);
}

class SignUpErrorState extends AuthState {
  final String error;

  SignUpErrorState(this.error) : super(AuthStatus.unauthenticated);
}

class SignUpSuccessState extends AuthState {
  SignUpSuccessState() : super(AuthStatus.unauthenticated);
}

class SignoutState extends AuthState {
  SignoutState() : super(AuthStatus.unauthenticated);
}
