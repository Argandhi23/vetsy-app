// lib/features/auth/presentation/cubit/auth_state.dart
part of 'auth_cubit.dart';

// Gunakan 'sealed' (OOP) untuk state yang pasti
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

// State saat user berhasil login (membawa data user)
final class Authenticated extends AuthState {
  final User user; // User dari Firebase Auth
  const Authenticated({required this.user});
  @override
  List<Object?> get props => [user];
}

// State saat user tidak login
final class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated({this.message});
  @override
  List<Object?> get props => [message];
}