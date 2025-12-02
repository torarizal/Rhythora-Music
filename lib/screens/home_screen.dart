import 'dart:async'; // WAJIB: Untuk Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart'; // WAJIB: Import GoRouter
import 'package:rhythora/state/home_cubit.dart';
import 'package:rhythora/state/home_state.dart';
import 'package:rhythora/state/navigation_cubit.dart';
import 'package:rhythora/state/navigation_state.dart';
import 'package:rhythora/state/playlist_cubit.dart';
import 'package:rhythora/state/playlist_state.dart';
import 'package:rhythora/widgets/loading_skeletons.dart';
import '../state/search_cubit.dart';
import '../state/search_state.dart';
import '../state/player_cubit.dart';
import '../state/player_state.dart';
import '../models/track_model.dart';
import 'detail_screen.dart';

// --- WARNA UI ---
const Color kBackgroundColor = Color(0xFF121212);
const Color kSidebarColor = Colors.black;
const Color kContentBackgroundColor = Color(0xFF18181B);
const Color kCardHoverColor = Color(0xFF27272A);
const Color kBorderColor = Color(0xFF3F3F46);
const Color kMutedTextColor = Color(0xFFA1A1AA);
const Color kBannerGradientStart = Color(0xFF4c1d95);
const Color kBannerGradientEnd = Color(0x80440C79);
const Color kPlayerBarBackgroundColor = kContentBackgroundColor;
const Color kSpotifyGreen = Color(0xFF1DB954);

// --- BREAKPOINTS ---
const double kMobileBreakpoint = 800.0;
const double kTabletBreakpoint = 1000.0;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ADAPTIVE: Jika lebar > 800, gunakan layout Row (Sidebar + Content)
          // Jika < 800, gunakan Drawer + Content
          if (constraints.maxWidth > kMobileBreakpoint) {
            return Row(
              children: [
                const SizedBox(width: 256, child: AppSidebar()),
                Expanded(child: MainContent()),
              ],
            );
          } else {
            return Scaffold(
              drawer: const Drawer(
                backgroundColor: kSidebarColor,
                child: AppSidebar(),
              ),
              appBar: AppBar(
                title: const Text('Rhythora', style: TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: kSidebarColor,
                elevation: 0,
                // Ikon menu otomatis muncul di sini untuk membuka Drawer
              ),
              body: MainContent(),
            );
          }
        },
      ),
      bottomNavigationBar: const _MusicPlayerBar(),
    );
  }
}

// ===== SIDEBAR (NAVIGASI URL /about) =====
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Container(
          color: kSidebarColor,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rhythora',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1.0)),
              const SizedBox(height: 32),

              NavItem(
                icon: Icons.home_filled,
                title: 'Beranda',
                isActive: state.page == NavPage.home,
                onTap: () {
                  context.read<NavigationCubit>().goToHome();
                  // Tutup drawer jika sedang di mobile
                  if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              NavItem(
                icon: Icons.search,
                title: 'Cari',
                isActive: state.page == NavPage.search,
                onTap: () {
                  context.read<NavigationCubit>().goToSearch();
                  if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              NavItem(
                icon: Icons.library_music,
                title: 'Koleksi Kamu',
                isActive: state.page == NavPage.library,
                onTap: () {
                  context.read<NavigationCubit>().goToLibrary();
                  if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                },
              ),

              // --- TOMBOL ABOUT US (Navigasi URL) ---
              const SizedBox(height: 8),
              NavItem(
                icon: Icons.info_outline,
                title: 'Tentang Kami',
                isActive: false,
                onTap: () {
                  context.go('/about');
                },
              ),
              // --------------------------------------

              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0), child: Divider(color: kBorderColor, thickness: 0.5)),

              const Text('DAFTAR PUTAR',
                  style: TextStyle(color: kMutedTextColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _PlaylistSidebarItem(title: 'Lagu Favorit', icon: Icons.favorite, color: Colors.purple.shade300),
                    const _PlaylistSidebarItem(title: 'Mix Harian 1'),
                    const _PlaylistSidebarItem(title: 'Top Hits Indonesia'),
                    const _PlaylistSidebarItem(title: 'Galau Akut'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===== ITEM WIDGETS (HELPER) =====
class _PlaylistSidebarItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;
  const _PlaylistSidebarItem({required this.title, this.icon, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
            onTap: () {},
            hoverColor: Colors.transparent,
            child: Row(children: [
              if (icon != null) ...[
                Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color!.withOpacity(0.8), color!]),
                        borderRadius: BorderRadius.circular(2)),
                    child: Icon(icon, size: 12, color: Colors.white)),
                const SizedBox(width: 12)
              ],
              Text(title, style: const TextStyle(color: kMutedTextColor, fontSize: 14))
            ])));
  }
}

