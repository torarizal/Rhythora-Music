import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
// Asumsikan path model dan state sudah benar
import '../models/track_model.dart'; 
import '../state/player_cubit.dart'; 
import '../state/player_state.dart'; 

class TrackDetailScreen extends StatefulWidget {
  final Track track;

  const TrackDetailScreen({super.key, required this.track});

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen>
    with SingleTickerProviderStateMixin {
  Color? _dominantColor;
  late AnimationController _animationController;
  String? _previousTrackId;
  double _backgroundGlowOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _updatePalette();
    _previousTrackId = widget.track.id;
  }

  @override
  void didUpdateWidget(covariant TrackDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.track.id != oldWidget.track.id) {
      _updatePalette();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updatePalette() async {
    // Reset warna dan opacity untuk transisi yang bagus
    if (mounted) {
      setState(() {
        _backgroundGlowOpacity = 0.0;
      });
    }

    final String? imageUrl = widget.track.albumImageUrl;
    Color calculatedColor = Colors.deepPurpleAccent;

    if (imageUrl != null) {
      final provider = NetworkImage(imageUrl);
      final palette =
          await PaletteGenerator.fromImageProvider(provider, size: const Size(200, 200));
      calculatedColor = palette.dominantColor?.color ?? Colors.deepPurpleAccent;
    }

    if (mounted) {
      setState(() {
        _dominantColor = calculatedColor;
        // Animasi opacity setelah warna diperbarui
        _backgroundGlowOpacity = 1.0; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = _dominantColor ?? Colors.deepPurpleAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(widget.track.albumName ?? "Now Playing",
            style: const TextStyle(
                color: Colors.white, fontSize: 14, letterSpacing: 1.2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _FloatingActionButton(
              icon: Icons.more_vert,
              onPressed: () {},
              neonColor: neonColor,
              size: 24,
              glowIntensity: 0.5,
              padding: 4, 
            ),
          )
        ],
      ),
      body: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, state) {
          final currentTrack = state.currentTrack ?? widget.track;
          final isPlaying = state.status == PlayerStatus.playing &&
              state.currentTrack?.id == currentTrack.id;

          // Kontrol Animasi Vinyl
          if (isPlaying) {
            if (!_animationController.isAnimating) {
              _animationController.repeat();
            }
          } else {
            _animationController.stop();
          }

          // Perbarui palet untuk lagu baru
          if (_previousTrackId != currentTrack.id) {
            _previousTrackId = currentTrack.id;
            if (widget.track.id == currentTrack.id) {
              _updatePalette();
            }
          }

          return Stack(
            children: [
              // Efek Glow Latar Belakang Besar
              AnimatedOpacity(
                opacity: _backgroundGlowOpacity,
                duration: const Duration(milliseconds: 800),
                child: Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    height: 500,
                    width: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: neonColor.withOpacity(0.3),
                          blurRadius: 150.0,
                          spreadRadius: 100.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Konten Utama
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      neonColor.withOpacity(0.4),
                      Colors.black.withOpacity(0.9),
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 10.0, sigmaY: 10.0), 
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            _RotatingVinylDisk(
                              animationController: _animationController,
                              currentTrack: currentTrack,
                              isPlaying: isPlaying,
                              dominantColor: neonColor,
                            ),
                            const SizedBox(height: 40),
                            _TrackInfo(
                                currentTrack: currentTrack,
                                dominantColor: neonColor),
                            const SizedBox(height: 40),
                            _PlayerControls(
                                state: state,
                                currentTrack: currentTrack,
                                isPlaying: isPlaying,
                                dominantColor: neonColor),
                            const SizedBox(height: 30),
                            _BottomBar(dominantColor: neonColor),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Widget untuk piringan hitam yang berputar
class _RotatingVinylDisk extends StatefulWidget {
  const _RotatingVinylDisk({
    required this.animationController,
    required this.currentTrack,
    required this.isPlaying,
    this.dominantColor,
  });

  final AnimationController animationController;
  final Track currentTrack;
  final bool isPlaying;
  final Color? dominantColor;

  @override
  State<_RotatingVinylDisk> createState() => _RotatingVinylDiskState();
}

class _RotatingVinylDiskState extends State<_RotatingVinylDisk>
    with TickerProviderStateMixin {
  late AnimationController _jiggleAnimationController;
  late Animation<double> _jiggleAnimation;
  late AnimationController _shadowAnimationController;
  late Animation<double> _shadowBlurAnimation;
  late Animation<double> _shadowSpreadAnimation;
  String? _previousTrackId;

  @override
  void initState() {
    super.initState();
    _jiggleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _jiggleAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(
        parent: _jiggleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _shadowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shadowBlurAnimation = Tween<double>(begin: 20, end: 50).animate(
      CurvedAnimation(
        parent: _shadowAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _shadowSpreadAnimation = Tween<double>(begin: 5, end: 10).animate(
      CurvedAnimation(
        parent: _shadowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _previousTrackId = widget.currentTrack.id;
  }

  @override
  void didUpdateWidget(covariant _RotatingVinylDisk oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentTrack.id != _previousTrackId && widget.isPlaying) {
      _jiggleAnimationController.forward(from: 0.0).then((_) {
        if (mounted) {
          _jiggleAnimationController.reverse();
        }
      });
      _previousTrackId = widget.currentTrack.id;
    }
  }

  @override
  void dispose() {
    _jiggleAnimationController.dispose();
    _shadowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = widget.dominantColor ?? Colors.deepPurpleAccent;

    return RotationTransition(
      turns: widget.animationController,
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_jiggleAnimationController, _shadowAnimationController]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _jiggleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    neonColor.withOpacity(0.6),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 1.0],
                ),
                border: Border.all(color: neonColor.withOpacity(0.8), width: 3),
                boxShadow: [
                  BoxShadow(
                      color: neonColor.withOpacity(0.7),
                      blurRadius: _shadowBlurAnimation.value,
                      spreadRadius: _shadowSpreadAnimation.value),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 40,
                      spreadRadius: 10)
                ],
              ),
              child: Hero(
                tag: 'track_image_${widget.currentTrack.id}',
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        height: 294, 
                        width: 294,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: 10.0, sigmaY: 10.0), 
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    widget.currentTrack.albumImageUrl ??
                                        'https://via.placeholder.com/400/1e1e1e/ffffff?text=NO+ART'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Lubang Piringan Hitam (Inner Circle)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        border:
                            Border.all(color: neonColor.withOpacity(0.8), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: neonColor.withOpacity(0.7),
                              blurRadius: 15,
                              spreadRadius: 4)
                        ],
                      ),
                      child: Center(
                          child: Icon(Icons.flash_on,
                              color: neonColor.withOpacity(0.9), size: 18)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget untuk informasi judul lagu dan artis
class _TrackInfo extends StatelessWidget {
  const _TrackInfo({required this.currentTrack, this.dominantColor});

  final Track currentTrack;
  final Color? dominantColor;

  @override
  Widget build(BuildContext context) {
    final neonColor = dominantColor ?? Colors.deepPurpleAccent;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0.0, 0.2), end: Offset.zero)
                  .animate(animation),
              child: child),
        );
      },
      child: AnimatedContainer(
        key: ValueKey<String>(currentTrack.id), // Key for AnimatedSwitcher
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: neonColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: neonColor.withOpacity(0.25),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentTrack.name,
              style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.5,
                  shadows: [
                    BoxShadow(
                        color: neonColor.withOpacity(0.7),
                        blurRadius: 10,
                        spreadRadius: 3)
                  ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              currentTrack.artistName,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400, 
                  letterSpacing: 1.0,
                  shadows: [
                    BoxShadow(
                        color: neonColor.withOpacity(0.4),
                        blurRadius: 7,
                        spreadRadius: 2)
                  ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk kontrol pemutar
class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.state,
    required this.currentTrack,
    required this.isPlaying,
    this.dominantColor,
  });

  final PlayerState state;
  final Track currentTrack;
  final bool isPlaying;
  final Color? dominantColor;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = twoDigits(duration.inMinutes.remainder(60));
    final s = twoDigits(duration.inSeconds.remainder(60));
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = dominantColor ?? Colors.deepPurpleAccent;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            
            // Konfigurasi Warna (Koreksi error ada di sini)
            activeTrackColor: neonColor.withOpacity(0.9),
            inactiveTrackColor: Colors.white.withOpacity(0.15),
            thumbColor: neonColor, // Hanya didefinisikan sekali
            overlayColor: neonColor.withOpacity(0.4),
          ),
          child: Slider(
            min: 0,
            max: state.totalDuration.inMilliseconds.toDouble() > 0
                ? state.totalDuration.inMilliseconds.toDouble()
                : 1,
            value: (state.currentTrack?.id == currentTrack.id)
                ? state.currentPosition.inMilliseconds.toDouble()
                : 0,
            onChanged: (value) {
              if (state.currentTrack?.id == currentTrack.id) {
                context
                    .read<PlayerCubit>()
                    .seek(Duration(milliseconds: value.round()));
              }
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                _formatDuration(state.currentTrack?.id == currentTrack.id
                    ? state.currentPosition
                    : Duration.zero),
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    letterSpacing: 0.8)),
            Text(_formatDuration(state.totalDuration),
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    letterSpacing: 0.8)),
          ],
        ),
        const SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FloatingActionButton(
              icon: Icons.shuffle_rounded,
              onPressed: () {},
              neonColor: neonColor,
              size: 28,
              glowIntensity: 0.6,
            ),
            _FloatingActionButton(
              icon: Icons.skip_previous_rounded,
              size: 48,
              onPressed: () => context.read<PlayerCubit>().previous(),
              neonColor: neonColor,
              glowIntensity: 0.8,
            ),
            _AnimatedPlayPauseButton(
              isPlaying: isPlaying,
              onTap: () {
                if (state.currentTrack?.id == currentTrack.id) {
                  context.read<PlayerCubit>().togglePlayPause();
                } else {
                  context.read<PlayerCubit>().play(currentTrack);
                }
              },
              neonColor: neonColor,
            ),
            _FloatingActionButton(
              icon: Icons.skip_next_rounded,
              size: 48,
              onPressed: () => context.read<PlayerCubit>().next(),
              neonColor: neonColor,
              glowIntensity: 0.8,
            ),
            _FloatingActionButton(
              icon: Icons.repeat_rounded,
              onPressed: () {},
              neonColor: neonColor,
              glowIntensity: 0.6,
            ),
          ],
        ),
      ],
    );
  }
}

