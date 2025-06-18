import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/utils/responsive_helper.dart';
import 'package:rent_cam/features/product/bloc/product/product_bloc.dart';
import 'package:rent_cam/features/product/service/product_service.dart';
import 'package:rent_cam/features/product/service/wishlist_service.dart';
import 'package:rent_cam/features/product/widget/product_card.dart';

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
      create: (context) => ProductBloc(
        productService: ProductService(),
        wishlistService: WishlistService(),
      )..add(category != null || brand != null
          ? FetchProductsByCategoryOrBrand(category: category, brand: brand)
          : FetchProducts()),
      child: BlocListener<ProductBloc, ProductState>(
        listenWhen: (previous, current) => current is ProductLoaded,
        listener: (context, state) {
          if (state is ProductLoaded) {
            // Sync wishlist state when the page becomes visible
            context.read<ProductBloc>().add(SyncWishlist());
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            showBackButton: true,
            title: 'Products',
            backButtonRoute: '/home',
            actions: [
              Padding(
                padding: EdgeInsets.only(
                  right: ResponsiveHelper.getResponsivePadding(context).right,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/wishList');
                  },
                  child: Lottie.asset(
                    'assets/images/Animation - wishList.json',
                    width: ResponsiveHelper.getResponsiveIconSize(context, 60),
                    height: ResponsiveHelper.getResponsiveIconSize(context, 60),
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
              } else if (state is ProductError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                  ),
                );
              } else if (state is ProductLoaded) {
                return GridView.builder(
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        ResponsiveHelper.getResponsiveGridCrossAxisCount(
                            context),
                    crossAxisSpacing:
                        ResponsiveHelper.getResponsivePadding(context)
                                .horizontal *
                            0.0,
                    mainAxisSpacing:
                        ResponsiveHelper.getResponsivePadding(context)
                                .vertical *
                            0.0,
                    childAspectRatio:
                        ResponsiveHelper.isMobile(context) ? 0.75 : 0.85,
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
              } else {
                return Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
