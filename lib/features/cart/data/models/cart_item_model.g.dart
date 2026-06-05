// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemModelImpl _$$CartItemModelImplFromJson(Map<String, dynamic> json) =>
    _$CartItemModelImpl(
      variantId: json['variant_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      variantLabel: json['variant_label'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$CartItemModelImplToJson(_$CartItemModelImpl instance) =>
    <String, dynamic>{
      'variant_id': instance.variantId,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'variant_label': instance.variantLabel,
      'image_url': instance.imageUrl,
      'price': instance.price,
      'quantity': instance.quantity,
    };