class NavItem extends StatelessWidget {
  const NavItem({super.key, required this.icon, required this.title, this.isActive = false, required this.onTap});
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: isActive ? kCardHoverColor : Colors.transparent, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(icon, color: isActive ? Colors.white : kMutedTextColor, size: 24),
              const SizedBox(width: 16),
              Text(title,
                  style: TextStyle(
                      color: isActive ? Colors.white : kMutedTextColor, fontWeight: FontWeight.w700, fontSize: 14))
            ])));
  }
}

// ===== MAIN CONTENT =====
class MainContent extends StatelessWidget {
  MainContent({super.key});
  final TextEditingController _searchController = TextEditingController();

  // ADAPTIVE: Mengambil lebar layar untuk menentukan padding
  EdgeInsets _getResponsivePadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // Jika Mobile (< 600), padding 16. Jika Desktop, padding 32.
    return EdgeInsets.symmetric(horizontal: width < 600 ? 16.0 : 32.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (state.page == NavPage.search)
              SliverAppBar(
                backgroundColor: kContentBackgroundColor,
                pinned: false,
                floating: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                    child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: 'Apa yang ingin kamu dengarkan?',
                            hintStyle: const TextStyle(color: kMutedTextColor),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            filled: true,
                            fillColor: Colors.grey[800],
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: const BorderSide(color: Colors.white, width: 1))),
                        onSubmitted: (query) {
                          if (query.isNotEmpty) context.read<SearchCubit>().searchTracks(query);
                        })),
              ),
            if (state.page == NavPage.home) _buildHomePageContent(context),
            if (state.page == NavPage.search) _buildSearchPageContent(context),
            if (state.page == NavPage.library) _buildLibraryPageContent(context),
          ],
        );
      },
    );
  }

  Widget _buildHomePageContent(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) return const HomeLoadingSkeleton();
        if (state is HomeError) {
          return SliverFillRemaining(child: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))));
        }
        if (state is HomeLoaded) {
          // Responsive Carousel Height
          double width = MediaQuery.of(context).size.width;
          double carouselHeight = width < 600 ? 220.0 : 300.0;

          return SliverList(
            delegate: SliverChildListDelegate([
              // Carousel
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0, top: 20.0),
                child: state.trendingTracks.isEmpty
                    ? const SizedBox(height: 250, child: Center(child: Text("Tidak ada lagu trending.", style: TextStyle(color: kMutedTextColor))))
                    : CarouselSlider.builder(
                        options: CarouselOptions(
                            height: carouselHeight,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: width < 600 ? 0.85 : 0.65, // Item lebih lebar di mobile
                            autoPlayInterval: const Duration(seconds: 6)),
                        itemCount: state.trendingTracks.length,
                        itemBuilder: (context, itemIndex, pageViewIndex) {
                          final track = state.trendingTracks[itemIndex];
                          return InkWell(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) => TrackInfoScreen(track: track))),
                            child: Hero(
                              tag: 'track_image_${track.id}',
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
                                    ],
                                    image: track.albumImageUrl != null
                                        ? DecorationImage(image: NetworkImage(track.albumImageUrl!), fit: BoxFit.cover)
                                        : null,
                                    gradient: track.albumImageUrl == null
                                        ? const LinearGradient(
                                            colors: [kBannerGradientStart, kBannerGradientEnd],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight)
                                        : null),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                          stops: const [0.6, 1.0])),
                                  padding: const EdgeInsets.all(20),
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("TRENDING",
                                            style: TextStyle(
                                                color: kSpotifyGreen,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2.0)),
                                        const SizedBox(height: 4),
                                        Text(track.name,
                                            style: TextStyle(
                                                fontSize: width < 600 ? 18.0 : 24.0, // Font responsive
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        Text(track.artistName,
                                            style: TextStyle(fontSize: 16.0, color: Colors.grey[300]),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis)
                                      ]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Recommended
              Padding(
                padding: _getResponsivePadding(context), // PADDING RESPONSIVE
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Rilis Baru Untukmu',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  state.recommendedTracks.isEmpty
                      ? const Center(child: Text('Tidak ada rekomendasi.', style: TextStyle(color: kMutedTextColor)))
                      : AnimationLimiter(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.recommendedTracks.length,
                              itemBuilder: (context, index) {
                                final track = state.recommendedTracks[index];
                                return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                            child: SongItem(
                                                track: track, trackNumber: (index + 1).toString()))));
                              })),
                  const SizedBox(height: 100),
                ]),
              ),
            ]),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildSearchPageContent(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(builder: (context, state) {
      if (state is SearchInitial) {
        return const SliverFillRemaining(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search, size: 80, color: kCardHoverColor),
          SizedBox(height: 16),
          Text('Mulai cari lagu favoritmu.', style: TextStyle(color: kMutedTextColor, fontSize: 16))
        ]));
      }
      return SliverPadding(padding: _getResponsivePadding(context), sliver: _buildSearchResults(state));
    });
  }

  Widget _buildLibraryPageContent(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0).copyWith(
          left: MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0, // Responsive padding
          right: MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0
        ),
        sliver: BlocBuilder<PlaylistCubit, PlaylistState>(builder: (context, state) {
          if (state is PlaylistLoading || state is PlaylistInitial) return const LibraryLoadingSkeleton();
          if (state is PlaylistError) {
            return SliverFillRemaining(child: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))));
          }
          if (state is PlaylistLoaded) {
            return SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0,
                    mainAxisSpacing: 24.0,
                    crossAxisSpacing: 24.0,
                    childAspectRatio: 0.8),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final playlist = state.playlists[index];
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                            decoration: BoxDecoration(
                                color: kCardHoverColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                                ],
                                image: playlist.imageUrl != null
                                    ? DecorationImage(image: NetworkImage(playlist.imageUrl!), fit: BoxFit.cover)
                                    : null),
                            child: playlist.imageUrl == null
                                ? const Center(child: Icon(Icons.music_note, size: 40, color: kMutedTextColor))
                                : null)),
                    const SizedBox(height: 12),
                    Text(playlist.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('By ${playlist.ownerName}',
                        style: const TextStyle(color: kMutedTextColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)
                  ]);
                }, childCount: state.playlists.length));
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }));
  }

  Widget _buildSearchResults(SearchState state) {
    if (state is SearchLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: kSpotifyGreen)));
    }
    if (state is SearchLoaded) {
      if (state.tracks.isEmpty) {
        return const SliverFillRemaining(
            child: Center(child: Text('Tidak ada hasil ditemukan.', style: TextStyle(color: kMutedTextColor))));
      }
      return SliverList(
          delegate: SliverChildListDelegate([
        const Text('Hasil Pencarian', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          return constraints.maxWidth > 600 ? const SongListHeader() : const SizedBox.shrink();
        }),
        const SizedBox(height: 16),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.tracks.length,
            itemBuilder: (context, index) {
              final track = state.tracks[index];
              return SongItem(track: track, trackNumber: (index + 1).toString());
            }),
        const SizedBox(height: 32),
      ]));
    }
    if (state is SearchError) {
      return SliverFillRemaining(
          child: Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red))));
    }
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

