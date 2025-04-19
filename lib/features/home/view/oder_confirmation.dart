import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/home/model/payment_model.dart';

class OrderConfirmationPage extends StatelessWidget {
  final PaymentDetails paymentDetails;

  const OrderConfirmationPage({required this.paymentDetails, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Order Confirmation'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText),
              ),
              const SizedBox(height: 24),
              Text(
                'Order ID: ${paymentDetails.orderId}',
                style: const TextStyle(color: AppColors.buttonText),
              ),
              Text(
                'Amount Paid: ₹${paymentDetails.partialAmount.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.buttonText),
              ),
              if (paymentDetails.isPartialPayment)
                Text(
                  'Balance Amount: ₹${paymentDetails.balanceAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.buttonText),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
