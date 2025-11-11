import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String? owner;
  final String? imageUrl;

  const Playlist({
    required this.id,
    required this.name,
    this.owner,
    this.imageUrl,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      owner: json['owner'] != null ? json['owner']['display_name'] : 'Unknown',
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['url']
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, owner, imageUrl];
}
