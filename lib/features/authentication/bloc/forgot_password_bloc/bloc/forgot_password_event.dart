// forgot_password_event.dart
abstract class ForgotPasswordEvent {}

class SendPasswordResetEmail extends ForgotPasswordEvent {
  final String email;

  SendPasswordResetEmail({required this.email});
}
