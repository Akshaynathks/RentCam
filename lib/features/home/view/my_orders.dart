// orderpage.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:intl/intl.dart';

class MyOrders extends StatelessWidget {
  const MyOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Orders',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
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
            const SizedBox(height: 8),
            Text(
              'Total: ₹${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
