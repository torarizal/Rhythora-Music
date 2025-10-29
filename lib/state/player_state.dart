import 'package:equatable/equatable.dart';
import '../models/track_model.dart'; // Pastikan path ini benar

// Enum untuk status pemutar
enum PlayerStatus {
  initial, // Keadaan awal, belum ada lagu
  loading, // Sedang memuat lagu (opsional, tapi bagus untuk UX)
  playing, // Sedang memutar
  paused,  // Dijeda
  stopped, // Dihentikan (tidak sama dengan initial) -> Bisa dihapus jika tidak perlu
  error    // Terjadi kesalahan
}

// Class state utama
class PlayerState extends Equatable {
  final PlayerStatus status;
  final Track? currentTrack; // Lagu yang sedang/terakhir diputar (bisa null)
  final Duration currentPosition; // Posisi saat ini
  final Duration totalDuration;   // Total durasi lagu
  final String? errorMessage;   // Pesan error jika status == PlayerStatus.error

  // Constructor dengan nilai default
  const PlayerState({
    this.status = PlayerStatus.initial,
    this.currentTrack,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.errorMessage,
  });

  // Fungsi helper 'copyWith' untuk memudahkan update state
  // Ini membuat state baru berdasarkan state lama, hanya mengubah properti yang diberikan
  PlayerState copyWith({
    PlayerStatus? status,
    Track? currentTrack, // Gunakan ValueGetter agar bisa di-set null secara eksplisit
    Duration? currentPosition,
    Duration? totalDuration,
    String? errorMessage,
    bool forceNullTrack = false, // Flag untuk memaksa track jadi null
  }) {
    return PlayerState(
      status: status ?? this.status,
      // Jika forceNullTrack true, set track jadi null.
      // Jika tidak, gunakan track baru jika ada, atau track lama jika tidak.
      currentTrack: forceNullTrack ? null : currentTrack ?? this.currentTrack,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      // Jika status bukan error, hapus pesan error lama
      errorMessage: status == PlayerStatus.error ? (errorMessage ?? this.errorMessage) : null,
    );
  }


  // Properti yang digunakan oleh Equatable untuk membandingkan state
  @override
  List<Object?> get props => [
        status,
        currentTrack,
        currentPosition,
        totalDuration,
        errorMessage,
      ];
}

