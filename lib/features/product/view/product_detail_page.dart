// product_detail_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/product/bloc/cart_bloc/cart_bloc.dart';
import 'package:rent_cam/features/product/bloc/product_details/product_detail_bloc.dart';
import 'package:rent_cam/features/product/model/product_detail_model.dart';
import 'package:rent_cam/features/product/service/product_detail_service.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductDetailBloc(productDetailService: ProductDetailService())
            ..add(FetchProductDetail(productId: productId)),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Product Details'),
        body: BlocListener<ProductDetailBloc, ProductDetailState>(
          listener: (context, state) {
            if (state is QuantityExceedsStock) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Only ${state.product.stock} items available')),
              );
            }
          },
          child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
            builder: (context, state) {
              if (state is ProductDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProductDetailError) {
                return Center(child: Text(state.message));
              } else if (state is ProductDetailLoaded) {
                final product = state.productDetail.product;
                final quantity = state.productDetail.quantity;
                final startDate = state.productDetail.startDate;
                final endDate = state.productDetail.endDate;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.indicatorInactive,
                          AppColors.cardGradientStart,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Images Carousel
                        if (product.images.isNotEmpty)
                          Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: PageView.builder(
                                  itemCount: product.images.length,
                                  onPageChanged: (index) {
                                    context
                                        .read<ProductDetailBloc>()
                                        .add(UpdateImageIndex(index: index));
                                  },
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: product.images[index],
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32, // Full width
                                          height: 250,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error,
                                                  size: 50,
                                                  color: AppColors.error),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Dot indicators
                              if (product.images.length > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    product.images.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: state.currentImageIndex == index
                                            ? AppColors.buttonText
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // Product Name and Model Number
                        Text(
                          "${product.name} - ${product.modelNumber}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.buttonText,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Product Description
                        Text(
                          product.description,
                          style: const TextStyle(
                              fontSize: 16, color: AppColors.buttonText),
                        ),
                        const SizedBox(height: 16),

                        // Rental Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Rent',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.buttonText,
                              ),
                            ),
                            Text(
                              '₹${product.rentalPrice}/Day',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.buttonText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Stock',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.buttonText,
                              ),
                            ),
                            Text(
                              '${product.stock}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.buttonText,
                              ),
                            ),
                          ],
                        ),
                        // Quantity Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                  fontSize: 16, color: AppColors.buttonText),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: AppColors.buttonText),
                                  onPressed: () {
                                    if (quantity > 1) {
                                      context.read<ProductDetailBloc>().add(
                                            UpdateQuantity(
                                                quantity: quantity - 1),
                                          );
                                    }
                                  },
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.buttonText),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: AppColors.buttonText),
                                  onPressed: () {
                                    if (quantity < product.stock) {
                                      context.read<ProductDetailBloc>().add(
                                            UpdateQuantity(
                                                quantity: quantity + 1),
                                          );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Cannot exceed available stock')),
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
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    if (endDate != null &&
                                        picked.isAfter(endDate)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Start date cannot be after end date'),
                                        ),
                                      );
                                    } else {
                                      context.read<ProductDetailBloc>().add(
                                            UpdateStartDate(startDate: picked),
                                          );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.buttonText),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    startDate == null
                                        ? 'Start Date'
                                        : DateFormat('yyyy-MMM-dd')
                                            .format(startDate),
                                    style: const TextStyle(
                                      fontSize: 16,
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
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    if (startDate != null &&
                                        picked.isBefore(startDate)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'End date cannot be before start date'),
                                        ),
                                      );
                                    } else {
                                      context.read<ProductDetailBloc>().add(
                                            UpdateEndDate(endDate: picked),
                                          );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.buttonText),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    endDate == null
                                        ? 'End Date'
                                        : DateFormat('yyyy-MMM-dd')
                                            .format(endDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.buttonText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Duration:',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.buttonText,
                              ),
                            ),
                            Text(
                              '${state.productDetail.duration} days',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.buttonText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // In your ProductDetailPage
                        Center(
                          child: BlocListener<CartBloc, CartState>(
                            listener: (context, state) {
                              if (state is CartError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else if (state is CartLoaded) {
                                Navigator.pushReplacementNamed(
                                    context, '/cart');
                              }
                            },
                            child: ElevatedButton(
                              onPressed: () {
                                if (startDate == null || endDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Please select both dates')),
                                  );
                                  return;
                                }

                                final productDetail = ProductDetailModel(
                                  product: product,
                                  quantity: quantity,
                                  startDate: startDate,
                                  endDate: endDate,
                                );

                                context.read<CartBloc>().add(
                                    AddToCart(productDetail: productDetail));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 36, 114, 248),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                              ),
                              child: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: Text('No product details available'));
            },
          ),
        ),
      ),
    );
  }
}
