import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final String id;
  final String name;
  final String artistName;
  final String? albumImageUrl;
  final String? previewUrl; // Untuk mode Guest!
  final int? durationMs; // Durasi dalam milidetik
  // --- TAMBAHAN BARU ---
  final String? albumName; // Nama album
  // --------------------

  const Track({
    required this.id,
    required this.name,
    required this.artistName,
    this.albumImageUrl,
    this.previewUrl,
    this.durationMs,
    this.albumName, // Tambahkan di constructor
  });

  // Factory constructor dari data API Spotify
  factory Track.fromJson(Map<String, dynamic> json) {
    // Ambil gambar (pilih yang resolusi tengah)
    String? imageUrl;
    String? currentAlbumName; // Variabel sementara untuk nama album
    if (json['album'] != null) {
       // Ambil nama album
       currentAlbumName = json['album']['name'];
       // Ambil gambar album
      if ((json['album']['images'] as List).isNotEmpty) {
         // Coba ambil gambar indeks 1 (medium), fallback ke 0 (large) jika hanya ada 1
         int imageIndex = (json['album']['images'] as List).length > 1 ? 1 : 0;
         imageUrl = json['album']['images'][imageIndex]['url'];
      }
    }


    // Ambil nama artis (gabungkan jika lebih dari satu)
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
      albumName: currentAlbumName, // Masukkan nama album
    );
  }

  @override
  List<Object?> get props => [id, name, artistName, albumImageUrl, previewUrl, durationMs, albumName]; // Tambahkan albumName ke props
}

