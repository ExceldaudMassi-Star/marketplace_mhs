import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketplace_mhs/models/user_profile_model.dart';
import 'package:marketplace_mhs/models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FUNGSI UNTUK PROFIL PENGGUNA ---

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .update(profile.toMap());
  }

  // --- FUNGSI UNTUK PRODUK ---

  Stream<List<Product>> getProducts(String? category) {
    Query query = _firestore
        .collection('products')
        .orderBy('timestamp', descending: true);
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addProduct(Product product) {
    return _firestore.collection('products').add(product.toMap());
  }

  // --- FUNGSI UNTUK FAVORIT ---

  Future<void> toggleFavoriteStatus(
      String userId, String productId, bool isCurrentlyFavorited) async {
    final userDocRef = _firestore.collection('users').doc(userId);
    if (isCurrentlyFavorited) {
      await userDocRef.update({
        'favorites': FieldValue.arrayRemove([productId])
      });
    } else {
      await userDocRef.update({
        'favorites': FieldValue.arrayUnion([productId])
      });
    }
  }

  Stream<List<Product>> getFavoriteProducts(List<String> productIds) {
    if (productIds.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection('products')
        .where(FieldPath.documentId, whereIn: productIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }
}
