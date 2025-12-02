import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Ultra Dark Background
      extendBodyBehindAppBar: true, // Agar AppBar transparan di atas konten
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Menambah area sentuh agar tombol lebih responsif
        leadingWidth: 60, 
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: "Kembali",
            onPressed: () {
              // LOGIKA FIX TOMBOL BACK:
              // Paksa ke '/home' jika pop tidak bisa (misal user refresh halaman ini)
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home'); 
              }
            }, 
          ),
        ),
        title: const Text(
          "Tentang Kami",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: const RythoraAboutContent(),
    );
  }
}

class RythoraAboutContent extends StatefulWidget {
  const RythoraAboutContent({super.key});

  @override
  State<RythoraAboutContent> createState() => _RythoraAboutContentState();
}

class _RythoraAboutContentState extends State<RythoraAboutContent> with TickerProviderStateMixin {
  // Data Developer
  final List<Map<String, String>> developers = [
    {
      "name": "Tora Rizal Pratama",
      "role": "Lead Developer",
      "image": "assets/images/tora.jpeg",
      "githubUrl": "https://github.com/torarizal",
      "instagramUrl": "https://www.instagram.com/mas_komting/",
    },
    {
      "name": "Hafiyyan Lintang Arizaki",
      "role": "Frontend Developer",
      "image": "assets/images/lintang.jpeg",
      "githubUrl": "https://github.com/hafiyyanlintang",
      "instagramUrl": "https://www.instagram.com/hafiarizaki/",
    },
    {
      "name": "Farid Ade Novian",
      "role": "Fronted Developer",
      "image": "assets/images/farid.jpeg",
      "githubUrl": "https://github.com/fnovians",
      "instagramUrl": "https://www.instagram.com/fnovian_/",
    },
    {
      "name": "Tiara Zahrofi Ifadhah",
      "role": "UI/UX Designer",
      "image": "assets/images/tiara.jpeg",
      "githubUrl": "https://github.com/tiarazahrofii",
      "instagramUrl": "https://www.instagram.com/tiarazahrofi/",
    },
    {
      "name": "Aurora Ilmannafia",
      "role": "UI/UX Designer",
      "image": "assets/images/aurora.jpeg",
      "githubUrl": "https://github.com/auroranafia",
      "instagramUrl": "https://www.instagram.com/auroraanafia/",
    },
    {
      "name": "Amelanov Destyawanda",
      "role": "QA Engineer",
      "image": "assets/images/amel.jpeg",
      "githubUrl": "https://github.com/AmelanovDestyawanda",
      "instagramUrl": "https://www.instagram.com/meyaalav__/",
    },
    {
      "name": "Kirana Shofa Dzakiyyah",
      "role": "QA Enginer",
      "image": "assets/images/kirana.jpeg",
      "githubUrl": "https://github.com/KirshX07",
      "instagramUrl": "https://www.instagram.com/kiranx_00/",
    },
  ];

  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;
        final double screenWidth = constraints.maxWidth;

