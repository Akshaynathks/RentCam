import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/search/bloc/search_bloc/search_event.dart';
import 'package:rent_cam/features/search/bloc/search_bloc/search_state.dart';
import 'package:rent_cam/features/product/model/product_model.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final List<Product> allProducts;
  String? currentFilter;
  String? currentCategory;
  String? currentBrand;
  bool showPriceFilter = false;
  double minPrice = 0;
  double maxPrice = 10000;

  // Define price thresholds for Beginner and Professional
  static const double beginnerMaxPrice = 1000;
  static const double professionalMinPrice = 1000;

  SearchBloc({required this.allProducts})
      : super(SearchSuccess(
          products: allProducts,
          currentFilter: null,
          currentCategory: null,
          currentBrand: null,
          showPriceFilter: false,
          minPrice: 0,
          maxPrice: 10000,
        )) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<FilterChanged>(_onFilterChanged);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
    on<BrandFilterChanged>(_onBrandFilterChanged);
    on<TogglePriceFilter>(_onTogglePriceFilter);
    on<PriceRangeChanged>(_onPriceRangeChanged);
  }

  void _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) {
    if (event.query.isEmpty) {
      emit(SearchSuccess(
        products: _applyFilters(allProducts),
        currentFilter: currentFilter,
        currentCategory: currentCategory,
        currentBrand: currentBrand,
        showPriceFilter: showPriceFilter,
        minPrice: minPrice,
        maxPrice: maxPrice,
      ));
      return;
    }

    final filteredProducts = allProducts.where((product) {
      final matchesQuery =
          product.name.toLowerCase().contains(event.query.toLowerCase());
      return matchesQuery && _matchesFilters(product);
    }).toList();

    emit(SearchSuccess(
      products: filteredProducts,
      currentFilter: currentFilter,
      currentCategory: currentCategory,
      currentBrand: currentBrand,
      showPriceFilter: showPriceFilter,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
  }

  void _onFilterChanged(FilterChanged event, Emitter<SearchState> emit) {
    currentFilter = currentFilter == event.filter ? null : event.filter;
    emit(SearchSuccess(
      products: _applyFilters(allProducts),
      currentFilter: currentFilter,
      currentCategory: currentCategory,
      currentBrand: currentBrand,
      showPriceFilter: showPriceFilter,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
  }

  void _onCategoryFilterChanged(
      CategoryFilterChanged event, Emitter<SearchState> emit) {
    currentCategory = currentCategory == event.category ? null : event.category;
    emit(SearchSuccess(
      products: _applyFilters(allProducts),
      currentFilter: currentFilter,
      currentCategory: currentCategory,
      currentBrand: currentBrand,
      showPriceFilter: showPriceFilter,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
  }

  void _onBrandFilterChanged(
      BrandFilterChanged event, Emitter<SearchState> emit) {
    currentBrand = currentBrand == event.brand ? null : event.brand;
    emit(SearchSuccess(
      products: _applyFilters(allProducts),
      currentFilter: currentFilter,
      currentCategory: currentCategory,
      currentBrand: currentBrand,
      showPriceFilter: showPriceFilter,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
  }

  void _onTogglePriceFilter(
      TogglePriceFilter event, Emitter<SearchState> emit) {
    showPriceFilter = !showPriceFilter;
    emit(SearchSuccess(
      products: _applyFilters(allProducts),
      currentFilter: currentFilter,
      currentCategory: currentCategory,
      currentBrand: currentBrand,
      showPriceFilter: showPriceFilter,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
  }

  void _onPriceRangeChanged(
      PriceRangeChanged event, Emitter<SearchState> emit) {
    minPrice = event.minPrice;
    maxPrice = event.maxPrice;
    emit(SearchSuccess(
      products: _applyFilters(allProducts),
      currentFilter: currentFilter,
      currentCategory: currentCategory,
      currentBrand: currentBrand,
      showPriceFilter: showPriceFilter,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
  }

  List<Product> _applyFilters(List<Product> products) {
    final filteredProducts =
        products.where((product) => _matchesFilters(product)).toList();
    print('Filtering products:');
    print('Current category: $currentCategory');
    print('Total products: ${products.length}');
    print('Filtered products: ${filteredProducts.length}');
    if (filteredProducts.isNotEmpty) {
      print(
          'First filtered product category: ${filteredProducts.first.category}');
    }
    return filteredProducts;
  }

  bool _matchesFilters(Product product) {
    // Convert both the product category and filter to lowercase for case-insensitive comparison
    final productCategory = product.category.toLowerCase();
    final filterCategory = currentFilter?.toLowerCase();
    final categoryFilter = currentCategory?.toLowerCase();
    final brandFilter = currentBrand?.toLowerCase();

    // Handle Beginner and Professional filters based on price
    bool matchesFilter = true;
    if (currentFilter != null) {
      if (currentFilter!.toLowerCase() == 'beginner') {
        matchesFilter = product.rentalPrice < beginnerMaxPrice;
      } else if (currentFilter!.toLowerCase() == 'professional') {
        matchesFilter = product.rentalPrice >= professionalMinPrice;
      } else {
        matchesFilter =
            filterCategory == null || productCategory == filterCategory;
      }
    }

    final matchesCategory =
        categoryFilter == null || productCategory == categoryFilter;
    final matchesBrand =
        brandFilter == null || product.brand.toLowerCase() == brandFilter;
    final matchesPrice = !showPriceFilter ||
        (product.rentalPrice >= minPrice && product.rentalPrice <= maxPrice);

    // Debug logging
    if (currentFilter != null) {
      print('Filter details:');
      print('Current filter: $currentFilter');
      print('Product price: ${product.rentalPrice}');
      print('Matches filter: $matchesFilter');
    }

    return matchesFilter && matchesCategory && matchesBrand && matchesPrice;
  }
}
