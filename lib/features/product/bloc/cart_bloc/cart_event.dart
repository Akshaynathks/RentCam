part of 'cart_bloc.dart';

abstract class CartEvent {}

class FetchCartItems extends CartEvent {}

class AddToCart extends CartEvent {
  final ProductDetailModel productDetail;

  AddToCart({required this.productDetail});
}

class RemoveFromCart extends CartEvent {
  final String cartItemId;

  RemoveFromCart({required this.cartItemId});
}

class UpdateCartItem extends CartEvent {
  final CartItem cartItem;

  UpdateCartItem({required this.cartItem});
}

class TogglePaymentOption extends CartEvent {
  final bool isPartialPayment;

  TogglePaymentOption({required this.isPartialPayment});
}