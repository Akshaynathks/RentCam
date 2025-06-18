import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/product/bloc/cart_bloc/cart_bloc.dart';
import 'package:rent_cam/features/product/model/cart_model.dart';

class EditCartItemPage extends StatefulWidget {
  final CartItem cartItem;

  const EditCartItemPage({super.key, required this.cartItem});

  @override
  State<EditCartItemPage> createState() => _EditCartItemPageState();
}

class _EditCartItemPageState extends State<EditCartItemPage> {
  late int quantity;
  late DateTime? startDate;
  late DateTime? endDate;

  @override
  void initState() {
    super.initState();
    quantity = widget.cartItem.productDetail.quantity;
    startDate = widget.cartItem.productDetail.startDate;
    endDate = widget.cartItem.productDetail.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Item'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.cartItem.product.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.buttonText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.buttonText,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.buttonText,
                      ),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      },
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.buttonText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.buttonText,
                      ),
                      onPressed: () {
                        if (quantity < widget.cartItem.product.stock) {
                          setState(() => quantity++);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cannot exceed available stock'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        if (endDate != null && picked.isAfter(endDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Start date cannot be after end date'),
                            ),
                          );
                        } else {
                          setState(() => startDate = picked);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        startDate == null
                            ? 'Start Date'
                            : DateFormat('dd MMM yyyy').format(startDate!),
                        style: const TextStyle(
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        if (startDate != null && picked.isBefore(startDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('End date cannot be before start date'),
                            ),
                          );
                        } else {
                          setState(() => endDate = picked);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        endDate == null
                            ? 'End Date'
                            : DateFormat('dd MMM yyyy').format(endDate!),
                        style: const TextStyle(
                          color: AppColors.buttonText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (startDate != null && endDate != null)
              Text(
                'Duration: ${endDate!.difference(startDate!).inDays + 1} days',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.buttonText,
                ),
              ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select both dates'),
                      ),
                    );
                    return;
                  }

                  final updatedCartItem = widget.cartItem.copyWith(
                    productDetail: widget.cartItem.productDetail.copyWith(
                      quantity: quantity,
                      startDate: startDate,
                      endDate: endDate,
                    ),
                    rent: (widget.cartItem.product.rentalPrice * quantity) *
                        (endDate!.difference(startDate!).inDays + 1),
                  );

                  context.read<CartBloc>().add(
                        UpdateCartItem(cartItem: updatedCartItem),
                      );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Update Item',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
