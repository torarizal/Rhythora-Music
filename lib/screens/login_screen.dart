import 'dart:ui'; // Diperlukan untuk ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../main.dart'; // Untuk mengakses variabel warna (kPrimaryColor, dll)
import '../state/login_cubit.dart';
import '../state/login_state.dart';
import 'home_screen.dart' hide kBackgroundColor, kBorderColor; // Layar tujuan setelah login sukses

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocListener digunakan untuk "melakukan aksi" (seperti pindah halaman)
    // saat state berubah.
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          // Jika login sukses, pindah ke HomeScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (state is LoginFailure) {
          // Jika login gagal, tampilkan pesan error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal Login: ${state.error}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          // Latar belakang dengan gradasi radial
          decoration: const BoxDecoration(
            color: kBackgroundColor,
            gradient: RadialGradient(
              center: Alignment(0.8, -0.8),
              radius: 1.0,
              colors: [
                Color.fromRGBO(88, 28, 135, 0.3), // hsla(270, 80%, 30%, 0.3)
                kBackgroundColor,
              ],
              stops: [0.0, 0.5],
            ),
          ),
          child: Stack(
            children: [
              // ... (Gradasi radial kedua Anda bisa tetap di sini) ...
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  // Kita gunakan BlocBuilder untuk mengubah tampilan tombol
                  // (misal: menampilkan loading)
                  child: BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      // Jika state sedang loading, tampilkan loading indicator
                      if (state is LoginLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        );
                      }
                      // Jika tidak loading, tampilkan kartu login
                      return _buildLoginCard(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ini adalah UI Kartu Kaca Anda
  Widget _buildLoginCard(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448), // max-w-md
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0), // rounded-2xl
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // backdrop-blur-lg
          child: Container(
            padding: const EdgeInsets.all(32.0), // p-8 md:p-10
            decoration: BoxDecoration(
              color: kCardBackgroundOpacityColor,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: kBorderColor.withOpacity(0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 32.0),
                // GANTI form email/password dengan tombol Spotify & Guest
                _buildSpotifyLoginButton(context), // Tombol Spotify
                const SizedBox(height: 16.0),
                _buildGuestLoginButton(context), // Tombol Guest
                const SizedBox(height: 24.0),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tombol Login Spotify
  Widget _buildSpotifyLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        // PANGGIL CUBIT SAAT DITEKAN
        onPressed: () {
          context.read<LoginCubit>().loginWithSpotify();
        },
        icon: const Icon(Icons.music_note), // Ganti dengan ikon Spotify
        label: const Text("Masuk dengan Spotify"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954), // Warna Hijau Spotify
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          textStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  // Tombol Login Guest
  Widget _buildGuestLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        // PANGGIL CUBIT SAAT DITEKAN
        onPressed: () {
          context.read<LoginCubit>().loginAsGuest();
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          foregroundColor: kTextSecondaryColor,
          side: const BorderSide(color: kBorderColor),
          backgroundColor: kFieldFillColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          "Lanjutkan sebagai Tamu",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // --- Widget Bantuan (UI Anda, tidak diubah) ---

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0), // p-3
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
            size: 32.0, // h-8 w-8
          ),
        ),
        const SizedBox(height: 16.0),
        const Text(
          "Octave",
          style: TextStyle(
            fontSize: 30.0, // text-3xl
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          "Selamat datang!",
          style: TextStyle(
            color: kTextSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Butuh akun? ",
          style: TextStyle(color: kTextSecondaryColor),
        ),
        TextButton(
          onPressed: () {
            // TODO: Buka link daftar Spotify
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text("Daftar di Spotify"),
        ),
      ],
    );
  }
}

