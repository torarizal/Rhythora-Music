import 'package:rhythora/models/media_item.dart';

/// Model untuk sebuah playlist, merupakan turunan dari [MediaItem].
///
/// Menerapkan [Inheritance] dengan `extends MediaItem`.
class Playlist extends MediaItem {
  final String? _description;
  final String? _imageUrl;
  final String _ownerName;

  const Playlist({
    required super.id,
    required super.name,
    String? description,
    String? imageUrl,
    required String ownerName,
  })  : _description = description,
        _imageUrl = imageUrl,
        _ownerName = ownerName;

  // --- Getters untuk Enkapsulasi ---
  String? get description => _description;
  String? get imageUrl => _imageUrl;
  String get ownerName => _ownerName;

  factory Playlist.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if ((json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['url'];
    }

    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: imageUrl,
      ownerName: json['owner']['display_name'] ?? 'Unknown',
    );
  }

  /// Implementasi metode dari [MediaItem] untuk [Polymorphism].
  @override
  String displayDetails() {
    return 'Playlist: $name - By: $ownerName';
  }

  @override
  List<Object?> get props => [...super.props, description, imageUrl, ownerName];
}
