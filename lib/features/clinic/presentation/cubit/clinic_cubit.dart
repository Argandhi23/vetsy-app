import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_entity.dart';
import 'package:vetsy_app/features/clinic/domain/usecases/get_clinics_usecase.dart';

part 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  final GetClinicsUseCase getClinicsUseCase;

  // Simpan data asli untuk keperluan pencarian lokal
  List<ClinicEntity> _allClinics = [];

  ClinicCubit({required this.getClinicsUseCase}) : super(ClinicInitial());

  Future<void> fetchClinics() async {
    emit(ClinicLoading());
    final result = await getClinicsUseCase();
    result.fold(
      (failure) => emit(ClinicError(message: failure.message)),
      (clinics) {
        _allClinics = clinics; // Backup data asli
        emit(ClinicLoaded(clinics: clinics));
      },
    );
  }

  // FITUR BARU: Pencarian Lokal
  void searchClinics(String query) {
    // Hanya proses jika data sudah dimuat
    if (state is! ClinicLoaded) return;

    if (query.isEmpty) {
      // Jika query kosong, kembalikan semua data
      emit(ClinicLoaded(clinics: _allClinics));
    } else {
      // Filter berdasarkan nama klinik atau alamat
      final filtered = _allClinics.where((clinic) {
        final nameLower = clinic.name.toLowerCase();
        final addressLower = clinic.address.toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower) || addressLower.contains(searchLower);
      }).toList();
      
      emit(ClinicLoaded(clinics: filtered));
    }
  }
}