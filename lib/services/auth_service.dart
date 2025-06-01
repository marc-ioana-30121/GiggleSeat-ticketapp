// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String accountType,
  }) async {
    try {
      // only allow 'admin' for specific domains
      bool allowAdmin = email.contains('@giggleinc.com') || email.contains('@test.com');
      String finalAccountType = (accountType == 'admin' && !allowAdmin) 
          ? 'user' 
          : accountType;
      
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = cred.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'accountType': finalAccountType,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email address is already in use';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted';
          break;
        case 'weak-password':
          message = 'The password is too weak';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      throw message;
    } catch (e) {
      throw 'Failed to sign up: $e';
    }
  }

  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Wrong password provided';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      throw message;
    } catch (e) {
      throw 'Failed to sign in: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out: $e';
    }
  }
}