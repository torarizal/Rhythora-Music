import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rhythora/screens/login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Memulai timer selama 3 detik
    Timer(const Duration(seconds: 3), _navigateToHome);
  }

  void _navigateToHome() {
    // Pastikan widget masih ada (mounted) sebelum melakukan navigasi
    if (mounted) {
      // Menggunakan pushReplacement agar pengguna tidak bisa kembali
      // ke splash screen ini.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          
          // aplikasi film Anda, misalnya MovieHomeScreen()
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kita gunakan Scaffold untuk tampilan halaman penuh
    return const Scaffold(
      // Warna latar belakang gelap seperti di bioskop
      backgroundColor: Color(0xFF1A1A1A), // Warna abu-abu sangat gelap
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon untuk tema film/bioskop
            Icon(
              Icons.theaters, // Ikon rol film
              size: 80.0,
              color: Colors.white,
            ),
            SizedBox(height: 24.0),
            
            // Nama "Cinema Kita"
            Text(
              'Cinema Kita',
              style: TextStyle(
                // Gunakan font yang sedikit 'cinematic' jika ada,
                // di sini kita pakai style standar yang elegan.
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0, // Sedikit jarak antar huruf
              ),
            ),
            
            SizedBox(height: 48.0),
            
            // Indikator loading
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
