// lib/features/auth/presentation/cubit/login/login_state.dart
part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

// Saat sukses, kita tidak perlu kirim data user,
// karena AuthCubit global akan menanganinya
final class LoginSuccess extends LoginState {} 

final class LoginFailure extends LoginState {
  final String message;
  const LoginFailure({required this.message});
  @override
  List<Object> get props => [message];
}