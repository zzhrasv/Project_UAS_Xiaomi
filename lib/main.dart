import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/network/supabase_client.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparansi status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Inisialisasi Supabase (singleton — aman dipanggil berkali-kali)
  await SupabaseClientManager.initialize(
    enableDebug: true, // Set false di production build
  );

  runApp(const App());
}
