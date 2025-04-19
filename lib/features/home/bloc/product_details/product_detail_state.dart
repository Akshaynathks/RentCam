// product_detail_state.dart
part of 'product_detail_bloc.dart';

abstract class ProductDetailState {}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final ProductDetailModel productDetail;
  final int currentImageIndex;

  ProductDetailLoaded({required this.productDetail,this.currentImageIndex=0});

  ProductDetailLoaded copyWith({
    ProductDetailModel? productDetail,
    int?currentImageIndex,
  }) {
    return ProductDetailLoaded(
      productDetail: productDetail ?? this.productDetail,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
    );
  }
}

class QuantityExceedsStock extends ProductDetailState {
  final Product product;

  QuantityExceedsStock({required this.product});
}

class ProductDetailError extends ProductDetailState {
  final String message;

  ProductDetailError({required this.message});
}