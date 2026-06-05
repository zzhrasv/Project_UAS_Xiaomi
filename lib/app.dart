import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/bloc/home_event.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

/// Tanggung jawab: Root widget aplikasi.
/// Mengkonfigurasi MaterialApp.router dengan tema dan GoRouter.
/// BLoC providers akan di-wrap di sini saat masing-masing modul siap.

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final productRepository = ProductRepositoryImpl(Supabase.instance.client);
    final authRepository = AuthRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(productRepository)..add(const HomeFetchRequested()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(repository: authRepository)..add(const AuthCheckRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Mi Store Indonesia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
