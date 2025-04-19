part of 'product_bloc.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<String> wishlist;

  ProductLoaded({required this.products, required this.wishlist});
}

class ProductError extends ProductState {
  final String message;

  ProductError({required this.message});
}