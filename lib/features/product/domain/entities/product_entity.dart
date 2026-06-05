// Tanggung jawab: Entity Domain untuk produk.
// Bebas dari dependency library — hanya Dart murni.

class ProductEntity {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final List<String> imageUrls;
  final bool isFeatured;
  final List<ProductVariantEntity> variants; // Di-load saat detail product

  const ProductEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.basePrice,
    required this.imageUrls,
    required this.isFeatured,
    this.variants = const [],
  });

  String get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Entity Domain untuk product_variants
class ProductVariantEntity {
  final String id;
  final String productId;
  final String? ram;
  final String? storage;
  final double price;
  final int stock;

  const ProductVariantEntity({
    required this.id,
    required this.productId,
    this.ram,
    this.storage,
    required this.price,
    required this.stock,
  });

  bool get isInStock => stock > 0;

  /// Label ringkas: e.g. "8GB / 256GB"
  String get variantLabel {
    final parts = <String>[];
    if (ram != null) parts.add(ram!);
    if (storage != null) parts.add(storage!);
    return parts.join(' / ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
