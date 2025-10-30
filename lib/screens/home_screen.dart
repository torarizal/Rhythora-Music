import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
// Import Cubit, State, Model
import '../state/search_cubit.dart';
import '../state/search_state.dart';
import '../state/player_cubit.dart';
import '../state/player_state.dart';
import '../models/track_model.dart';
import '../services/spotify_service.dart';
// --- IMPORT BARU UNTUK HALAMAN DETAIL ---
import 'player_screens.dart';
// ------------------------------------
// --- Import untuk debugPrint ---
import 'package:flutter/foundation.dart';
// -----------------------------

// --- WARNA DARI UI BARU ANDA ---
const Color kBackgroundColor = Color(0xFF121212);
const Color kSidebarColor = Colors.black;
// ... (Warna Anda yang lain tetap di sini) ...
const Color kContentBackgroundColor = Color(0xFF18181B);
const Color kCardHoverColor = Color(0xFF27272A);
const Color kBorderColor = Color(0xFF3F3F46);
const Color kMutedTextColor = Color(0xFFA1A1AA);
const Color kBannerGradientStart = Color(0xFF4c1d95);
const Color kBannerGradientEnd = Color(0x80440C79);
const Color kBannerTextColor = Color(0xFFd8b4fe);
const Color kPlayerBarBackgroundColor = kContentBackgroundColor;
// ---------------------------------


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                child: AppSidebar(),
              ),
              appBar: AppBar(
                title: const Text('Rhythora'),
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
  // ... (Kode AppSidebar tidak berubah) ...
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSidebarColor, // Latar belakang sidebar
      padding: const EdgeInsets.all(24.0), // Padding
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
            ),
          ),
          const SizedBox(height: 32),

          // Navigasi Utama
          const NavItem(
            icon: Icons.home_filled,
            title: 'Beranda',
            isActive: true, // Item Beranda aktif
          ),
          const SizedBox(height: 8),
          const NavItem(
            icon: Icons.search,
            title: 'Cari',
          ),
          const SizedBox(height: 8),
          const NavItem(
            icon: Icons.library_music,
            title: 'Koleksi Kamu',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(color: kBorderColor), // Garis pemisah
          ),

          // --- Daftar Putar (Hapus Dummy) ---
          const Text(
            'Daftar Putar',
            style: TextStyle(
              color: kMutedTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 16
            ),
          ),
          const SizedBox(height: 16),
          // TODO: Ganti dengan BlocBuilder<PlaylistCubit, PlaylistState>
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: const [
                 Padding( // Contoh item playlist
                   padding: EdgeInsets.symmetric(vertical: 6.0),
                   child: Text('Lagu Favorit', style: TextStyle(color: kMutedTextColor)),
                 ),
                 Padding(
                   padding: EdgeInsets.symmetric(vertical: 6.0),
                   child: Text('Mix Harian 1', style: TextStyle(color: kMutedTextColor)),
                 ),
                 // ... tambahkan item lain jika perlu
              ],
            ),
          ),
          // ------------------------------------
        ],
      ),
    );
  }
}

// Widget untuk item navigasi di sidebar
class NavItem extends StatelessWidget {
  // ... (Kode NavItem tidak berubah) ...
  const NavItem({
    super.key,
    required this.icon,
    required this.title,
    this.isActive = false,
  });

  final IconData icon;
  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : kMutedTextColor; // Tentukan warna

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? kCardHoverColor : Colors.transparent, // Latar belakang jika aktif
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== WIDGET KONTEN UTAMA =====
class MainContent extends StatefulWidget {
   MainContent({super.key});

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  // ... (Kode _MainContentState tidak berubah signifikan) ...
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<Track> _trendingTracks = []; // Untuk data slider
  List<Track> _homeRecommendations = [];
  bool _isLoadingHome = true;
  String? _homeError;

 @override
  void initState() {
    super.initState();
    _loadHomeRecommendations();
  }

