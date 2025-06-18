import 'package:rent_cam/features/studio/model/booking_model.dart';

abstract class StudioBookingState {}

class StudioBookingInitial extends StudioBookingState {}

class StudioBookingLoading extends StudioBookingState {}

class StudioBookingSuccess extends StudioBookingState {
  final List<StudioBooking> bookings;
  final StudioBooking? currentBooking;

  StudioBookingSuccess({
    this.bookings = const [],
    this.currentBooking,
  });
}

class StudioBookingFailure extends StudioBookingState {
  final String error;

  StudioBookingFailure(this.error);
}
