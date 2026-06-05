/// Tanggung jawab: Mendefinisikan semua named route constants yang dipakai GoRouter.
/// Setiap route name bersifat immutable dan digunakan sebagai key navigasi.
/// Perubahan path hanya dilakukan di sini — tidak ada string path di tempat lain.
abstract final class AppRoutes {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // ── Main Shell (Bottom Nav) ───────────────────────────────────────────────
  static const String home = '/home';
  static const String explore = '/explore';
  static const String cart = '/cart';
  static const String profile = '/profile';

  // ── Product ───────────────────────────────────────────────────────────────
  static const String productDetail = '/product/:id';
  static const String productList = '/products';

  // ── Order ─────────────────────────────────────────────────────────────────
  static const String checkout = '/checkout';
  static const String orderList = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String orderSuccess = '/orders/success';

  // ── Profile & Settings ────────────────────────────────────────────────────
  static const String editProfile = '/profile/edit';
  static const String miPoints = '/profile/mi-points';
  static const String addresses = '/profile/addresses';

  // ── Service Center ────────────────────────────────────────────────────────
  static const String serviceCenter = '/service-center';

  // ── Search ────────────────────────────────────────────────────────────────
  static const String search = '/search';

  // ── Helper — route names (untuk GoRouter .name) ───────────────────────────
  static const String homeName = 'home';
  static const String productDetailName = 'product-detail';
  static const String orderDetailName = 'order-detail';
  static const String checkoutName = 'checkout';
  static const String serviceCenterName = 'service-center';
  static const String profileName = 'profile';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String searchName = 'search';
}
