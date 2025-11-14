import 'dart:async';
import 'dart:convert';
// --- IMPORT BARU ---
import 'package:flutter/foundation.dart'; // Untuk 'kIsWeb' DAN 'kDebugMode'
import 'package:flutter/material.dart'; // Untuk debugPrint
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka URL login
// 'dart:html' hanya di-import jika platformnya web
// Kita gunakan 'conditional import' agar tidak error di mobile
import 'html_stub.dart' if (dart.library.html) 'dart:html' as html;
// -------------------
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
  static const String _clientId = "6ad4ddc21f4c4746a3a0e47492a02c0b";
  
  // --- Tentukan Redirect URI berdasarkan Platform ---
  // 1. Ini untuk Mobile (Android/iOS)
  static const String _mobileRedirectUrl = "rhythora://callback"; 
  
  
  String get _webRedirectUrl {
    
    if (kDebugMode) {
      
      return "http://127.0.0.1:49614/callback.html";
    } else {
      
      return "https://torarizal.github.io/rythora_music_web/"; 
    }
  }
  // --------------------------------------------------------

  // Ganti ini dengan URL Vercel Anda yang AKTIF
  static const String _backendUrl = "https://rhythora-backend-update.vercel.app/api";

  final _storage = const FlutterSecureStorage();

  AuthStatus _authStatus = AuthStatus.unknown;
  
  bool get isPremium => _authStatus == AuthStatus.premium;
  AuthStatus get currentStatus => _authStatus;

  // --- Helper untuk mendapatkan Redirect URL yang benar ---
  String get _redirectUrl {
  if (kIsWeb) {
    return _webRedirectUrl; 
  } else {
    return _mobileRedirectUrl;
  }
}

  // --------------------------------------------------

  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    await _storage.write(key: 'spotify_access_token', value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: 'spotify_refresh_token', value: refreshToken);
    } else {
      await _storage.delete(key: 'spotify_refresh_token');
    }
  }

  Future<AuthStatus> loginWithSpotify() async {
    if (kIsWeb) {
      return _loginWithSpotifyWeb();
    } else {
      return _loginWithSpotifyMobile();
    }
  }

  Future<AuthStatus> _loginWithSpotifyMobile() async {
    try {
      debugPrint("Mencoba login Mobile dengan redirect URL: $_mobileRedirectUrl");
      final accessToken = await SpotifySdk.getAccessToken(
        clientId: _clientId,
        redirectUrl: _mobileRedirectUrl,
        scope: "app-remote-control, user-read-playback-state, streaming, user-read-email, user-read-private",
      );
      debugPrint("Login Spotify (Mobile) Berhasil!");
      await _saveTokens(accessToken, "DUMMY_REFRESH_TOKEN_SDK_PLEASE_REPLACE"); 
      final userType = await checkUserTypeWithToken(accessToken);
      _authStatus = (userType == 'premium') ? AuthStatus.premium : AuthStatus.free;
      return _authStatus;
    } catch (e) {
      debugPrint("Gagal login Spotify SDK (Mobile): $e");
      throw Exception("Gagal terhubung ke Spotify. Pastikan Spotify terinstal.");
    }
  }

  Future<AuthStatus> _loginWithSpotifyWeb() async {
     final completer = Completer<String>();
     final scope = "app-remote-control user-read-playback-state streaming user-read-email user-read-private";
     final authUrl = Uri.parse('https://accounts.spotify.com/authorize?' +
        'response_type=code' +
        '&client_id=$_clientId' +
        '&scope=${Uri.encodeComponent(scope)}' +
        '&redirect_uri=${Uri.encodeComponent(_redirectUrl)}'); 
        
   final eventListener = html.window.onMessage.listen((event) {
  final data = event.data.toString();
  if (data.contains('code=')) {
    final uri = Uri.parse(data);
    final code = uri.queryParameters['code'];
    if (code != null) {
      completer.complete(code);
    }
  }
});



     try {
        html.window.open(authUrl.toString(), "Spotify Login", "width=500,height=800");
     } catch (e) {
         debugPrint("Gagal buka popup, fallback ke launchUrl: $e");
         if (!await launchUrl(authUrl, mode: LaunchMode.externalApplication)) {
             eventListener.cancel();
             throw Exception('Tidak bisa membuka URL login Spotify.');
         }
     }
     
     try {
       final code = await completer.future;
       eventListener.cancel();
       debugPrint("Web login: 'code' diterima, menukar token di backend...");
       final response = await http.post(
         Uri.parse("$_backendUrl/exchange-token"),
         headers: {'Content-Type': 'application/json'},
         body: json.encode({
           'code': code,
           'redirect_uri': _redirectUrl // Kirim redirect_uri yang dinamis
         }),
       );

       if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final accessToken = data['access_token'];
          final refreshToken = data['refresh_token'];
          await _saveTokens(accessToken, refreshToken);
          final userType = await checkUserTypeWithToken(accessToken);
          _authStatus = (userType == 'premium') ? AuthStatus.premium : AuthStatus.free;
          debugPrint("Login Spotify (Web) Berhasil: $_authStatus");
          return _authStatus;
       } else {
         throw Exception("Gagal menukar kode dengan token di backend: ${response.body}");
       }
     } catch (e) {
        eventListener.cancel();
        debugPrint("Gagal login Spotify (Web): $e");
        throw Exception("Gagal login: ${e.toString()}");
     }
  }

  Future<AuthStatus> loginAsGuest() async {
    // ... (Fungsi ini tidak berubah) ...
    try {
      final response = await http.get(
        Uri.parse("$_backendUrl/guest-token"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        await _saveTokens(accessToken, null);
        _authStatus = AuthStatus.guest;
        debugPrint("Login Guest Berhasil");
        return _authStatus;
      } else {
        String serverError = response.body;
        try {
          final errorData = json.decode(response.body);
          serverError = errorData['error'] ?? response.body;
        } catch (_) {}
        throw Exception("Gagal mendapatkan token tamu dari server: ${response.statusCode} - $serverError");
      }
    } catch (e) {
      debugPrint("Error loginAsGuest: $e");
      if (e is http.ClientException) {
         throw Exception("Gagal terhubung ke server backend. Periksa koneksi internet dan URL backend.");
      }
      throw Exception("Terjadi kesalahan saat login sebagai tamu.");
    }
  }

  Future<String> refreshToken() async {
    // ... (Fungsi ini tidak berubah) ...
    final storedRefreshToken = await _storage.read(key: 'spotify_refresh_token');

    if (storedRefreshToken == null || storedRefreshToken.isEmpty || storedRefreshToken == "DUMMY_REFRESH_TOKEN_SDK_PLEASE_REPLACE") {
      _authStatus = AuthStatus.unknown;
       await _storage.deleteAll();
      throw Exception("Sesi berakhir. Silakan login kembali (refresh token tidak valid).");
    }

    try {
      final response = await http.post(
        Uri.parse("$_backendUrl/refresh-token"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': storedRefreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['access_token'];
        String newRefreshToken = storedRefreshToken; 
        if (data['refresh_token'] != null) {
          newRefreshToken = data['refresh_token'];
        }
        await _saveTokens(newAccessToken, newRefreshToken);
         final userType = await checkUserTypeWithToken(newAccessToken);
         _authStatus = (userType == 'premium') ? AuthStatus.premium : AuthStatus.free;
        return newAccessToken;
      } else {
         String serverError = response.body;
         try {
           final errorData = json.decode(response.body);
           serverError = errorData['error'] ?? response.body;
         } catch (_) {}
          _authStatus = AuthStatus.unknown;
          await _storage.deleteAll();
         throw Exception("Gagal memperbarui token: ${response.statusCode} - $serverError. Sesi berakhir.");
      }
    } catch (e) {
       debugPrint("Error refreshToken: $e");
       if (e is http.ClientException) {
          throw Exception("Gagal terhubung ke server backend untuk refresh token.");
       }
        _authStatus = AuthStatus.unknown;
        await _storage.deleteAll();
       throw Exception("Terjadi kesalahan saat memperbarui sesi. Silakan login kembali.");
    }
  }


  Future<String> checkUserTypeWithToken(String token) async {
    // ... (Fungsi ini tidak berubah) ...
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
         return 'failed'; 
      }
    } catch (e) {
       debugPrint("Error _getUserType: $e");
      return 'failed';
    }
  }

  Future<void> checkInitialAuthStatus() async {
    // ... (Fungsi ini tidak berubah) ...
     final token = await _storage.read(key: 'spotify_access_token');
     final storedRefreshToken = await _storage.read(key: 'spotify_refresh_token');

     if (token == null) {
       _authStatus = AuthStatus.unknown;
       return;
     }
     
     final userType = await checkUserTypeWithToken(token);

     if (userType == 'failed' && storedRefreshToken != null && storedRefreshToken.isNotEmpty) {
        try {
          await refreshToken(); 
          debugPrint("Token berhasil direfresh saat startup.");
          return;
        } catch (e) {
           debugPrint("Refresh token gagal saat startup: $e");
           _authStatus = AuthStatus.unknown;
           await _storage.deleteAll();
           return;
        }
     } 
     else if (userType == 'failed' && (storedRefreshToken == null || storedRefreshToken.isEmpty)){
         _authStatus = AuthStatus.guest; 
     }
      else {
       _authStatus = (userType == 'premium') ? AuthStatus.premium : AuthStatus.free;
     }
      debugPrint("Status awal terdeteksi: $_authStatus");
  }

  /// Menghubungkan ke Spotify SDK Remote Control
  Future<bool> connectSdk() async {
    // Hanya coba hubungkan jika user premium
    if (_authStatus != AuthStatus.premium) return false;

    try {
      debugPrint("Mencoba menghubungkan Spotify SDK Remote...");
      final connected = await SpotifySdk.connectToSpotifyRemote(
        clientId: _clientId,
        redirectUrl: _redirectUrl,
      );
      if (connected) {
        debugPrint("Berhasil terhubung ke Spotify SDK Remote.");
      } else {
        debugPrint("Gagal terhubung ke Spotify SDK Remote (dikembalikan false oleh SDK).");
      }
      return connected;
    } catch (e) {
      debugPrint("Error saat menghubungkan Spotify SDK Remote: $e");
      return false;
    }
  }
}

