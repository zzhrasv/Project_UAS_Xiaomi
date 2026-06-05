import '../entities/product_entity.dart';

/// Tanggung jawab: Kontrak (interface) untuk repository produk.
/// Use cases bergantung pada abstraksi ini — bukan implementasi konkret.

abstract interface class ProductRepository {
  /// Mengambil semua produk featured untuk ditampilkan di carousel Home.
  Future<List<ProductEntity>> getFeaturedProducts();

  /// Mengambil produk berdasarkan kategori.
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);

  /// Mengambil detail produk beserta seluruh variannya.
  Future<ProductEntity> getProductById(String productId);

  /// Pencarian produk berdasarkan query string.
  Future<List<ProductEntity>> searchProducts(String query);
}
