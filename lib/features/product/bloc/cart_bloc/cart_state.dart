// cart_state.dart
part of 'cart_bloc.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> cartItems;

  CartLoaded({required this.cartItems});
}

class CartError extends CartState {
  final String message;

  CartError({required this.message});
}