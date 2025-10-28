// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../services/spotify_service.dart'; // Sesuaikan path jika perlu
// import 'search_state.dart';

// /// Cubit ini bertindak sebagai jembatan antara UI (layar)
// /// dan Service (logika API).
// class SearchCubit extends Cubit<SearchState> {
//   // 1. Butuh 'SpotifyService' untuk melakukan panggilan API
//   final SpotifyService _spotifyService;

//   // 2. Tentukan state awalnya, yaitu 'SearchInitial'
//   SearchCubit(this._spotifyService) : super(SearchInitial());

//   /// 3. Fungsi publik yang akan dipanggil oleh UI
//   Future<void> searchTracks(String query) async {
//     // Jika query kosong, kembalikan ke state awal (menampilkan 'silakan cari')
//     if (query.isEmpty) {
//       emit(SearchInitial());
//       return;
//     }

//     // 4. Beri tahu UI bahwa kita sedang loading
//     emit(SearchLoading());

//     try {
//       // 5. Panggil API melalui service
//       // (Di sinilah 'SpotifyService' bekerja)
//       final tracks = await _spotifyService.searchTracks(query);

//       // 6. Jika berhasil, kirim data (list of tracks) ke UI
//       // UI akan otomatis rebuild berkat BlocBuilder
//       if (tracks.isEmpty) {
//         emit(const SearchError("Lagu tidak ditemukan."));
//       } else {
//         emit(SearchLoaded(tracks));
//       }
//     } catch (e) {
//       // 7. Jika gagal (misal: token expired, internet mati), kirim pesan error
//       emit(SearchError(e.toString()));
//     }
//   }
// }
