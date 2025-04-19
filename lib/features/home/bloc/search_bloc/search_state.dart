import 'package:rent_cam/features/home/model/product_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<Product> products;
  SearchSuccess(this.products);
}

class SearchFailure extends SearchState {
  final String error;
  SearchFailure(this.error);
}