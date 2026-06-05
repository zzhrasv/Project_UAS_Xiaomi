part of 'auth_bloc.dart';

/// Tanggung jawab: Mendefinisikan semua event yang bisa dikirim ke [AuthBloc].

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dipanggil saat app pertama kali dibuka untuk cek sesi
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Dipanggil saat user menekan tombol "Login"
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Dipanggil saat user menekan tombol "Daftar"
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [email, password, fullName, phoneNumber];
}

/// Dipanggil saat user menekan tombol "Keluar"
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
