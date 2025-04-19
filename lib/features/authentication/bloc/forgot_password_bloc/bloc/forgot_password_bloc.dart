import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<SendPasswordResetEmail>(_onSendPasswordResetEmail);
  }

  Future<void> _onSendPasswordResetEmail(SendPasswordResetEmail event, Emitter<ForgotPasswordState> emit) async {
    emit(ForgotPasswordLoading());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);
      emit(ForgotPasswordSuccess());
    } on FirebaseAuthException catch (e) {
      emit(ForgotPasswordError(errorMessage: e.message ?? 'An error occurred'));
    }
  }
}