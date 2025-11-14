// lib/features/auth/presentation/cubit/register/register_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/auth/domain/repositories/auth_repository.dart'; // Import 'kontrak'
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  // Kita 'minta' 'kontrak' repository
  final AuthRepository authRepository;

  RegisterCubit({required this.authRepository}) : super(RegisterInitial());

  // Ini adalah fungsi yang akan dipanggil oleh UI
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    // 1. Kirim state loading
    emit(RegisterLoading());

    // 2. Panggil fungsi signUp dari repository
    final result = await authRepository.signUp(
      email: email,
      password: password,
      username: username,
    );

    // 3. Tangani hasilnya (pakai 'fold' dari dartz)
    result.fold(
      // Kiri (Gagal)
      (failure) {
        emit(RegisterFailure(message: failure.message));
      },
      // Kanan (Sukses)
      (user) {
        emit(RegisterSuccess());
      },
    );
  }
}