// PERBAIKAN UNTUK: lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_mhs/models/user_profile_model.dart';
import 'package:marketplace_mhs/services/auth_service.dart';
import 'package:marketplace_mhs/services/firestore_service.dart';
import 'package:marketplace_mhs/models/product_model.dart';
import 'package:marketplace_mhs/widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = FirestoreService();
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorit Saya"),
      ),
      body: userId == null
          ? const Center(
              child: Text("Silakan login untuk melihat favorit Anda."))
          // --- BAGIAN YANG DIPERBAIKI ---
          // Menggunakan StreamBuilder untuk update real-time
          : StreamBuilder<UserProfile?>(
              stream: firestoreService.getUserProfileStream(userId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return const Center(
                      child: Text("Tidak bisa memuat data favorit."));
                }

                final favoriteIds = userSnapshot.data!.favorites;

                if (favoriteIds.isEmpty) {
                  return const Center(
                    child: Text(
                      'Anda belum memiliki produk favorit.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return StreamBuilder<List<Product>>(
                  stream: firestoreService.getFavoriteProducts(favoriteIds),
                  builder: (context, productSnapshot) {
                    if (productSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!productSnapshot.hasData ||
                        productSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Produk favorit tidak ditemukan atau sudah dihapus.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final favoriteProducts = productSnapshot.data!;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: favoriteProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: favoriteProducts[index]);
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
