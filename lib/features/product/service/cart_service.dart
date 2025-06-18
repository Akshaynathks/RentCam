// cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_cam/features/product/model/cart_model.dart';
import 'package:rent_cam/features/product/model/product_detail_model.dart';
import 'package:rent_cam/features/product/model/product_model.dart';
import 'package:rent_cam/features/product/service/product_service.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProductService _productService = ProductService();

  Future<List<CartItem>> fetchCartItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

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
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Check if product is out of stock
    if (product.stock == 0) {
      throw 'Product is not available now';
    }

    // Check if there's enough stock
    if (product.stock < productDetail.quantity) {
      throw 'Only ${product.stock} items available';
    }

    final rent =
        (product.rentalPrice * productDetail.quantity) * productDetail.duration;

    // Start a batch write
    final batch = _firestore.batch();

    // Add to cart
    final cartRef =
        _firestore.collection('users').doc(userId).collection('cart').doc();

    batch.set(cartRef, {
      'productId': product.id,
      'quantity': productDetail.quantity,
      'startDate': productDetail.startDate?.toIso8601String(),
      'endDate': productDetail.endDate?.toIso8601String(),
      'duration': productDetail.duration,
      'rent': rent,
      'isPartialPayment': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update product stock
    final productRef = _firestore.collection('products').doc(product.id);
    batch.update(productRef, {
      'stock': FieldValue.increment(-productDetail.quantity),
    });

    // Commit the batch
    await batch.commit();
  }

  Future<void> removeFromCart(String cartItemId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Get the cart item first to know the quantity
    final cartItemDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .get();

    if (!cartItemDoc.exists) return;

    final data = cartItemDoc.data()!;
    final productId = data['productId'] as String;
    final quantity = (data['quantity'] as num).toInt();

    // Start a batch write
    final batch = _firestore.batch();

    // Remove from cart
    final cartRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId);
    batch.delete(cartRef);

    // Update product stock
    final productRef = _firestore.collection('products').doc(productId);
    batch.update(productRef, {
      'stock': FieldValue.increment(quantity),
    });

    // Commit the batch
    await batch.commit();
  }

  Future<void> updateCartItem(CartItem cartItem) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Get the old cart item to know the previous quantity
    final oldCartItemDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItem.id)
        .get();

    if (!oldCartItemDoc.exists) return;

    final oldData = oldCartItemDoc.data()!;
    final oldQuantity = (oldData['quantity'] as num).toInt();
    final newQuantity = cartItem.productDetail.quantity;

    // Check if there's enough stock for the new quantity
    final currentStock =
        cartItem.product.stock + oldQuantity; // Add back the old quantity
    if (currentStock < newQuantity) {
      throw Exception('Only ${currentStock} items available');
    }

    // Start a batch write
    final batch = _firestore.batch();

    // Update cart item
    final cartRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItem.id);

    batch.update(cartRef, {
      'quantity': newQuantity,
      'startDate': cartItem.productDetail.startDate?.toIso8601String(),
      'endDate': cartItem.productDetail.endDate?.toIso8601String(),
      'duration': cartItem.productDetail.duration,
      'rent': cartItem.rent,
    });

    // Update product stock
    final productRef =
        _firestore.collection('products').doc(cartItem.product.id);
    batch.update(productRef, {
      'stock': FieldValue.increment(oldQuantity - newQuantity),
    });

    // Commit the batch
    await batch.commit();
  }

  Future<void> togglePaymentOption({
    required bool isPartialPayment,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();
      final cartItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

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
