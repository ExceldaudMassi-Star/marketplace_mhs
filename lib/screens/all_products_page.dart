import 'package:flutter/material.dart';

class AllProductsPage extends StatelessWidget {
  const AllProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Semua Produk")),
      body: const Center(
        child: Text('Menampilkan semua produk yang tersedia.'),
      ),
    );
  }
}
