// PERBAIKAN UNTUK: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_mhs/services/auth_service.dart';
import 'package:marketplace_mhs/screens/auth_gate.dart';
import 'package:marketplace_mhs/screens/splash_screen.dart';
import 'package:marketplace_mhs/screens/login_screen.dart';
import 'package:marketplace_mhs/screens/register_screen.dart';
import 'package:marketplace_mhs/screens/home_screen.dart';
import 'package:marketplace_mhs/screens/add_product_screen.dart';
import 'package:marketplace_mhs/screens/profile_screen.dart';
import 'package:marketplace_mhs/screens/chat_screen.dart';
import 'package:marketplace_mhs/screens/favorites_screen.dart';
import 'package:marketplace_mhs/screens/search_screen.dart';
import 'firebase_options.dart';
import 'package:device_preview/device_preview.dart';
import 'package:marketplace_mhs/screens/product_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      // [Modifikasi] Bungkus MyApp dengan DevicePreview agar bisa simulasi HP
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'MyMarket',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          fontFamily: 'Inter',
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/auth_gate': (context) => const AuthGate(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/add_product': (context) => const AddProductScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/chat': (context) => const ChatScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/search': (context) => const SearchScreen(),
          '/product_detail': (context) => const ProductDetailScreen(),
          // Rute untuk detail produk tidak perlu ditambahkan jika menggunakan MaterialPageRoute
        },
      ),
    );
  }
}
