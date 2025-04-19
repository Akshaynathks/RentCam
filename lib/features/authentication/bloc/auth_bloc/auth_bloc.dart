import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_cam/features/authentication/models/user_model.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';
import 'package:rent_cam/features/home/bloc/profile_photo/profile_image_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<CheckLoaginStatusEvent>(_onCheckLoginStatus);
    on<SignupEvent>(_onSignup);
    on<LoaginEvent>(_onLogin);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckLoginStatus(
      CheckLoaginStatusEvent event, Emitter<AuthState> emit) async {
    try {
      final user = await authService.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (_) {
      emit(AuthenticatedError(message: "Failed to check login status."));
    }
  }

  Future<void> _onSignup(SignupEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authService.signUp(
        event.user.email,
        event.user.password.toString(),
        event.user.name,
        event.user.mobile,
      );

      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthenticatedError(
            message: "Failed to sign up. Please try again."));
      }
    } catch (e) {
      emit(AuthenticatedError(message: "An error occurred during sign-up."));
    }
  }

  Future<void> _onLogin(LoaginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authService.login(event.email, event.password);
      if (user != null) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          emit(Authenticated(firebaseUser));
        } else {
          emit(AuthenticatedError(message: "Login failed. Please try again."));
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = switch (e.code) {
        'user-not-found' =>
          "No account exists with this email. Please sign up first.",
        'wrong-password' => "The password you entered is incorrect.",
        'invalid-email' => "Please enter a valid email address.",
        _ => "Login failed. Please check your credentials and try again.",
      };
      emit(AuthenticatedError(message: errorMessage));
    } catch (e) {
      emit(AuthenticatedError(message: "An error occurred. Please try again."));
    }
  }

  Future<void> _onGoogleSignIn(
      GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authService.googleSignIn();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthenticatedError(message: "Google Sign-In failed. Try again."));
      }
    } catch (_) {
      emit(AuthenticatedError(
          message: "An error occurred during Google Sign-In."));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await authService.logout(); 
      event.context
          .read<ProfileImageBloc>()
          .add(ClearProfileImageEvent()); 
      emit(UnAuthenticated()); 
      Navigator.pushReplacementNamed(
          event.context, '/login');
    } catch (_) {
      emit(AuthenticatedError(message: "Failed to log out. Please try again."));
    }
  }

  User? get currentUser {
  if (state is Authenticated) {
    return (state as Authenticated).user;
  }
  return null;
}
}
