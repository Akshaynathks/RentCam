import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/home/bloc/payment_bloc/payment_bloc.dart';
import 'package:rent_cam/features/home/model/cart_model.dart';
import 'package:rent_cam/features/home/model/offer_model.dart';
import 'package:rent_cam/features/home/view/oder_confirmation.dart';
import 'package:rent_cam/features/home/view/offer_page.dart';

class PaymentSelectionPage extends StatelessWidget {
  final double grandTotal;
  final List<CartItem> cartItems;
  final bool isPartialPayment;

  const PaymentSelectionPage({
    required this.grandTotal,
    required this.cartItems,
    required this.isPartialPayment,
    super.key,
  });

 @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(
        cartItems: cartItems,
        grandTotal: grandTotal,
        isPartialPayment: isPartialPayment,
      ),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Select Payment Method'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductInfo(cartItems),
              const SizedBox(height: 16),
              _buildCouponSection(),
              const SizedBox(height: 16),
              _buildPaymentSummary(),
              const SizedBox(height: 16),
              _buildPaymentOptions(),
              const SizedBox(height: 24),
              _buildOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(List<CartItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items
                .map((item) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product: ${item.product.name}'),
                        Text('Duration: ${item.productDetail.duration} days'),
                        Text(
                          'From ${DateFormat('dd MMM yyyy').format(item.productDetail.startDate!)} '
                          'to ${DateFormat('dd MMM yyyy').format(item.productDetail.endDate!)}',
                        ),
                        const Divider(),
                      ],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        final couponController = TextEditingController();
        bool isCouponApplied = state is PaymentCouponApplied;

        if (isCouponApplied) {
          couponController.text = state.appliedOffer.couponCode;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apply Coupon',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: couponController,
                  decoration: const InputDecoration(
                    hintText: 'Enter coupon code',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: isCouponApplied,
                  enabled: !isPartialPayment,
                ),
                const SizedBox(height: 8),
                if (!isCouponApplied && !isPartialPayment)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (couponController.text.isNotEmpty) {
                              // Here you would validate the coupon code
                              // For demo, we'll create a temporary offer
                              final tempOffer = Offer(
                                id: 'temp',
                                couponCode: couponController.text,
                                percentage: 10, // Default percentage for demo
                                description: 'Manual coupon',
                                imageUrl: null,
                              );
                              context
                                  .read<PaymentBloc>()
                                  .add(ApplyCoupon(tempOffer));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please enter a coupon code')),
                              );
                            }
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OfferPage(),
                              ),
                            ).then((offer) {
                              if (offer != null) {
                                couponController.text = offer.couponCode;
                                context
                                    .read<PaymentBloc>()
                                    .add(ApplyCoupon(offer));
                              }
                            });
                          },
                          child: const Text('Offers'),
                        ),
                      ),
                    ],
                  ),
                if (isCouponApplied)
                  ElevatedButton(
                    onPressed: () {
                      context.read<PaymentBloc>().add(RemoveCoupon());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Remove Coupon'),
                  ),
                if (isPartialPayment)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Coupons can only be applied to full payments',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                if (isCouponApplied) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Discount: ${state.appliedOffer.percentage}% applied',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentSummary() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        // Calculate totals from cart items
        final totalRent = cartItems.fold(0.0, (sum, item) => sum + item.rent);
        final insuranceCharge = cartItems.length * 100.0;
        final grandTotal = totalRent + insuranceCharge;
        final partialAmount = cartItems.fold(
            0.0,
            (sum, item) =>
                sum + (item.isPartialPayment ? item.partialAmount : 0));
        final balanceAmount = cartItems.fold(
            0.0,
            (sum, item) =>
                sum + (item.isPartialPayment ? item.balanceAmount : 0));
        final payableAmount =
            cartItems.fold(0.0, (sum, item) => sum + item.payableAmount);

        double displayTotal = grandTotal;
        double displayPartial = partialAmount;
        double displayBalance = balanceAmount;
        double displayPayable = payableAmount;

        if (state is PaymentCouponApplied && !isPartialPayment) {
          displayTotal = state.discountedTotal;
          displayPayable = state.discountedTotal;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                    'Rental Charge:', '₹${totalRent.toStringAsFixed(2)}'),
                _buildSummaryRow('Insurance Charge:',
                    '₹${insuranceCharge.toStringAsFixed(2)}'),
                _buildSummaryRow(
                    'Grand Total:', '₹${grandTotal.toStringAsFixed(2)}'),
                if (state is PaymentCouponApplied && !isPartialPayment)
                  _buildSummaryRow(
                    'Discount (${state.appliedOffer.percentage}%):',
                    '-₹${(grandTotal - state.discountedTotal).toStringAsFixed(2)}',
                  ),
                _buildSummaryRow(
                  'Total Amount:',
                  '₹${displayTotal.toStringAsFixed(2)}',
                  isBold: true,
                ),
                if (isPartialPayment) ...[
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Partial Amount:',
                    '₹${displayPartial.toStringAsFixed(2)}',
                  ),
                  _buildSummaryRow(
                    'Balance Amount:',
                    '₹${displayBalance.toStringAsFixed(2)}',
                    textColor: AppColors.error,
                  ),
                ],
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Total Payable:',
                  '₹${displayPayable.toStringAsFixed(2)}',
                  isBold: true,
                  textColor: AppColors.done,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOptions() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        String? selectedMethod;
        if (state is PaymentCouponApplied) {
          selectedMethod = state.paymentMethod;
        } else if (state is PaymentMethodSelected) {
          selectedMethod = state.paymentMethod;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.buttonText),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Online Payment'),
                    selected: selectedMethod == 'Online',
                    onSelected: (selected) {
                      context
                          .read<PaymentBloc>()
                          .add(SelectPaymentMethod(selected ? 'Online' : ''));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Cash on Pickup'),
                    selected: selectedMethod == 'Cash',
                    onSelected: (selected) {
                      context
                          .read<PaymentBloc>()
                          .add(SelectPaymentMethod(selected ? 'Cash' : ''));
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderButton() {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is OrderPlaced) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmationPage(
                paymentDetails: state.paymentDetails,
              ),
            ),
          );
        } else if (state is PaymentProcessing) {
          // Handle payment processing state if needed
        }
      },
      builder: (context, state) {
        bool isMethodSelected = false;
        String? paymentMethod;

        if (state is PaymentCouponApplied) {
          isMethodSelected = state.paymentMethod != null;
          paymentMethod = state.paymentMethod;
        } else if (state is PaymentMethodSelected) {
          isMethodSelected = true;
          paymentMethod = state.paymentMethod;
        }

        return Center(
          child: Column(
            children: [
              Text(
                'Order ID: ${_generateTempOrderId()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.buttonText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (isMethodSelected && paymentMethod != null) {
                    if (paymentMethod == 'Online') {
                      // Initiate Razorpay payment
                      context.read<PaymentBloc>().add(InitiateRazorpayPayment(
                            amount: (state is PaymentCouponApplied)
                                ? state.discountedTotal
                                : grandTotal,
                            isPartialPayment: isPartialPayment,
                          ));
                    } else {
                      // Cash on pickup
                      context.read<PaymentBloc>().add(PlaceOrder(paymentMethod));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a payment method'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor:
                      isMethodSelected ? AppColors.buttonPrimary : Colors.grey,
                ),
                child: Text(
                  'PLACE ORDER',
                  style: TextStyle(
                    fontSize: 18,
                    color: isMethodSelected
                        ? AppColors.buttonText
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
              color: textColor, // Color only applied to the value
            ),
          ),
        ],
      ),
    );
  }

  String _generateTempOrderId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      10,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }
}