class SongListHeader extends StatelessWidget {
  const SongListHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBorderColor))),
        child: Row(children: [
          const SizedBox(
              width: 48,
              child: Text('#',
                  textAlign: TextAlign.center, style: TextStyle(color: kMutedTextColor, fontWeight: FontWeight.w500))),
          const SizedBox(width: 16),
          const Expanded(
              flex: 3, child: Text('JUDUL', style: TextStyle(color: kMutedTextColor, fontWeight: FontWeight.w500))),
          const Expanded(
              flex: 2, child: Text('ALBUM', style: TextStyle(color: kMutedTextColor, fontWeight: FontWeight.w500))),
          SizedBox(
              width: 100,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.access_time, size: 16, color: kMutedTextColor)))
        ]));
  }
}

class SongItem extends StatefulWidget {
  const SongItem({super.key, required this.track, required this.trackNumber});
  final Track track;
  final String trackNumber;
  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  bool _isHovered = false;
  String _formatDuration(int? milliseconds) {
    if (milliseconds == null || milliseconds <= 0) return '-:--';
    final duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.track.albumImageUrl ?? 'https://via.placeholder.com/40/3f3f46/71717a?text=?';
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {
          if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => TrackInfoScreen(track: widget.track)));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: _isHovered ? kCardHoverColor : Colors.transparent, borderRadius: BorderRadius.circular(4)),
          child: LayoutBuilder(builder: (context, constraints) {
            // ADAPTIVE: Sembunyikan kolom Album pada layar kecil
            final bool isDesktop = constraints.maxWidth > 600;
            
            return Row(children: [
              SizedBox(
                  width: 48,
                  child: Center(
                      child: _isHovered
                          ? const Icon(Icons.info_outline, color: Colors.white, size: 20)
                          : Text(widget.trackNumber,
                              style: TextStyle(color: _isHovered ? Colors.white : kMutedTextColor)))),
              const SizedBox(width: 16),
              Expanded(
                  flex: isDesktop ? 3 : 1,
                  child: Row(children: [
                    Hero(
                        tag: 'track_image_${widget.track.id}',
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                    width: 40,
                                    height: 40,
                                    color: kBorderColor,
                                    child: const Icon(Icons.music_note, size: 20, color: kMutedTextColor))))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.track.name,
                          style: TextStyle(fontWeight: FontWeight.w500, color: _isHovered ? kSpotifyGreen : Colors.white),
                          overflow: TextOverflow.ellipsis),
                      Text(widget.track.artistName,
                          style: const TextStyle(fontSize: 13, color: kMutedTextColor), overflow: TextOverflow.ellipsis)
                    ]))
                  ])),
              if (isDesktop)
                Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(widget.track.albumName ?? '-',
                            style: const TextStyle(color: kMutedTextColor, fontSize: 13),
                            overflow: TextOverflow.ellipsis))),
              SizedBox(
                  width: isDesktop ? 100 : 60,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(_formatDuration(widget.track.durationMs),
                          style: const TextStyle(fontSize: 13, color: kMutedTextColor)))),
            ]);
          }),
        ),
      ),
    );
  }
}

