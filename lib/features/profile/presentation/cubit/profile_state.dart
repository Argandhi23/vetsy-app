// lib/features/profile/presentation/cubit/profile_state.dart
part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, loaded, error, success }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}