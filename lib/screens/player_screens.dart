import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rhythora/models/track_model.dart';

class TrackDetailScreen extends StatefulWidget {
  final Track track;

  const TrackDetailScreen({super.key, required this.track});

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen> with TickerProviderStateMixin {
  double _sliderValue = 20.0;
  bool _isPlaying = false;
  bool _isLiked = false;

  // Controller untuk animasi "Bernapas" (Shadow Album)
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  // Variabel untuk Animasi Background Gradient
  Alignment _gradientBegin = Alignment.topLeft;
  Alignment _gradientEnd = Alignment.bottomRight;

  @override
  void initState() {
    super.initState();
    
    // Setup Animasi Bernapas
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _breathingAnimation = Tween<double>(begin: 10.0, end: 35.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Setup Animasi Background (Looping)
    // Kita jalankan timer sederhana untuk mengubah alignment gradient
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBackgroundAnimation();
    });
  }

  void _startBackgroundAnimation() async {
    while (mounted) {
      if (!mounted) break;
      setState(() {
        _gradientBegin = _gradientBegin == Alignment.topLeft ? Alignment.bottomLeft : Alignment.topLeft;
        _gradientEnd = _gradientEnd == Alignment.bottomRight ? Alignment.topRight : Alignment.bottomRight;
      });
      await Future.delayed(const Duration(seconds: 4)); // Ganti arah setiap 4 detik
    }
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _breathingController.repeat(reverse: true);
      } else {
        _breathingController.stop();
        _breathingController.animateTo(0); // Reset ke posisi awal
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final String imageUrl = widget.track.albumImageUrl ?? "";
    final double imageSize = min(size.width * 0.8, size.height * 0.45);

    return Scaffold(
      body: Stack(
        children: [
          // 1. LATAR BELAKANG GAMBAR STATIS
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
              color: Colors.grey.shade900,
            ),
          ),
          
          // 2. ANIMATED GRADIENT OVERLAY (Aurora Effect)
          // Ini memberikan efek warna yang bergerak perlahan di atas gambar
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientBegin,
                end: _gradientEnd,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.2), // Sedikit terang di tengah gerakan
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // 3. BLUR FILTER
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // Blur sedikit dikurangi agar gradient terlihat
            child: Container(color: Colors.transparent),
          ),

          // 4. KONTEN UTAMA (SCROLLABLE)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // --- AppBar ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Column(
                                children: [
                                  const Text(
                                    "PLAYING FROM PLAYLIST",
                                    style: TextStyle(
                                      color: Colors.white54, 
                                      fontSize: 10, 
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "Daily Mix 1",
                                    style: TextStyle(
                                      color: Colors.white, 
                                      fontSize: 14, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_horiz, color: Colors.white),
                                onPressed: () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // --- Animated Album Art ---
                          AnimatedBuilder(
                            animation: _breathingAnimation,
                            builder: (context, child) {
                              return Container(
                                height: imageSize,
                                width: imageSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    // Shadow yang "bernapas"
                                    BoxShadow(
                                      color: _isPlaying 
                                          ? Colors.white.withOpacity(0.3) // Warna glow saat play
                                          : Colors.black.withOpacity(0.5),
                                      offset: const Offset(0, 20),
                                      blurRadius: _isPlaying ? _breathingAnimation.value : 30, // Animasi blur
                                      spreadRadius: _isPlaying ? 5 : 5,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade800,
                                  child: const Icon(Icons.music_note, color: Colors.white24, size: 80),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // --- Info Lagu & Like Button ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.track.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 24, 
                                        fontWeight: FontWeight.bold, 
                                        color: Colors.white
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.track.artistName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18, 
                                        color: Colors.white.withOpacity(0.6)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol Like dengan Animasi
                              IconButton(
                                icon: Icon(
                                  _isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: _isLiked ? const Color(0xFF1DB954) : Colors.white, // Spotify Green jika liked
                                  size: 30,
                                ),
                                onPressed: () {
                                  setState(() => _isLiked = !_isLiked);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // --- Slider & Time ---
                          Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white24,
                                  trackHeight: 4.0,
                                  thumbColor: Colors.white,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                                  trackShape: const RoundedRectSliderTrackShape(),
                                ),
                                child: Slider(
                                  value: _sliderValue,
                                  min: 0,
                                  max: 100,
                                  onChanged: (v) => setState(() => _sliderValue = v),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("0:20", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                    Text("3:00", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // --- Player Controls ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shuffle),
                                color: Colors.white,
                                iconSize: 26,
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_previous_rounded),
                                color: Colors.white,
                                iconSize: 45,
                                onPressed: () {},
                              ),
                              // Play Button dengan Scale Animation kecil saat ditekan
                              GestureDetector(
                                onTap: _togglePlay,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 70, width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      if (_isPlaying)
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 2
                                        )
                                    ]
                                  ),
                                  child: Icon(
                                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.black, size: 40,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_next_rounded),
                                color: Colors.white,
                                iconSize: 45,
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.repeat),
                                color: Colors.white,
                                iconSize: 26,
                                onPressed: () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 30), // Bottom padding
                          
                          // Lyrics Hint
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C1D95).withOpacity(0.3), // Ungu transparan
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "LYRICS",
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 12, 
                                letterSpacing: 1
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}