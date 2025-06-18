import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_cam/features/product/model/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> fetchProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product.fromMap(data, doc.id);
    }).toList();
  }

  Future<List<Product>> fetchProductsByCategoryOrBrand(
      {String? category, String? brand}) async {
    Query query = _firestore.collection('products');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    } else if (brand != null) {
      query = query.where('brand', isEqualTo: brand);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Product.fromMap(data, doc.id);
    }).toList();
  }

    Future<Product> fetchProductById(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return Product.fromMap(doc.data()!, doc.id);
    } else {
      throw Exception('Product not found');
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    await _firestore.collection('products').doc(productId).update({
      'stock': newStock,
    });
  }
}
