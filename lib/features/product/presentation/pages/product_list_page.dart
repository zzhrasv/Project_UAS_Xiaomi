import 'package:flutter/material.dart';

/// Tanggung jawab: Placeholder halaman daftar produk per kategori.

class ProductListPage extends StatelessWidget {
  final String? categoryId;

  const ProductListPage({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      body: const Center(child: Text('Product List — Coming Soon')),
    );
  }
}
