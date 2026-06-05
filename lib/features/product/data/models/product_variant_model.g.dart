// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariantModelImpl _$$ProductVariantModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProductVariantModelImpl(
  id: json['id'] as String,
  productId: json['product_id'] as String,
  ram: json['ram'] as String?,
  storage: json['storage'] as String?,
  price: (json['price'] as num).toDouble(),
  stock: (json['stock'] as num).toInt(),
);

Map<String, dynamic> _$$ProductVariantModelImplToJson(
  _$ProductVariantModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'ram': instance.ram,
  'storage': instance.storage,
  'price': instance.price,
  'stock': instance.stock,
};
