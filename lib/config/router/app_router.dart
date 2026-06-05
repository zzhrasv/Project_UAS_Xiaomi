import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';

/// Tanggung jawab: Konfigurasi seluruh routing aplikasi dengan GoRouter.
/// Route guard (redirect) untuk cek autentikasi akan ditambahkan di task auth.
/// Navigator key global digunakan untuk navigasi dari luar widget tree.

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true, // Nonaktifkan di production

  // TODO: Tambahkan redirect guard setelah AuthBloc siap
  // redirect: (context, state) { ... }

  routes: [
    // ── Auth ────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.loginName,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRoutes.registerName,
      builder: (context, state) => const RegisterPage(),
    ),

    // ── Home ────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeName,
      builder: (context, state) => const HomePage(),
    ),

    // ── Product ─────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.productList,
      name: 'product-list',
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['categoryId'];
        return ProductListPage(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      name: AppRoutes.productDetailName,
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailPage(productId: productId);
      },
    ),

    // ── Cart ────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.cart,
      name: 'cart',
      builder: (context, state) => const CartPage(),
    ),
  ],

  // ── Error Page ────────────────────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Halaman tidak ditemukan: ${state.error}',
        textAlign: TextAlign.center,
      ),
    ),
  ),
);
