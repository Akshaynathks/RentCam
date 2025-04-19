abstract class HomeState {}

class HomeInitialState extends HomeState {}

class TabChangedState extends HomeState {
  final int index; // Add this parameter

  TabChangedState(this.index); // Constructor
}