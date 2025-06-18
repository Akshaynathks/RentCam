import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/product/bloc/cart_bloc/cart_bloc.dart';
import 'package:rent_cam/features/product/model/cart_model.dart';
import 'package:rent_cam/features/product/service/cart_service.dart';
import 'package:rent_cam/features/product/view/checkout.dart';
import 'package:rent_cam/features/product/view/edit_cart.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CartBloc(cartService: CartService())..add(FetchCartItems()),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'My Cart',backButtonRoute:
              '/home',),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CartError) {
              return Center(child: Text(state.message));
            } else if (state is CartLoaded) {
              final cartItems = state.cartItems;

              if (cartItems.isEmpty) {
                return const Center(
                    child: Text(
                  'Your cart is empty',
                  style: TextStyle(color: AppColors.buttonText),
                ));
              }

              final totalRent =
                  cartItems.fold(0.0, (sum, item) => sum + item.rent);
              final insuranceCharge = cartItems.length * 100.0;
              final grandTotal = totalRent + insuranceCharge;
              final partialAmount = grandTotal / 2;
              final balanceAmount = grandTotal - partialAmount;
              final isAnyPartial =
                  cartItems.any((item) => item.isPartialPayment);
              final payableAmount = isAnyPartial ? partialAmount : grandTotal;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return _buildCartItem(context, item);
                      },
                    ),
                  ),
                  _buildRentSummary(
                    context,
                    totalRent,
                    insuranceCharge,
                    grandTotal,
                    partialAmount,
                    balanceAmount,
                    payableAmount,
                    cartItems,
                  ),
                ],
              );
            }
            return const Center(child: Text('No cart items available'));
          },
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.product.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.images.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rent: ₹${item.rent.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Quantity: ${item.productDetail.quantity}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Duration: ${item.productDetail.duration.toString()} days',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'From ${item.productDetail.startDate != null ? DateFormat('dd MMM yyyy').format(item.productDetail.startDate!) : 'Not set'} to ${item.productDetail.endDate != null ? DateFormat('dd MMM yyyy').format(item.productDetail.endDate!) : 'Not set'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditCartItemPage(cartItem: item),
                        ),
                      );
                    } else if (value == 'delete') {
                      context.read<CartBloc>().add(
                            RemoveFromCart(cartItemId: item.id),
                          );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'edit', 'delete'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child:
                            Text(choice[0].toUpperCase() + choice.substring(1)),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentSummary(
    BuildContext context,
    double totalRent,
    double insuranceCharge,
    double grandTotal,
    double partialAmount,
    double balanceAmount,
    double payableAmount,
    List<CartItem> cartItems,
  ) {
    final isPartialPayment = cartItems.any((item) => item.isPartialPayment);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Rent Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Rental Charge:', totalRent.toStringAsFixed(1)),
          _buildSummaryRow(
              'Insurance Charge:', insuranceCharge.toStringAsFixed(1)),
          _buildSummaryRow('Grand Total:', grandTotal.toStringAsFixed(1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPaymentOption(
                context,
                'Full Amount',
                !isPartialPayment,
                false,
              ),
              _buildPaymentOption(
                context,
                'Partial Amount',
                isPartialPayment,
                true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Total Payable',
            grandTotal.toStringAsFixed(1),
            isBold: true,
          ),
          if (isPartialPayment) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Partial Amount (Pay Now):',
              partialAmount.toStringAsFixed(1),
              textColor: Colors.green,
            ),
            _buildSummaryRow(
              'Balance Amount (Pay Later):',
              balanceAmount.toStringAsFixed(1),
              textColor: Colors.orange,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSelectionPage(
                        grandTotal: grandTotal,
                        cartItems: cartItems,
                        isPartialPayment: isPartialPayment,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                ),
                child: const Text(
                  'CHECKOUT',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
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
            '₹$value',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String label,
    bool isSelected,
    bool isPartial,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<CartBloc>().add(
              TogglePaymentOption(isPartialPayment: isPartial),
            );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.buttonPrimary : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
