// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketplace_mhs/models/user_profile_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(name);

      // Buat dokumen profil baru dengan semua field
      UserProfile newProfile = UserProfile(
        uid: userCredential.user!.uid,
        email: email,
        fullName: name,
        phoneNumber: '',
        gender: null,
        address: '',
        campus: '',
        bio: '',
        photoURL: null,
      );
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newProfile.toMap());

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Terjadi kesalahan saat mendaftar.';
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Terjadi kesalahan saat login.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
