// services/studio_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudioFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> addStudio(Studio studio) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (studio.name.isEmpty ||
          studio.phone.isEmpty ||
          studio.email.isEmpty ||
          studio.location.isEmpty) {
        throw Exception('All fields are required');
      }

      if (studio.trendingImages.isEmpty) {
        throw Exception('At least one trending image is required');
      }

      if (studio.services.isEmpty) {
        throw Exception('At least one service is required');
      }

      for (var service in studio.services) {
        if (service.packages.isEmpty) {
          throw Exception('Each service must have at least one package');
        }
      }

      final query = await _firestore
          .collection('studios')
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return 'limit_reached';
      }

      final docRef = _firestore.collection('studios').doc();

      final studioData = {
        ...studio.copyWith(id: docRef.id).toMap(),
        'userId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(studioData);

      print('Studio added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding studio: $e');
      throw Exception('Failed to add studio: $e');
    }
  }

  Future<void> updateStudio(Studio studio) async {
    try {
      if (studio.id.isEmpty) {
        throw Exception('Studio ID is required for update');
      }
      await _firestore
          .collection('studios')
          .doc(studio.id)
          .update(studio.toMap());
    } catch (e) {
      throw Exception('Failed to update studio: $e');
    }
  }

  Stream<List<Studio>> getStudios() {
    try {
      return _firestore
          .collection('studios')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id; 
              return Studio.fromMap(data);
            } catch (e) {
              print('Error converting document ${doc.id}: $e');
              return Studio.empty();
            }
          }).toList();
        } catch (e) {
          print('Error processing studios snapshot: $e');
          return <Studio>[];
        }
      });
    } catch (e) {
      print('Error setting up studios stream: $e');
      return Stream.value(<Studio>[]);
    }
  }

  Future<void> deleteStudio(String studioId) async {
    try {
      if (studioId.isEmpty) {
        throw Exception('Invalid studio ID');
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      final studioDoc =
          await _firestore.collection('studios').doc(studioId).get();

      if (!studioDoc.exists) {
        throw Exception('Studio not found');
      }

      final studioData = studioDoc.data();
      if (studioData == null || studioData['userId'] != currentUser.uid) {
        throw Exception('Not authorized to delete this studio');
      }

      await _firestore.collection('studios').doc(studioId).delete();

      
      final verifyDoc =
          await _firestore.collection('studios').doc(studioId).get();
      if (verifyDoc.exists) {
        throw Exception('Failed to delete studio: Document still exists');
      }
    } catch (e) {
      throw Exception('Failed to delete studio: $e');
    }
  }
}
