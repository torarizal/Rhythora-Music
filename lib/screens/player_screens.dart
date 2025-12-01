import 'dart:async'; // Perlu ini untuk Timer
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
  // --- STATE AUDIO (SIMULASI) ---
  bool _isPlaying = false;
  bool _isLiked = false;
  
  // STATE BARU: Shuffle & Repeat
  bool _isShuffleOn = false;
  // 0: Off, 1: Repeat All, 2: Repeat One
  int _repeatMode = 0; 

  // Durasi & Posisi
  Duration _position = Duration.zero; // Posisi saat ini (0:00)
  Duration _duration = const Duration(minutes: 3, seconds: 45); // Total durasi (Dummy 3:45)
  Timer? _timer; // Timer untuk jalan otomatis

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

    // Setup Animasi Background
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
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  // --- LOGIKA PEMUTAR MUSIK ---
  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _breathingController.repeat(reverse: true);
        _startTimer(); // Mulai timer berjalan
      } else {
        _breathingController.stop();
        _breathingController.animateTo(0);
        _stopTimer(); // Hentikan timer
      }
    });
  }

  // LOGIKA BARU: Toggle Shuffle
  void _toggleShuffle() {
    setState(() {
      _isShuffleOn = !_isShuffleOn;
    });
    // Feedback visual (Snackbar) dummy
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isShuffleOn ? "Shuffle On" : "Shuffle Off"),
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.grey[900],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // LOGIKA BARU: Toggle Repeat (Cycle 3 State)
  void _toggleRepeat() {
    setState(() {
      _repeatMode = (_repeatMode + 1) % 3; // Cycle: 0 -> 1 -> 2 -> 0
    });
    
    String msg = "";
    if (_repeatMode == 0) msg = "Repeat Off";
    if (_repeatMode == 1) msg = "Repeat All";
    if (_repeatMode == 2) msg = "Repeat One";

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.grey[900],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final seconds = _position.inSeconds + 1;
        if (seconds < _duration.inSeconds) {
          _position = Duration(seconds: seconds);
        } else {
          // Lagu selesai
          if (_repeatMode == 2) { 
             // Jika Repeat One, ulang dari awal dan tetap main
             _position = Duration.zero;
          } else {
             // Jika tidak, stop (Simulasi sederhana)
             _timer?.cancel();
             _isPlaying = false;
             _position = Duration.zero;
             _breathingController.stop();
             _breathingController.animateTo(0);
          }
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
  // ---------------------------

  @override
  void dispose() {
    _timer?.cancel(); 
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
          
          // 2. ANIMATED GRADIENT OVERLAY
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientBegin,
                end: _gradientEnd,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // 3. BLUR FILTER
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(color: Colors.transparent),
          ),

          // 4. KONTEN UTAMA
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
                              // TOMBOL KEMBALI
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                                onPressed: () {
                                  // Navigasi Pop standar (Animasi slide down otomatis jika dibuka sbg FullscreenDialog)
                                  Navigator.of(context).pop();
                                },
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
                                    BoxShadow(
                                      color: _isPlaying 
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.black.withOpacity(0.5),
                                      offset: const Offset(0, 20),
                                      blurRadius: _isPlaying ? _breathingAnimation.value : 30,
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
                              IconButton(
                                icon: Icon(
                                  _isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: _isLiked ? const Color(0xFF1DB954) : Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  setState(() => _isLiked = !_isLiked);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // --- Slider & Time Berjalan ---
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
                                  value: _position.inSeconds.toDouble(),
                                  min: 0,
                                  max: _duration.inSeconds.toDouble(),
                                  onChanged: (v) {
                                    setState(() {
                                      _position = Duration(seconds: v.toInt());
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(_position), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                    Text(_formatDuration(_duration), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
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
                              // TOMBOL SHUFFLE
                              IconButton(
                                icon: const Icon(Icons.shuffle),
                                color: _isShuffleOn ? const Color(0xFF1DB954) : Colors.white, // Hijau jika aktif
                                iconSize: 26,
                                onPressed: _toggleShuffle,
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_previous_rounded),
                                color: Colors.white,
                                iconSize: 45,
                                onPressed: () {
                                  setState(() => _position = Duration.zero);
                                },
                              ),
                              // Play Button
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
                                onPressed: () {
                                  setState(() {
                                    _position = Duration.zero;
                                    _isPlaying = false;
                                    _breathingController.stop();
                                    _timer?.cancel();
                                  });
                                },
                              ),
                              // TOMBOL REPEAT
                              IconButton(
                                icon: Icon(
                                  _repeatMode == 2 ? Icons.repeat_one : Icons.repeat // Ikon berubah saat Repeat One
                                ),
                                color: _repeatMode > 0 ? const Color(0xFF1DB954) : Colors.white, // Hijau jika aktif
                                iconSize: 26,
                                onPressed: _toggleRepeat,
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),
                          
                          // Lyrics Hint
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C1D95).withOpacity(0.3),
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