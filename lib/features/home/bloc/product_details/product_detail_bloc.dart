import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/home/model/product_detail_model.dart';
import 'package:rent_cam/features/home/model/product_model.dart';
import 'package:rent_cam/features/home/services/product_detail_service.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductDetailService productDetailService;

  ProductDetailBloc({required this.productDetailService})
      : super(ProductDetailInitial()) {
    on<FetchProductDetail>(_onFetchProductDetail);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<UpdateStartDate>(_onUpdateStartDate);
    on<UpdateEndDate>(_onUpdateEndDate);
    on<UpdateImageIndex>(_onUpdateImageIndex);
  }

  void _onFetchProductDetail(
      FetchProductDetail event, Emitter<ProductDetailState> emit) async {
    emit(ProductDetailLoading());
    try {
      final product =
          await productDetailService.fetchProductById(event.productId);

      final productDetail = ProductDetailModel(
        product: product,
        quantity: 1,
        startDate: null,
        endDate: null,
      );

      emit(ProductDetailLoaded(productDetail: productDetail));
    } catch (e) {
      emit(ProductDetailError(message: e.toString()));
    }
  }

  void _onUpdateQuantity(
      UpdateQuantity event, Emitter<ProductDetailState> emit) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      final int newQuantity = event.quantity;

      if (newQuantity > 0 &&
          newQuantity <= currentState.productDetail.product.stock) {
        emit(currentState.copyWith(
          productDetail: currentState.productDetail.copyWith(
            quantity: newQuantity,
            startDate: currentState.productDetail.startDate,
            endDate: currentState.productDetail.endDate,
          ),
        ));
      } else if (newQuantity > currentState.productDetail.product.stock) {
        emit(currentState.copyWith(
          productDetail: currentState.productDetail.copyWith(
            quantity: currentState.productDetail.product.stock,
            startDate: currentState.productDetail.startDate,
            endDate: currentState.productDetail.endDate,
          ),
        ));
        emit(QuantityExceedsStock(product: currentState.productDetail.product));
      }
    }
  }

  void _onUpdateStartDate(
      UpdateStartDate event, Emitter<ProductDetailState> emit) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      emit(currentState.copyWith(
        productDetail:
            currentState.productDetail.copyWith(startDate: event.startDate),
      ));
    }
  }

  void _onUpdateEndDate(UpdateEndDate event, Emitter<ProductDetailState> emit) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      emit(currentState.copyWith(
        productDetail:
            currentState.productDetail.copyWith(endDate: event.endDate),
      ));
    }
  }

  void _onUpdateImageIndex(
      UpdateImageIndex event, Emitter<ProductDetailState> emit) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      emit(currentState.copyWith(
        currentImageIndex: event.index,
      ));
    }
  }
}
