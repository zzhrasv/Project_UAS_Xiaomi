// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_variant_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductVariantModel _$ProductVariantModelFromJson(Map<String, dynamic> json) {
  return _ProductVariantModel.fromJson(json);
}

/// @nodoc
mixin _$ProductVariantModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  String? get ram => throw _privateConstructorUsedError;
  String? get storage => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;

  /// Serializes this ProductVariantModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariantModelCopyWith<ProductVariantModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariantModelCopyWith<$Res> {
  factory $ProductVariantModelCopyWith(
    ProductVariantModel value,
    $Res Function(ProductVariantModel) then,
  ) = _$ProductVariantModelCopyWithImpl<$Res, ProductVariantModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    String? ram,
    String? storage,
    double price,
    int stock,
  });
}

/// @nodoc
class _$ProductVariantModelCopyWithImpl<$Res, $Val extends ProductVariantModel>
    implements $ProductVariantModelCopyWith<$Res> {
  _$ProductVariantModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? ram = freezed,
    Object? storage = freezed,
    Object? price = null,
    Object? stock = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            ram: freezed == ram
                ? _value.ram
                : ram // ignore: cast_nullable_to_non_nullable
                      as String?,
            storage: freezed == storage
                ? _value.storage
                : storage // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductVariantModelImplCopyWith<$Res>
    implements $ProductVariantModelCopyWith<$Res> {
  factory _$$ProductVariantModelImplCopyWith(
    _$ProductVariantModelImpl value,
    $Res Function(_$ProductVariantModelImpl) then,
  ) = __$$ProductVariantModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    String? ram,
    String? storage,
    double price,
    int stock,
  });
}

/// @nodoc
class __$$ProductVariantModelImplCopyWithImpl<$Res>
    extends _$ProductVariantModelCopyWithImpl<$Res, _$ProductVariantModelImpl>
    implements _$$ProductVariantModelImplCopyWith<$Res> {
  __$$ProductVariantModelImplCopyWithImpl(
    _$ProductVariantModelImpl _value,
    $Res Function(_$ProductVariantModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductVariantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? ram = freezed,
    Object? storage = freezed,
    Object? price = null,
    Object? stock = null,
  }) {
    return _then(
      _$ProductVariantModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        ram: freezed == ram
            ? _value.ram
            : ram // ignore: cast_nullable_to_non_nullable
                  as String?,
        storage: freezed == storage
            ? _value.storage
            : storage // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVariantModelImpl implements _ProductVariantModel {
  const _$ProductVariantModelImpl({
    required this.id,
    @JsonKey(name: 'product_id') required this.productId,
    this.ram,
    this.storage,
    required this.price,
    required this.stock,
  });

  factory _$ProductVariantModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariantModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  final String? ram;
  @override
  final String? storage;
  @override
  final double price;
  @override
  final int stock;

  @override
  String toString() {
    return 'ProductVariantModel(id: $id, productId: $productId, ram: $ram, storage: $storage, price: $price, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariantModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.ram, ram) || other.ram == ram) &&
            (identical(other.storage, storage) || other.storage == storage) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stock, stock) || other.stock == stock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, productId, ram, storage, price, stock);

  /// Create a copy of ProductVariantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariantModelImplCopyWith<_$ProductVariantModelImpl> get copyWith =>
      __$$ProductVariantModelImplCopyWithImpl<_$ProductVariantModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariantModelImplToJson(this);
  }
}

abstract class _ProductVariantModel implements ProductVariantModel {
  const factory _ProductVariantModel({
    required final String id,
    @JsonKey(name: 'product_id') required final String productId,
    final String? ram,
    final String? storage,
    required final double price,
    required final int stock,
  }) = _$ProductVariantModelImpl;

  factory _ProductVariantModel.fromJson(Map<String, dynamic> json) =
      _$ProductVariantModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  String? get ram;
  @override
  String? get storage;
  @override
  double get price;
  @override
  int get stock;

  /// Create a copy of ProductVariantModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariantModelImplCopyWith<_$ProductVariantModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
