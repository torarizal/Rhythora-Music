import 'dart:async';
// Sembunyikan 'PlayerState' dari just_audio agar tidak bentrok
import 'package:just_audio/just_audio.dart' hide PlayerState; 
import 'package:spotify_sdk/spotify_sdk.dart';
import '../models/track_model.dart';
import 'auth_service.dart';
import '../state/player_state.dart'; // Import state Anda

/// Service ini adalah 'Abstraction Layer'
/// Cubit tidak peduli apakah yang memutar SDK atau just_audio,
/// yang penting Cubit memanggil 'play()' di service ini.
class PlayerService {
  final AuthService _authService;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Untuk Guest

  // Variabel untuk menyimpan state terakhir dengan efisien
  PlayerState _currentState = const PlayerState();

  PlayerService(this._authService) {
    // Dengarkan stream internal untuk meng-update _currentState
    _playerStateController.stream.listen((newState) {
      _currentState = newState;
    });

    // Dengarkan stream posisi dari just_audio (untuk Guest)
    _audioPlayer.positionStream.listen((position) {
      if (!_authService.isPremium) { // Hanya update posisi jika Guest
        _positionController.add(position);
        // Update state juga agar UI konsisten
         _playerStateController.add(_currentState.copyWith(currentPosition: position));
      }
    });

    // Dengarkan event selesai dari just_audio (untuk Guest)
    _audioPlayer.playerStateStream.listen((state) {
       if (!_authService.isPremium && state.processingState == ProcessingState.completed) {
         // Reset state saat preview selesai
         _playerStateController.add(const PlayerState());
       }
    });
  }

  // Stream yang akan didengarkan oleh PlayerCubit
  final StreamController<PlayerState> _playerStateController =
      StreamController.broadcast();
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;

  // Stream terpisah untuk posisi (opsional, bisa digabung ke PlayerState)
  final StreamController<Duration> _positionController =
      StreamController.broadcast();
  Stream<Duration> get positionStream => _positionController.stream;

  // Getter untuk status premium (digunakan secara internal)
  bool _isPremiumUser() => _authService.isPremium;

  Future<void> play(Track track) async {
    // Hentikan pemutaran sebelumnya (jika ada)
    await stop(); 

    if (_isPremiumUser()) {
      // --- LOGIKA PREMIUM (Gunakan SDK) ---
      try {
        await SpotifySdk.play(spotifyUri: "spotify:track:${track.id}");

        _playerStateController.add(PlayerState(
            status: PlayerStatus.playing,
            currentTrack: track,
            totalDuration: track.durationMs != null
                ? Duration(milliseconds: track.durationMs!)
                : Duration.zero));
        
        // TODO: Implementasikan listener posisi untuk Spotify SDK
        // SpotifySdk.subscribePlayerState().listen((playerState) {
        //   _positionController.add(Duration(milliseconds: playerState.playbackPosition));
        //   // Update state juga
        //  _playerStateController.add(_currentState.copyWith(currentPosition: Duration(milliseconds: playerState.playbackPosition)));
        // });

      } catch (e) {
         _playerStateController.add(const PlayerState(status: PlayerStatus.error, errorMessage: "Gagal memulai pemutaran Spotify."));
         print("Spotify SDK Play Error: $e");
      }

    } else {
      // --- LOGIKA GUEST (Gunakan just_audio) ---
      if (track.previewUrl == null) {
        _playerStateController.add(const PlayerState(status: PlayerStatus.error, errorMessage: "Lagu ini tidak memiliki preview."));
        return; // Keluar jika tidak ada preview
      }

      try {
        await _audioPlayer.setUrl(track.previewUrl!);
        final totalDuration =
            await _audioPlayer.load(); // Muat dan dapatkan durasi

        _playerStateController.add(PlayerState(
            status: PlayerStatus.playing,
            currentTrack: track,
            totalDuration: totalDuration ?? Duration.zero));

        _audioPlayer.play();
        // Listener posisi sudah diatur di constructor

      } catch (e) {
         _playerStateController.add(const PlayerState(status: PlayerStatus.error, errorMessage: "Gagal memuat audio preview."));
         print("Just Audio Play Error: $e");
      }
    }
  }

  Future<void> pause() async {
    if (_currentState.status != PlayerStatus.playing) return; // Jangan pause jika tidak playing

    try {
      if (_isPremiumUser()) {
        await SpotifySdk.pause();
      } else {
        await _audioPlayer.pause();
      }
      _playerStateController.add(_currentState.copyWith(
        status: PlayerStatus.paused,
      ));
    } catch (e) {
       _playerStateController.add(_currentState.copyWith(
         status: PlayerStatus.error, 
         errorMessage: "Gagal menjeda."
       ));
       print("Pause Error: $e");
    }
  }

  Future<void> resume() async {
    // Hanya resume jika sedang paused dan ada lagu
    if (_currentState.status != PlayerStatus.paused || _currentState.currentTrack == null) return; 

    try {
      if (_isPremiumUser()) {
        await SpotifySdk.resume();
      } else {
        await _audioPlayer.play();
      }
      _playerStateController.add(_currentState.copyWith(
        status: PlayerStatus.playing,
      ));
    } catch (e) {
      _playerStateController.add(_currentState.copyWith(
         status: PlayerStatus.error, 
         errorMessage: "Gagal melanjutkan."
       ));
       print("Resume Error: $e");
    }
  }

  void seek(Duration position) {
     if (_currentState.currentTrack == null) return; // Jangan seek jika tidak ada lagu

    try {
      if (_isPremiumUser()) {
        SpotifySdk.seekTo(positionedMilliseconds: position.inMilliseconds);
      } else {
        _audioPlayer.seek(position);
      }
      // Update state posisi secara manual saat seek
      _positionController.add(position);
      _playerStateController.add(_currentState.copyWith(currentPosition: position));
    } catch (e) {
       // Mungkin tidak perlu emit error state saat seek gagal?
       print("Seek Error: $e");
    }
  }

  Future<void> stop() async {
    try {
      if (_isPremiumUser()) {
        // SDK tidak punya 'stop', kita 'pause' dan 'seekToZero' jika ada lagu
        if (_currentState.currentTrack != null) {
          await SpotifySdk.pause();
          await SpotifySdk.seekTo(positionedMilliseconds: 0);
        }
      } else {
        await _audioPlayer.stop(); // just_audio punya stop
      }
      _playerStateController.add(const PlayerState()); // Reset ke state awal (idle)
      _positionController.add(Duration.zero); // Reset posisi
    } catch (e) {
       _playerStateController.add(const PlayerState(status: PlayerStatus.error, errorMessage: "Gagal menghentikan."));
       print("Stop Error: $e");
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _playerStateController.close();
    _positionController.close();
  }
}

