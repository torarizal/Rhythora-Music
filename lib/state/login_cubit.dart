import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;

  LoginCubit(this._authService) : super(LoginInitial());

  Future<void> loginWithSpotify() async {
    emit(LoginLoading());
    try {
      final authStatus = await _authService.loginWithSpotify();
      emit(LoginSuccess(authStatus));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> loginAsGuest() async {
    emit(LoginLoading());
    try {
      final authStatus = await _authService.loginAsGuest();
      emit(LoginSuccess(authStatus));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
