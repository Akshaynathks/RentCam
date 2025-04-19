part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentCouponApplied extends PaymentState {
  final Offer appliedOffer;
  final double discountedTotal;
  final double partialAmount;
  final double balanceAmount;
  final String? paymentMethod;

  const PaymentCouponApplied({
    required this.appliedOffer,
    required this.discountedTotal,
    required this.partialAmount,
    required this.balanceAmount,
    this.paymentMethod,
  });

  PaymentCouponApplied copyWith({
    Offer? appliedOffer,
    double? discountedTotal,
    double? partialAmount,
    double? balanceAmount,
    String? paymentMethod,
  }) {
    return PaymentCouponApplied(
      appliedOffer: appliedOffer ?? this.appliedOffer,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      partialAmount: partialAmount ?? this.partialAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  List<Object> get props => [
        appliedOffer,
        discountedTotal,
        partialAmount,
        balanceAmount,
        paymentMethod ?? '',
      ];
}

class PaymentMethodSelected extends PaymentState {
  final String paymentMethod;
  final double grandTotal;
  final double partialAmount;
  final double balanceAmount;

  const PaymentMethodSelected({
    required this.paymentMethod,
    required this.grandTotal,
    required this.partialAmount,
    required this.balanceAmount,
  });

  @override
  List<Object> get props => [
        paymentMethod,
        grandTotal,
        partialAmount,
        balanceAmount,
      ];
}

class OrderPlaced extends PaymentState {
  final PaymentDetails paymentDetails;

  const OrderPlaced(this.paymentDetails);

  @override
  List<Object> get props => [paymentDetails];
}

class PaymentProcessing extends PaymentState {}

class PaymentFailedState extends PaymentState {
  final String errorMessage;

  const PaymentFailedState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}