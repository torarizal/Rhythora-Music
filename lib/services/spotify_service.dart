import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import storage
import '../models/track_model.dart';
import 'auth_service.dart'; // Masih perlu untuk cek status & refresh

class SpotifyService {
  final String _baseUrl = 'https://api.spotify.com/v1';
  final AuthService _authService; // Perlu untuk refresh token
  final _storage = const FlutterSecureStorage(); // Tambahkan storage

  // Inject AuthService
  SpotifyService(this._authService, FlutterSecureStorage read);

  // --- Helper internal untuk melakukan panggilan API ---
  Future<http.Response> _makeApiCall(
    Future<http.Response> Function(String token) apiRequest, {
    bool requiresToken = true, // Beberapa API (seperti guest) tidak butuh token user
  }) async {
    String? token;
    if (requiresToken) {
      // 1. Coba ambil token dari storage
      token = await _storage.read(key: 'spotify_access_token');
      if (token == null) {
        throw Exception('Not authenticated'); // Seharusnya tidak terjadi jika alur benar
      }
    }

    // 2. Coba lakukan panggilan API dengan token saat ini (atau tanpa token jika tidak perlu)
    http.Response response = await apiRequest(token ?? ''); // Kirim token atau string kosong

    // 3. Jika token expired (401) dan memang memerlukan token, coba refresh dan ulangi
    if (response.statusCode == 401 && requiresToken && token != null) {
      try {
        final newToken = await _authService.refreshToken();
        // Ulangi panggilan API dengan token baru
        response = await apiRequest(newToken);
      } catch (e) {
        // Jika refresh gagal, lempar error asli (401) atau error refresh
        throw Exception('Session expired or refresh failed: ${e.toString()}');
      }
    }

    // Kembalikan response (baik yang sukses pertama atau setelah refresh)
    return response;
  }

  /// Mencari lagu di Spotify
  Future<List<Track>> searchTracks(String query) async {
    // Pastikan query di-encode agar aman untuk URL
    final encodedQuery = Uri.encodeComponent(query);

    final response = await _makeApiCall((token) {
      return http.get(
        Uri.parse('$_baseUrl/search?q=$encodedQuery&type=track&limit=20'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Validasi struktur data sebelum parsing
      if (data['tracks'] != null && data['tracks']['items'] != null) {
        final List trackList = data['tracks']['items'];
        return trackList
            .map((json) {
              try {
                return Track.fromJson(json);
              } catch (e) {
                print("Error parsing track: $e");
                print("Track JSON: $json");
                return null; // Skip track yang error parsing
              }
            })
            .where((track) => track != null) // Hapus track yang null (error parsing)
            .cast<Track>() // Pastikan tipenya benar
            .toList();
      } else {
        return []; // Kembalikan list kosong jika data tidak sesuai format
      }
    } else {
      // Tangani error lain (selain 401 yang sudah diatasi _makeApiCall)
      throw Exception('Failed to search tracks. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // --- Tambahkan fungsi lain di sini ---
  // Contoh: Future<List<Playlist>> getUserPlaylists() async { ... }
  // Contoh: Future<Album> getAlbumDetails(String albumId) async { ... }
}

