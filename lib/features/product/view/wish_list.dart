import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/core/utils/responsive_helper.dart';
import 'package:rent_cam/features/product/bloc/product/product_bloc.dart';
import 'package:rent_cam/features/product/service/product_service.dart';
import 'package:rent_cam/features/product/service/wishlist_service.dart';
import 'package:rent_cam/features/product/widget/product_card.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductBloc(
        productService: ProductService(),
        wishlistService: WishlistService(),
      )..add(FetchProducts()),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () async {
          // Trigger sync when navigating back
          context.read<ProductBloc>().add(SyncWishlist());
          return true;
        },
        child: Scaffold(
          appBar: const CustomAppBar(
            title: 'Wishlist',
            showBackButton: true,
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
                final wishlistedProducts = state.products
                    .where((product) => state.wishlist.contains(product.id))
                    .toList();

                if (wishlistedProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'No products in your wishlist.',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 16),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductBloc>().add(LoadWishlist());
                  },
                  child: GridView.builder(
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
                    itemCount: wishlistedProducts.length,
                    itemBuilder: (context, index) {
                      final product = wishlistedProducts[index];
                      return ProductCard(
                        productId: product.id,
                        imageUrl:
                            product.images.isNotEmpty ? product.images[0] : '',
                        name: product.name,
                        price: product.rentalPrice.toString(),
                      );
                    },
                  ),
                );
              }
              return Center(
                child: Text(
                  'No products available',
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 16),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
