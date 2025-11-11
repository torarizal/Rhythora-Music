import 'package:rhythora/models/media_item.dart';

/// Model untuk seorang artis, merupakan turunan dari [MediaItem].
///
/// Menerapkan [Inheritance] dengan `extends MediaItem`.
class Artist extends MediaItem {
  final List<String> _genres;
  final String? _imageUrl;
  final int _popularity;

  const Artist({
    required super.id,
    required super.name,
    required List<String> genres,
    String? imageUrl,
    required int popularity,
  })  : _genres = genres,
        _imageUrl = imageUrl,
        _popularity = popularity;

  // --- Getters untuk Enkapsulasi ---
  List<String> get genres => _genres;
  String? get imageUrl => _imageUrl;
  int get popularity => _popularity;

  factory Artist.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if ((json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['url'];
    }

    return Artist(
      id: json['id'],
      name: json['name'],
      genres: List<String>.from(json['genres'] ?? []),
      imageUrl: imageUrl,
      popularity: json['popularity'] ?? 0,
    );
  }

  /// Implementasi metode dari [MediaItem] untuk [Polymorphism].
  @override
  String displayDetails() {
    return 'Artist: $name - Genres: ${genres.join(', ')}';
  }

  @override
  List<Object?> get props => [...super.props, genres, imageUrl, popularity];
}
