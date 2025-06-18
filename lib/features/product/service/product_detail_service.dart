import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_cam/features/product/model/product_detail_model.dart';
import 'package:rent_cam/features/product/model/product_model.dart';

class ProductDetailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Product> fetchProductById(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return Product.fromMap(doc.data()!, doc.id);
    } else {
      throw Exception('Product not found');
    }
  }

  Future<void> addToCart(String userId, ProductDetailModel productDetail) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .add(productDetail.toMap());
  }

  Future<void> updateStock(String productId, int newStock) async {
    await _firestore.collection('products').doc(productId).update({
      'stock': newStock,
    });
  }
}