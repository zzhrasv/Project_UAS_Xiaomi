import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

/// Tanggung jawab: Model untuk item di keranjang belanja.
/// Cart disimpan di local storage (SharedPreferences) — bukan di Supabase.
/// Sync ke tabel `order_items` hanya terjadi saat checkout.

@freezed
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    @JsonKey(name: 'variant_id') required String variantId,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'variant_label') required String variantLabel, // "8GB / 256GB"
    @JsonKey(name: 'image_url') required String imageUrl,
    required double price,
    @Default(1) int quantity,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}

/// Extension: hitung subtotal per item
extension CartItemModelX on CartItemModel {
  double get subtotal => price * quantity;
}
