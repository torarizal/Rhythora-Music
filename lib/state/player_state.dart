// import 'package:equatable/equatable.dart';
// import '../models/track_model.dart'; // Sesuaikan path jika perlu

// // Enum untuk status pemutar yang lebih rapi
// enum PlayerStatus {
//   initial, // Belum ada lagu
//   loading, // Sedang memuat lagu baru
//   playing, // Sedang memutar
//   paused, // Dijeda
//   stopped, // Dihentikan
//   error // Terjadi error
// }

// /// Tidak seperti SearchState, untuk Player lebih efisien menggunakan SATU kelas state
// /// dan 'copyWith' untuk meng-update bagian tertentu (misal: hanya durasinya).
// class PlayerState extends Equatable {
//   final PlayerStatus status;
//   final Track? currentTrack; // Lagu yang sedang aktif
//   final Duration currentPosition; // Posisi durasi saat ini
//   final Duration totalDuration; // Total durasi lagu
//   final String errorMessage;

//   const PlayerState({
//     this.status = PlayerStatus.initial,
//     this.currentTrack,
//     this.currentPosition = Duration.zero,
//     this.totalDuration = Duration.zero,
//     this.errorMessage = '',
//   });

//   // Helper 'copyWith' untuk mempermudah update state
//   // Misalnya: kita hanya ingin update 'status' tapi 'currentTrack' tetap sama
//   PlayerState copyWith({
//     PlayerStatus? status,
//     Track? currentTrack, // Gunakan 'ValueGetter' jika ingin meng-set null
//     Duration? currentPosition,
//     Duration? totalDuration,
//     String? errorMessage,
//   }) {
//     return PlayerState(
//       status: status ?? this.status,
//       currentTrack: currentTrack ?? this.currentTrack,
//       currentPosition: currentPosition ?? this.currentPosition,
//       totalDuration: totalDuration ?? this.totalDuration,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         status,
//         currentTrack,
//         currentPosition,
//         totalDuration,
//         errorMessage,
//       ];
// }
