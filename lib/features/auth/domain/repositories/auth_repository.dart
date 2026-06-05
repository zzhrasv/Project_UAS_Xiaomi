import '../entities/profile_entity.dart';

/// Tanggung jawab: Kontrak (interface) untuk repository autentikasi.
/// Layer Domain mendefinisikan kontrak ini; layer Data mengimplementasikannya.
/// Dependency Inversion Principle: use cases bergantung pada abstraksi ini.

abstract interface class AuthRepository {
  /// Login dengan email dan password.
  /// Return [ProfileEntity] jika berhasil.
  Future<ProfileEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registrasi akun baru.
  /// Otomatis membuat row di tabel `profiles` via Supabase trigger/function.
  Future<ProfileEntity> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });

  /// Logout dan invalidasi sesi saat ini.
  Future<void> signOut();

  /// Mengambil data profil user yang sedang login.
  /// Return null jika tidak ada sesi aktif.
  Future<ProfileEntity?> getCurrentProfile();

  /// Stream untuk mendengarkan perubahan status autentikasi (login/logout).
  Stream<ProfileEntity?> get authStateChanges;
}
