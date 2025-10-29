import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart'; // Import AuthService dan AuthStatus
import 'auth_state.dart';             // Import AuthState

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial()) {
    // Panggil pengecekan status awal saat Cubit dibuat
    checkAuthStatus();
  }

  /// Memeriksa status autentikasi awal
  Future<void> checkAuthStatus() async {
    try {
      await _authService.checkInitialAuthStatus();
      final status = _authService.currentStatus;

      if (status == AuthStatus.unknown) {
        emit(Unauthenticated());
      } else {
        // Jika Guest, Premium, atau Free, anggap sudah terautentikasi
        emit(Authenticated(status));
      }
    } catch (e) {
      // Jika ada error saat cek status (misal refresh gagal total), anggap unauthenticated
      print("Error checkAuthStatus: $e");
      emit(Unauthenticated());
    }
  }

  /// Dipanggil saat pengguna berhasil login (dari LoginCubit)
  void loggedIn(AuthStatus status) {
    emit(Authenticated(status));
  }

  /// Dipanggil saat pengguna logout
  Future<void> loggedOut() async {
    // Anda mungkin perlu menambahkan fungsi logout di AuthService
    // await _authService.logout();
    emit(Unauthenticated());
  }

  checkInitialAuthStatus() {}
}
