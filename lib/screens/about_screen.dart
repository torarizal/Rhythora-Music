import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(), // Kembali ke Home
        ),
        title: const Text("Tentang Kami", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: const SingleChildScrollView(
        child: RythoraAboutContent(),
      ),
    );
  }
}

// --- DI BAWAH INI ADALAH KODE UI ABOUT US YANG ANDA BERIKAN (DIPINDAHKAN DARI HOME) ---

class RythoraAboutContent extends StatefulWidget {
  const RythoraAboutContent({super.key});

  @override
  State<RythoraAboutContent> createState() => _RythoraAboutContentState();
}

class _RythoraAboutContentState extends State<RythoraAboutContent> {
  final List<Map<String, String>> developers = [
    {
      "name": "Dev Satu",
      "role": "Lead Developer",
      "image": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop&q=80",
    },
    {
      "name": "Dev Dua",
      "role": "Frontend Engineer",
      "image": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&h=500&fit=crop&q=80",
    },
    {
      "name": "Dev Tiga",
      "role": "Backend Engineer",
      "image": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&h=500&fit=crop&q=80",
    },
    {
      "name": "Dev Empat",
      "role": "UI/UX Designer",
      "image": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&h=500&fit=crop&q=80",
    },
    {
      "name": "Dev Lima",
      "role": "Mobile Developer",
      "image": "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&h=500&fit=crop&q=80",
    },
    {
      "name": "Dev Enam",
      "role": "QA Engineer",
      "image": "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&h=500&fit=crop&q=80",
    },
    {
      "name": "Dev Tujuh",
      "role": "DevOps Engineer",
      "image": "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&h=500&fit=crop&q=80",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;
        
        return Column(
          children: [
            SizedBox(
              height: 600,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 50,
                    child: Container(
                      width: isMobile ? 300 : 600,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(300),
                      ),
                    ).blur(80),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        FadeInAnimation(
                          delay: 0,
                          child: Text(
                            "Rythora Music.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 42 : 72,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              letterSpacing: -2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInAnimation(
                          delay: 200,
                          child: SizedBox(
                            width: 700,
                            child: Text(
                              "Dengarkan tanpa batas. Kualitas audio terbaik dengan antarmuka yang memukau.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 20,
                                color: Colors.grey[400],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              color: const Color(0xFF09090B),
              width: double.infinity,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      const FadeInAnimation(
                        child: Text(
                          "Fitur Unggulan",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 64),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFeatureCard(Icons.bolt, "Cepat & Ringan", "Optimasi performa tinggi.", isMobile),
                          _buildFeatureCard(Icons.wifi_off, "Mode Offline", "Dengarkan tanpa internet.", isMobile),
                          _buildFeatureCard(Icons.mic, "Lirik Lagu", "Bernyanyi bersama lirik.", isMobile),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              color: Colors.black,
              width: double.infinity,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      const FadeInAnimation(
                        child: Text(
                          "Tim Developer",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 64),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: developers.asMap().entries.map((entry) {
                          return DeveloperCard(
                            name: entry.value['name']!,
                            role: entry.value['role']!,
                            imageUrl: entry.value['image']!,
                            width: isMobile ? double.infinity : 250,
                            delay: entry.key * 100,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        );
      }
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}

class DeveloperCard extends StatefulWidget {
  final String name;
  final String role;
  final String imageUrl;
  final double width;
  final int delay;

  const DeveloperCard({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.width,
    required this.delay,
  });

  @override
  State<DeveloperCard> createState() => _DeveloperCardState();
}

class _DeveloperCardState extends State<DeveloperCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      delay: widget.delay,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.width,
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? Colors.white54 : Colors.white10,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  color: _isHovered ? null : Colors.white.withOpacity(0.2),
                  colorBlendMode: _isHovered ? BlendMode.dst : BlendMode.saturation,
                  errorBuilder: (ctx, _, __) => Container(color: Colors.grey[900], child: const Icon(Icons.person, size: 50, color: Colors.white24)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(widget.role, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const FadeInAnimation({super.key, required this.child, this.delay = 0});

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _translate = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _controller.forward(); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _opacity, child: SlideTransition(position: _translate, child: widget.child));
}

extension BlurExtension on Widget {
  Widget blur(double sigma) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: this,
    );
  }
}