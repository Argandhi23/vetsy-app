// lib/features/profile/presentation/cubit/profile_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/auth/domain/entities/user_entity.dart';
import 'package:vetsy_app/features/auth/domain/usecases/get_user_profile_usecase.dart';

part 'profile_state.dart'; // <-- Pastikan file profile_state.dart ada

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  ProfileCubit({required this.getUserProfileUseCase})
      : super(const ProfileState());

  Future<void> fetchUserProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await getUserProfileUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
          status: ProfileStatus.error, errorMessage: failure.message)),
      (user) =>
          emit(state.copyWith(status: ProfileStatus.loaded, user: user)),
    );
  }

  // FUNGSI UNTUK MERESET STATE SAAT LOGOUT
  void reset() {
    emit(const ProfileState());
  }
}