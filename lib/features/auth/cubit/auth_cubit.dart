import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown());

  final AuthRepository _authRepository;

  Future<void> init() async {
    final token = await _authRepository.getToken();
    if (token == null || token.isEmpty) {
      emit(const AuthState.unauthenticated());
    } else {
      emit(const AuthState.authenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.login(email: email, password: password, deviceName: 'android');
      emit(const AuthState.authenticated());
    } catch (e) {
      var msg = e.toString();
      const prefix = 'Exception: ';
      if (msg.startsWith(prefix)) msg = msg.substring(prefix.length);
      emit(AuthState.unauthenticated(msg));
    }
  }

  Future<void> logout() async {
    emit(const AuthState.loading());
    try {
      await _authRepository.logout();
    } finally {
      emit(const AuthState.unauthenticated());
    }
  }
}
