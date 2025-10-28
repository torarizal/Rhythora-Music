// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../models/track_model.dart';
// import '../services/player_service.dart'; 
// import 'player_state.dart';

// /// Cubit ini mengelola state pemutar musik di seluruh aplikasi.
// /// (Misalnya untuk 'mini_player' di bagian bawah layar).
// class PlayerCubit extends Cubit<PlayerState> {
//   final PlayerService _playerService;
//   StreamSubscription? _playerStateSubscription;
//   StreamSubscription? _positionSubscription;

//   PlayerCubit(this._playerService) : super(const PlayerState()) {
//     // Langsung dengarkan perubahan dari 'player_service'
//     _listenToPlayerChanges();
//   }

//   /// Memutar lagu baru
//   Future<void> play(Track track) async {
//     try {
//       // Beri tahu UI bahwa lagu sedang di-load
//       emit(state.copyWith(status: PlayerStatus.loading, currentTrack: track));
      
//       // (Asumsi mode Guest): Jika lagu tidak punya preview_url
//       if (track.previewUrl == null && !_playerService.isPremiumUser()) {
//          throw Exception("Lagu ini butuh Premium (tidak ada preview).");
//       }

//       await _playerService.play(track);
      
//       // 'player_service' akan meng-update status via Stream
//       // tapi kita bisa set 'playing' di sini untuk respon lebih cepat
//       emit(state.copyWith(status: PlayerStatus.playing));

//     } catch (e) {
//       emit(state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()));
//     }
//   }

//   /// Menjeda lagu
//   Future<void> pause() async {
//     await _playerService.pause();
//     emit(state.copyWith(status: PlayerStatus.paused));
//   }

//   /// Melanjutkan lagu
//   Future<void> resume() async {
//     await _playerService.resume();
//     emit(state.copyWith(status: PlayerStatus.playing));
//   }
  
//   /// Pindah durasi
//   void seek(Duration position) {
//     _playerService.seek(position);
//   }

//   /// Berhenti dan reset player
//   Future<void> stop() async {
//     await _playerService.stop();
//     emit(const PlayerState()); // Kembali ke state awal
//   }

//   /// Fungsi internal untuk mendengarkan perubahan dari service
//   void _listenToPlayerChanges() {
//     // Dengarkan perubahan status (play, pause, stop dari service)
//     _playerStateSubscription = _playerService.playerStateStream.listen((playerState) {
//       emit(playerState);
//     });

//     // Dengarkan perubahan durasi (progress bar)
//     _positionSubscription = _playerService.positionStream.listen((position) {
//       emit(state.copyWith(currentPosition: position));
//     });
//   }

//   // Jangan lupa tutup stream saat cubit ditutup!
//   @override
//   Future<void> close() {
//     _playerStateSubscription?.cancel();
//     _positionSubscription?.cancel();
//     return super.close();
//   }
// }
