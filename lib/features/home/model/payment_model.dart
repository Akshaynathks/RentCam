class PaymentDetails {
  final String orderId;
  final DateTime startDate;
  final DateTime endDate;
  final double grandTotal;
  final double discountPercentage;
  final double discountedTotal;
  final double partialAmount;
  final double balanceAmount;
  final String paymentMethod;
  final String? paymentId; 
  final String couponCode;
  final bool isPartialPayment;
  final DateTime paymentDate;
  final List<String> productNames;
  final int duration;

  PaymentDetails({
    required this.orderId,
    required this.startDate,
    required this.endDate,
    required this.grandTotal,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.partialAmount,
    required this.balanceAmount,
    required this.paymentMethod,
    this.paymentId,
    required this.couponCode,
    required this.isPartialPayment,
    required this.paymentDate,
    required this.productNames,
    required this.duration,
  });
}