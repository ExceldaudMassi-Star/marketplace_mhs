import 'package:flutter/material.dart';
import 'package:marketplace_mhs/models/product_model.dart';
import 'package:marketplace_mhs/services/firestore_service.dart';
import 'package:marketplace_mhs/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_mhs/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  String? selectedCategory;
  String? searchQuery;

  void _showCategorySearchSheet(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Cari & Pilih Kategori",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Cari produk...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CategoryIcon(
                      label: "Fashion",
                      icon: Icons.checkroom,
                      onTap: () {
                        setState(() {
                          selectedCategory = "Fashion";
                          searchQuery = null;
                        });
                        Navigator.pop(context);
                      }),
                  _CategoryIcon(
                      label: "Elektronik",
                      icon: Icons.devices_other,
                      onTap: () {
                        setState(() {
                          selectedCategory = "Elektronik";
                          searchQuery = null;
                        });
                        Navigator.pop(context);
                      }),
                  _CategoryIcon(
                      label: "Book",
                      icon: Icons.menu_book,
                      onTap: () {
                        setState(() {
                          selectedCategory = "Book";
                          searchQuery = null;
                        });
                        Navigator.pop(context);
                      }),
                  _CategoryIcon(
                      label: "Equipment",
                      icon: Icons.construction,
                      onTap: () {
                        setState(() {
                          selectedCategory = "Equipment";
                          searchQuery = null;
                        });
                        Navigator.pop(context);
                      }),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = null;
                    searchQuery = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Reset Filter"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final User? user =
        Provider.of<AuthService>(context, listen: false).currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            elevation: 1,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      user?.displayName ?? "Pengguna",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list, color: Colors.grey[700]),
                onPressed: () {
                  _showCategorySearchSheet(context);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Produk Unggulan",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          StreamBuilder<List<Product>>(
            stream: firestoreService.getProducts(selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Belum ada produk.')),
                );
              }
              var products = snapshot.data!;
              if (searchQuery != null && searchQuery!.isNotEmpty) {
                products = products
                    .where((p) => p.title
                        .toLowerCase()
                        .contains(searchQuery!.toLowerCase()))
                    .toList();
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(
                      product: products[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product_detail',
                          arguments: products[index],
                        );
                      },
                      onFavoriteTap: () {
                        // Tambahkan/menghapus favorit
                        // Implementasi sesuai kebutuhan
                      },
                      isFavorite: false, // Implementasi sesuai kebutuhan
                    ),
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _CategoryIcon(
      {required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.indigo[50],
            radius: 24,
            child: Icon(icon, color: Colors.indigo, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
