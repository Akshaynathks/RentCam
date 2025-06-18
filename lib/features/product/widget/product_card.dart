import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/core/utils/responsive_helper.dart';
import 'package:rent_cam/features/product/bloc/product/product_bloc.dart';
import 'package:rent_cam/features/product/view/product_detail_page.dart';
import 'package:rent_cam/core/widget/shimmer.dart';

class ProductCard extends StatefulWidget {
  final String productId;
  final String imageUrl;
  final String name;
  final String price;

  const ProductCard({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _previousWishlistState = false;
  String _formatPrice(String price) {
    try {
      final number = double.tryParse(price) ?? 0;
      final format = NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 0,
        locale: 'en_IN',
      );
      return format.format(number);
    } catch (e) {
      return '₹$price';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        bool isWishlisted = false;
        if (state is ProductLoaded) {
          isWishlisted = state.wishlist.contains(widget.productId);
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailPage(productId: widget.productId),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal:
                  ResponsiveHelper.getResponsivePadding(context).horizontal / 4,
              vertical:
                  ResponsiveHelper.getResponsivePadding(context).vertical / 4,
            ),
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context).horizontal / 4),
            decoration: BoxDecoration(
              color: AppColors.cardGradientEnd,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height:
                          ResponsiveHelper.getResponsiveImageHeight(context) *
                              0.75,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.imageUrl.isEmpty
                            ? const ShimmerEffect.rectangular(
                                height: 100, width: double.infinity)
                            : Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const ShimmerEffect.rectangular(
                                      height: 100, width: double.infinity);
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image,
                                      size: 50, color: Colors.red);
                                },
                              ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsiveHeight(context, 0.5)),
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsiveHeight(context, 0.3)),
                    Text(
                      _formatPrice(widget.price),
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.done,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      final wasWishlisted = isWishlisted;
                      context
                          .read<ProductBloc>()
                          .add(ToggleWishlist(productId: widget.productId));
                      // Show SnackBar only on user action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            wasWishlisted
                                ? 'Item removed from wishlist'
                                : 'Item added to wishlist',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted
                          ? AppColors.error
                          : AppColors.textSecondary,
                      size: ResponsiveHelper.getResponsiveIconSize(context, 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
