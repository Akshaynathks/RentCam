import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/home/bloc/home_bloc/home_event.dart';
import 'package:rent_cam/features/home/bloc/home_bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitialState()) {
    on<ChangeTabEvent>((event, emit) {
      emit(TabChangedState(event.index)); // Update the state with the new index
    });
  }
}
