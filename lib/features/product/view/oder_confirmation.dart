import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/product/model/payment_model.dart';

class OrderConfirmationPage extends StatelessWidget {
  final PaymentDetails paymentDetails;

  const OrderConfirmationPage({required this.paymentDetails, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showBackButton: false,
      ),
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cardGradientStart,
                    AppColors.cardGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/images/Animation - payment.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Placed Successfully!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildDetailCard(paymentDetails),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white70,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
              'Balance Amount',
              '₹${paymentDetails.balanceAmount.toStringAsFixed(2)}',
              valueColor: Colors.orange,
            ),
            _buildDetailRow(
              'Payment Method',
              paymentDetails.paymentMethod,
            ),
          ] else ...[
            _buildDetailRow(
              'Amount Paid',
              '₹${paymentDetails.discountedTotal.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
            _buildDetailRow(
              'Payment Method',
              paymentDetails.paymentMethod,
            ),
          ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
