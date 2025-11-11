import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/spotify_service.dart';
import 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  final SpotifyService _spotifyService;

  PlaylistCubit(this._spotifyService) : super(PlaylistInitial());

  Future<void> fetchUserPlaylists() async {
    try {
      emit(PlaylistLoading());
      final playlists = await _spotifyService.getUserPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError('Gagal memuat playlist: $e'));
    }
  }
}
