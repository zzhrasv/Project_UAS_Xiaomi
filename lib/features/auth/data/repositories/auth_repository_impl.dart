import 'package:supabase_flutter/supabase_flutter.dart' as net;
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/profile_model.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/errors/exceptions.dart';

/// Tanggung jawab: Implementasi konkret dari [AuthRepository].
/// Berkomunikasi langsung dengan Supabase Auth & tabel `profiles`.
/// Melempar [Exception] (bukan Failure) — konversi ke Failure ada di use case / bloc.

final class AuthRepositoryImpl implements AuthRepository {

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

      Map<String, dynamic> profileData;
      try {
        profileData = await supabase
            .from(SupabaseTables.profiles)
            .select()
            .eq('id', response.user!.id)
            .single();
      } catch (_) {
        // Fallback: Jika baris profile tidak ada di database (misal trigger SQL belum berjalan),
        // buat baris profil default secara dinamis di database.
        final defaultProfile = {
          'id': response.user!.id,
          'full_name': response.user!.userMetadata?['full_name'] ?? 'Xiaomi User',
          'phone_number': response.user!.phone,
          'mi_points': 0,
        };
        await supabase.from(SupabaseTables.profiles).insert(defaultProfile);
        profileData = defaultProfile;
      }

      final model = ProfileModel.fromJson(profileData);
      return _toEntity(model);
    } on net.AuthException catch (e) {
      throw AuthException(message: _translateAuthError(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProfileEntity> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await supabaseAuth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
        },
      );

      if (response.user == null) {
        throw const AuthException(message: 'Registrasi gagal.');
      }

      // Fallback: Coba buat baris profil secara langsung di database.
      // Jika email confirmation aktif, insert ini mungkin gagal (karena belum authenticated),
      // namun kita abaikan saja karena trigger akan berjalan saat verifikasi email selesai.
      try {
        await supabase.from(SupabaseTables.profiles).insert({
          'id': response.user!.id,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'mi_points': 0,
        });
      } catch (_) {
        // Abaikan error RLS/constraint di sini.
      }

      return ProfileEntity(
        id: response.user!.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        miPoints: 0,
      );
    } on net.AuthException catch (e) {
      throw AuthException(message: _translateAuthError(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await supabaseAuth.signOut();
  }

  @override
  Future<ProfileEntity?> getCurrentProfile() async {
    final user = supabaseAuth.currentUser;
    if (user == null) return null;

    try {
      Map<String, dynamic> profileData;
      try {
        profileData = await supabase
            .from(SupabaseTables.profiles)
            .select()
            .eq('id', user.id)
            .single();
      } catch (_) {
        // Fallback: Jika profile hilang dari database, buat baru
        final defaultProfile = {
          'id': user.id,
          'full_name': user.userMetadata?['full_name'] ?? 'Xiaomi User',
          'phone_number': user.phone,
          'mi_points': 0,
        };
        await supabase.from(SupabaseTables.profiles).insert(defaultProfile);
        profileData = defaultProfile;
      }

      final model = ProfileModel.fromJson(profileData);
      return _toEntity(model);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<ProfileEntity?> get authStateChanges {
    return supabaseAuth.onAuthStateChange.asyncMap((authState) async {
      final user = authState.session?.user;
      if (user == null) return null;

      try {
        Map<String, dynamic> profileData;
        try {
          profileData = await supabase
              .from(SupabaseTables.profiles)
              .select()
              .eq('id', user.id)
              .single();
        } catch (_) {
          // Fallback: Jika profile hilang dari database, buat baru
          final defaultProfile = {
            'id': user.id,
            'full_name': user.userMetadata?['full_name'] ?? 'Xiaomi User',
            'phone_number': user.phone,
            'mi_points': 0,
          };
          await supabase.from(SupabaseTables.profiles).insert(defaultProfile);
          profileData = defaultProfile;
        }

        final model = ProfileModel.fromJson(profileData);
        return _toEntity(model);
      } catch (_) {
        return null;
      }
    });
  }

  // ── Helper: Terjemahkan Error Supabase Auth ──────────────────────────────────
  String _translateAuthError(net.AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('rate limit') || message.contains('over_email_send_rate_limit')) {
      return 'Batas pengiriman email pendaftaran terlampaui (Rate Limit). Silakan matikan opsi "Confirm email" di Supabase Dashboard -> Auth -> Providers -> Email Anda, atau tunggu beberapa menit.';
    }
    if (message.contains('invalid login credentials') || message.contains('invalid credentials')) {
      return 'Email atau kata sandi salah. Silakan periksa kembali.';
    }
    if (message.contains('user already exists') || message.contains('already registered')) {
      return 'Email ini sudah terdaftar. Silakan gunakan email lain atau masuk.';
    }
    if (message.contains('email not confirmed')) {
      return 'Email Anda belum dikonfirmasi. Silakan periksa kotak masuk email Anda.';
    }
    return e.message;
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
