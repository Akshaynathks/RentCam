import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_cam/features/studio/model/booking_model.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'studio_bookings';

  // Create a new booking
  Future<StudioBooking> createBooking(StudioBooking booking) async {
    final docRef = _firestore.collection(_collection).doc();
    final newBooking = booking.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      status: 'pending',
    );

    await docRef.set(newBooking.toMap());
    return newBooking;
  }

  // Get bookings for a user
  Stream<List<StudioBooking>> getUserBookings(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudioBooking.fromMap(doc.data()))
            .toList());
  }

  // Get bookings for a studio
  Stream<List<StudioBooking>> getStudioBookings(String studioId) {
    return _firestore
        .collection(_collection)
        .where('studioId', isEqualTo: studioId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudioBooking.fromMap(doc.data()))
            .toList());
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection(_collection).doc(bookingId).update({
      'status': status,
      if (status == 'confirmed') 'paymentDate': FieldValue.serverTimestamp(),
    });
  }

  // Update payment ID
  Future<void> updatePaymentId(String bookingId, String paymentId) async {
    await _firestore.collection(_collection).doc(bookingId).update({
      'paymentId': paymentId,
      'status': 'confirmed',
      'paymentDate': FieldValue.serverTimestamp(),
    });
  }

  // Check if dates are available
  Future<bool> areDatesAvailable(String studioId, List<DateTime> dates) async {
    final bookings = await _firestore
        .collection(_collection)
        .where('studioId', isEqualTo: studioId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    for (var booking in bookings.docs) {
      final bookingData = StudioBooking.fromMap(booking.data());
      for (var date in dates) {
        if (bookingData.selectedDates.any((bookingDate) =>
            bookingDate.year == date.year &&
            bookingDate.month == date.month &&
            bookingDate.day == date.day)) {
          return false;
        }
      }
    }
    return true;
  }
}
