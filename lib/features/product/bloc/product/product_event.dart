part of 'product_bloc.dart';

abstract class ProductEvent {}

class FetchProducts extends ProductEvent {}

class FetchProductsByCategoryOrBrand extends ProductEvent {
  final String? category;
  final String? brand;

  FetchProductsByCategoryOrBrand({this.category, this.brand});
}

class ToggleWishlist extends ProductEvent {
  final String productId;

  ToggleWishlist({required this.productId});
}

class LoadWishlist extends ProductEvent {}

class SyncWishlist extends ProductEvent {}