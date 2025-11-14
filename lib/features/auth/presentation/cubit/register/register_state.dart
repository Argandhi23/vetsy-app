// lib/features/auth/presentation/cubit/register/register_state.dart
part of 'register_cubit.dart';

// Sealed class untuk state
sealed class RegisterState extends Equatable {
  const RegisterState();
  @override
  List<Object> get props => [];
}

// State awal (halaman baru dibuka)
final class RegisterInitial extends RegisterState {}

// State saat tombol ditekan (menampilkan loading)
final class RegisterLoading extends RegisterState {}

// State saat register sukses
final class RegisterSuccess extends RegisterState {}

// State saat register gagal (membawa pesan error)
final class RegisterFailure extends RegisterState {
  final String message;
  const RegisterFailure({required this.message});
  @override
  List<Object> get props => [message];
}