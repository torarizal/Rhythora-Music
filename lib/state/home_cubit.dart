import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/spotify_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final SpotifyService _spotifyService;

  HomeCubit(this._spotifyService) : super(HomeInitial());

  Future<void> fetchHomeData() async {
    try {
      emit(HomeLoading());
      final trending = await _spotifyService.searchTracks('trending songs indonesia');
      final recommendations = await _spotifyService.searchTracks('new releases indonesia');
      emit(HomeLoaded(
        trendingTracks: trending.take(5).toList(),
        recommendedTracks: recommendations,
      ));
    } catch (e) {
      emit(HomeError('Gagal memuat data: $e'));
    }
  }
}
