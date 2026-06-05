// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) {
  return _CartItemModel.fromJson(json);
}

/// @nodoc
mixin _$CartItemModel {
  @JsonKey(name: 'variant_id')
  String get variantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_name')
  String get productName => throw _privateConstructorUsedError;
  @JsonKey(name: 'variant_label')
  String get variantLabel => throw _privateConstructorUsedError; // "8GB / 256GB"
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  /// Serializes this CartItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemModelCopyWith<CartItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemModelCopyWith<$Res> {
  factory $CartItemModelCopyWith(
    CartItemModel value,
    $Res Function(CartItemModel) then,
  ) = _$CartItemModelCopyWithImpl<$Res, CartItemModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'variant_id') String variantId,
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'product_name') String productName,
    @JsonKey(name: 'variant_label') String variantLabel,
    @JsonKey(name: 'image_url') String imageUrl,
    double price,
    int quantity,
  });
}

/// @nodoc
class _$CartItemModelCopyWithImpl<$Res, $Val extends CartItemModel>
    implements $CartItemModelCopyWith<$Res> {
  _$CartItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? variantId = null,
    Object? productId = null,
    Object? productName = null,
    Object? variantLabel = null,
    Object? imageUrl = null,
    Object? price = null,
    Object? quantity = null,
  }) {
    return _then(
      _value.copyWith(
            variantId: null == variantId
                ? _value.variantId
                : variantId // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            variantLabel: null == variantLabel
                ? _value.variantLabel
                : variantLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CartItemModelImplCopyWith<$Res>
    implements $CartItemModelCopyWith<$Res> {
  factory _$$CartItemModelImplCopyWith(
    _$CartItemModelImpl value,
    $Res Function(_$CartItemModelImpl) then,
  ) = __$$CartItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'variant_id') String variantId,
    @JsonKey(name: 'product_id') String productId,
    @JsonKey(name: 'product_name') String productName,
    @JsonKey(name: 'variant_label') String variantLabel,
    @JsonKey(name: 'image_url') String imageUrl,
    double price,
    int quantity,
  });
}

/// @nodoc
class __$$CartItemModelImplCopyWithImpl<$Res>
    extends _$CartItemModelCopyWithImpl<$Res, _$CartItemModelImpl>
    implements _$$CartItemModelImplCopyWith<$Res> {
  __$$CartItemModelImplCopyWithImpl(
    _$CartItemModelImpl _value,
    $Res Function(_$CartItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? variantId = null,
    Object? productId = null,
    Object? productName = null,
    Object? variantLabel = null,
    Object? imageUrl = null,
    Object? price = null,
    Object? quantity = null,
  }) {
    return _then(
      _$CartItemModelImpl(
        variantId: null == variantId
            ? _value.variantId
            : variantId // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        variantLabel: null == variantLabel
            ? _value.variantLabel
            : variantLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemModelImpl implements _CartItemModel {
  const _$CartItemModelImpl({
    @JsonKey(name: 'variant_id') required this.variantId,
    @JsonKey(name: 'product_id') required this.productId,
    @JsonKey(name: 'product_name') required this.productName,
    @JsonKey(name: 'variant_label') required this.variantLabel,
    @JsonKey(name: 'image_url') required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });

  factory _$CartItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemModelImplFromJson(json);

  @override
  @JsonKey(name: 'variant_id')
  final String variantId;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  @JsonKey(name: 'product_name')
  final String productName;
  @override
  @JsonKey(name: 'variant_label')
  final String variantLabel;
  // "8GB / 256GB"
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  final double price;
  @override
  @JsonKey()
  final int quantity;

  @override
  String toString() {
    return 'CartItemModel(variantId: $variantId, productId: $productId, productName: $productName, variantLabel: $variantLabel, imageUrl: $imageUrl, price: $price, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemModelImpl &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.variantLabel, variantLabel) ||
                other.variantLabel == variantLabel) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    variantId,
    productId,
    productName,
    variantLabel,
    imageUrl,
    price,
    quantity,
  );

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      __$$CartItemModelImplCopyWithImpl<_$CartItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemModelImplToJson(this);
  }
}

abstract class _CartItemModel implements CartItemModel {
  const factory _CartItemModel({
    @JsonKey(name: 'variant_id') required final String variantId,
    @JsonKey(name: 'product_id') required final String productId,
    @JsonKey(name: 'product_name') required final String productName,
    @JsonKey(name: 'variant_label') required final String variantLabel,
    @JsonKey(name: 'image_url') required final String imageUrl,
    required final double price,
    final int quantity,
  }) = _$CartItemModelImpl;

  factory _CartItemModel.fromJson(Map<String, dynamic> json) =
      _$CartItemModelImpl.fromJson;

  @override
  @JsonKey(name: 'variant_id')
  String get variantId;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  @JsonKey(name: 'product_name')
  String get productName;
  @override
  @JsonKey(name: 'variant_label')
  String get variantLabel; // "8GB / 256GB"
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  double get price;
  @override
  int get quantity;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
