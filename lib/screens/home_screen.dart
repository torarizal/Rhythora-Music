import 'dart:async'; // WAJIB: Untuk Timer agar durasi berjalan
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
import 'package:flutter/foundation.dart';
import 'detail_screen.dart';
// --- WARNA DARI UI BARU ANDA ---
const Color kBackgroundColor = Color(0xFF121212);
const Color kSidebarColor = Colors.black;
const Color kContentBackgroundColor = Color(0xFF18181B);
const Color kCardHoverColor = Color(0xFF27272A);
const Color kBorderColor = Color(0xFF3F3F46);
const Color kMutedTextColor = Color(0xFFA1A1AA);
const Color kBannerGradientStart = Color(0xFF4c1d95);
const Color kBannerGradientEnd = Color(0x80440C79);
const Color kBannerTextColor = Color(0xFFd8b4fe);
const Color kPlayerBarBackgroundColor = kContentBackgroundColor;
const Color kSpotifyGreen = Color(0xFF1DB954); // Warna Hijau Khas
// ---------------------------------


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsif: Desktop vs Mobile/Tablet
          if (constraints.maxWidth > 1024) {
            return Row(
              children: [
                const SizedBox(
                  width: 256,
                  child: AppSidebar(),
                ),
                Expanded(
                  child: MainContent(),
                ),
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

// ===== WIDGET SIDEBAR =====
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
              // Logo atau Nama Web
              const Text(
                'Rhythora',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 32),

              // Navigasi Utama
              NavItem(
                icon: Icons.home_filled,
                title: 'Beranda',
                isActive: state.page == NavPage.home,
                onTap: () {
                  context.read<NavigationCubit>().goToHome();
                  if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context); // Tutup drawer di mobile
                  }
                },
              ),
              const SizedBox(height: 8),
              NavItem(
                icon: Icons.search,
                title: 'Cari',
                isActive: state.page == NavPage.search,
                onTap: () {
                  context.read<NavigationCubit>().goToSearch();
                  if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 8),
              NavItem(
                icon: Icons.library_music,
                title: 'Koleksi Kamu',
                isActive: state.page == NavPage.library,
                onTap: () {
                  context.read<NavigationCubit>().goToLibrary();
                  if (Scaffold.maybeOf(context)?.hasDrawer == true && Scaffold.of(context).isDrawerOpen) {
                    Navigator.pop(context);
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Divider(color: kBorderColor, thickness: 0.5),
              ),

              // --- Daftar Putar ---
              const Text(
                'DAFTAR PUTAR',
                style: TextStyle(
                  color: kMutedTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2
                ),
              ),
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
                     const _PlaylistSidebarItem(title: 'Semangat Pagi'),
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
        onTap: (){},
        hoverColor: Colors.transparent,
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color!.withOpacity(0.8), color!]),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Icon(icon, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 12),
            ],
            Text(title, style: const TextStyle(color: kMutedTextColor, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// Widget untuk item navigasi di sidebar
class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.title,
    this.isActive = false,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : kMutedTextColor;

    return InkWell( // Menggunakan InkWell untuk efek splash saat klik
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Sedikit diperbesar
        decoration: BoxDecoration(
          color: isActive ? kCardHoverColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700, // Lebih tebal
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== WIDGET KONTEN UTAMA =====
class MainContent extends StatelessWidget {
  MainContent({super.key});

  final TextEditingController _searchController = TextEditingController();

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
                        borderRadius: BorderRadius.circular(30.0), // Lebih bulat
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    onSubmitted: (query) {
                      if (query.isNotEmpty) {
                        context.read<SearchCubit>().searchTracks(query);
                      }
                    },
                  ),
                ),
              ),

            if (state.page == NavPage.home)
              _buildHomePageContent(),
            if (state.page == NavPage.search)
              _buildSearchPageContent(),
            if (state.page == NavPage.library)
              _buildLibraryPageContent(),
            
          ],
        );
      },
    );
  }

  Widget _buildHomePageContent() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const HomeLoadingSkeleton();
        }
        if (state is HomeError) {
          return SliverFillRemaining(
            child: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))),
          );
        }
        if (state is HomeLoaded) {
          return SliverList(
            delegate: SliverChildListDelegate(
              [
                // Banner / Carousel
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 20.0),
                  child: state.trendingTracks.isEmpty
                      ? const SizedBox(height: 250, child: Center(child: Text("Tidak ada lagu trending.", style: TextStyle(color: kMutedTextColor))))
                      : CarouselSlider.builder(
                          options: CarouselOptions(
                            height: 300.0, // Lebih tinggi sedikit
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.65, // Biar lebih fokus
                            autoPlayInterval: const Duration(seconds: 6),
                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                          ),
                          itemCount: state.trendingTracks.length,
                          itemBuilder: (context, itemIndex, pageViewIndex) {
                            final track = state.trendingTracks[itemIndex];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TrackInfoScreen(track: track),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'track_image_${track.id}',
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(16), // Rounded lebih halus
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                    image: track.albumImageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(track.albumImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                    gradient: track.albumImageUrl == null
                                      ? const LinearGradient(
                                          colors: [kBannerGradientStart, kBannerGradientEnd],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  ),
                                  // Gradient Overlay di dalam gambar agar teks terbaca
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                        stops: const [0.6, 1.0],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "TRENDING",
                                          style: TextStyle(
                                            color: kSpotifyGreen, 
                                            fontSize: 10, 
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2.0
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          track.name,
                                          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          track.artistName,
                                          style: TextStyle(fontSize: 16.0, color: Colors.grey[300]),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Judul Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rilis Baru Untukmu',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
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
                                          track: track,
                                          trackNumber: (index + 1).toString(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ),
                      const SizedBox(height: 100), // Extra space di bawah
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildSearchPageContent() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial) {
          return const SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 80, color: kCardHoverColor),
                SizedBox(height: 16),
                Text('Mulai cari lagu favoritmu.', style: TextStyle(color: kMutedTextColor, fontSize: 16)),
              ],
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          sliver: _buildSearchResults(state),
        );
      },
    );
  }

  Widget _buildLibraryPageContent() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      sliver: BlocBuilder<PlaylistCubit, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading || state is PlaylistInitial) {
            return const LibraryLoadingSkeleton();
          }
          if (state is PlaylistError) {
            return SliverFillRemaining(
              child: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))),
            );
          }
          if (state is PlaylistLoaded) {
            return SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: 24.0,
                crossAxisSpacing: 24.0,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final playlist = state.playlists[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: kCardHoverColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                            ],
                            image: playlist.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(playlist.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: playlist.imageUrl == null
                              ? const Center(child: Icon(Icons.music_note, size: 40, color: kMutedTextColor))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        playlist.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${playlist.ownerName}',
                        style: const TextStyle(color: kMutedTextColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
                childCount: state.playlists.length,
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    );
  }

  Widget _buildSearchResults(SearchState state) {
      if (state is SearchLoading) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator(color: kSpotifyGreen)),
        );
      }
      if (state is SearchLoaded) {
         if (state.tracks.isEmpty) {
           return const SliverFillRemaining(
             child: Center(child: Text('Tidak ada hasil ditemukan.', style: TextStyle(color: kMutedTextColor))),
           );
        }
        return SliverList(
          delegate: SliverChildListDelegate(
           [
              const Text(
                'Hasil Pencarian',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
             const SizedBox(height: 20),
             LayoutBuilder(
                builder: (context, constraints) {
                  final bool isDesktop = constraints.maxWidth > 600;
                  return isDesktop ? const SongListHeader() : const SizedBox.shrink();
                },
              ),
             const SizedBox(height: 16),
             ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.tracks.length,
                itemBuilder: (context, index) {
                  final track = state.tracks[index];
                  return SongItem(
                    track: track,
                    trackNumber: (index + 1).toString(),
                  );
                },
              ),
              const SizedBox(height: 32),
           ],
         ),
        );
      }
      if (state is SearchError) {
        return SliverFillRemaining(
          child: Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red))),
        );
      }
      return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