// ===== WIDGET PLAYER BAR (UPDATED & RESPONSIVE) =====
class _MusicPlayerBar extends StatefulWidget {
  const _MusicPlayerBar();
  @override
  State<_MusicPlayerBar> createState() => _MusicPlayerBarState();
}

class _MusicPlayerBarState extends State<_MusicPlayerBar> {
  double _sliderValue = 0.0;
  bool _isDraggingSlider = false;
  bool _isPlaying = false;
  Timer? _timer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 3, seconds: 45);
  bool _isShuffle = false;
  int _repeatMode = 0;
  bool _isLiked = false;
  double _volume = 0.7;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      try {
        if (context.read<PlayerCubit>().state.currentTrack != null) {
          context.read<PlayerCubit>().togglePlayPause();
        }
      } catch (e) {
        debugPrint("Cubit error: $e");
      }
      if (_isPlaying) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_totalDuration.inSeconds == 0) return;
        final newSeconds = _currentPosition.inSeconds + 1;
        if (newSeconds <= _totalDuration.inSeconds) {
          _currentPosition = Duration(seconds: newSeconds);
          double progress = _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
          if (progress.isNaN || progress.isInfinite) progress = 0.0;
          _sliderValue = progress.clamp(0.0, 1.0);
        } else {
          if (_repeatMode == 2) {
            _currentPosition = Duration.zero;
            _sliderValue = 0.0;
          } else {
            _isPlaying = false;
            _currentPosition = Duration.zero;
            _sliderValue = 0.0;
            _stopTimer();
          }
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _toggleShuffle() => setState(() => _isShuffle = !_isShuffle);
  void _toggleRepeat() {
    setState(() {
      _repeatMode = (_repeatMode + 1) % 3;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_repeatMode == 0 ? "Repeat Off" : (_repeatMode == 1 ? "Repeat All" : "Repeat One")),
        duration: const Duration(milliseconds: 500),
        backgroundColor: kCardHoverColor));
  }

  void _toggleLike() => setState(() => _isLiked = !_isLiked);
  void _onVolumeChanged(double value) => setState(() => _volume = value);
  void _showLyrics(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: kCardHoverColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Container(
            padding: const EdgeInsets.all(24),
            height: 500,
            child: Column(children: [
              const Text("Lirik Lagu",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                  child: SingleChildScrollView(
                      child: Text("[Verse 1]\nIni adalah lirik simulasi...\n\n[Chorus]\nRhythora... Rhythora...",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18, height: 1.5))))
            ])));
  }

  void _showQueue(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: kCardHoverColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Antrian Berikutnya",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                  child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (ctx, i) => ListTile(
                          leading: const Icon(Icons.music_note, color: kMutedTextColor),
                          title: Text("Lagu Berikutnya ${i + 1}", style: const TextStyle(color: Colors.white)),
                          subtitle: const Text("Artist Unknown", style: TextStyle(color: kMutedTextColor)),
                          trailing: const Icon(Icons.drag_handle, color: kMutedTextColor))))
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerCubit, PlayerState>(
      listener: (context, state) {
        if (state.currentTrack != null && state.currentTrack!.durationMs != null) {
          if ((_totalDuration.inMilliseconds - state.currentTrack!.durationMs!).abs() > 1000) {
            _totalDuration = Duration(milliseconds: state.currentTrack!.durationMs!);
          }
        }
      },
      builder: (context, state) {
        final track = state.currentTrack;
        
        // ADAPTIVE: Gunakan LayoutBuilder untuk mengubah tampilan PlayerBar
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmallScreen = constraints.maxWidth < 600;

            return Container(
              height: isSmallScreen ? 120 : 90, // Lebih tinggi sedikit di mobile jika perlu stacking, atau tetap 90
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: const BoxDecoration(
                  color: kContentBackgroundColor,
                  border: Border(top: BorderSide(color: kBorderColor, width: 1))),
              child: isSmallScreen 
                // --- MOBILE LAYOUT (Simplified) ---
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Baris Atas: Info Lagu + Controls Utama
                      Row(
                        children: [
                          // Info Lagu
                          Expanded(
                            child: Row(children: [
                              Hero(
                                  tag: 'track_image_${track?.id ?? 'default_player_image'}',
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4.0),
                                      child: Image.network(
                                          track?.albumImageUrl ??
                                              'https://via.placeholder.com/56/3f3f46/71717a?text=?',
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                              width: 48,
                                              height: 48,
                                              color: kBorderColor,
                                              child: const Icon(Icons.music_note, color: kMutedTextColor))))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                    Text(track?.name ?? 'Pilih Lagu',
                                        style: const TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        overflow: TextOverflow.ellipsis),
                                    Text(track?.artistName ?? '-',
                                        style: const TextStyle(color: kMutedTextColor, fontSize: 11),
                                        overflow: TextOverflow.ellipsis)
                                  ])),
                              IconButton(
                                icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: _isLiked ? kSpotifyGreen : kMutedTextColor, size: 20),
                                onPressed: _toggleLike,
                              )
                            ]),
                          ),
                          // Controls Play/Pause
                          InkWell(
                              onTap: _togglePlay,
                              customBorder: const CircleBorder(),
                              child: Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration:
                                      const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.black, size: 20))),
                        ],
                      ),
                      // Baris Bawah: Progress Bar Sederhana
                      SizedBox(
                        height: 20,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              trackHeight: 2.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.grey[800],
                              thumbColor: Colors.white),
                          child: Slider(
                            value: _sliderValue,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) {
                              setState(() {
                                _isDraggingSlider = true;
                                _sliderValue = value;
                                if (_totalDuration.inMilliseconds > 0) {
                                  _currentPosition = Duration(
                                      milliseconds: (value * _totalDuration.inMilliseconds).round());
                                }
                              });
                            },
                            onChangeEnd: (value) => setState(() => _isDraggingSlider = false),
                          ),
                        ),
                      )
                    ],
                  )
                // --- DESKTOP / TABLET LAYOUT (Full) ---
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // KIRI: Track Info
                    Flexible(
                        flex: 1,
                        child: Row(children: [
                          Hero(
                              tag: 'track_image_${track?.id ?? 'default_player_image'}',
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child: Image.network(
                                      track?.albumImageUrl ??
                                          'https://via.placeholder.com/56/3f3f46/71717a?text=?',
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                          width: 56,
                                          height: 56,
                                          color: kBorderColor,
                                          child: const Icon(Icons.music_note, color: kMutedTextColor))))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                Text(track?.name ?? 'Pilih Lagu',
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(track?.artistName ?? '-',
                                    style: const TextStyle(color: kMutedTextColor, fontSize: 12),
                                    overflow: TextOverflow.ellipsis)
                              ])),
                          const SizedBox(width: 8),
                          IconButton(
                              icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: _isLiked ? kSpotifyGreen : kMutedTextColor, size: 20),
                              onPressed: _toggleLike,
                              tooltip: 'Simpan ke Koleksi')
                        ])),
                    
                    // TENGAH: Controls & Progress
                    Expanded(
                        flex: 2,
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            IconButton(
                                icon: const Icon(Icons.shuffle),
                                color: _isShuffle ? kSpotifyGreen : kMutedTextColor,
                                iconSize: 20,
                                tooltip: 'Acak',
                                onPressed: _toggleShuffle),
                            const SizedBox(width: 8),
                            IconButton(
                                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
                                tooltip: 'Sebelumnya',
                                onPressed: track != null
                                    ? () {
                                        setState(() {
                                          _currentPosition = Duration.zero;
                                          _sliderValue = 0.0;
                                        });
                                        try {
                                          context.read<PlayerCubit>().previous();
                                        } catch (e) {}
                                      }
                                    : null),
                            const SizedBox(width: 8),
                            InkWell(
                                onTap: _togglePlay,
                                customBorder: const CircleBorder(),
                                child: Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    decoration:
                                        const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.black, size: 24))),
                            const SizedBox(width: 8),
                            IconButton(
                                icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                                tooltip: 'Berikutnya',
                                onPressed: track != null
                                    ? () {
                                        setState(() {
                                          _currentPosition = Duration.zero;
                                          _sliderValue = 0.0;
                                        });
                                        try {
                                          context.read<PlayerCubit>().next();
                                        } catch (e) {}
                                      }
                                    : null),
                            const SizedBox(width: 8),
                            IconButton(
                                icon: Icon(_repeatMode == 2 ? Icons.repeat_one : Icons.repeat),
                                color: _repeatMode > 0 ? kSpotifyGreen : kMutedTextColor,
                                iconSize: 20,
                                tooltip: 'Ulangi',
                                onPressed: _toggleRepeat)
                          ]),
                          const SizedBox(height: 4),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(_formatDuration(_currentPosition),
                                style: const TextStyle(color: kMutedTextColor, fontSize: 11)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: SizedBox(
                                    height: 12,
                                    child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                            trackHeight: 3.0,
                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                                            activeTrackColor: Colors.white,
                                            inactiveTrackColor: Colors.grey[800],
                                            thumbColor: Colors.white,
                                            overlayColor: Colors.white.withOpacity(0.2)),
                                        child: Slider(
                                            value: _sliderValue,
                                            min: 0.0,
                                            max: 1.0,
                                            onChanged: (value) {
                                              setState(() {
                                                _isDraggingSlider = true;
                                                _sliderValue = value;
                                                if (_totalDuration.inMilliseconds > 0) {
                                                  _currentPosition = Duration(
                                                      milliseconds: (value * _totalDuration.inMilliseconds)
                                                          .round());
                                                }
                                              });
                                            },
                                            onChangeEnd: (value) {
                                              setState(() {
                                                _isDraggingSlider = false;
                                              });
                                            })))),
                            const SizedBox(width: 8),
                            Text(_formatDuration(_totalDuration),
                                style: const TextStyle(color: kMutedTextColor, fontSize: 11))
                          ])
                        ])),

                    // KANAN: Volume & Extra Controls
                    Flexible(
                        flex: 1,
                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          IconButton(
                              icon: const Icon(Icons.lyrics_outlined),
                              color: kMutedTextColor,
                              iconSize: 20,
                              tooltip: 'Lirik',
                              onPressed: () => _showLyrics(context)),
                          IconButton(
                              icon: const Icon(Icons.queue_music),
                              color: kMutedTextColor,
                              iconSize: 20,
                              tooltip: 'Antrian',
                              onPressed: () => _showQueue(context)),
                          Row(children: [
                            Icon(
                                _volume == 0
                                    ? Icons.volume_off
                                    : _volume < 0.5
                                        ? Icons.volume_down
                                        : Icons.volume_up,
                                color: kMutedTextColor,
                                size: 20),
                            SizedBox(
                                width: 80,
                                child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                        trackHeight: 3.0,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                                        activeTrackColor: Colors.white,
                                        inactiveTrackColor: Colors.grey[800],
                                        thumbColor: Colors.white),
                                    child: Slider(
                                        value: _volume, min: 0.0, max: 1.0, onChanged: _onVolumeChanged)))
                          ])
                        ]))
                  ],
                ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}