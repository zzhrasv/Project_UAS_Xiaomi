import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product_entity.dart';

part 'product_variant_model.freezed.dart';
part 'product_variant_model.g.dart';

@freezed
class ProductVariantModel with _$ProductVariantModel {
  const factory ProductVariantModel({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    String? ram,
    String? storage,
    required double price,
    required int stock,
  }) = _ProductVariantModel;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantModelFromJson(json);
}

extension ProductVariantModelX on ProductVariantModel {
  ProductVariantEntity toEntity() => ProductVariantEntity(
        id: id,
        productId: productId,
        ram: ram,
        storage: storage,
        price: price,
        stock: stock,
      );
}