 @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeRecommendations() async {
    setState(() {
      _isLoadingHome = true;
      _homeError = null;
    });
    try {
      if (!mounted) return;
      final spotifyService = RepositoryProvider.of<SpotifyService>(context);
      final List<Track> fetchedTrending = await spotifyService.searchTracks('trending songs indonesia');
      final List<Track> recommendedTracks = await spotifyService.searchTracks('new releases indonesia');

       if (mounted) {
        setState(() {
          _homeRecommendations = recommendedTracks;
          _trendingTracks = fetchedTrending.take(5).toList();
          _isLoadingHome = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading home recommendations: $e");
       if (mounted) {
        setState(() {
          _homeError = "Gagal memuat rekomendasi."; // Pesan lebih singkat
          _isLoadingHome = false;
        });
       }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: kContentBackgroundColor,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari lagu atau artis...',
                  hintStyle: const TextStyle(color: kMutedTextColor),
                  prefixIcon: const Icon(Icons.search, color: kMutedTextColor),
                  filled: true,
                  fillColor: kCardHoverColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    debugPrint("HomeScreen: Memanggil SearchCubit.searchTracks dengan query: $query");
                    if (mounted) {
                       context.read<SearchCubit>().searchTracks(query);
                    }
                  }
                },
              ),
            ),
          ),

          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is SearchLoading || state is SearchLoaded || state is SearchError) {
                 return SliverPadding(
                   padding: const EdgeInsets.symmetric(horizontal: 32.0),
                   sliver: _buildSearchResults(state),
                 );
              }

