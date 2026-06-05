import 'package:flutter/material.dart';
import 'config/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Tanggung jawab: Root widget aplikasi.
/// Mengkonfigurasi MaterialApp.router dengan tema dan GoRouter.
/// BLoC providers akan di-wrap di sini saat masing-masing modul siap.

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mi Store Indonesia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
