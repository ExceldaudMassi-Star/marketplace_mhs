import 'package:flutter/material.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;
  const SearchResultsPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hasil untuk "$query"')),
      body: Center(
        child: Text('Mencari produk untuk: $query'),
      ),
    );
  }
}
