import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_cam/features/authentication/models/user_model.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<CheckLoaginStatusEvent>((event, emit) async {
      try {
        final user = await authService.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(UnAuthenticated());
        }
      } catch (e) {
        emit(AuthenticatedError(message: e.toString()));
      }
    });

    on<SignupEvent>((event, emit) async {
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
          emit(UnAuthenticated());
        }
      } catch (e) {
        emit(AuthenticatedError(message: e.toString()));
      }
    });

    on<LoaginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authService.login(event.email, event.password);
        if (user != null) {
          emit(Authenticated(user));
        }
      } catch (e) {
        emit(AuthenticatedError(message: e.toString()));
      }
    });

    on<GoogleSignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authService.googleSignIn();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(UnAuthenticated());
        }
      } catch (e) {
        emit(AuthenticatedError(message: e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      try {
        await authService.logout();
        emit(UnAuthenticated());
      } catch (e) {
        emit(AuthenticatedError(message: e.toString()));
      }
    });
  }
}
