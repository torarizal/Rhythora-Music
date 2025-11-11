import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rhythora/state/playlist_cubit.dart';
import 'package:rhythora/state/playlist_state.dart';
import 'package:rhythora/widgets/loading_skeletons.dart';

// --- WARNA KONSISTEN ---
const Color kContentBackgroundColor = Color(0xFF18181B);
const Color kCardHoverColor = Color(0xFF27272A);
const Color kBorderColor = Color(0xFF3F3F46);
const Color kMutedTextColor = Color(0xFFA1A1AA);
// -------------------------

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Panggil cubit untuk mengambil data playlist saat halaman ini dibuka
    context.read<PlaylistCubit>().fetchUserPlaylists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kContentBackgroundColor,
      appBar: AppBar(
        title: const Text('Koleksi Kamu'),
        backgroundColor: kContentBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: kMutedTextColor,
          tabs: const [
            Tab(text: 'Playlist'),
            Tab(text: 'Artis'),
            Tab(text: 'Album'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlaylistsGrid(),
          _buildPlaceholder('Artis yang Anda ikuti akan muncul di sini.'),
          _buildPlaceholder('Album yang Anda simpan akan muncul di sini.'),
        ],
      ),
    );
  }

  Widget _buildPlaylistsGrid() {
    // Menggunakan kembali logika dari home_screen sebelumnya
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        if (state is PlaylistLoading || state is PlaylistInitial) {
          // Gunakan skeleton loading yang sesuai untuk grid
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: LibraryLoadingSkeleton(), // Asumsi ini adalah skeleton grid
          );
        }
        if (state is PlaylistError) {
          return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)));
        }
        if (state is PlaylistLoaded) {
          if (state.playlists.isEmpty) {
            return _buildPlaceholder('Anda belum memiliki playlist.');
          }
          return GridView.builder(
            padding: const EdgeInsets.all(24.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220.0,
              mainAxisSpacing: 24.0,
              crossAxisSpacing: 24.0,
              childAspectRatio: 0.8,
            ),
            itemCount: state.playlists.length,
            itemBuilder: (context, index) {
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
                        image: playlist.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(playlist.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: playlist.imageUrl == null
                          ? const Center(
                              child: Icon(Icons.music_note,
                                  size: 40, color: kMutedTextColor))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    playlist.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Playlist • ${playlist.ownerName}',
                    style:
                        const TextStyle(color: kMutedTextColor, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: kMutedTextColor, fontSize: 16),
        ),
      ),
    );
  }
}
