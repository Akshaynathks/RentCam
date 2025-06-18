// Events
import 'package:flutter/material.dart';
import 'package:rent_cam/features/studio/model/booking_model.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';

abstract class StudioBookingEvent {}

class CreateStudioBooking extends StudioBookingEvent {
  final Studio studio;
  final StudioService service;
  final ServicePackage package;
  final List<DateTime> selectedDates;
  final String location;
  final BuildContext context;

  CreateStudioBooking({
    required this.studio,
    required this.service,
    required this.package,
    required this.selectedDates,
    required this.location,
    required this.context,
  });
}

class UpdateStudioBookingStatus extends StudioBookingEvent {
  final String bookingId;
  final String status;

  UpdateStudioBookingStatus({
    required this.bookingId,
    required this.status,
  });
}

class LoadUserStudioBookings extends StudioBookingEvent {}

class LoadStudioBookings extends StudioBookingEvent {
  final String studioId;

  LoadStudioBookings(this.studioId);
}

class CancelStudioBooking extends StudioBookingEvent {
  final String bookingId;

  CancelStudioBooking(this.bookingId);
}
