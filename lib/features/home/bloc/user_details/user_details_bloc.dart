import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rent_cam/features/home/services/user_service.dart';

part 'user_details_event.dart';
part 'user_details_state.dart';

class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  final UserService userService;

  UserDetailsBloc({required this.userService}) : super(UserDetailsInitial()) {
    on<FetchUserDetails>(_onFetchUserDetails);
    on<UpdateUserDetails>(_onUpdateUserDetails);
  }

  Future<void> _onFetchUserDetails(
      FetchUserDetails event, Emitter<UserDetailsState> emit) async {
    emit(UserDetailsLoading());
    try {
      final userDetails = await userService.fetchUserDetails();
      emit(UserDetailsLoaded(userDetails));
    } catch (e) {
      emit(UserDetailsError(e.toString()));
    }
  }

    Future<void> _onUpdateUserDetails(
      UpdateUserDetails event, Emitter<UserDetailsState> emit) async {
    emit(UserDetailsLoading());
    try {
      await userService.updateUserDetails(event.name, event.phone);

      final updatedDetails = await userService.fetchUserDetails();

      emit(UserDetailsLoaded(updatedDetails));
    } catch (e) {
      emit(UserDetailsError(e.toString()));
    }
  }



}
