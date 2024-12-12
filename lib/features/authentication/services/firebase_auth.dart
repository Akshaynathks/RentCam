// firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred';
    }
  }
}
