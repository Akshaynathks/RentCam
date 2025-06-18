import 'package:rent_cam/features/product/model/product_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<Product> products;
  final String? currentFilter;
  final String? currentCategory;
  final String? currentBrand;
  final bool showPriceFilter;
  final double minPrice;
  final double maxPrice;

  SearchSuccess({
    required this.products,
    this.currentFilter,
    this.currentCategory,
    this.currentBrand,
    this.showPriceFilter = false,
    this.minPrice = 0,
    this.maxPrice = 10000,
  });
}

class SearchFailure extends SearchState {
  final String error;
  SearchFailure(this.error);
}
