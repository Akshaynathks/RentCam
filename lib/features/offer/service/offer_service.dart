import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_cam/features/offer/model/offer_model.dart';

class OfferRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Offer>> getOffers() async {
    final snapshot = await _firestore.collection('offers').get();
    return snapshot.docs
        .map((doc) => Offer.fromMap(doc.data(), doc.id))
        .toList();
  }
}
