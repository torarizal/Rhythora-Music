import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';

// --- GANTI INI ---
// Ganti 'login_screen.dart' dengan file login Anda
// Ganti 'LoginScreen()' dengan class login Anda
// import 'login_screen.dart'; // <--- ASUMSI NAMA FILE LOGIN ANDA - SUDAH TIDAK DIPERLUKAN
// -----------------

// Konfigurasi Warna
const Color kBackgroundColor = Color(0xFF111827); // gray-900
const Color kLogoPurple = Color(0xFF4C1D95);
const Color kParticleColor = Color(0xFF9CA3AF); // Light gray untuk partikel

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  // Animasi untuk logo (pop in)
  late AnimationController _logoEntranceController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  // Animasi untuk teks "by Kelompok 4"
  late AnimationController _textController;
  late Animation<double> _textOpacityAnimation;

  // Animasi untuk partikel latar belakang
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  final Random _random = Random();
  
  bool _particlesInitialized = false;
  Size _screenSize = Size.zero;

  // --- BARU: Untuk Visualizer ---
  Timer? _visualizerTimer;
  List<double> _barHeights = [10.0, 25.0, 15.0, 30.0, 20.0];
  // -----------------------------

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // --- Inisialisasi Animasi Logo ---
    _logoEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoEntranceController,
        curve: Curves.elasticOut, // Efek pop yang memantul
      ),
    );
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoEntranceController,
        curve: Curves.easeIn,
      ),
    );

    // --- Inisialisasi Animasi Teks ---
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // --- Inisialisasi Animasi Partikel ---
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      _updateParticles();
      setState(() {});
    });

    // --- BARU: Inisialisasi Timer Visualizer ---
    _visualizerTimer = Timer.periodic(const Duration(milliseconds: 180), _updateVisualizer);
    // ----------------------------------------

    // --- Jadwal Animasi ---
    Timer(const Duration(milliseconds: 200), () {
      _logoEntranceController.forward();
    });

    Timer(const Duration(milliseconds: 1500), () {
      _textController.forward();
    });

    // Pindah ke Halaman LOGIN
    Timer(const Duration(milliseconds: 4000), () { // Beri waktu 4 detik
      _navigateToLogin();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_particlesInitialized) {
      _screenSize = MediaQuery.of(context).size;
      for (int i = 0; i < 50; i++) {
        _particles.add(Particle(
          x: _random.nextDouble() * _screenSize.width,
          y: _random.nextDouble() * _screenSize.height,
          size: _random.nextDouble() * 2 + 0.5,
          speed: _random.nextDouble() * 0.5 + 0.1,
          alpha: _random.nextDouble() * 0.5 + 0.5,
        ));
      }
      _particleController.repeat();
      _particlesInitialized = true;
    }
  }

  // --- BARU: Method untuk update Visualizer ---
  void _updateVisualizer(Timer t) {
    if (!mounted) return;
    setState(() {
      _barHeights = List.generate(5, (_) => _random.nextDouble() * 40 + 10); // Tinggi acak 10-50
    });
  }
  // -----------------------------------------

  void _updateParticles() {
    if (_screenSize == Size.zero) return;
    for (int i = 0; i < _particles.length; i++) {
      _particles[i].x += _particles[i].speed * cos(_particles[i].angle);
      _particles[i].y += _particles[i].speed * sin(_particles[i].angle);

      if (_particles[i].x < 0 || _particles[i].x > _screenSize.width ||
          _particles[i].y < 0 || _particles[i].y > _screenSize.height) {
        _particles[i] = Particle(
          x: _random.nextDouble() * _screenSize.width,
          y: _random.nextDouble() * _screenSize.height,
          size: _random.nextDouble() * 2 + 0.5,
          speed: _random.nextDouble() * 0.5 + 0.1,
          alpha: _random.nextDouble() * 0.5 + 0.5,
        );
      }
    }
  }

  void _navigateToLogin() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); <-- TIDAK PERLU LAGI
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _logoEntranceController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _visualizerTimer?.cancel(); // <-- BARU: Hentikan timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // --- BARU: Gradasi Latar Belakang ---
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9, // Radius lebih besar
            colors: [
              kLogoPurple.withOpacity(0.25), // Ungu SANGAT halus
              kBackgroundColor, // Hitam
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        // ---------------------------------
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Latar Belakang Partikel Bergerak
            CustomPaint(
              painter: ParticlePainter(_particles, kParticleColor),
            ),
            
            // --- DIPERBARUI: Visualizer dan Logo digabung dalam 1 Column ---
            Center(
              child: Column( // <-- BARU: Dibungkus Column
                mainAxisSize: MainAxisSize.min, // Agar Column tidak memenuhi layar
                children: [
                  // 2. Logo Utama (Sekarang di dalam Column)
                  ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: FadeTransition(
                      opacity: _logoOpacityAnimation,
                      child: Image.asset(
                        'assets/images/logo_rhythora.png',
                        width: 250,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), // <-- BARU: Jarak antara logo dan bar

                  // 3. Visualizer Audio (Dipindah ke sini, di bawah logo)
                  Opacity(
                    opacity: 0.6, // <-- Opacity dinaikkan sedikit
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end, // Bar mulai dari bawah
                      children: List.generate(5, (index) {
                        final colors = [
                          const Color(0xFFa855f7), // Ungu
                          const Color(0xFF7c3aed), // Violet
                          const Color(0xFF22d3ee), // Cyan
                          const Color(0xFF4ade80), // Hijau
                          const Color(0xFFa855f7), // Ungu lagi
                        ];
                        return _VisualizerBar(
                          height: _barHeights[index],
                          color: colors[index],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            // ----------------------------------------------------

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Text(
                    "by Kelompok 4",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- BARU: Widget untuk Bar Visualizer ---
class _VisualizerBar extends StatelessWidget {
  final double height;
  final Color color;
  const _VisualizerBar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150), // Animasi super cepat
      curve: Curves.easeOut,
      width: 10, // Lebar bar
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 5), // Jarak antar bar
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
// ----------------------------------------

// --- Kelas Partikel (Tidak Berubah) ---
class Particle {
  double x, y, size, speed, alpha;
  double angle;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.alpha,
  }) : angle = Random().nextDouble() * 2 * pi;
}

// --- CustomPainter Partikel (Tidak Berubah) ---
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color particleColor;

  ParticlePainter(this.particles, this.particleColor);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particleColor.withOpacity(particle.alpha)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


