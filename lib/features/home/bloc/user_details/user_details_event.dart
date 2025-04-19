part of 'user_details_bloc.dart';

@immutable
sealed class UserDetailsEvent {}

final class FetchUserDetails extends UserDetailsEvent {}

final class UpdateUserDetails extends UserDetailsEvent {
  final String name;
  final String phone;

  UpdateUserDetails(this.name, this.phone);
}