class _FloatingActionButton extends StatefulWidget {
  const _FloatingActionButton({
    required this.icon,
    required this.onPressed,
    this.size = 28,
    this.neonColor,
    this.glowIntensity = 0.5,
    this.padding = 8.0,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? neonColor;
  final double glowIntensity;
  final double padding;

  @override
  State<_FloatingActionButton> createState() => _FloatingActionButtonState();
}

class _FloatingActionButtonState extends State<_FloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0).then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.neonColor ?? Colors.deepPurpleAccent;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(widget.padding),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(
                        widget.glowIntensity * _glowAnimation.value + 0.1),
                    blurRadius: 15 * _glowAnimation.value + 5,
                    spreadRadius: 3 * _glowAnimation.value + 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(widget.icon,
                  color: Colors.white.withOpacity(0.9), size: widget.size),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedPlayPauseButton extends StatefulWidget {
  const _AnimatedPlayPauseButton({
    required this.isPlaying,
    required this.onTap,
    this.neonColor,
  });

  final bool isPlaying;
  final VoidCallback onTap;
  final Color? neonColor;

  @override
  State<_AnimatedPlayPauseButton> createState() =>
      _AnimatedPlayPauseButtonState();
}

class _AnimatedPlayPauseButtonState extends State<_AnimatedPlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedPlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = widget.neonColor ?? Colors.deepPurpleAccent;

