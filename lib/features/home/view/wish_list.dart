import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/features/home/bloc/product/product_bloc.dart';
import 'package:rent_cam/features/home/widget/product_card.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Wishlist',
        showBackButton: true,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoaded) {
            final wishlistedProducts = state.products
                .where((product) => state.wishlist.contains(product.id))
                .toList();

            if (wishlistedProducts.isEmpty) {
              return const Center(child: Text('No products in your wishlist.'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: wishlistedProducts.length,
              itemBuilder: (context, index) {
                final product = wishlistedProducts[index];
                return ProductCard(
                  productId: product.id,
                  imageUrl: product.images.isNotEmpty ? product.images[0] : '',
                  name: product.name,
                  price: product.rentalPrice.toString(),
                );
              },
            );
          } else if (state is ProductError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}