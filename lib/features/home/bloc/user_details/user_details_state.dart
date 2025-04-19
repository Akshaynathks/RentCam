part of 'user_details_bloc.dart';

@immutable
sealed class UserDetailsState {}

final class UserDetailsInitial extends UserDetailsState {}

final class UserDetailsLoading extends UserDetailsState {}

final class UserDetailsLoaded extends UserDetailsState {
  final Map<String, dynamic> userDetails;

  UserDetailsLoaded(this.userDetails);
}

final class UserDetailsError extends UserDetailsState {
  final String error;

  UserDetailsError(this.error);
}
