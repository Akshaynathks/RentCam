import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/product/model/product_model.dart';
import 'package:rent_cam/features/product/service/product_service.dart';
import 'package:rent_cam/features/product/service/wishlist_service.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService productService;
  final WishlistService wishlistService;

  ProductBloc({
    required this.productService,
    required this.wishlistService,
  }) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchProductsByCategoryOrBrand>(_onFetchProductsByCategoryOrBrand);
    on<ToggleWishlist>(_onToggleWishlist);
    on<LoadWishlist>(_onLoadWishlist);
    on<SyncWishlist>(_onSyncWishlist);
  }

  void _onFetchProducts(FetchProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await productService.fetchProducts();
      final wishlist = await wishlistService.getWishlist();
      emit(ProductLoaded(products: products, wishlist: wishlist));
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
      final wishlist = await wishlistService.getWishlist();
      emit(ProductLoaded(products: products, wishlist: wishlist));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  void _onToggleWishlist(ToggleWishlist event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      await wishlistService.toggleWishlist(event.productId);
      final updatedWishlist = await wishlistService.getWishlist();
      
      emit(ProductLoaded(
        products: currentState.products,
        wishlist: updatedWishlist,
      ));
    }
  }

  void _onLoadWishlist(LoadWishlist event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final wishlist = await wishlistService.getWishlist();
      emit(ProductLoaded(
        products: currentState.products,
        wishlist: wishlist,
      ));
    }
  }

  void _onSyncWishlist(SyncWishlist event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final wishlist = await wishlistService.getWishlist();
      emit(ProductLoaded(
        products: currentState.products,
        wishlist: wishlist,
      ));
    }
  }
}