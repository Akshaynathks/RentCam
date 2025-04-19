import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;
  Future<Map<String, dynamic>> fetchUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data() ?? {};
  }
 Future<void> updateUserDetails(String name, String phone) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception("User not logged in");

  print("Updating user details: $name, $phone");

  await _firestore.collection('users').doc(user.uid).update({
    'name': name,
    'phone': phone,
  });
  print("User details updated successfully.");
}
}
