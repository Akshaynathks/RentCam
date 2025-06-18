import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> getWishlist() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data()?.containsKey('wishlist') == true) {
      return List<String>.from(doc.data()!['wishlist'] ?? []);
    }
    return [];
  }

  Future<void> toggleWishlist(String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = _firestore.collection('users').doc(userId);
    final doc = await userRef.get();
    
    List<String> wishlist = [];
    if (doc.exists && doc.data()?.containsKey('wishlist') == true) {
      wishlist = List<String>.from(doc.data()!['wishlist'] ?? []);
    }

    if (wishlist.contains(productId)) {
      wishlist.remove(productId);
    } else {
      wishlist.add(productId);
    }

    await userRef.set({
      'wishlist': wishlist,
    }, SetOptions(merge: true));
  }
} 