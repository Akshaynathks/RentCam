// product_detail_event.dart
part of 'product_detail_bloc.dart';

abstract class ProductDetailEvent {}

class FetchProductDetail extends ProductDetailEvent {
  final String productId;

  FetchProductDetail({required this.productId});
}

class UpdateQuantity extends ProductDetailEvent {
  final int quantity;

  UpdateQuantity({required this.quantity});
}

class UpdateStartDate extends ProductDetailEvent {
  final DateTime startDate;

  UpdateStartDate({required this.startDate});
}

class UpdateEndDate extends ProductDetailEvent {
  final DateTime endDate;

  UpdateEndDate({required this.endDate});
}


class UpdateImageIndex extends ProductDetailEvent { 
  final int index;
  UpdateImageIndex({required this.index});
}
