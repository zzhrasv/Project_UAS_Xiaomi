import 'package:supabase_flutter/supabase_flutter.dart';

// =============================================================================
// CARA MENJALANKAN DENGAN ENVIRONMENT VARIABLES
// =============================================================================
// Development (terminal):
//   flutter run \
//     --dart-define=SUPABASE_URL=https://hctfvbpzcwgbaeosrjdn.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=sb_publishable_rPpBO9M0rDargqOoVzr7HA_LdV3TbM1
//
// Atau buat file .vscode/launch.json:
//   "toolArgs": [
//     "--dart-define=SUPABASE_URL=https://hctfvbpzcwgbaeosrjdn.supabase.co",
//     "--dart-define=SUPABASE_ANON_KEY=sb_publishable_rPpBO9M0rDargqOoVzr7HA_LdV3TbM1"
//   ]
//
// Production build:
//   flutter build apk \
//     --dart-define=SUPABASE_URL=... \
//     --dart-define=SUPABASE_ANON_KEY=...
//
// PENTING: Jangan commit nilai asli key ke git.
//          Gunakan .env atau CI/CD secrets untuk production.
// =============================================================================

// ── Environment Variables ─────────────────────────────────────────────────────
const String _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://hctfvbpzcwgbaeosrjdn.supabase.co',
);

const String _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjdGZ2YnB6Y3dnYmFlb3NyamRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MzYyODUsImV4cCI6MjA5NjIxMjI4NX0.hRgPUN50wyJVEdgYxOzQZkFP_FXrDXb4Di8ZAmBoKVg',
);

// =============================================================================
// SINGLETON — SupabaseClientManager
// =============================================================================

/// Singleton manager untuk Supabase.
/// Dipanggil SEKALI di main.dart via [SupabaseClientManager.initialize].
/// Setelah itu, akses client via getter shorthand di bawah.
final class SupabaseClientManager {
  SupabaseClientManager._(); // private constructor — tidak bisa di-instantiate

  static bool _isInitialized = false;

  /// Inisialisasi Supabase — harus dipanggil pertama kali sebelum runApp().
  /// Aman dipanggil berkali-kali (idempotent via flag [_isInitialized]).
  static Future<void> initialize({bool enableDebug = false}) async {
    if (_isInitialized) return;

    assert(
      _supabaseUrl.isNotEmpty && !_supabaseUrl.contains('YOUR_PROJECT'),
      '❌ SUPABASE_URL belum diisi! '
      'Gunakan --dart-define=SUPABASE_URL=https://xxx.supabase.co',
    );

    assert(
      _supabaseAnonKey.isNotEmpty && _supabaseAnonKey != 'YOUR_ANON_KEY',
      '❌ SUPABASE_ANON_KEY belum diisi! '
      'Gunakan --dart-define=SUPABASE_ANON_KEY=...',
    );

    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
      debug: enableDebug,
    );

    _isInitialized = true;
  }

  /// Akses ke [SupabaseClient] instance.
  /// Throw [StateError] jika [initialize] belum dipanggil.
  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'SupabaseClientManager belum diinisialisasi. '
        'Panggil SupabaseClientManager.initialize() di main() terlebih dahulu.',
      );
    }
    return Supabase.instance.client;
  }

  /// Apakah Supabase sudah diinisialisasi?
  static bool get isInitialized => _isInitialized;
}

// =============================================================================
// GETTER SHORTHAND — Gunakan ini di datasource / repository
// =============================================================================

/// Shorthand akses ke [SupabaseClient].
/// Contoh: `supabase.from('products').select()`
SupabaseClient get supabase => SupabaseClientManager.client;

/// Shorthand akses ke [GoTrueClient] (Auth).
/// Contoh: `supabaseAuth.signInWithPassword(...)`
GoTrueClient get supabaseAuth => SupabaseClientManager.client.auth;

/// Shorthand akses ke [SupabaseStorageClient] (Storage).
/// Contoh: `supabaseStorage.from('avatars').upload(...)`
SupabaseStorageClient get supabaseStorage => SupabaseClientManager.client.storage;

// =============================================================================
// KONSTANTA — Nama Tabel & Bucket (hindari typo string literal)
// =============================================================================

/// Nama tabel di Supabase PostgreSQL.
/// Selalu gunakan konstanta ini — jangan tulis string literal secara langsung.
abstract final class SupabaseTables {
  static const String profiles = 'profiles';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String productVariants = 'product_variants';
  static const String orders = 'orders';
  static const String orderItems = 'order_items';
  static const String serviceCenters = 'service_centers';
}

/// Nama bucket di Supabase Storage.
abstract final class SupabaseBuckets {
  static const String productImages = 'product-images';
  static const String avatars = 'avatars';
}

/// Nama Edge Functions yang tersedia.
abstract final class SupabaseFunctions {
  static const String processOrder = 'process-order';
  static const String calculateShipping = 'calculate-shipping';
}
