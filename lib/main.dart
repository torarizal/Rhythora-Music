import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart'; // 1. Import GoRouter

// --- Import Halaman ---
import 'package:rhythora/screens/splash_screen.dart';
import 'package:rhythora/screens/home_screen.dart';
import 'package:rhythora/screens/login_screen.dart'; 
import 'package:rhythora/screens/about_screen.dart'; // Halaman About

// --- Import State Management & Services ---
import 'package:rhythora/state/auth_cubit.dart';
import 'package:rhythora/state/home_cubit.dart';
import 'package:rhythora/state/login_cubit.dart';
import 'package:rhythora/state/navigation_cubit.dart';
import 'package:rhythora/state/playlist_cubit.dart';
import 'services/auth_service.dart';
import 'services/player_service.dart';
import 'services/spotify_service.dart';
import 'state/player_cubit.dart';
import 'state/search_cubit.dart';

// --- Konstanta Warna ---
const Color kBackgroundColor = Color(0xFF121212);
const Color kCardBackgroundColor = Color(0xFF1F1F1F);
const Color kCardBackgroundOpacityColor = Color.fromRGBO(39, 39, 42, 0.7);
const Color kPrimaryColor = Color(0xFF4F46E5);
const Color kTextColor = Colors.white;
const Color kTextSecondaryColor = Color(0xFFA1A1AA);
const Color kTextMutedColor = Color(0xFF71717A);
const Color kBorderColor = Color(0xFF3F3F46);
const Color kFieldFillColor = Color(0xFF27272A);
// -----------------------

// 2. Konfigurasi Router
// Ini mendefinisikan "Peta" URL aplikasi Anda
final GoRouter _router = GoRouter(
  initialLocation: '/', // Halaman pertama yang dibuka
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<FlutterSecureStorage>(
      create: (context) => const FlutterSecureStorage(),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthService>(
            create: (context) => AuthService(),
          ),
          RepositoryProvider<PlayerService>(
            create: (context) => PlayerService(
              context.read<AuthService>(),
            ),
          ),
          RepositoryProvider<SpotifyService>(
            create: (context) => SpotifyService(
              context.read<AuthService>(),
              context.read<FlutterSecureStorage>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(
                context.read<AuthService>(),
              )..checkInitialAuthStatus(),
            ),
            BlocProvider<SearchCubit>(
              create: (context) => SearchCubit(
                context.read<SpotifyService>(),
              ),
            ),
            BlocProvider<PlayerCubit>(
              create: (context) => PlayerCubit(
                context.read<PlayerService>(),
              ),
            ),
            BlocProvider<LoginCubit>(
              create: (context) => LoginCubit(
                context.read<AuthService>(),
              ),
            ),
            BlocProvider<HomeCubit>(
              create: (context) => HomeCubit(
                context.read<SpotifyService>(),
              )..fetchHomeData(),
            ),
            BlocProvider<PlaylistCubit>(
              create: (context) => PlaylistCubit(
                context.read<SpotifyService>(),
              ),
            ),
            BlocProvider<NavigationCubit>(
              create: (context) => NavigationCubit(),
            ),
          ],
          // 3. Gunakan MaterialApp.router
          child: MaterialApp.router(
            routerConfig: _router, // Masukkan konfigurasi router di sini
            title: 'Rhythora',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: kBackgroundColor,
              primaryColor: kPrimaryColor,
              fontFamily: 'Inter',
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: kTextColor),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: kPrimaryColor,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: kFieldFillColor,
                hintStyle: const TextStyle(color: kTextMutedColor),
                prefixIconColor: kTextSecondaryColor,
                suffixIconColor: kTextSecondaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 5.0,
                ),
              ),
            ),
            // Hapus properti 'home:', karena sudah digantikan oleh routerConfig
          ),
        ),
      ),
    );
  }
}