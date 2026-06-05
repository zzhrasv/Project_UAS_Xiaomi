import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

/// Tanggung jawab: Model Data untuk tabel `profiles` di Supabase.
/// Freezed menghasilkan: copyWith, equality, toString, dan fromJson/toJson.
/// Penamaan field sesuai snake_case kolom database Supabase.

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'mi_points') @Default(0) int miPoints,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}
