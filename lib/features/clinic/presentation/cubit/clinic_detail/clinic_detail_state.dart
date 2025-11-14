// lib/features/clinic/presentation/cubit/clinic_detail/clinic_detail_state.dart
part of 'clinic_detail_cubit.dart';

sealed class ClinicDetailState extends Equatable {
  const ClinicDetailState();
  @override
  List<Object> get props => [];
}

final class ClinicDetailInitial extends ClinicDetailState {}

final class ClinicDetailLoading extends ClinicDetailState {}

// State saat data berhasil dimuat (membawa 1 data detail)
final class ClinicDetailLoaded extends ClinicDetailState {
  final ClinicDetailEntity clinic;
  const ClinicDetailLoaded({required this.clinic});
  @override
  List<Object> get props => [clinic];
}

// State saat data gagal dimuat
final class ClinicDetailError extends ClinicDetailState {
  final String message;
  const ClinicDetailError({required this.message});
  @override
  List<Object> get props => [message];
}