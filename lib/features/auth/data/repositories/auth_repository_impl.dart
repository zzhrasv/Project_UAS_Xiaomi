import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/profile_model.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/errors/exceptions.dart';

/// Tanggung jawab: Implementasi konkret dari [AuthRepository].
/// Berkomunikasi langsung dengan Supabase Auth & tabel `profiles`.
/// Melempar [Exception] (bukan Failure) — konversi ke Failure ada di use case / bloc.

final class AuthRepositoryImpl implements AuthRepository {
  // TODO: Implementasi lengkap akan ditambahkan di task auth

  @override
  Future<ProfileEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseAuth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException(message: 'Login gagal. Periksa email & password.');
      }

      final profileData = await supabase
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', response.user!.id)
          .single();

      final model = ProfileModel.fromJson(profileData);
      return _toEntity(model);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProfileEntity> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // TODO: Implementasi lengkap di task auth
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    await supabaseAuth.signOut();
  }

  @override
  Future<ProfileEntity?> getCurrentProfile() async {
    final user = supabaseAuth.currentUser;
    if (user == null) return null;

    final profileData = await supabase
        .from(SupabaseTables.profiles)
        .select()
        .eq('id', user.id)
        .single();

    final model = ProfileModel.fromJson(profileData);
    return _toEntity(model);
  }

  @override
  Stream<ProfileEntity?> get authStateChanges {
    return supabaseAuth.onAuthStateChange.map((event) {
      // TODO: Fetch profile on auth state change
      return null;
    });
  }

  // ── Mapper: Model → Entity ─────────────────────────────────────────────────
  ProfileEntity _toEntity(ProfileModel model) {
    return ProfileEntity(
      id: model.id,
      fullName: model.fullName,
      phoneNumber: model.phoneNumber,
      miPoints: model.miPoints,
    );
  }
}
