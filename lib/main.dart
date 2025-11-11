import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage
// --- PERBAIKAN: Tambahkan import HomeScreen ---
import 'package:rhythora/screens/splash_screen.dart';
import 'package:rhythora/state/auth_cubit.dart'; // Import AuthCubitState
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
const Color kPrimaryColor = Color(0xFF4F46E5); // Indigo-600
const Color kTextColor = Colors.white;
const Color kTextSecondaryColor = Color(0xFFA1A1AA); // zinc-400
const Color kTextMutedColor = Color(0xFF71717A); // zinc-500
const Color kBorderColor = Color(0xFF3F3F46); // zinc-700
const Color kFieldFillColor = Color(0xFF27272A); // zinc-800
// -----------------------

void main() {
  // Pastikan Flutter binding siap sebelum mengakses service
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sediakan FlutterSecureStorage agar bisa di-inject ke Service
    return RepositoryProvider<FlutterSecureStorage>(
      create: (context) => const FlutterSecureStorage(),
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthService>(
            // AuthService tidak butuh storage di constructor
            create: (context) => AuthService(),
          ),
          RepositoryProvider<PlayerService>(
            create: (context) => PlayerService(
              context.read<AuthService>(),
            ),
          ),
          RepositoryProvider<SpotifyService>(
             // --- PERBAIKAN 1: Pastikan constructor SpotifyService menerima 2 argumen ---
             // Jika constructor SpotifyService Anda hanya menerima AuthService, hapus argumen kedua.
             // Jika constructor butuh keduanya (seperti kode service yang saya berikan), ini sudah benar.
            create: (context) => SpotifyService(
              context.read<AuthService>(),
              context.read<FlutterSecureStorage>(), // SpotifyService butuh storage
            ),
             // --------------------------------------------------------------------------
          ),
        ],
        child: MultiBlocProvider(
          providers: [
             BlocProvider<AuthCubit>(
               create: (context) => AuthCubit(
                 context.read<AuthService>(),
               // --- PERBAIKAN 2: Nama fungsi salah ---
               )..checkInitialAuthStatus(), // Ganti nama fungsinya
               // ------------------------------------
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
              )..fetchUserPlaylists(),
            ),
            BlocProvider<NavigationCubit>(
              create: (context) => NavigationCubit(),
            ),
          ],
          child: MaterialApp(
            title: 'Rhythora',
            debugShowCheckedModeBanner: false,
            theme: ThemeData( // Tema Anda sudah benar
              brightness: Brightness.dark,
              scaffoldBackgroundColor: kBackgroundColor,
              primaryColor: kPrimaryColor,
              fontFamily: 'Inter', // Pastikan font ada di pubspec.yaml
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
             home: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
