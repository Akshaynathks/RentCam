import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/features/home/bloc/product/product_bloc.dart';
import 'package:rent_cam/features/home/services/product_service.dart';
import 'package:rent_cam/features/home/widget/product_card.dart';

class ProductsPage extends StatelessWidget {
  final String? category;
  final String? brand;

  const ProductsPage({super.key, this.category, this.brand});

  static Route<void> route({String? category, String? brand}) {
    return MaterialPageRoute(
      builder: (context) => ProductsPage(category: category, brand: brand),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final category = args?['category'] as String?;
    final brand = args?['brand'] as String?;

    return BlocProvider(
      create: (context) => ProductBloc(productService: ProductService())
        ..add(category != null || brand != null
            ? FetchProductsByCategoryOrBrand(category: category, brand: brand)
            : FetchProducts()),
      child: Scaffold(
        appBar: CustomAppBar(
          showBackButton: true,
          title: 'Products',
          backButtonRoute:
              '/home', // Pass the route name for the main home page
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/wishList');
                },
                child: Lottie.asset(
                  'assets/images/Animation - wishList.json',
                  width: 60,
                  height: 60,
                  repeat: true,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductLoaded) {
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return ProductCard(
                    productId: product.id,
                    imageUrl:
                        product.images.isNotEmpty ? product.images[0] : '',
                    name: product.name,
                    price: product.rentalPrice.toString(),
                  );
                },
              );
            } else if (state is ProductError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('No products available'));
            }
          },
        ),
      ),
    );
  }
}
