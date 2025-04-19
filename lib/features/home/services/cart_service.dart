// cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_cam/features/home/model/cart_model.dart';
import 'package:rent_cam/features/home/model/product_detail_model.dart';
import 'package:rent_cam/features/home/model/product_model.dart';
import 'package:rent_cam/features/home/services/product_service.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();

  Future<List<CartItem>> fetchCartItems() async {
  try {
    final cartSnapshot = await _firestore.collection('cart').get();
    final cartItems = <CartItem>[];

    for (var doc in cartSnapshot.docs) {
      final data = doc.data();
      final productId = data['productId'] as String? ?? '';
      
      // Ensure numeric fields have default values if null
      final quantity = (data['quantity'] as num?)?.toInt() ?? 1;
      final rent = (data['rent'] as num?)?.toDouble() ?? 0.0;
      final insuranceCharge = 100.0; // Fixed insurance charge
      
      // Calculate totals with null checks
      final totalRent = rent;
      final grandTotal = totalRent + insuranceCharge;
      final partialAmount = grandTotal / 2;
      final balanceAmount = grandTotal - partialAmount;
      final payableAmount = (data['isPartialPayment'] as bool? ?? false) 
          ? partialAmount 
          : grandTotal;

      // Parse dates with null checks
      DateTime? startDate;
      DateTime? endDate;
      try {
        startDate = data['startDate'] != null 
            ? DateTime.parse(data['startDate'] as String)
            : null;
        endDate = data['endDate'] != null
            ? DateTime.parse(data['endDate'] as String)
            : null;
      } catch (e) {
        print('Error parsing dates: $e');
      }

      final product = await _productService.fetchProductById(productId);
      
      cartItems.add(CartItem(
        id: doc.id,
        product: product,
        productDetail: ProductDetailModel(
          product: product,
          quantity: quantity,
          startDate: startDate,
          endDate: endDate,
        ),
        rent: rent,
        totalRent: totalRent,
        insuranceCharge: insuranceCharge,
        grandTotal: grandTotal,
        partialAmount: partialAmount,
        balanceAmount: balanceAmount,
        payableAmount: payableAmount,
        isPartialPayment: data['isPartialPayment'] as bool? ?? false,
      ));
    }

    return cartItems;
  } catch (e) {
    print('Error fetching cart items: $e');
    rethrow;
  }
}

  Future<void> addToCart({
    required Product product,
    required ProductDetailModel productDetail,
  }) async {
    final rent = (product.rentalPrice * productDetail.quantity) * productDetail.duration;
    
    await _firestore.collection('cart').add({
      'productId': product.id,
      'quantity': productDetail.quantity,
      'startDate': productDetail.startDate?.toIso8601String(),
      'endDate': productDetail.endDate?.toIso8601String(),
      'duration': productDetail.duration,
      'rent': rent,
      'isPartialPayment': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _firestore.collection('cart').doc(cartItemId).delete();
  }

  Future<void> updateCartItem(CartItem cartItem) async {
    await _firestore.collection('cart').doc(cartItem.id).update({
      'quantity': cartItem.productDetail.quantity,
      'startDate': cartItem.productDetail.startDate?.toIso8601String(),
      'endDate': cartItem.productDetail.endDate?.toIso8601String(),
      'duration': cartItem.productDetail.duration,
      'rent': cartItem.rent,
    });
  }

Future<void> togglePaymentOption({
  required bool isPartialPayment,
}) async {
  try {
    final batch = _firestore.batch();
    final cartItems = await _firestore.collection('cart').get();

    for (final doc in cartItems.docs) {
      final data = doc.data();
      final rent = (data['rent'] as num?)?.toDouble() ?? 0.0;
      final insuranceCharge = 100.0;
      final grandTotal = rent + insuranceCharge;
      final partialAmount = grandTotal / 2;

      batch.update(doc.reference, {
        'isPartialPayment': isPartialPayment,
        'payableAmount': isPartialPayment ? partialAmount : grandTotal,
      });
    }

    await batch.commit();
  } catch (e) {
    print('Error toggling payment option: $e');
    rethrow;
  }
}
}