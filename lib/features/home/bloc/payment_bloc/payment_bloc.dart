import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rent_cam/features/home/model/cart_model.dart';
import 'package:rent_cam/features/home/model/offer_model.dart';
import 'package:rent_cam/features/home/model/payment_model.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final List<CartItem> cartItems;
  final double grandTotal;
  final bool isPartialPayment;
  late Razorpay _razorpay;

  PaymentBloc({
    required this.cartItems,
    required this.grandTotal,
    required this.isPartialPayment,
  }) : super(PaymentInitial()) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<PlaceOrder>(_onPlaceOrder);
    on<InitiateRazorpayPayment>(_onInitiateRazorpayPayment);
    on<PaymentFailedEvent>(_onPaymentFailed);
  }

  void _onApplyCoupon(ApplyCoupon event, Emitter<PaymentState> emit) {
    final discountedTotal =
        (grandTotal - (grandTotal * event.appliedOffer.percentage / 100))
            .toDouble();
    final discountedPartial =
        (isPartialPayment ? discountedTotal / 2 : 0.0).toDouble();

    if (state is PaymentCouponApplied) {
      final currentState = state as PaymentCouponApplied;
      emit(currentState.copyWith(
        appliedOffer: event.appliedOffer,
        discountedTotal: discountedTotal,
        partialAmount: discountedPartial,
        balanceAmount: (discountedTotal - discountedPartial).toDouble(),
      ));
    } else if (state is PaymentMethodSelected) {
      final currentState = state as PaymentMethodSelected;
      emit(PaymentCouponApplied(
        appliedOffer: event.appliedOffer,
        discountedTotal: discountedTotal,
        partialAmount: discountedPartial,
        balanceAmount: (discountedTotal - discountedPartial).toDouble(),
        paymentMethod: currentState.paymentMethod,
      ));
    } else {
      emit(PaymentCouponApplied(
        appliedOffer: event.appliedOffer,
        discountedTotal: discountedTotal,
        partialAmount: discountedPartial,
        balanceAmount: (discountedTotal - discountedPartial).toDouble(),
      ));
    }
  }

  void _onRemoveCoupon(RemoveCoupon event, Emitter<PaymentState> emit) {
    emit(PaymentInitial());
  }

  void _onSelectPaymentMethod(
      SelectPaymentMethod event, Emitter<PaymentState> emit) {
    if (state is PaymentCouponApplied) {
      final currentState = state as PaymentCouponApplied;
      emit(currentState.copyWith(paymentMethod: event.method));
    } else {
      emit(PaymentMethodSelected(
        paymentMethod: event.method,
        grandTotal: grandTotal,
        partialAmount: isPartialPayment ? grandTotal / 2 : 0,
        balanceAmount: isPartialPayment ? grandTotal / 2 : 0,
      ));
    }
  }

  void _onInitiateRazorpayPayment(
      InitiateRazorpayPayment event, Emitter<PaymentState> emit) async {
    emit(PaymentProcessing());

    try {
      var options = {
        'key': 'rzp_test_S1CDiBKOKdlxHY', 
        'amount': (event.amount * 100).toInt(), // Amount in paise
        'name': 'Rent Cam',
        'description': 'Camera Rental Payment',
        'prefill': {
          'contact': '8888888888', // You can get this from user profile
          'email': 'user@example.com' // You can get this from user profile
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      emit(PaymentError('Failed to initiate payment: $e'));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    add(PlaceOrder('Online', paymentId: response.paymentId));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    add(PaymentFailedEvent(response.message ?? 'Payment failed'));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
  }

  void _onPaymentFailed(PaymentFailedEvent event, Emitter<PaymentState> emit) {
    emit(PaymentFailedState(event.errorMessage));
  }

  Future<void> _onPlaceOrder(
      PlaceOrder event, Emitter<PaymentState> emit) async {
    try {
      final orderId = _generateOrderId();
      final productNames = cartItems.map((item) => item.product.name).toList();
      final startDate = cartItems.first.productDetail.startDate!;
      final endDate = cartItems.first.productDetail.endDate!;

      double discountPercentage = 0;
      double discountedTotal = grandTotal;
      String couponCode = '';

      if (state is PaymentCouponApplied) {
        final couponState = state as PaymentCouponApplied;
        discountPercentage = couponState.appliedOffer.percentage;
        discountedTotal = couponState.discountedTotal;
        couponCode = couponState.appliedOffer.couponCode;
      }

      final paymentDetails = PaymentDetails(
        orderId: orderId,
        startDate: startDate,
        endDate: endDate,
        grandTotal: grandTotal,
        discountPercentage: discountPercentage,
        discountedTotal: discountedTotal,
        partialAmount: isPartialPayment ? discountedTotal / 2 : 0,
        balanceAmount: isPartialPayment ? discountedTotal / 2 : 0,
        paymentMethod: event.paymentMethod,
        paymentId: event.paymentId,
        couponCode: couponCode,
        isPartialPayment: isPartialPayment,
        paymentDate: DateTime.now(),
        productNames: productNames,
        duration: cartItems.first.productDetail.duration,
      );

      await _saveOrderToFirebase(paymentDetails);
      await _removeItemsFromCart();

      emit(OrderPlaced(paymentDetails));
    } catch (e) {
      emit(PaymentError('Failed to place order: $e'));
    }
  }

  Future<void> _saveOrderToFirebase(PaymentDetails paymentDetails) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('orders').doc(paymentDetails.orderId).set({
      'orderId': paymentDetails.orderId,
      'productNames': paymentDetails.productNames,
      'startDate': paymentDetails.startDate.toIso8601String(),
      'endDate': paymentDetails.endDate.toIso8601String(),
      'duration': paymentDetails.duration,
      'grandTotal': paymentDetails.grandTotal,
      'discountedTotal': paymentDetails.discountedTotal,
      'paymentMethod': paymentDetails.paymentMethod,
      'paymentId': paymentDetails.paymentId,
      'paymentDate': paymentDetails.paymentDate.toIso8601String(),
      'status': paymentDetails.paymentMethod == 'Online' ? 'Paid' : 'Pending',
      'couponCode': paymentDetails.couponCode,
      'isPartialPayment': paymentDetails.isPartialPayment,
      'partialAmount': paymentDetails.partialAmount,
      'balanceAmount': paymentDetails.balanceAmount,
    });
  }

  Future<void> _removeItemsFromCart() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    for (var item in cartItems) {
      batch.delete(firestore.collection('cart').doc(item.id));
    }

    await batch.commit();
  }

  String _generateOrderId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      10,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}