              // KONDISI AWAL (SearchInitial) - Tampilkan konten default (Home Page)
               return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: _isLoadingHome
                          ? const SizedBox(height: 250, child: Center(child: CircularProgressIndicator(color: Colors.green)))
                          : _homeError != null
                              ? SizedBox(height: 250, child: Center(child: Text(_homeError!, style: const TextStyle(color: Colors.red))))
                              : _trendingTracks.isEmpty
                                  ? const SizedBox(height: 250, child: Center(child: Text("Tidak ada lagu trending.", style: TextStyle(color: kMutedTextColor))))
                                  : CarouselSlider.builder(
                                      options: CarouselOptions(
                                        height: 250.0,
                                        autoPlay: true,
                                        enlargeCenterPage: true,
                                        viewportFraction: 0.8,
                                        autoPlayInterval: const Duration(seconds: 5),
                                      ),
                                      itemCount: _trendingTracks.length,
                                      itemBuilder: (context, itemIndex, pageViewIndex) {
                                        final track = _trendingTracks[itemIndex];
                                        return InkWell(
                                           onTap: () {
                                              if (mounted) {
                                                 debugPrint("Slider Tapped: ${track.name}");
                                                 context.read<PlayerCubit>().play(track);
                                                 Navigator.push(
                                                   context,
                                                   MaterialPageRoute(
                                                     builder: (context) => TrackDetailScreen(track: track),
                                                   ),
                                                 );
                                              }
                                           },
                                          child: Hero(
                                            tag: 'track_image_${track.id}',
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[800],
                                                borderRadius: BorderRadius.circular(12),
                                                image: track.albumImageUrl != null
                                                  ? DecorationImage(
                                                      image: NetworkImage(track.albumImageUrl!),
                                                      fit: BoxFit.cover,
                                                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)
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
                                              child: Stack(
                                                 children: [
                                                    if (track.albumImageUrl == null)
                                                       Center(child: Icon(Icons.music_note, color: kMutedTextColor.withOpacity(0.5), size: 80)),
                                                    Positioned(
                                                      bottom: 16,
                                                      left: 16,
                                                      right: 16,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                           Text(
                                                            track.name,
                                                            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 2)]),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                           Text(
                                                            track.artistName,
                                                            style: TextStyle(fontSize: 14.0, color: Colors.grey[300], shadows: const [Shadow(blurRadius: 1)]),
                                                             maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                 ]
                                               ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rilis Baru',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            _isLoadingHome
                                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                                : _homeError != null
                                    ? Center(child: Text(_homeError!, style: const TextStyle(color: Colors.red)))
                                    : _homeRecommendations.isEmpty
                                        ? const Center(child: Text('Tidak ada rekomendasi.', style: TextStyle(color: kMutedTextColor)))
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: _homeRecommendations.length,
                                            itemBuilder: (context, index) {
                                              final track = _homeRecommendations[index];
                                              return SongItem(
                                                track: track,
                                                trackNumber: (index + 1).toString(),
                                              );
                                            },
                                          ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState state) {
// ... (Kode _buildSearchResults tidak berubah) ...
     if (state is SearchLoading) {
       return const SliverFillRemaining(
         child: Center(child: CircularProgressIndicator(color: Colors.green)),
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
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
                  // Pastikan context tersedia sebelum memanggil read
                  // InkWell sudah ada di dalam SongItem, tidak perlu di sini
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

// Widget header tabel (tidak berubah)
class SongListHeader extends StatelessWidget {
// ... (Kode SongListHeader tidak berubah) ...
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

// Widget item lagu (MODIFIKASI: Tambahkan Navigasi dan Hero)
class SongItem extends StatefulWidget {
// ... (Kode properti SongItem tidak berubah) ...
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
             debugPrint("SongItem Tapped: ${widget.track.name}");
             context.read<PlayerCubit>().play(widget.track);
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => TrackDetailScreen(track: widget.track),
               ),
             );
           }
         },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? kCardHoverColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
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
                          ? const Icon(Icons.play_arrow, color: Colors.white, size: 20)
                          : Text(widget.trackNumber, style: const TextStyle(color: kMutedTextColor)),
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
                              Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white), overflow: TextOverflow.ellipsis),
                              Text(artist, style: const TextStyle(fontSize: 14, color: kMutedTextColor), overflow: TextOverflow.ellipsis),
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
                        child: Text(displayAlbum, style: const TextStyle(color: kMutedTextColor), overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  SizedBox(
                    width: isDesktop ? 100 : 60,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(displayDuration, style: const TextStyle(fontSize: 14, color: kMutedTextColor)),
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

// Widget player bar (MODIFIKASI: Tambahkan Hero dan Perbaikan Layout)
class _MusicPlayerBar extends StatefulWidget {
   const _MusicPlayerBar();
   @override State<_MusicPlayerBar> createState() => _MusicPlayerBarState();
 }
 class _MusicPlayerBarState extends State<_MusicPlayerBar> {
   double _sliderValue = 0.0;
   bool _isDraggingSlider = false;
   Duration _currentPosition = Duration.zero;

   @override
   Widget build(BuildContext context) {
     return BlocConsumer<PlayerCubit, PlayerState>(
      listener: (context, state) {
        final totalMillis = state.totalDuration.inMilliseconds;
        if (!_isDraggingSlider && totalMillis > 0) {
          if(mounted){
             setState(() {
              _sliderValue = (state.currentPosition.inMilliseconds / totalMillis).clamp(0.0, 1.0);
              _currentPosition = state.currentPosition;
            });
          }
        }
        if (state.status == PlayerStatus.initial || state.status == PlayerStatus.error) {
           if(mounted){
             setState(() {
              _sliderValue = 0.0;
              _currentPosition = Duration.zero;
            });
           }
         }
      },
      builder: (context, state) {
        final track = state.currentTrack;
        final totalDuration = state.totalDuration;
        final bool isPlaying = state.status == PlayerStatus.playing;

        return Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: const BoxDecoration(
            color: kContentBackgroundColor,
            border: Border(top: BorderSide(color: kBorderColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Info Lagu
              // --- PERBAIKAN: Ganti Expanded -> Flexible ---
              Flexible(
                flex: 1, // Bagian ini bisa mengecil
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
                          Text(track?.name ?? 'Belum ada lagu', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(track?.artistName ?? '-', style: const TextStyle(color: kMutedTextColor, fontSize: 12), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(icon: Icon(Icons.favorite_border, color: kMutedTextColor, size: 20), onPressed: () {}),
                  ],
                ),
              ),
              // -------------------------------------------
              // Kontrol Player
              Expanded( // Bagian tengah tetap Expanded agar mengambil sisa ruang
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         IconButton(icon: Icon(Icons.shuffle, color: kMutedTextColor, size: 20), onPressed: () {}),
                         IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28), onPressed: track != null ? () { if(mounted) context.read<PlayerCubit>().previous(); } : null),
                         InkWell(
                           onTap: track != null ? () { if(mounted) context.read<PlayerCubit>().togglePlayPause(); } : null,
                           customBorder: const CircleBorder(),
                           child: Container(
                            width: 40, height: 40, margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 28),
                           ),
                         ),
                         IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 28), onPressed: track != null ? () { if(mounted) context.read<PlayerCubit>().next(); } : null),
                         IconButton(icon: Icon(Icons.repeat, color: kMutedTextColor, size: 20), onPressed: () {}),
                       ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_formatDuration(_isDraggingSlider ? _currentPosition : state.currentPosition), style: const TextStyle(color: kMutedTextColor, fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(trackHeight: 4.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0), overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0), activeTrackColor: Colors.white, inactiveTrackColor: kBorderColor, thumbColor: Colors.white, overlayColor: Colors.white.withOpacity(0.2)),
                            child: Slider(
                              value: _sliderValue.clamp(0.0, 1.0), min: 0.0, max: 1.0,
                              onChanged: track != null && totalDuration.inMilliseconds > 0 ? (value) { if(mounted) setState(() { _isDraggingSlider = true; _sliderValue = value; _currentPosition = Duration(milliseconds: (value * totalDuration.inMilliseconds).round()); }); } : null,
                              onChangeEnd: track != null && totalDuration.inMilliseconds > 0 ? (value) { final seekPosition = Duration(milliseconds: (value * totalDuration.inMilliseconds).round()); if(mounted) context.read<PlayerCubit>().seek(seekPosition); Future.delayed(const Duration(milliseconds: 200), () { if (mounted) { setState(() { _isDraggingSlider = false; }); } }); } : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_formatDuration(totalDuration), style: const TextStyle(color: kMutedTextColor, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              // Kontrol Ekstra
              // --- PERBAIKAN: Ganti Expanded -> Flexible ---
              Flexible(
                flex: 1, // Bagian ini bisa mengecil
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     IconButton(icon: Icon(Icons.mic, color: kMutedTextColor, size: 20), onPressed: () {}),
                     IconButton(icon: Icon(Icons.queue_music, color: kMutedTextColor, size: 20), onPressed: () {}),
                    Icon(Icons.volume_up, color: kMutedTextColor, size: 20),
                    // Gunakan Expanded di dalam Flexible Row agar slider mengambil sisa ruang
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(trackHeight: 4.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0), overlayShape: const RoundSliderOverlayShape(overlayRadius: 0), activeTrackColor: Colors.white, inactiveTrackColor: kBorderColor, thumbColor: Colors.white), 
                        child: Slider(
                          value: 0.75, min: 0.0, max: 1.0, 
                          onChanged: (value) { /* TODO: Implement Volume */ }
                        )
                      ),
                    ),
                  ],
                ),
              ),
              // -------------------------------------------
            ],
          ),
        );
      },
    );
   }

   String _formatDuration(Duration duration) {
     if (duration == Duration.zero) return '-:--';
     String twoDigits(int n) => n.toString().padLeft(2, '0');
     final minutes = twoDigits(duration.inMinutes.remainder(60));
     final seconds = twoDigits(duration.inSeconds.remainder(60));
     return "$minutes:$seconds";
   }
 }

