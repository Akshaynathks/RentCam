import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/home/model/product_model.dart';
import 'package:rent_cam/features/home/services/product_service.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService productService;
  List<String> wishlist = [];

  ProductBloc({required this.productService}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchProductsByCategoryOrBrand>(_onFetchProductsByCategoryOrBrand);
    on<ToggleWishlist>(_onToggleWishlist);
  }

  void _onFetchProducts(FetchProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await productService.fetchProducts();
      emit(ProductLoaded(products: products, wishlist: List.from(wishlist)));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  void _onFetchProductsByCategoryOrBrand(
    FetchProductsByCategoryOrBrand event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await productService.fetchProductsByCategoryOrBrand(
        category: event.category,
        brand: event.brand,
      );
      emit(ProductLoaded(products: products, wishlist: List.from(wishlist)));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  void _onToggleWishlist(ToggleWishlist event, Emitter<ProductState> emit) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final updatedWishlist = List<String>.from(currentState.wishlist);

      if (updatedWishlist.contains(event.productId)) {
        updatedWishlist.remove(event.productId);
      } else {
        updatedWishlist.add(event.productId);
      }

      wishlist = updatedWishlist;

      emit(ProductLoaded(
        products: currentState.products,
        wishlist: updatedWishlist,
      ));
    }
  }
}