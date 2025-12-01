import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // WAJIB: Import Audio Player
import 'package:rhythora/models/track_model.dart';

class TrackDetailScreen extends StatefulWidget {
  final Track track;

  const TrackDetailScreen({super.key, required this.track});

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen> with TickerProviderStateMixin {
  // --- AUDIO PLAYER ---
  late AudioPlayer _audioPlayer;
  
  // --- STATE UI ---
  bool _isPlaying = false;
  bool _isLiked = false;
  bool _isShuffleOn = false;
  int _repeatMode = 0; // 0: Off, 1: All, 2: One
  
  // --- DURASI & POSISI ---
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isDraggingSlider = false;

  // --- ANIMASI ---
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  
  // Variabel untuk Animasi Background Gradient
  Alignment _gradientBegin = Alignment.topLeft;
  Alignment _gradientEnd = Alignment.bottomRight;
  Timer? _gradientTimer;

  @override
  void initState() {
    super.initState();
    
    // 1. Setup Audio Player
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();

    // 2. Setup Animasi Bernapas (Shadow Album)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Lebih cepat dikit biar kerasa beat-nya
    );
    _breathingAnimation = Tween<double>(begin: 10.0, end: 25.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 3. Mulai Animasi Background Aurora
    _startBackgroundAnimation();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // URL Lagu Dummy (Karena API Spotify butuh Premium untuk streaming langsung)
      // Ganti dengan widget.track.previewUrl jika API Anda menyediakannya
      const String url = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"; 
      
      // Setup Listeners
      _audioPlayer.positionStream.listen((p) {
        if (mounted && !_isDraggingSlider) setState(() => _position = p);
      });

      _audioPlayer.durationStream.listen((d) {
        if (mounted) setState(() => _duration = d ?? Duration.zero);
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _isPlaying = false;
              _position = Duration.zero;
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.pause();
              _breathingController.stop();
            }
          });
          
          // Sinkronisasi animasi bernapas dengan status play
          if (_isPlaying) {
            _breathingController.repeat(reverse: true);
          } else {
            _breathingController.stop();
            _breathingController.animateTo(0);
          }
        }
      });

      // Load Audio
      await _audioPlayer.setUrl(url);
      // Auto Play saat masuk halaman (Opsional, matikan jika tidak ingin autoplay)
      _audioPlayer.play(); 

    } catch (e) {
      debugPrint("Error audio: $e");
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _startBackgroundAnimation() {
    _gradientTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _gradientBegin = _gradientBegin == Alignment.topLeft ? Alignment.bottomLeft : Alignment.topLeft;
          _gradientEnd = _gradientEnd == Alignment.bottomRight ? Alignment.topRight : Alignment.bottomRight;
        });
      }
    });
  }

  // --- FORMAT DURASI (MM:SS) ---
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // --- FITUR LAIN ---
  void _toggleShuffle() {
    setState(() => _isShuffleOn = !_isShuffleOn);
    _showSnackBar(_isShuffleOn ? "Shuffle On" : "Shuffle Off");
  }

  void _toggleRepeat() {
    setState(() => _repeatMode = (_repeatMode + 1) % 3);
    String msg = _repeatMode == 0 ? "Repeat Off" : (_repeatMode == 1 ? "Repeat All" : "Repeat One");
    _showSnackBar(msg);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        duration: const Duration(milliseconds: 600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- BOTTOM SHEET: LYRICS ---
  void _showLyrics() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: const Color(0xFF18181B).withOpacity(0.9),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 20),
                      const Text("Lirik Lagu", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          controller: controller,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Text(
                              "[Intro]\n(Musik Instrumental)\n\n[Verse 1]\nIni adalah simulasi lirik\nKarena API lirik butuh lisensi mahal\nTapi bayangkan lagu ini sangat indah\nMenyentuh hati dan jiwa...\n\n[Chorus]\nRhythora... Rhythora...\nMusic for everyone...\nDengarkan iramanya...\nRasakan getarannya...\n\n[Verse 2]\nCoding flutter itu menyenangkan\nApalagi pakai animasi keren\nJangan lupa ngopi dulu\nBiar coding makin laju...\n\n[Outro]\nYeah... Rhythora...",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18, height: 1.8, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _breathingController.dispose();
    _gradientTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final String imageUrl = widget.track.albumImageUrl ?? "";
    // Ukuran gambar responsif (tidak terlalu besar di desktop)
    final double imageSize = min(size.width * 0.85, size.height * 0.42); 

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
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
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientBegin,
                end: _gradientEnd,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.purple.shade900.withOpacity(0.3), // Sentuhan ungu
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // 3. GLASSMOPHISM BLUR
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
            child: Container(color: Colors.transparent),
          ),

          // 4. KONTEN UTAMA
          SafeArea(
            child: Column(
              children: [
                // --- HEADER / APPBAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Column(
                        children: [
                          Text(
                            "PLAYING FROM PLAYLIST",
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "My Favorites",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.white, size: 28),
                        onPressed: () {
                          _showSnackBar("More options clicked");
                        },
                      ),
                    ],
                  ),
                ),

                // --- FLEXIBLE SPACE (ALBUM ART) ---
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _breathingAnimation,
                      builder: (context, child) {
                        return Container(
                          height: imageSize,
                          width: imageSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              // Shadow yang bernapas
                              BoxShadow(
                                color: _isPlaying 
                                    ? Colors.white.withOpacity(0.25)
                                    : Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 20),
                                blurRadius: _isPlaying ? _breathingAnimation.value : 20,
                                spreadRadius: _isPlaying ? 2 : 0,
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: Hero(
                        tag: 'track_image_${widget.track.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800, child: const Icon(Icons.music_note, size: 80, color: Colors.white24)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // --- INFO & CONTROLS SECTION ---
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Penting agar tidak overflow
                    children: [
                      // Judul & Artis
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.track.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.track.artistName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.6)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? const Color(0xFF1DB954) : Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() => _isLiked = !_isLiked);
                              _showSnackBar(_isLiked ? "Added to Liked Songs" : "Removed from Liked Songs");
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          trackHeight: 4.0,
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                          overlayColor: Colors.white.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                          min: 0,
                          max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                          onChanged: (v) {
                            setState(() {
                              _isDraggingSlider = true;
                              _position = Duration(seconds: v.toInt());
                            });
                          },
                          onChangeEnd: (v) {
                            _audioPlayer.seek(Duration(seconds: v.toInt()));
                            setState(() => _isDraggingSlider = false);
                          },
                        ),
                      ),
                      
                      // Durasi Waktu
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

                      const SizedBox(height: 10),

                      // Main Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shuffle),
                            color: _isShuffleOn ? const Color(0xFF1DB954) : Colors.white,
                            iconSize: 28,
                            onPressed: _toggleShuffle,
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded),
                            color: Colors.white,
                            iconSize: 48,
                            onPressed: () => _audioPlayer.seek(Duration.zero),
                          ),
                          
                          // Play Button Besar dengan Efek Scale
                          GestureDetector(
                            onTap: _togglePlay,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 72, 
                              width: 72,
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
                                color: Colors.black, size: 42,
                              ),
                            ),
                          ),
                          
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded),
                            color: Colors.white,
                            iconSize: 48,
                            onPressed: () {
                              // Simulasi skip: restart lagu
                              _audioPlayer.seek(Duration.zero);
                              _audioPlayer.play();
                            },
                          ),
                          IconButton(
                            icon: Icon(_repeatMode == 2 ? Icons.repeat_one : Icons.repeat),
                            color: _repeatMode > 0 ? const Color(0xFF1DB954) : Colors.white,
                            iconSize: 28,
                            onPressed: _toggleRepeat,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Extra Controls (Lyrics & Share)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.speaker_group_outlined, color: Colors.white54),
                            onPressed: () => _showSnackBar("Connect a device"),
                          ),
                          
                          // Tombol Lyrics
                          GestureDetector(
                            onTap: _showLyrics,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4C1D95).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white12),
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
                          ),

                          IconButton(
                            icon: const Icon(Icons.list_rounded, color: Colors.white54),
                            onPressed: () => _showSnackBar("Queue List"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}