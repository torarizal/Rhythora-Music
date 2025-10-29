import 'package:equatable/equatable.dart';
import '../services/auth_service.dart'; // Import AuthStatus

// Kelas dasar
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// 1. Initial State: Saat aplikasi baru mulai, belum tahu statusnya
class AuthInitial extends AuthState {}

// 2. Authenticated State: Pengguna sudah login (Guest, Premium, atau Free)
class Authenticated extends AuthState {
  final AuthStatus authStatus; // Bawa status spesifiknya

  const Authenticated(this.authStatus);

  @override
  List<Object?> get props => [authStatus];
}

// 3. Unauthenticated State: Pengguna belum login
class Unauthenticated extends AuthState {}
