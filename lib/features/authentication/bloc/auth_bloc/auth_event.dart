part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class CheckLoaginStatusEvent extends AuthEvent {}

class LoaginEvent extends AuthEvent {
  final String email;
  final String password;

  LoaginEvent({required this.email, required this.password});
}

class SignupEvent extends AuthEvent {
  final UserModel user;
  SignupEvent({required this.user});
}

class GoogleSignInEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent{}