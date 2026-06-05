import 'package:flutter/material.dart';

/// Tanggung jawab: Placeholder halaman detail produk.

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Center(child: Text('Product Detail: $productId — Coming Soon')),
    );
  }
}
