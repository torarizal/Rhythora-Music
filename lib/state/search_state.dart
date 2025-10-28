// import 'package:equatable/equatable.dart';
// import '../models/track_model.dart'; // Sesuaikan path jika perlu

// // Kelas dasar abstrak untuk semua state pencarian
// abstract class SearchState extends Equatable {
//   const SearchState();

//   @override
//   List<Object> get props => [];
// }

// /// 1. KONDISI AWAL
// /// State saat layar baru dibuka, sebelum ada aksi pencarian.
// class SearchInitial extends SearchState {}

// /// 2. KONDISI LOADING
// /// State saat aplikasi sedang memanggil API pencarian.
// /// UI akan menampilkan loading indicator.
// class SearchLoading extends SearchState {}

// /// 3. KONDISI SUKSES (DATA DIDAPAT)
// /// State saat API berhasil dan mengembalikan data lagu.
// class SearchLoaded extends SearchState {
//   final List<Track> tracks;

//   // State ini 'membawa' data hasil pencarian
//   const SearchLoaded(this.tracks);

//   @override
//   List<Object> get props => [tracks];
// }

// /// 4. KONDISI GAGAL
// /// State saat terjadi error (API gagal, tidak ada internet, dll).
// class SearchError extends SearchState {
//   final String message;

//   // State ini 'membawa' pesan error untuk ditampilkan ke user
//   const SearchError(this.message);

//   @override
//   List<Object> get props => [message];
// }
