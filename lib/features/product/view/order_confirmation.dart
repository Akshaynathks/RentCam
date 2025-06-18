import 'package:flutter/material.dart';
import 'package:rent_cam/features/product/model/payment_model.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/color.dart';

class OrderConfirmation extends StatefulWidget {
  final PaymentDetails paymentDetails;

  const OrderConfirmation({
    Key? key,
    required this.paymentDetails,
  }) : super(key: key);

  @override
  _OrderConfirmationState createState() => _OrderConfirmationState();
}

class _OrderConfirmationState extends State<OrderConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.cardGradientStart,
              AppColors.cardGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/images/Animation - payment done.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Confirmed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your order has been placed successfully',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDetailCard(widget.paymentDetails),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.cardGradientStart,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(PaymentDetails paymentDetails) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Order ID', paymentDetails.orderId),
          _buildDetailRow('Products', paymentDetails.productNames.join(', ')),
          _buildDetailRow('Duration', '${paymentDetails.duration} days'),
          _buildDetailRow('Start Date', _formatDate(paymentDetails.startDate)),
          _buildDetailRow('End Date', _formatDate(paymentDetails.endDate)),
          _buildDetailRow('Total Amount',
              '₹${paymentDetails.grandTotal.toStringAsFixed(2)}'),
          if (paymentDetails.discountPercentage > 0) ...[
            _buildDetailRow(
              'Discount Applied',
              '${paymentDetails.discountPercentage}%',
              valueColor: Colors.green,
            ),
            _buildDetailRow(
              'Discounted Amount',
              '₹${paymentDetails.discountedTotal.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
          ],
          if (paymentDetails.isPartialPayment) ...[
            _buildDetailRow(
              'Amount Paid',
              '₹${paymentDetails.partialAmount.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
            _buildDetailRow(
              'Balance Amount (Pending)',
              '₹${paymentDetails.balanceAmount.toStringAsFixed(2)}',
              valueColor: Colors.orange,
            ),
          ] else ...[
            _buildDetailRow(
              'Amount Paid',
              '₹${paymentDetails.discountedTotal.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
          ],
          _buildDetailRow('Payment Method', paymentDetails.paymentMethod),
          if (paymentDetails.paymentId != null)
            _buildDetailRow('Payment ID', paymentDetails.paymentId!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
