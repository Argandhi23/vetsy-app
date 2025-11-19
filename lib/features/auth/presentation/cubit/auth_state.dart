part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final String role;       // 'user' atau 'admin'
  final String? clinicId;  // ID Klinik (jika admin)
  final String? username;  // Nama user (untuk greeting di Home)

  const Authenticated({
    required this.user,
    this.role = 'user', 
    this.clinicId,
    this.username,
  });

  @override
  List<Object?> get props => [user, role, clinicId, username];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}