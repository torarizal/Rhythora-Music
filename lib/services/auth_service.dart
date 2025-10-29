import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

// Enum untuk status autentikasi
enum AuthStatus {
  unknown,
  guest,
  premium,
  free,
}

class AuthService {
  // Ganti dengan Client ID Anda dari Spotify Dashboard
  static const String _clientId = "02418a8456574b5cb62c47abb34877c0"; // Pastikan ini benar
  // Ganti 'rhythora' jika Anda mengubahnya, tapi ini sudah benar
  static const String _redirectUrl = "rhythora://callback";

  // Ganti ini dengan URL Vercel Anda yang AKTIF
  static const String _backendUrl = "https://rhythora-backend-new.vercel.app/api"; 

  final _storage = const FlutterSecureStorage();

  // Variabel internal untuk menyimpan status
  AuthStatus _authStatus = AuthStatus.unknown;

  // Getter publik agar file lain (seperti PlayerService) bisa cek
  bool get isPremium => _authStatus == AuthStatus.premium;
  AuthStatus get currentStatus => _authStatus;

  // Menyimpan token
  Future<void> _saveTokens(String accessToken, String? refreshToken) async { // Ubah jadi String?
    await _storage.write(key: 'spotify_access_token', value: accessToken);
    // Hanya simpan refresh token jika tidak null atau kosong
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: 'spotify_refresh_token', value: refreshToken);
    } else {
      // Hapus refresh token jika null atau kosong (misal untuk Guest)
      await _storage.delete(key: 'spotify_refresh_token');
    }
  }

  // --- FUNGSI UTAMA UNTUK LOGIN CUBIT ---

  /// Mencoba login dengan Spotify SDK (Premium / Free User)
  Future<AuthStatus> loginWithSpotify() async {
    try {
      final accessToken = await SpotifySdk.getAccessToken(
        clientId: _clientId,
        redirectUrl: _redirectUrl,
        scope: "app-remote-control, user-read-playback-state, streaming, user-read-email, user-read-private",
      );

      // (PENTING) SDK tidak memberikan refresh token.
      // Anda HARUS mengimplementasikan 'Authorization Code Flow' via backend
      // untuk mendapatkan refresh token asli agar sesi bertahan lama.
      // Untuk SEKARANG, kita simpan access token saja dan refresh token palsu.
      await _saveTokens(accessToken, "DUMMY_REFRESH_TOKEN_SDK_PLEASE_REPLACE");
      // ------------------------------------

      // Cek tipe akun (Premium atau Free)
      final userType = await _getUserType(accessToken);
      _authStatus = (userType == 'premium') ? AuthStatus.premium : AuthStatus.free;

      debugPrint("Login Spotify Berhasil: $_authStatus");
      return _authStatus;

    } catch (e) {
      debugPrint("Gagal login Spotify SDK: $e");
      throw Exception("Gagal terhubung ke Spotify. Pastikan Spotify terinstal.");
    }
  }

  /// Mencoba login sebagai Guest (Memanggil Backend)
  Future<AuthStatus> loginAsGuest() async {
    try {
      final response = await http.get(
        Uri.parse("$_backendUrl/guest-token"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];

        // Gunakan fungsi helper (dengan refresh token kosong)
        await _saveTokens(accessToken, null); // Guest tidak punya refresh token
        _authStatus = AuthStatus.guest;

        debugPrint("Login Guest Berhasil");
        return _authStatus;
      } else {
        // Coba baca pesan error dari backend jika ada
        String serverError = response.body;
        try {
          final errorData = json.decode(response.body);
          serverError = errorData['error'] ?? response.body;
        } catch (_) {} // Abaikan jika body bukan JSON
        throw Exception("Gagal mendapatkan token tamu dari server: ${response.statusCode} - $serverError");
      }
    } catch (e) {
      debugPrint("Error loginAsGuest: $e");
      // Perjelas errornya
      if (e is http.ClientException) {
         throw Exception("Gagal terhubung ke server backend. Periksa koneksi internet dan URL backend.");
      }
      throw Exception("Terjadi kesalahan saat login sebagai tamu.");
    }
  }

  /// Memperbarui token yang expired (Memanggil Backend)
  Future<String> refreshToken() async {
    // --- PERBAIKAN: Ganti nama variabel lokal ---
    final storedRefreshToken = await _storage.read(key: 'spotify_refresh_token');
    // -------------------------------------------

    // Cek jika refresh token valid (bukan dummy dari SDK)
    if (storedRefreshToken == null || storedRefreshToken.isEmpty || storedRefreshToken == "DUMMY_REFRESH_TOKEN_SDK_PLEASE_REPLACE") {
    // --- Gunakan storedRefreshToken ---
      _authStatus = AuthStatus.unknown;
       await _storage.deleteAll(); // Hapus semua token jika refresh token tidak valid
      throw Exception("Sesi berakhir. Silakan login kembali (refresh token tidak valid).");
    }

    try {
      final response = await http.post(
        Uri.parse("$_backendUrl/refresh-token"),
        headers: {'Content-Type': 'application/json'},
         // --- Gunakan storedRefreshToken ---
        body: json.encode({'refresh_token': storedRefreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access_token'];
        // --- Gunakan storedRefreshToken ---
        String newRefreshToken = storedRefreshToken; // Tetap gunakan yang lama jika tidak ada yang baru

        // Spotify mungkin mengirim refresh token baru, simpan jika ada
        if (data['refresh_token'] != null) {
          newRefreshToken = data['refresh_token'];
        }

        // Gunakan fungsi helper
        await _saveTokens(newAccessToken, newRefreshToken);

        // Penting: Update juga status user (premium/free) karena bisa saja berubah
         final userType = await _getUserType(newAccessToken);
         _authStatus = (userType == 'premium') ? AuthStatus.premium : AuthStatus.free;

        return newAccessToken;
      } else {
         String serverError = response.body;
         try {
           final errorData = json.decode(response.body);
           serverError = errorData['error'] ?? response.body;
         } catch (_) {}
         // Jika refresh token gagal (misal dicabut), logout paksa
          _authStatus = AuthStatus.unknown;
          await _storage.deleteAll();
         throw Exception("Gagal memperbarui token: ${response.statusCode} - $serverError. Sesi berakhir.");
      }
    } catch (e) {
       debugPrint("Error refreshToken: $e");
       if (e is http.ClientException) {
          throw Exception("Gagal terhubung ke server backend untuk refresh token.");
       }
       // Jika error lain, mungkin sesi berakhir
        _authStatus = AuthStatus.unknown;
        await _storage.deleteAll();
       throw Exception("Terjadi kesalahan saat memperbarui sesi. Silakan login kembali.");
    }
  }


  // --- Helper ---

  /// Cek tipe akun ke Spotify API
  Future<String> _getUserType(String token) async {
     if (token.isEmpty) return 'free';

    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['product'] ?? 'free';
      } else {
         debugPrint("Gagal cek user type: ${response.statusCode}");
        return 'free';
      }
    } catch (e) {
       debugPrint("Error _getUserType: $e");
      return 'free';
    }
  }

  // --- Tambahan: Fungsi untuk cek status awal ---
  /// Cek status login saat aplikasi dimulai
  Future<void> checkInitialAuthStatus() async {
     final token = await _storage.read(key: 'spotify_access_token');
     // --- PERBAIKAN: Ganti nama variabel lokal ---
     final storedRefreshToken = await _storage.read(key: 'spotify_refresh_token');
     // -------------------------------------------

     if (token == null) {
       _authStatus = AuthStatus.unknown;
       return;
     }

     // Coba cek user type dengan token yang ada
     final userType = await _getUserType(token);

     // Jika gagal cek user type (token mungkin expired) DAN ada refresh token valid
     // --- Gunakan storedRefreshToken ---
     if (userType == 'free' && storedRefreshToken != null && storedRefreshToken.isNotEmpty && storedRefreshToken != "DUMMY_REFRESH_TOKEN_SDK_PLEASE_REPLACE") {
        try {
          // Coba refresh token
          await refreshToken(); // Panggil fungsi refresh (tidak perlu simpan hasilnya)
          // Setelah refresh, status user sudah diupdate di dalam refreshToken()
          debugPrint("Token berhasil direfresh saat startup.");
          return; // Status sudah diupdate
        } catch (e) {
           // Jika refresh gagal, anggap logout
           debugPrint("Refresh token gagal saat startup: $e");
           _authStatus = AuthStatus.unknown;
           await _storage.deleteAll();
           return;
        }
     // --- Gunakan storedRefreshToken ---
     } else if (userType == 'free' && (storedRefreshToken == null || storedRefreshToken.isEmpty || storedRefreshToken == "DUMMY_REFRESH_TOKEN_SDK_PLEASE_REPLACE")){
        // Jika token ada tapi refresh token tidak valid (Guest atau SDK dummy)
         // --- Gunakan storedRefreshToken ---
         if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
            _authStatus = AuthStatus.guest; // Anggap guest jika refresh token tidak ada
         } else {
            // Jika token ada dan refresh token = dummy, berarti dari SDK login
             _authStatus = AuthStatus.free; // Anggap free (karena tidak bisa refresh)
         }
     }
      else {
       // Jika user type berhasil dicek (premium/free)
       _authStatus = (userType == 'premium') ? AuthStatus.premium : AuthStatus.free;
     }
      debugPrint("Status awal terdeteksi: $_authStatus");
  }


}

