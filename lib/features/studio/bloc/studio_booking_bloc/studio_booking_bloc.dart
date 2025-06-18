import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/studio/bloc/studio_booking_bloc/studio_booking_event.dart';
import 'package:rent_cam/features/studio/bloc/studio_booking_bloc/studio_booking_state.dart';
import 'package:rent_cam/features/studio/model/booking_model.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';
import 'package:rent_cam/features/studio/service/booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:rent_cam/features/chat/services/chat_service.dart';
import 'package:rent_cam/features/chat/model/chat_models.dart';
import 'package:rent_cam/features/chat/bloc/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:rent_cam/features/chat/view/chat_detail_page.dart';

class StudioBookingBloc extends Bloc<StudioBookingEvent, StudioBookingState> {
  final BookingService _bookingService;
  final ChatService _chatService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  StudioBookingBloc({
    required BookingService bookingService,
    ChatService? chatService,
  })  : _bookingService = bookingService,
        _chatService = chatService ?? ChatService(),
        super(StudioBookingInitial()) {
    on<CreateStudioBooking>(_onCreateStudioBooking);
    on<UpdateStudioBookingStatus>(_onUpdateStudioBookingStatus);
    on<LoadUserStudioBookings>(_onLoadUserStudioBookings);
    on<LoadStudioBookings>(_onLoadStudioBookings);
    on<CancelStudioBooking>(_onCancelStudioBooking);
  }

  Future<void> _onCreateStudioBooking(
    CreateStudioBooking event,
    Emitter<StudioBookingState> emit,
  ) async {
    try {
      emit(StudioBookingLoading());

      // Check if dates are available
      final areAvailable = await _bookingService.areDatesAvailable(
        event.studio.id,
        event.selectedDates,
      );

      if (!areAvailable) {
        emit(StudioBookingFailure('Selected dates are not available'));
        return;
      }

      // Generate IDs for service and package if they don't exist
      final serviceId =
          event.service.id.isEmpty ? _uuid.v4() : event.service.id;
      final packageId =
          event.package.id.isEmpty ? _uuid.v4() : event.package.id;

      // Create booking
      final booking = StudioBooking(
        id: '',
        studioId: event.studio.id,
        serviceId: serviceId,
        packageId: packageId,
        userId: _auth.currentUser!.uid,
        selectedDates: event.selectedDates,
        location: event.location,
        packageRate: event.package.rate,
        bookingFee: 0.0, // No booking fee
        totalAmount:
            event.package.rate, // Total amount is just the package rate
        paymentId: '', // No payment ID needed
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final newBooking = await _bookingService.createBooking(booking);

      // Send chat message to studio owner
      final chatId = await _chatService.getOrCreateChat(event.studio.userId);
      final messageText = '''
New booking request for ${event.service.name} - ${event.package.name}
Location: ${event.location}
Dates: ${event.selectedDates.map((date) => '${date.day}/${date.month}/${date.year}').join(', ')}
Rate: ₹${event.package.rate.toStringAsFixed(2)}
''';
      await _chatService.sendMessage(
        chatId: chatId,
        receiverId: event.studio.userId,
        text: messageText,
        type: MessageType.booking,
        bookingId: newBooking.id,
      );

      emit(StudioBookingSuccess(bookings: [], currentBooking: newBooking));

      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Show confirmation dialog before navigating to chat
        showDialog(
          context: event.context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.green[600],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      '🎉 Booking Confirmed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Message
                    Text(
                      'Your booking request has been successfully sent to the studio owner. They will review your request and get back to you soon!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Booking Details Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.camera_alt,
                                  color: Colors.blue[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${event.service.name} - ${event.package.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.red[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Colors.orange[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${event.selectedDates.length} date${event.selectedDates.length > 1 ? 's' : ''} selected',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.payment,
                                  color: Colors.green[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '₹${event.package.rate.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                              Navigator.of(context)
                                  .pop(); // Go back to previous screen
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Go Back',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                              // Navigate to chat detail page
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BlocProvider<ChatDetailBloc>(
                                    create: (context) => ChatDetailBloc(
                                      chatService: _chatService,
                                    ),
                                    child: ChatDetailPage(chatId: chatId),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chat, size: 16),
                                const SizedBox(width: 4),
                                const Text(
                                  'Chat',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      emit(StudioBookingFailure(e.toString()));
    }
  }

  Future<void> _onUpdateStudioBookingStatus(
    UpdateStudioBookingStatus event,
    Emitter<StudioBookingState> emit,
  ) async {
    try {
      emit(StudioBookingLoading());
      await _bookingService.updateBookingStatus(event.bookingId, event.status);
      add(LoadUserStudioBookings());
    } catch (e) {
      emit(StudioBookingFailure(e.toString()));
    }
  }

  Future<void> _onCancelStudioBooking(
    CancelStudioBooking event,
    Emitter<StudioBookingState> emit,
  ) async {
    try {
      emit(StudioBookingLoading());
      await _bookingService.updateBookingStatus(event.bookingId, 'cancelled');
      add(LoadUserStudioBookings());
    } catch (e) {
      emit(StudioBookingFailure(e.toString()));
    }
  }

  Future<void> _onLoadUserStudioBookings(
    LoadUserStudioBookings event,
    Emitter<StudioBookingState> emit,
  ) async {
    try {
      emit(StudioBookingLoading());
      await emit.forEach<List<StudioBooking>>(
        _bookingService.getUserBookings(_auth.currentUser!.uid),
        onData: (bookings) => StudioBookingSuccess(bookings: bookings),
        onError: (_, __) => StudioBookingFailure('Failed to load bookings'),
      );
    } catch (e) {
      emit(StudioBookingFailure(e.toString()));
    }
  }

  Future<void> _onLoadStudioBookings(
    LoadStudioBookings event,
    Emitter<StudioBookingState> emit,
  ) async {
    try {
      emit(StudioBookingLoading());
      await emit.forEach<List<StudioBooking>>(
        _bookingService.getStudioBookings(event.studioId),
        onData: (bookings) => StudioBookingSuccess(bookings: bookings),
        onError: (_, __) => StudioBookingFailure('Failed to load bookings'),
      );
    } catch (e) {
      emit(StudioBookingFailure(e.toString()));
    }
  }
}
