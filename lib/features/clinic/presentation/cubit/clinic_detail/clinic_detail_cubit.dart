// lib/features/clinic/presentation/cubit/clinic_detail/clinic_detail_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_detail_entity.dart';
// Import UseCase yang kita buat di Langkah 9
import 'package:vetsy_app/features/clinic/domain/usecases/get_clinic_detail_usecase.dart';

part 'clinic_detail_state.dart';

class ClinicDetailCubit extends Cubit<ClinicDetailState> {
  final GetClinicDetailUseCase getClinicDetailUseCase;

  ClinicDetailCubit({required this.getClinicDetailUseCase})
      : super(ClinicDetailInitial());

  // Fungsi yang akan dipanggil UI untuk 'menarik' data
  Future<void> fetchClinicDetail(String clinicId) async {
    // 1. Kirim state Loading
    emit(ClinicDetailLoading());

    // 2. Panggil UseCase dengan ID
    final result = await getClinicDetailUseCase(clinicId);

    // 3. Tangani hasilnya
    result.fold(
      // Kiri (Gagal)
      (failure) {
        emit(ClinicDetailError(message: failure.message));
      },
      // Kanan (Sukses)
      (clinicDetail) {
        emit(ClinicDetailLoaded(clinic: clinicDetail));
      },
    );
  }
}