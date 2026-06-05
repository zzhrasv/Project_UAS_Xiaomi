import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// Tanggung jawab: Model Data untuk tabel `products` di Supabase.
/// Field `imageUrls` adalah array PostgreSQL yang di-map ke `List<String>`.

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    @JsonKey(name: 'category_id') required String categoryId,
    required String name,
    String? description,
    @JsonKey(name: 'base_price') required double basePrice,
    @JsonKey(name: 'image_urls') @Default([]) List<String> imageUrls,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
