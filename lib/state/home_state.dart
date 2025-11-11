import 'package:equatable/equatable.dart';
import '../models/track_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Track> trendingTracks;
  final List<Track> recommendedTracks;

  const HomeLoaded({required this.trendingTracks, required this.recommendedTracks});

  @override
  List<Object> get props => [trendingTracks, recommendedTracks];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
