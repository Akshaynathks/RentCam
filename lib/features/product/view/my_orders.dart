// orderpage.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrders extends StatelessWidget {
  const MyOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        appBar: CustomAppBar(
          title: 'My Orders',
        ),
        body: Center(child: Text('Please sign in to view your orders')),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Orders',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orders')
            .orderBy('paymentDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final order = snapshot.data!.docs[index];
              final data = order.data() as Map<String, dynamic>;

              return _buildOrderCard(
                context,
                data['orderId'],
                data['productNames'].join(', '),
                data['duration'],
                data['startDate'],
                data['endDate'],
                data['discountedTotal'] ?? data['grandTotal'],
                data['paymentMethod'],
                data['status'] ?? 'Pending',
                data['isPartialPayment'] ?? false,
                data['partialAmount'] ?? 0.0,
                data['balanceAmount'] ?? 0.0,
                data['discountPercentage'] ?? 0.0,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    String orderId,
    String productNames,
    int duration,
    String startDate,
    String endDate,
    double totalAmount,
    String paymentMethod,
    String status,
    bool isPartialPayment,
    double partialAmount,
    double balanceAmount,
    double discountPercentage,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #$orderId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: status == 'Pending'
                      ? Colors.orange[100]
                      : Colors.green[100],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              productNames,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: $duration days',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'From ${DateFormat('dd MMM yyyy').format(DateTime.parse(startDate))} '
              'to ${DateFormat('dd MMM yyyy').format(DateTime.parse(endDate))}',
              style: const TextStyle(fontSize: 14),
            ),
            if (discountPercentage > 0)
              Text(
                'Discount Applied: ${discountPercentage}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isPartialPayment) ...[
              const SizedBox(height: 8),
              Text(
                'Amount Paid: ₹${partialAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
              Text(
                'Balance Amount : ₹${balanceAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Payment Status: Partial Payment',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 8, 8, 8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Payment Method: $paymentMethod',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
