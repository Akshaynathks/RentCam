abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class FilterChanged extends SearchEvent {
  final String filter;
  FilterChanged(this.filter);
}

class CategoryFilterChanged extends SearchEvent {
  final String category;
  CategoryFilterChanged(this.category);
}

class BrandFilterChanged extends SearchEvent {
  final String brand;
  BrandFilterChanged(this.brand);
}