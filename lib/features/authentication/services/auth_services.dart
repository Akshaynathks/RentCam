import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rent_cam/features/authentication/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<User?> signUp(
      String email, String password, String name, String mobile) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'phone': mobile,
        'createdAt': DateTime.now(),
      });
    }
    return user;
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user == null) return null;

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(credential.user!.uid)
          .get();

      return UserModel(
        uid: credential.user!.uid,
        email: credential.user!.email ?? '',
        name: userDoc.data()?['name'] ?? '',
        mobile: userDoc.data()?['phone'] ?? '',
        password: '', imageUrls: '',
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User?> googleSignIn() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
