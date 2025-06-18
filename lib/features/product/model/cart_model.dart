// cart_model.dart
import 'package:rent_cam/features/product/model/product_detail_model.dart';
import 'package:rent_cam/features/product/model/product_model.dart';

class CartItem {
  final String id; 
  final Product product;
  final ProductDetailModel productDetail;
  final double rent;
  final double totalRent;
  final double insuranceCharge;
  final double grandTotal;
  final double partialAmount;
  final double balanceAmount;
  final double payableAmount;
  final bool isPartialPayment;

  CartItem({
    required this.id,
    required this.product,
    required this.productDetail,
    required this.rent,
    required this.totalRent,
    this.insuranceCharge = 100.0,
    required this.grandTotal,
    required this.partialAmount,
    required this.balanceAmount,
    required this.payableAmount,
    this.isPartialPayment = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': productDetail.quantity,
      'startDate': productDetail.startDate?.toIso8601String(),
      'endDate': productDetail.endDate?.toIso8601String(),
      'duration': productDetail.duration,
      'rent': rent,
      'totalRent': totalRent,
      'insuranceCharge': insuranceCharge,
      'grandTotal': grandTotal,
      'partialAmount': partialAmount,
      'balanceAmount': balanceAmount,
      'payableAmount': payableAmount,
      'isPartialPayment': isPartialPayment,
    };
  }

 factory CartItem.fromMap(Map<String, dynamic> map, String id, Product product) {
  final quantity = (map['quantity'] as num?)?.toInt() ?? 1;
  final rent = (map['rent'] as num?)?.toDouble() ?? 0.0;
  final insuranceCharge = 100.0;

  DateTime? startDate;
  DateTime? endDate;
  try {
    startDate = map['startDate'] != null 
        ? DateTime.parse(map['startDate'] as String)
        : null;
    endDate = map['endDate'] != null
        ? DateTime.parse(map['endDate'] as String)
        : null;
  } catch (e) {
    print('Error parsing dates: $e');
  }

  return CartItem(
    id: id,
    product: product,
    productDetail: ProductDetailModel(
      product: product,
      quantity: quantity,
      startDate: startDate,
      endDate: endDate,
    ),
    rent: rent,
    totalRent: rent,
    insuranceCharge: insuranceCharge,
    grandTotal: rent + insuranceCharge,
    partialAmount: (rent + insuranceCharge) / 2,
    balanceAmount: (rent + insuranceCharge) / 2,
    payableAmount: (map['isPartialPayment'] as bool? ?? false)
        ? (rent + insuranceCharge) / 2
        : rent + insuranceCharge,
    isPartialPayment: map['isPartialPayment'] as bool? ?? false,
  );
}

  CartItem copyWith({
    String? id,
    Product? product,
    ProductDetailModel? productDetail,
    double? rent,
    double? totalRent,
    double? insuranceCharge,
    double? grandTotal,
    double? partialAmount,
    double? balanceAmount,
    double? payableAmount,
    bool? isPartialPayment,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      productDetail: productDetail ?? this.productDetail,
      rent: rent ?? this.rent,
      totalRent: totalRent ?? this.totalRent,
      insuranceCharge: insuranceCharge ?? this.insuranceCharge,
      grandTotal: grandTotal ?? this.grandTotal,
      partialAmount: partialAmount ?? this.partialAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      payableAmount: payableAmount ?? this.payableAmount,
      isPartialPayment: isPartialPayment ?? this.isPartialPayment,
    );
  }
}