import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/auth_model.dart';
import '../../data/services/auth_svc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthStateInitial()) {
    on<SignOutEvent>(_signOut);
    on<ResetPassEvent>(_resetPass);
    on<AuthInitialEvent>(_onInittial);
    on<SignInWithEmailEvent>(_signInWithEmail);
    on<SignInAsGuestEvent>(_signInAsGuest);
    on<SignInWithGoogleEvent>(_signInWithGoogle);
    on<SignUpWithEmailEvent>(_signUpWithEmail);
  }

  Future<void> _onInittial(
    AuthInitialEvent event,
    Emitter<AuthState> emit,
  ) async {
    AuthModel? auth = await authService.loadAuthFromHive();
    if (auth != null) {
      final authStream = authService.streamUser(auth.uid!);
      if (authStream != null) {
        emit(AuthStateAuthenticated(
          authStream: authStream,
          uid: auth.uid!,
        ));
      }
    }
  }

  Future<void> _signUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      await authService.registerWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(SignUpSuccessState());
    } catch (error) {
      String errorMessage = "An error occurred during registration.";
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The account already exists for that email.';
            break;
          default:
            errorMessage = 'Error: ${error.message}';
        }
      }
      emit(SignUpErrorState(errorMessage));
    }
  }

  Future<void> _signInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      final User? auth = await authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      await _handleAuthLogin(emit, auth, "Email");
    } catch (error) {
      String errorMessage = "An error occurred during sign-in.";
      if (error is FirebaseAuthException) {
        print("code:::::::${error.code}::::::::::::${error.message}");
        switch (error.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'invalid-credential':
            errorMessage = 'Wrong password provided for that user.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided for that user.';
            break;
          default:
            errorMessage = 'Error: ${error.message}';
        }
      }
      emit(SignInErrorState(errorMessage));
    }
  }

  Future<void> _signInAsGuest(
    SignInAsGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      final User? auth = await authService.signInAnonymously();
      await _handleAuthLogin(emit, auth, "Anonymous");
    } catch (error) {
      String errorMessage = "An error occurred during Sign In As Guest.";
      if (error is FirebaseAuthException) {
        switch (error.code) {
          default:
            errorMessage = 'Error: ${error.message}';
        }
      }
      emit(SignInErrorState(errorMessage));
    }
  }

  Future<void> _signInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthStateLoading());
      final User? auth = await authService.signInWithGoogle();
      await _handleAuthLogin(emit, auth, "Google");
    } catch (error) {
      String errorMessage =
          "An error occurred during Google sign-in: ${error.toString()}";
      if (error is FirebaseAuthException) {
        switch (error.code) {
          default:
            errorMessage = 'Error: ${error.message}';
        }
      }
      emit(SignInErrorState(errorMessage));
    }
  }

  Future<void> _resetPass(
    ResetPassEvent event,
    Emitter<AuthState> emit,
  ) async {
    await authService.resetPass(event.email);
  }

  Future<void> _signOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    print("Signing out");
    await authService.signOut();
    emit(SignoutState());
  }

  Future<void> _handleAuthLogin(
      Emitter<AuthState> emit, User? auth, String provider) async {
    if (auth != null) {
      authService.updateAuthLastSignIn(
        uid: auth.uid,
        provider: provider,
        photoUrl: auth.photoURL,
        email: auth.email,
        displayName: auth.displayName,
      );
      emit(SignInSuccessState());
      await Future.delayed(Duration(seconds: 1));
      emit(AuthStateAuthenticated(
        authStream: authService.streamUser(auth.uid)!,
        uid: auth.uid,
      ));
    }
  }
}
