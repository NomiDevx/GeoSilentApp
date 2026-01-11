import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toJson());

        return newUser;
      }
      return null;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          UserModel user =
              UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

          // Update last login
          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({'lastLogin': DateTime.now().toIso8601String()});

          return user;
        }
      }
      return null;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
  }

  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
