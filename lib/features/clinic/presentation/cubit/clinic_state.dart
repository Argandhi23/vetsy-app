// lib/features/clinic/presentation/cubit/clinic_state.dart
part of 'clinic_cubit.dart';

sealed class ClinicState extends Equatable {
  const ClinicState();
  @override
  List<Object> get props => [];
}

final class ClinicInitial extends ClinicState {}

final class ClinicLoading extends ClinicState {}

// State saat data berhasil dimuat
final class ClinicLoaded extends ClinicState {
  final List<ClinicEntity> clinics;
  const ClinicLoaded({required this.clinics});
  @override
  List<Object> get props => [clinics];
}

// State saat data gagal dimuat
final class ClinicError extends ClinicState {
  final String message;
  const ClinicError({required this.message});
  @override
  List<Object> get props => [message];
}