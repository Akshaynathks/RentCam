abstract class HomeEvent {}

class ChangeTabEvent extends HomeEvent {
  final int index;
  ChangeTabEvent(this.index);
}