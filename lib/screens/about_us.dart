import 'package:flutter/material.dart';
import 'dart:ui'; // Untuk ImageFilter (Blur)

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar untuk responsivitas
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 80),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.7),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Rythora",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  if (!isMobile)
                    Row(
                      children: [
                        _NavBarItem(title: "Beranda"),
                        const SizedBox(width: 30),
                        _NavBarItem(title: "Tentang", isActive: true),
                        const SizedBox(width: 30),
                        _NavBarItem(title: "Download"),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HERO SECTION ---
            SizedBox(
              height: 700,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow Background
                  Positioned(
                    top: 100,
                    child: Container(
                      width: 600,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.grey[800]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(300),
                      ),
                    ).blur(100),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        Text(
                          "Rythora Music.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 42 : 72,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 700,
                          child: Text(
                            "Aplikasi pemutar musik yang dirancang untuk kesederhanaan dan kecepatan. Rythora menghadirkan pengalaman mendengarkan musik yang ringan, tanpa gangguan.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 20,
                              color: Colors.grey[400],
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "Mulai Mendengarkan",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 60),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 30),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- FEATURES SECTION ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
              color: const Color(0xFF09090B), // Zinc-950
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Kenapa Rythora?",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Fitur sederhana yang kamu butuhkan.",
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 64),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFeatureCard(
                                icon: Icons.bolt,
                                title: "Ringan & Cepat",
                                desc: "Teknologi terbaru untuk performa maksimal tanpa membebani.",
                                width: isMobile ? double.infinity : (constraints.maxWidth - 48) / 3,
                              ),
                              _buildFeatureCard(
                                icon: Icons.wifi_off,
                                title: "Mode Offline",
                                desc: "Simpan lagu favoritmu ke penyimpanan lokal dan dengarkan kapan saja.",
                                width: isMobile ? double.infinity : (constraints.maxWidth - 48) / 3,
                              ),
                              _buildFeatureCard(
                                icon: Icons.mic,
                                title: "Lirik Real-time",
                                desc: "Bernyanyi bersama dengan tampilan lirik yang tersinkronisasi.",
                                width: isMobile ? double.infinity : (constraints.maxWidth - 48) / 3,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- DEVELOPER SECTION ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
              color: Colors.black,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Meet the Developers",
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Tim di balik layar yang membangun Rythora dengan penuh dedikasi.",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 64),
                      
                      // Developer Grid Layout
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Tentukan lebar kartu berdasarkan ukuran layar
                          double cardWidth;
                          if (constraints.maxWidth < 600) {
                            cardWidth = constraints.maxWidth; // 1 Kolom (HP)
                          } else if (constraints.maxWidth < 900) {
                            cardWidth = (constraints.maxWidth - 24) / 2; // 2 Kolom (Tablet)
                          } else if (constraints.maxWidth < 1200) {
                            cardWidth = (constraints.maxWidth - 48) / 3; // 3 Kolom
                          } else {
                            cardWidth = (constraints.maxWidth - 72) / 4; // 4 Kolom
                          }

                          final developers = [
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

                          return Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: developers.asMap().entries.map((entry) {
                              return DeveloperCard(
                                name: entry.value['name']!,
                                role: entry.value['role']!,
                                imageUrl: entry.value['image']!,
                                width: cardWidth,
                                delay: entry.key * 100,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- FOOTER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Color(0xFF09090B),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Center(
                child: Text(
                  "© ${DateTime.now().year} Rythora Music Project.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String desc, required double width}) {
    return HoverCard(
      width: width,
      builder: (isHovered) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B), // Zinc-900
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? Colors.grey[600]! : Colors.white10,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                desc,
                style: TextStyle(color: Colors.grey[400], height: 1.5, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- WIDGET PENDUKUNG ---

class _NavBarItem extends StatelessWidget {
  final String title;
  final bool isActive;

  const _NavBarItem({required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: isActive ? Colors.white : Colors.grey[400],
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    );
  }
}

// Widget untuk mendeteksi Hover
class HoverCard extends StatefulWidget {
  final Widget Function(bool isHovered) builder;
  final double? width;

  const HoverCard({super.key, required this.builder, this.width});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: SizedBox(
        width: widget.width,
        child: widget.builder(_isHovered),
      ),
    );
  }
}

// Widget Kartu Developer dengan Hover Effect dan Fallback Image
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.width,
        decoration: BoxDecoration(
          color: const Color(0xFF18181B), // Zinc-900
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? Colors.grey[500]! : Colors.white10,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1, // Persegi
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    color: _isHovered ? null : Colors.white.withOpacity(0.2),
                    colorBlendMode: _isHovered ? BlendMode.dst : BlendMode.saturation, // Grayscale effect manual
                    errorBuilder: (context, error, stackTrace) {
                        // Fallback Avatar jika gambar error
                        return Container(
                          color: Colors.grey[850],
                          child: Center(
                            child: Text(
                              widget.name[0],
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white24),
                            ),
                          ),
                        );
                    },
                  ),
                ),
                // Gradient Overlay Bottom
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Content Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(24).copyWith(bottom: _isHovered ? 24 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Row(
                            children: [
                              Icon(Icons.code, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Text("DEVELOPER", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(widget.name, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(widget.role, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
                          
                          // Social Icons (Hidden by default, shown on hover/tap)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isHovered ? 1.0 : 0.0,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                children: [
                                  _SocialIcon(Icons.code, "GitHub"), // Placeholder GitHub icon
                                  const SizedBox(width: 12),
                                  _SocialIcon(Icons.business, "LinkedIn"), // Placeholder LinkedIn icon
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SocialIcon(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 16),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }
}

// Extension untuk efek Blur
extension BlurExtension on Widget {
  Widget blur(double sigma) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: this,
    );
  }
}
