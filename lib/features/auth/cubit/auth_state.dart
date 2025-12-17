part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState._({required this.status, this.error});

  const AuthState.unknown() : this._(status: AuthStatus.unknown);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated() : this._(status: AuthStatus.authenticated);
  const AuthState.unauthenticated([String? error]) : this._(status: AuthStatus.unauthenticated, error: error);

  final AuthStatus status;
  final String? error;

  @override
  List<Object?> get props => [status, error];
}

enum AuthStatus { unknown, loading, authenticated, unauthenticated }