    return GestureDetector(
      onTap: () {
        widget.onTap();
        _controller.forward(from: 0.0).then((_) {
          if (!widget.isPlaying) {
            _controller.reverse();
          }
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                gradient: LinearGradient(
                  colors: [
                    neonColor.withOpacity(0.8 * _controller.value + 0.1),
                    neonColor.withOpacity(0.4 * _controller.value + 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: neonColor.withOpacity(0.8 * _controller.value + 0.2),
                      blurRadius: 25 * _controller.value + 5,
                      spreadRadius: 5 * _controller.value + 1),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1)
                ],
              ),
              child: Center(
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _controller,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget untuk bar bawah (Bottom Bar)
class _BottomBar extends StatefulWidget {
  const _BottomBar({this.dominantColor});

  final Color? dominantColor;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> with TickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartSizeAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartSizeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      if (_isFavorite) {
        _heartAnimationController.forward(from: 0.0);
      } else {
        _heartAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = widget.dominantColor ?? Colors.deepPurpleAccent;
    final favoriteColor = _isFavorite ? Colors.redAccent : neonColor;

    return Row(
      children: [
        // Tombol Favorite
        GestureDetector(
          onTap: _toggleFavorite,
          child: AnimatedBuilder(
            animation: _heartAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _heartSizeAnimation.value,
                child: _FloatingActionButton(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  onPressed: () {}, // Handled by GestureDetector
                  neonColor: favoriteColor,
                  size: 28,
                  glowIntensity: _isFavorite ? 1.0 : 0.5,
                ),
              );
            },
          ),
        ),
        const Spacer(),
        // Tombol Cast
        _FloatingActionButton(
          icon: Icons.cast_connected, 
          onPressed: () {},
          neonColor: neonColor,
          glowIntensity: 0.6,
        ),
        const SizedBox(width: 20),
        // Tombol Volume
        _FloatingActionButton(
          icon: Icons.volume_up,
          onPressed: () {},
          neonColor: neonColor,
          glowIntensity: 0.6,
        ),
      ],
    );
  }
}