// lib/features/auth/presentation/cubit/login/login_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/auth/domain/repositories/auth_repository.dart'; // Import 'kontrak'
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit({required this.authRepository}) : super(LoginInitial());

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // 1. Kirim state loading
    emit(LoginLoading());

    // 2. Panggil fungsi signIn dari repository
    final result = await authRepository.signIn(
      email: email,
      password: password,
    );

    // 3. Tangani hasilnya
    result.fold(
      // Kiri (Gagal)
      (failure) {
        emit(LoginFailure(message: failure.message));
      },
      // Kanan (Sukses)
      (user) {
        emit(LoginSuccess());
      },
    );
  }
}