        return Stack(
          children: [
            // --- 1. ANIMATED BACKGROUND BLOBS ---
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _blobController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Blob Ungu Atas
                      Positioned(
                        top: -100 + (math.sin(_blobController.value * 2 * math.pi) * 50),
                        left: -50 + (math.cos(_blobController.value * 2 * math.pi) * 30),
                        child: _buildBlob(Colors.purple.shade900, 400),
                      ),
                      // Blob Biru Kanan
                      Positioned(
                        top: 200,
                        right: -100 + (math.sin(_blobController.value * 2 * math.pi) * -50),
                        child: _buildBlob(Colors.blue.shade900, 300),
                      ),
                      // Blob Pink Bawah
                      Positioned(
                        bottom: -100,
                        left: screenWidth * 0.3 + (math.sin(_blobController.value * math.pi) * 100),
                        child: _buildBlob(Colors.pink.shade900.withOpacity(0.5), 500),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // --- 2. MAIN CONTENT ---
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --- HERO SECTION ---
                  SizedBox(
                    height: isMobile ? 500 : 600,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 80), // Spacer untuk AppBar
                            // Logo / Title Animasi
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.blueAccent, Colors.purpleAccent, Colors.pinkAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  "Rhythora Music.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isMobile ? 48 : 96,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                    letterSpacing: -2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Subtitle Slide Up
                            SlideUpAnimation(
                              delay: 300,
                              child: SizedBox(
                                width: 700,
                                child: Text(
                                  "Experience audio without limits.\nDesigned for audiophiles, engineered for performance.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 24,
                                    color: Colors.grey[300],
                                    height: 1.5,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- FEATURES GRID ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withOpacity(0.05))),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Wrap(
                          spacing: 30,
                          runSpacing: 30,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildGlassFeatureCard(Icons.bolt_rounded, "Blazing Fast", "Optimized Flutter engine for 60fps performance.", isMobile, 400),
                            _buildGlassFeatureCard(Icons.offline_bolt_rounded, "Offline Mode", "Listen anywhere, anytime without connection.", isMobile, 500),
                            _buildGlassFeatureCard(Icons.lyrics_rounded, "Live Lyrics", "Sing along with synchronized lyrics.", isMobile, 600),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- TEAM SECTION ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          children: [
                            const SlideUpAnimation(
                              delay: 100,
                              child: Text(
                                "Meet The Minds",
                                style: TextStyle(
                                  fontSize: 40, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.white,
                                  letterSpacing: 1.5
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SlideUpAnimation(
                              delay: 200,
                              child: Container(
                                width: 60, height: 4, 
                                decoration: BoxDecoration(
                                  color: Colors.purpleAccent, 
                                  borderRadius: BorderRadius.circular(2)
                                ),
                              ),
                            ),
                            const SizedBox(height: 80),
                            
                            // Grid Developer
                            Wrap(
                              spacing: 30,
                              // FIX: Menambah jarak antar baris agar bayangan tidak tumpuk
                              runSpacing: 60, 
                              alignment: WrapAlignment.center,
                              children: developers.asMap().entries.map((entry) {
                                return DeveloperCard3D(
                                  name: entry.value['name']!,
                                  role: entry.value['role']!,
                                  imageUrl: entry.value['image']!,
                                  githubUrl: entry.value['githubUrl'] ?? "",
                                  instagramUrl: entry.value['instagramUrl'] ?? "",
                                  width: isMobile ? double.infinity : 260,
                                  delay: 300 + (entry.key * 100), 
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Footer Space
                  const SizedBox(height: 100),
                  Text(
                    "© 2025 Rhythora Music Inc.",
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          )
        ],
      ),
    ).blur(60);
  }

  Widget _buildGlassFeatureCard(IconData icon, String title, String desc, bool isMobile, int delay) {
    return SlideUpAnimation(
      delay: delay,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: isMobile ? double.infinity : 300,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.02)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], height: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGET PENDUKUNG ---

class DeveloperCard3D extends StatefulWidget {
  final String name;
  final String role;
  final String imageUrl;
  final String githubUrl;
  final String instagramUrl;
  final double width;
  final int delay;

  const DeveloperCard3D({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.width,
    required this.delay,
    this.githubUrl = "",
    this.instagramUrl = "",
  });

  @override
  State<DeveloperCard3D> createState() => _DeveloperCard3DState();
}

class _DeveloperCard3DState extends State<DeveloperCard3D> {
  bool _isHovered = false;

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Container Pembungkus diberi margin yang CUKUP di atas & bawah
    // Agar saat card 'naik' (translate -10.0), dia tidak keluar dari batas rendering
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 40, 10, 20), // Top 40 agar aman saat naik
      child: SlideUpAnimation(
        delay: widget.delay,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: widget.width,
            // Animasi naik saat hover
            transform: Matrix4.identity()..translate(0.0, _isHovered ? -10.0 : 0.0), 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF18181B),
              border: Border.all(
                color: _isHovered ? Colors.purpleAccent.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: [
                // Shadow default
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
                // Shadow saat hover (Glow)
                if (_isHovered)
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gambar dengan Efek Zoom saat Hover
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedScale(
                          scale: _isHovered ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          child: Image.asset(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, _, __) => Container(color: Colors.grey[900], child: const Icon(Icons.person, size: 60, color: Colors.white24)),
                          ),
                        ),
                        // Overlay Gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Info dan Tombol
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.role,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1),
                        ),
                        const SizedBox(height: 20),
                        
                        // Social Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.githubUrl.isNotEmpty)
                              _SocialButton(
                                icon: FontAwesomeIcons.github,
                                onTap: () => _launchURL(widget.githubUrl),
                                isHoveredCard: _isHovered,
                              ),
                            if (widget.githubUrl.isNotEmpty && widget.instagramUrl.isNotEmpty)
                              const SizedBox(width: 16),
                            if (widget.instagramUrl.isNotEmpty)
                              _SocialButton(
                                icon: FontAwesomeIcons.instagram,
                                onTap: () => _launchURL(widget.instagramUrl),
                                isHoveredCard: _isHovered,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isHoveredCard;

  const _SocialButton({required this.icon, required this.onTap, required this.isHoveredCard});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: FaIcon(icon, size: 20),
      color: isHoveredCard ? Colors.white : Colors.grey[600],
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        padding: const EdgeInsets.all(10),
      ),
      tooltip: "Visit Profile",
    );
  }
}

class SlideUpAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const SlideUpAnimation({super.key, required this.child, this.delay = 0});

  @override
  State<SlideUpAnimation> createState() => _SlideUpAnimationState();
}

class _SlideUpAnimationState extends State<SlideUpAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
    _translate = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _translate, child: widget.child),
    );
  }
}

extension BlurExtension on Widget {
  Widget blur(double sigma) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: this,
    );
  }
}