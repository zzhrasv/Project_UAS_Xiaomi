// Tanggung jawab: Mendefinisikan semua exception kustom di layer Data.
// Exception hanya dilempar dari datasource, lalu dikonversi ke Failure di repository.

/// Dipanggil saat request ke Supabase gagal (network, timeout, dll).
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Dipanggil saat tidak ada koneksi internet.
class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: No internet connection';
}

/// Dipanggil saat sesi autentikasi tidak valid atau kedaluwarsa.
class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

/// Dipanggil saat data yang dicari tidak ditemukan di database.
class NotFoundException implements Exception {
  final String entity;

  const NotFoundException({required this.entity});

  @override
  String toString() => 'NotFoundException: $entity not found';
}

/// Dipanggil saat stok produk tidak mencukupi untuk pesanan.
class InsufficientStockException implements Exception {
  final String variantId;
  final int requestedQty;
  final int availableStock;

  const InsufficientStockException({
    required this.variantId,
    required this.requestedQty,
    required this.availableStock,
  });

  @override
  String toString() =>
      'InsufficientStockException: variant $variantId requested=$requestedQty available=$availableStock';
}

/// Dipanggil saat upload file ke Supabase Storage gagal.
class StorageException implements Exception {
  final String message;

  const StorageException({required this.message});

  @override
  String toString() => 'StorageException: $message';
}