// Widget header tabel
class SongListHeader extends StatelessWidget {
  const SongListHeader({super.key});
  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorderColor)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 48,
            child: Text('#', textAlign: TextAlign.center, style: TextStyle(color: kMutedTextColor, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            flex: 3,
            child: Text('JUDUL', style: TextStyle(color: kMutedTextColor, fontWeight: FontWeight.w500)),
          ),
          const Expanded(
            flex: 2,
            child: Text('ALBUM', style: TextStyle(color: kMutedTextColor, fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.access_time, size: 16, color: kMutedTextColor),
            ),
          ),
        ],
      ),
    );
   }
}

// Widget item lagu
class SongItem extends StatefulWidget {
  const SongItem({
    super.key,
    required this.track,
    required this.trackNumber,
    this.album,
    this.duration,
  });
  final Track track;
  final String trackNumber;
  final String? album;
  final String? duration;
  @override State<SongItem> createState() => _SongItemState();
}
class _SongItemState extends State<SongItem> {
  bool _isHovered = false;
  String _formatDuration(int? milliseconds) {
      if (milliseconds == null || milliseconds <= 0) return '-:--';
      final duration = Duration(milliseconds: milliseconds);
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return "$minutes:$seconds";
    }
  @override Widget build(BuildContext context) {
      final String title = widget.track.name;
      final String artist = widget.track.artistName;
      final String imageUrl = widget.track.albumImageUrl ?? 'https://via.placeholder.com/40/3f3f46/71717a?text=?';
      final String displayAlbum = widget.track.albumName ?? '-';
      final String displayDuration = _formatDuration(widget.track.durationMs);

      return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
         onTap: () {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackInfoScreen(track: widget.track),
                ),
              );
            }
         },
         child: AnimatedContainer(
           duration: const Duration(milliseconds: 200),
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           decoration: BoxDecoration(
             color: _isHovered ? kCardHoverColor : Colors.transparent,
             borderRadius: BorderRadius.circular(4),
           ),
           child: LayoutBuilder(
             builder: (context, constraints) {
               final bool isDesktop = constraints.maxWidth > 600;
               return Row(
                 children: [
                   SizedBox(
                     width: 48,
                     child: Center(
                       child: _isHovered
                           ? const Icon(Icons.info_outline, color: Colors.white, size: 20)
                           : Text(widget.trackNumber, style: TextStyle(color: _isHovered ? Colors.white : kMutedTextColor)),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     flex: isDesktop ? 3 : 1,
                     child: Row(
                       children: [
                         Hero(
                           tag: 'track_image_${widget.track.id}',
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(4),
                             child: Image.network(
                               imageUrl,
                               width: 40,
                               height: 40,
                               fit: BoxFit.cover,
                               errorBuilder: (context, error, stackTrace) =>
                                   Container(width: 40, height: 40, color: kBorderColor, child: const Icon(Icons.music_note, size: 20, color: kMutedTextColor)),
                             ),
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 title, 
                                 style: TextStyle(fontWeight: FontWeight.w500, color: _isHovered ? kSpotifyGreen : Colors.white), 
                                 overflow: TextOverflow.ellipsis
                               ),
                               Text(artist, style: const TextStyle(fontSize: 13, color: kMutedTextColor), overflow: TextOverflow.ellipsis),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                   if (isDesktop)
                     Expanded(
                       flex: 2,
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
                         child: Text(displayAlbum, style: const TextStyle(color: kMutedTextColor, fontSize: 13), overflow: TextOverflow.ellipsis),
                       ),
                     ),
                   SizedBox(
                     width: isDesktop ? 100 : 60,
                     child: Align(
                       alignment: Alignment.centerRight,
                       child: Text(displayDuration, style: const TextStyle(fontSize: 13, color: kMutedTextColor)),
                     ),
                   ),
                 ],
               );
             },
           ),
         ),
       ),
     );
    }
}

