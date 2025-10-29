import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/player_service.dart'; // Import service Anda
import 'player_state.dart'; // Import state Anda
import '../models/track_model.dart'; // Import model lagu

class PlayerCubit extends Cubit<PlayerState> {
  final PlayerService _playerService;
  late StreamSubscription<PlayerState> _playerStateSubscription;

  PlayerCubit(this._playerService) : super(const PlayerState()) { // State awal adalah initial
    // Mulai mendengarkan perubahan state dari PlayerService
    _playerStateSubscription = _playerService.playerStateStream.listen(
      (playerState) {
        emit(playerState); // Teruskan state ke UI
      },
      onError: (error) {
        // Tangani error dari stream service jika perlu
        print("Error pada stream PlayerService: $error");
        emit(PlayerState(status: PlayerStatus.error, errorMessage: error.toString()));
      },
    );
  }

  // --- Fungsi yang dipanggil oleh UI ---

  /// Memulai pemutaran lagu baru
  Future<void> play(Track track) async {
    // Bisa tambahkan state loading di sini jika play butuh waktu
    // emit(state.copyWith(status: PlayerStatus.loading, currentTrack: track));
    try {
      await _playerService.play(track);
      // State playing/error akan di-emit oleh listener di atas
    } catch (e) {
       emit(PlayerState(status: PlayerStatus.error, currentTrack: track, errorMessage: e.toString()));
    }
  }

  /// Menjeda pemutaran
  Future<void> pause() async {
    await _playerService.pause();
  }

  /// Melanjutkan pemutaran
  Future<void> resume() async {
    await _playerService.resume();
  }

  /// Menggabungkan pause dan resume
  Future<void> togglePlayPause() async {
    if (state.status == PlayerStatus.playing) {
      await pause();
    } else if (state.status == PlayerStatus.paused) {
      await resume();
    } else if (state.currentTrack != null) {
      // Jika status initial/stop tapi ada track, coba play lagi
      await play(state.currentTrack!);
    }
  }

  /// Pindah ke posisi tertentu dalam lagu
  void seek(Duration position) {
    _playerService.seek(position);
  }

  /// Menghentikan pemutaran
  Future<void> stop() async {
    await _playerService.stop();
  }

  /// Pindah ke lagu selanjutnya (Logika playlist belum ada)
  Future<void> next() async {
    // TODO: Implementasikan logika untuk mengambil lagu selanjutnya dari playlist
    print("Fungsi 'next' belum diimplementasikan");
    // Contoh: Jika ada list lagu
    // final currentIndex = playlist.indexOf(state.currentTrack);
    // if (currentIndex != -1 && currentIndex < playlist.length - 1) {
    //   await play(playlist[currentIndex + 1]);
    // }
  }

  /// Pindah ke lagu sebelumnya (Logika playlist belum ada)
  Future<void> previous() async {
    // TODO: Implementasikan logika untuk mengambil lagu sebelumnya dari playlist
    print("Fungsi 'previous' belum diimplementasikan");
    // Contoh: Jika ada list lagu
    // final currentIndex = playlist.indexOf(state.currentTrack);
    // if (currentIndex > 0) {
    //   await play(playlist[currentIndex - 1]);
    // } else if (state.currentPosition > Duration(seconds: 3)) {
    //    seek(Duration.zero); // Kembali ke awal jika di awal lagu
    // }
  }


  // --- Cleanup ---

  @override
  Future<void> close() {
    _playerStateSubscription.cancel(); // Hentikan listener saat Cubit ditutup
    // _playerService.dispose(); // Hati-hati, service mungkin dipakai Cubit lain
    return super.close();
  }
}

