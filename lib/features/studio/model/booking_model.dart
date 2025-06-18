import 'package:cloud_firestore/cloud_firestore.dart';

class StudioBooking {
  final String id;
  final String studioId;
  final String serviceId;
  final String packageId;
  final String userId;
  final List<DateTime> selectedDates;
  final String location;
  final double packageRate;
  final double bookingFee;
  final double totalAmount;
  final String paymentId;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;
  final DateTime? paymentDate;

  StudioBooking({
    required this.id,
    required this.studioId,
    required this.serviceId,
    required this.packageId,
    required this.userId,
    required this.selectedDates,
    required this.location,
    required this.packageRate,
    required this.bookingFee,
    required this.totalAmount,
    required this.paymentId,
    required this.status,
    required this.createdAt,
    this.paymentDate,
  });

  factory StudioBooking.fromMap(Map<String, dynamic> map) {
    return StudioBooking(
      id: map['id'] ?? '',
      studioId: map['studioId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      packageId: map['packageId'] ?? '',
      userId: map['userId'] ?? '',
      selectedDates: (map['selectedDates'] as List<dynamic>)
          .map((date) => (date as Timestamp).toDate())
          .toList(),
      location: map['location'] ?? '',
      packageRate: (map['packageRate'] ?? 0.0).toDouble(),
      bookingFee: (map['bookingFee'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      paymentId: map['paymentId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      paymentDate: map['paymentDate'] != null
          ? (map['paymentDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studioId': studioId,
      'serviceId': serviceId,
      'packageId': packageId,
      'userId': userId,
      'selectedDates':
          selectedDates.map((date) => Timestamp.fromDate(date)).toList(),
      'location': location,
      'packageRate': packageRate,
      'bookingFee': bookingFee,
      'totalAmount': totalAmount,
      'paymentId': paymentId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentDate':
          paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
    };
  }

  StudioBooking copyWith({
    String? id,
    String? studioId,
    String? serviceId,
    String? packageId,
    String? userId,
    List<DateTime>? selectedDates,
    String? location,
    double? packageRate,
    double? bookingFee,
    double? totalAmount,
    String? paymentId,
    String? status,
    DateTime? createdAt,
    DateTime? paymentDate,
  }) {
    return StudioBooking(
      id: id ?? this.id,
      studioId: studioId ?? this.studioId,
      serviceId: serviceId ?? this.serviceId,
      packageId: packageId ?? this.packageId,
      userId: userId ?? this.userId,
      selectedDates: selectedDates ?? this.selectedDates,
      location: location ?? this.location,
      packageRate: packageRate ?? this.packageRate,
      bookingFee: bookingFee ?? this.bookingFee,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentId: paymentId ?? this.paymentId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }
}
