import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/track_model.dart';
import '../state/player_cubit.dart';
import '../state/player_state.dart';
// Import warna kustom Anda dari home_screen atau main.dart
import 'home_screen.dart'; // atau import '../main.dart'

class TrackDetailScreen extends StatelessWidget {
  final Track track;

  const TrackDetailScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    // Helper untuk format durasi
    String formatDuration(int? milliseconds) {
      if (milliseconds == null || milliseconds <= 0) return '-:--';
      final duration = Duration(milliseconds: milliseconds);
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return "$minutes:$seconds";
    }

    return Scaffold(
      backgroundColor: kContentBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparan
        elevation: 0, // Hilangkan bayangan
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          track.albumName ?? 'Detail Lagu',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gambar Album Besar
            Hero( // Animasi transisi yang bagus
              tag: 'track_image_${track.id}', // Tag unik untuk animasi
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  track.albumImageUrl ?? 'https://via.placeholder.com/400/3f3f46/71717a?text=?',
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width - 48, // Buat gambar jadi kotak
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width - 48,
                        color: kBorderColor,
                        child: const Icon(Icons.music_note, size: 100, color: kMutedTextColor),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // Judul Lagu
            Text(
              track.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            // Nama Artis
            Text(
              track.artistName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kMutedTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48.0),

            // --- Kontrol Pemutaran ---
            // Kita gunakan BlocBuilder untuk mengubah ikon Play/Pause
            BlocBuilder<PlayerCubit, PlayerState>(
              builder: (context, state) {
                // Cek apakah lagu ini adalah lagu yang sedang aktif di player
                final bool isCurrentlyPlayingThisTrack = 
                    state.currentTrack?.id == track.id && 
                    state.status == PlayerStatus.playing;

                return Column(
                  children: [
                    // Slider (Gunakan slider kustom dari home_screen jika Anda mau)
                    // TODO: Anda bisa buat slider ini interaktif seperti di _MusicPlayerBar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // Tampilkan posisi saat ini jika ini lagu yang aktif
                          isCurrentlyPlayingThisTrack ? _formatDuration(state.currentPosition) : '0:00',
                          style: const TextStyle(color: kMutedTextColor, fontSize: 12),
                        ),
                        Text(
                          formatDuration(track.durationMs),
                          style: const TextStyle(color: kMutedTextColor, fontSize: 12),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: kBorderColor,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: (isCurrentlyPlayingThisTrack && state.totalDuration.inMilliseconds > 0)
                            ? (state.currentPosition.inMilliseconds / state.totalDuration.inMilliseconds).clamp(0.0, 1.0)
                            : 0.0,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          // Panggil seek jika ini adalah lagu yang aktif
                          if (state.currentTrack?.id == track.id) {
                            final seekPosition = Duration(milliseconds: (value * (track.durationMs ?? 0)).round());
                            context.read<PlayerCubit>().seek(seekPosition);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Tombol Kontrol
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tombol Previous
                        IconButton(
                          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                          onPressed: () => context.read<PlayerCubit>().previous(),
                        ),
                        const SizedBox(width: 24),
                        // Tombol Play/Pause Utama
                        InkWell(
                          onTap: () {
                            // Panggil togglePlayPause jika ini lagu yang aktif,
                            // atau panggil play(track) jika ini lagu yang berbeda
                            if (state.currentTrack?.id == track.id) {
                              context.read<PlayerCubit>().togglePlayPause();
                            } else {
                              context.read<PlayerCubit>().play(track);
                            }
                          },
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCurrentlyPlayingThisTrack ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Tombol Next
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                          onPressed: () => context.read<PlayerCubit>().next(),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper duplikat dari _MusicPlayerBarState
  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '0:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
