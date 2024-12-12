import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Check login status
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Sign up with email and password
  Future<User?> signUp(String email, String password, String name, String mobile) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      // Save user details to Firestore
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

  // Login with email and password
  Future<User?> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Google Sign-In
  Future<User?> googleSignIn() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return null; // User canceled sign-in
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
