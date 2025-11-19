import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/auth/domain/entities/user_entity.dart';
import 'package:vetsy_app/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:vetsy_app/features/auth/domain/usecases/update_user_profile_usecase.dart'; // Import

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase; // Tambah ini

  ProfileCubit({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase, 
  }) : super(const ProfileState());

  Future<void> fetchUserProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await getUserProfileUseCase();
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.error, errorMessage: failure.message)),
      (user) => emit(state.copyWith(status: ProfileStatus.loaded, user: user)),
    );
  }

  void reset() {
    emit(const ProfileState());
  }

  // Fungsi Baru: Update Profile
  Future<void> updateProfile(String newUsername) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await updateUserProfileUseCase(username: newUsername);
    
    result.fold(
      (failure) => emit(state.copyWith(status: ProfileStatus.error, errorMessage: failure.message)),
      (_) {
        // Jika sukses, fetch ulang data user terbaru
        fetchUserProfile();
      },
    );
  }
}