import 'package:rhythora/models/media_item.dart';

/// Model untuk sebuah lagu (Track), merupakan turunan dari [MediaItem].
///
/// Menerapkan [Inheritance] dengan `extends MediaItem`.
/// Menerapkan [Encapsulation] pada properti spesifiknya.
class Track extends MediaItem {
  final String _artistName;
  final String? _albumImageUrl;
  final String? _previewUrl;
  final int? _durationMs;
  final String? _albumName;

  const Track({
    required super.id,
    required super.name,
    required String artistName,
    String? albumImageUrl,
    String? previewUrl,
    int? durationMs,
    String? albumName,
  })  : _artistName = artistName,
        _albumImageUrl = albumImageUrl,
        _previewUrl = previewUrl,
        _durationMs = durationMs,
        _albumName = albumName;

  // --- Getters untuk Enkapsulasi ---
  String get artistName => _artistName;
  String? get albumImageUrl => _albumImageUrl;
  String? get previewUrl => _previewUrl;
  int? get durationMs => _durationMs;
  String? get albumName => _albumName;

  // Factory constructor dari data API Spotify
  factory Track.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    String? currentAlbumName;
    if (json['album'] != null) {
      currentAlbumName = json['album']['name'];
      if ((json['album']['images'] as List).isNotEmpty) {
        int imageIndex = (json['album']['images'] as List).length > 1 ? 1 : 0;
        imageUrl = json['album']['images'][imageIndex]['url'];
      }
    }

    String artists = (json['artists'] as List)
        .map((artist) => artist['name'])
        .join(', ');

    return Track(
      id: json['id'],
      name: json['name'],
      artistName: artists,
      albumImageUrl: imageUrl,
      previewUrl: json['preview_url'],
      durationMs: json['duration_ms'],
      albumName: currentAlbumName,
    );
  }

  /// Implementasi metode dari [MediaItem] untuk [Polymorphism].
  @override
  String displayDetails() {
    return 'Track: $name - Artist: $artistName';
  }

  @override
  List<Object?> get props => [
        ...super.props, // Mengambil props dari MediaItem (id, name)
        artistName,
        albumImageUrl,
        previewUrl,
        durationMs,
        albumName,
      ];
}