import 'package:equatable/equatable.dart';

/// Tanggung jawab: Mendefinisikan semua Failure yang dikembalikan layer Domain/Repository
/// sebagai Left value dari `Either<Failure, T>`.
/// Failure adalah representasi error yang aman untuk UI — tidak mengekspos detail teknis.

/// Base class untuk semua failure
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Kegagalan yang berasal dari server / Supabase API
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Kegagalan karena tidak ada koneksi internet
class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(message: 'Tidak ada koneksi internet. Periksa jaringanmu.');
}

/// Kegagalan terkait autentikasi (belum login, sesi kedaluwarsa)
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Kegagalan ketika resource tidak ditemukan
class NotFoundFailure extends Failure {
  final String entity;

  const NotFoundFailure({required this.entity})
      : super(message: '$entity tidak ditemukan.');

  @override
  List<Object?> get props => [message, entity];
}

/// Kegagalan karena stok tidak cukup
class InsufficientStockFailure extends Failure {
  final int availableStock;

  const InsufficientStockFailure({required this.availableStock})
      : super(message: 'Stok tidak mencukupi. Tersisa: $availableStock unit.');

  @override
  List<Object?> get props => [message, availableStock];
}

/// Kegagalan saat upload/download file ke Supabase Storage
class StorageFailure extends Failure {
  const StorageFailure({required super.message});
}

/// Kegagalan validasi input pengguna
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Kegagalan tidak terduga / catch-all
class UnexpectedFailure extends Failure {
  const UnexpectedFailure()
      : super(message: 'Terjadi kesalahan tak terduga. Silakan coba lagi.');
}
