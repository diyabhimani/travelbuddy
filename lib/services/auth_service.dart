import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 LOGIN USER
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Please fill all fields";
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login failed";
    } catch (e) {
      return e.toString();
    }
  }

  // 🆕 REGISTER USER
  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return "Please fill all fields";
      }

      // Create user
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data in Firestore
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'uid': userCred.user!.uid,
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Signup failed";
    } catch (e) {
      return e.toString();
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 👤 GET CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}