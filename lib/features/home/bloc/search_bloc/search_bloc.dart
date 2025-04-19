import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/home/bloc/search_bloc/search_event.dart';
import 'package:rent_cam/features/home/bloc/search_bloc/search_state.dart';
import 'package:rent_cam/features/home/model/product_model.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final List<Product> allProducts;
  String currentFilter = 'All';
  String currentCategory = 'All';
  String currentBrand = 'All'; 

  SearchBloc({required this.allProducts}) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<FilterChanged>(_onFilterChanged);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
    on<BrandFilterChanged>(_onBrandFilterChanged); // New event handler
    // ignore: invalid_use_of_visible_for_testing_member
    emit(SearchSuccess(allProducts));
  }

  void _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    final filteredProducts = _filterProducts(event.query, currentFilter, currentCategory, currentBrand);
    emit(SearchSuccess(filteredProducts));
  }

  void _onFilterChanged(FilterChanged event, Emitter<SearchState> emit) {
    // Toggle behavior: If the same filter is selected again, reset it to 'All'
    currentFilter = (currentFilter == event.filter) ? 'All' : event.filter;
    final filteredProducts = _filterProducts('', currentFilter, currentCategory, currentBrand);
    emit(SearchSuccess(filteredProducts));
  }

  void _onCategoryFilterChanged(CategoryFilterChanged event, Emitter<SearchState> emit) {
    // Toggle behavior: If the same category is selected again, reset it to 'All'
    currentCategory = (currentCategory == event.category) ? 'All' : event.category;
    final filteredProducts = _filterProducts('', currentFilter, currentCategory, currentBrand);
    emit(SearchSuccess(filteredProducts));
  }

  void _onBrandFilterChanged(BrandFilterChanged event, Emitter<SearchState> emit) {
    // Toggle behavior: If the same brand is selected again, reset it to 'All'
    currentBrand = (currentBrand == event.brand) ? 'All' : event.brand;
    final filteredProducts = _filterProducts('', currentFilter, currentCategory, currentBrand);
    emit(SearchSuccess(filteredProducts));
  }

  List<Product> _filterProducts(String query, String filter, String category, String brand) {
    List<Product> filteredProducts = allProducts;

    // Apply price filter
    filteredProducts = filteredProducts.where((product) {
      final rentalPrice = double.tryParse(product.rentalPrice.toString()) ?? 0;
      
      if (filter == 'Beginner') {
        return rentalPrice < 1000;
      } else if (filter == 'Professional') {
        return rentalPrice >= 1000;
      }
      return true; 
    }).toList();

    // Apply category filter
    if (category != 'All') {
      filteredProducts = filteredProducts
          .where((product) => product.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    // Apply brand filter
    if (brand != 'All') {
      filteredProducts = filteredProducts
          .where((product) => product.brand.toLowerCase() == brand.toLowerCase())
          .toList();
    }

    // Apply search query filter
    if (query.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return filteredProducts;
  }
}