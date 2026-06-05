part of 'auth_bloc.dart';

/// Tanggung jawab: Mendefinisikan semua state yang bisa di-emit oleh [AuthBloc].

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum cek sesi dilakukan
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Sedang memproses: login, register, atau cek sesi
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User berhasil login — membawa data profil
class AuthAuthenticated extends AuthState {
  final ProfileEntity profile;

  const AuthAuthenticated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// User belum login atau sudah logout
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Terjadi error saat proses autentikasi
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
