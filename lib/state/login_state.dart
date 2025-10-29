import 'package:equatable/equatable.dart';
import '../services/auth_service.dart'; 

// Kelas dasar untuk semua state
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

// 1. Kondisi Awal: Saat layar baru dibuka
class LoginInitial extends LoginState {}

// 2. Kondisi Loading: Saat tombol login ditekan
class LoginLoading extends LoginState {}

// 3. Kondisi Sukses: Berhasil login (baik sebagai Guest atau Spotify)
class LoginSuccess extends LoginState {
  final AuthStatus authStatus; 

  const LoginSuccess(this.authStatus);

  @override
  List<Object> get props => [authStatus];
}

// 4. Kondisi Gagal: Error saat login
class LoginFailure extends LoginState {
  final String error;

  const LoginFailure(this.error);

  @override
  List<Object> get props => [error];
}