// =========================================================
// WIDGET PLAYER BAR YANG SUDAH DIPERBAGUS & DIFUNGSIKAN (UPDATED V2)
// =========================================================
class _MusicPlayerBar extends StatefulWidget {
   const _MusicPlayerBar();
   @override State<_MusicPlayerBar> createState() => _MusicPlayerBarState();
 }
 
 class _MusicPlayerBarState extends State<_MusicPlayerBar> {
   // State Visual Slider
   double _sliderValue = 0.0;
   
   // State Audio Simulasi
   bool _isPlaying = false; 
   Timer? _timer;
   Duration _currentPosition = Duration.zero;
   Duration _totalDuration = const Duration(minutes: 3, seconds: 45); // Dummy duration default

   // State Fitur Lain
   bool _isShuffle = false;
   int _repeatMode = 0; // 0: Off, 1: All, 2: One
   bool _isLiked = false;
   double _volume = 0.7; 

   @override
   void dispose() {
     _timer?.cancel();
     super.dispose();
   }

   // Fungsi Toggle Play/Pause dengan Timer Visual
   void _togglePlay() {
     setState(() {
       _isPlaying = !_isPlaying;
       
       // Coba panggil cubit, tapi jangan sampai crash jika cubit belum siap
       try {
         // Hanya panggil cubit jika track ada, kalau tidak, ini murni simulasi UI
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
     _stopTimer(); // Reset timer sebelumnya jika ada
     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
       setState(() {
         // Cek total duration agar tidak error
         if (_totalDuration.inSeconds == 0) return;

         final newSeconds = _currentPosition.inSeconds + 1;
         
         if (newSeconds <= _totalDuration.inSeconds) {
           _currentPosition = Duration(seconds: newSeconds);
           // Update slider value (0.0 - 1.0) dengan safe division
           double progress = _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
           if (progress.isNaN || progress.isInfinite) progress = 0.0;
           _sliderValue = progress.clamp(0.0, 1.0);
         } else {
           // Lagu selesai
           if (_repeatMode == 2) { // Repeat One
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
     String msg = _repeatMode == 0 ? "Repeat Off" : (_repeatMode == 1 ? "Repeat All" : "Repeat One");
     ScaffoldMessenger.of(context).clearSnackBars();
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
       content: Text(msg), duration: const Duration(milliseconds: 500), backgroundColor: kCardHoverColor,
     ));
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
         child: Column(
           children: [
             const Text("Lirik Lagu", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
             const SizedBox(height: 20),
             Expanded(
               child: SingleChildScrollView(
                 child: Text(
                   "[Verse 1]\nIni adalah lirik simulasi\nKarena API lirik membutuhkan akses premium\nTapi anggap saja ini lirik lagu yang sedang diputar\nBernyanyilah sesuka hati...\n\n[Chorus]\nRhythora... Rhythora...\nAplikasi musik paling kece...\n\n(Lirik berlanjut...)",
                   textAlign: TextAlign.center,
                   style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18, height: 1.5),
                 ),
               ),
             )
           ],
         ),
       ),
     );
   }

   void _showQueue(BuildContext context) {
     showModalBottomSheet(
       context: context,
       backgroundColor: kCardHoverColor,
       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
       builder: (ctx) => Container(
         padding: const EdgeInsets.all(24),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text("Antrian Berikutnya", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
             Expanded(
               child: ListView.builder(
                 itemCount: 10,
                 itemBuilder: (ctx, i) => ListTile(
                   leading: const Icon(Icons.music_note, color: kMutedTextColor),
                   title: Text("Lagu Berikutnya ${i+1}", style: const TextStyle(color: Colors.white)),
                   subtitle: const Text("Artist Unknown", style: TextStyle(color: kMutedTextColor)),
                   trailing: const Icon(Icons.drag_handle, color: kMutedTextColor),
                 ),
               ),
             )
           ],
         ),
       ),
     );
   }

   @override
   Widget build(BuildContext context) {
     return BlocConsumer<PlayerCubit, PlayerState>(
      listener: (context, state) {
        // Sync durasi real jika ada
        if (state.currentTrack != null && state.currentTrack!.durationMs != null) {
           // Hanya update jika berbeda signifikan (menghindari reset loop)
           if ((_totalDuration.inMilliseconds - state.currentTrack!.durationMs!).abs() > 1000) {
              _totalDuration = Duration(milliseconds: state.currentTrack!.durationMs!);
           }
        }
      },
      builder: (context, state) {
        final track = state.currentTrack;
        
        return Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: const BoxDecoration(
            color: kContentBackgroundColor,
            border: Border(top: BorderSide(color: kBorderColor, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ====================
              // 1. INFO LAGU (KIRI)
              // ====================
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Hero(
                      tag: 'track_image_${track?.id ?? 'default_player_image'}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image.network(
                          track?.albumImageUrl ?? 'https://via.placeholder.com/56/3f3f46/71717a?text=?',
                          width: 56, height: 56, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                            Container(width: 56, height: 56, color: kBorderColor, child: const Icon(Icons.music_note, color: kMutedTextColor)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(track?.name ?? 'Pilih Lagu', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(track?.artistName ?? '-', style: const TextStyle(color: kMutedTextColor, fontSize: 12), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Love Button Interactive
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? kSpotifyGreen : kMutedTextColor,
                        size: 20
                      ),
                      onPressed: _toggleLike,
                      tooltip: 'Simpan ke Koleksi',
                    ),
                  ],
                ),
              ),

              // ====================
              // 2. KONTROL PLAYER (TENGAH)
              // ====================
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Kontrol
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         // Shuffle Button
                         IconButton(
                           icon: const Icon(Icons.shuffle),
                           color: _isShuffle ? kSpotifyGreen : kMutedTextColor, // Hijau jika aktif
                           iconSize: 20,
                           tooltip: 'Acak',
                           onPressed: _toggleShuffle,
                         ),
                         const SizedBox(width: 8),
                         IconButton(
                           icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
                           tooltip: 'Sebelumnya',
                           onPressed: () { 
                             // Reset timer & posisi
                             setState(() { _currentPosition = Duration.zero; _sliderValue = 0.0; });
                             try { context.read<PlayerCubit>().previous(); } catch(e){}
                           } 
                         ),
                         const SizedBox(width: 8),
                         
                         // PLAY / PAUSE BUTTON
                         InkWell(
                           onTap: _togglePlay, // Selalu aktif untuk simulasi
                           customBorder: const CircleBorder(),
                           child: Container(
                            width: 36, height: 36,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 24),
                           ),
                         ),
                         
                         const SizedBox(width: 8),
                         IconButton(
                           icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                           tooltip: 'Berikutnya',
                           onPressed: () { 
                             // Reset timer & posisi
                             setState(() { _currentPosition = Duration.zero; _sliderValue = 0.0; });
                             try { context.read<PlayerCubit>().next(); } catch(e){}
                           } 
                         ),
                         const SizedBox(width: 8),
                         // Repeat Button (Cycle)
                         IconButton(
                           icon: Icon(_repeatMode == 2 ? Icons.repeat_one : Icons.repeat),
                           color: _repeatMode > 0 ? kSpotifyGreen : kMutedTextColor,
                           iconSize: 20,
                           tooltip: 'Ulangi',
                           onPressed: _toggleRepeat,
                         ),
                       ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Slider Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Waktu Berjalan (Gunakan State Lokal _currentPosition)
                        Text(_formatDuration(_currentPosition), style: const TextStyle(color: kMutedTextColor, fontSize: 11)),
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
                                overlayColor: Colors.white.withOpacity(0.2)
                              ),
                              child: Slider(
                                value: _sliderValue, // Gunakan State Lokal
                                min: 0.0, 
                                max: 1.0,
                                // Fitur Seek (Geser)
                                onChanged: (value) {
                                  setState(() {
                                    _sliderValue = value;
                                    // Hitung posisi baru berdasarkan persentase geser
                                    if (_totalDuration.inMilliseconds > 0) {
                                      _currentPosition = Duration(milliseconds: (value * _totalDuration.inMilliseconds).round());
                                    }
                                  });
                                },
                                onChangeEnd: (value) {
                                  setState(() {
                                    // Timer lanjut dari posisi baru
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Total Durasi
                        Text(_formatDuration(_totalDuration), style: const TextStyle(color: kMutedTextColor, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              // ====================
              // 3. KONTROL EKSTRA (KANAN)
              // ====================
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     IconButton(
                       icon: const Icon(Icons.lyrics_outlined), 
                       color: kMutedTextColor, 
                       iconSize: 20,
                       tooltip: 'Lirik',
                       onPressed: () => _showLyrics(context),
                     ),
                     IconButton(
                       icon: const Icon(Icons.queue_music), 
                       color: kMutedTextColor, 
                       iconSize: 20,
                       tooltip: 'Antrian',
                       onPressed: () => _showQueue(context),
                     ),
                     
                     // Volume Control dengan Ikon Dinamis
                     Row(
                       children: [
                         Icon(
                           _volume == 0 ? Icons.volume_off : _volume < 0.5 ? Icons.volume_down : Icons.volume_up, 
                           color: kMutedTextColor, 
                           size: 20
                         ),
                         SizedBox(
                           width: 80, 
                           child: SliderTheme(
                             data: SliderTheme.of(context).copyWith(
                               trackHeight: 3.0, 
                               thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0), 
                               overlayShape: const RoundSliderOverlayShape(overlayRadius: 0), 
                               activeTrackColor: Colors.white, 
                               inactiveTrackColor: Colors.grey[800], 
                               thumbColor: Colors.white
                             ), 
                             child: Slider(
                               value: _volume, 
                               min: 0.0, 
                               max: 1.0, 
                               onChanged: _onVolumeChanged,
                             )
                           )
                         ),
                       ],
                     ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
   }

   String _formatDuration(Duration duration) {
     String twoDigits(int n) => n.toString().padLeft(2, '0');
     final minutes = twoDigits(duration.inMinutes.remainder(60));
     final seconds = twoDigits(duration.inSeconds.remainder(60));
     return "$minutes:$seconds";
   }
 }