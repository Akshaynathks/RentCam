abstract class ForgotPasswordEvent {}

class SendPasswordResetEmail extends ForgotPasswordEvent {
  final String email;

  SendPasswordResetEmail({required this.email});
}