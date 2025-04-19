import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/home/model/cart_model.dart';
import 'package:rent_cam/features/home/model/product_detail_model.dart';
import 'package:rent_cam/features/home/services/cart_service.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService cartService;

  CartBloc({required this.cartService}) : super(CartInitial()) {
    on<FetchCartItems>(_onFetchCartItems);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<TogglePaymentOption>(_onTogglePaymentOption);
  }

  Future<void> _onFetchCartItems(
      FetchCartItems event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cartItems = await cartService.fetchCartItems();
      emit(CartLoaded(cartItems: cartItems));
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> _onAddToCart(
      AddToCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      await cartService.addToCart(
        product: event.productDetail.product,
        productDetail: event.productDetail,
      );
      final cartItems = await cartService.fetchCartItems();
      emit(CartLoaded(cartItems: cartItems));
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCart event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        await cartService.removeFromCart(event.cartItemId);
        add(FetchCartItems());
      } catch (e) {
        emit(CartError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateCartItem(
      UpdateCartItem event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        await cartService.updateCartItem(event.cartItem);
        add(FetchCartItems());
      } catch (e) {
        emit(CartError(message: e.toString()));
      }
    }
  }

Future<void> _onTogglePaymentOption(
    TogglePaymentOption event, Emitter<CartState> emit) async {
  if (state is CartLoaded) {
    try {
      await cartService.togglePaymentOption(
        isPartialPayment: event.isPartialPayment,
      );
      add(FetchCartItems());
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }
}
}