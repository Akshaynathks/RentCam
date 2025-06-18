part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class ApplyCoupon extends PaymentEvent {
  final Offer appliedOffer;

  const ApplyCoupon(this.appliedOffer);

  @override
  List<Object> get props => [appliedOffer];
}

class RemoveCoupon extends PaymentEvent {}

class SelectPaymentMethod extends PaymentEvent {
  final String method;

  const SelectPaymentMethod(this.method);

  @override
  List<Object> get props => [method];
}

class PlaceOrder extends PaymentEvent {
  final String paymentMethod;
  final String? paymentId;

  const PlaceOrder(this.paymentMethod, {this.paymentId});

  @override
  List<Object> get props => [paymentMethod, paymentId ?? ''];
}

class InitiateRazorpayPayment extends PaymentEvent {
  final double amount;
  final bool isPartialPayment;

  const InitiateRazorpayPayment({
    required this.amount,
    required this.isPartialPayment,
  });

  @override
  List<Object> get props => [amount, isPartialPayment];
}

class PaymentFailedEvent extends PaymentEvent {
  final String errorMessage;

  const PaymentFailedEvent(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
