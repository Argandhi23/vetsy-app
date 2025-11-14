// lib/features/clinic/presentation/cubit/clinic_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_entity.dart';
import 'package:vetsy_app/features/clinic/domain/usecases/get_clinics_usecase.dart'; // Import UseCase

part 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  final GetClinicsUseCase getClinicsUseCase;

  ClinicCubit({required this.getClinicsUseCase}) : super(ClinicInitial());

  // Fungsi yang akan dipanggil UI untuk 'menarik' data
  Future<void> fetchClinics() async {
    // 1. Kirim state Loading
    emit(ClinicLoading());

    // 2. Panggil UseCase (yang memanggil Repository)
    final result = await getClinicsUseCase();

    // 3. Tangani hasilnya
    result.fold(
      // Kiri (Gagal)
      (failure) {
        emit(ClinicError(message: failure.message));
      },
      // Kanan (Sukses)
      (clinics) {
        emit(ClinicLoaded(clinics: clinics));
      },
    );
  }
}