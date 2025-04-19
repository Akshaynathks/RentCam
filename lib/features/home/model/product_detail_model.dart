import 'package:rent_cam/features/home/model/product_model.dart';

class ProductDetailModel {
  final Product product;
  final int quantity;
  final DateTime? startDate;
  final DateTime? endDate;
  final int duration;

  ProductDetailModel({
    required this.product,
    required this.quantity,
    this.startDate,
    this.endDate,
  }) : duration = (startDate != null && endDate != null) 
            ? endDate.difference(startDate).inDays + 1 
            : 0;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'duration': duration,
    };
  }

  ProductDetailModel copyWith({
    Product? product,
    int? quantity,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ProductDetailModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}