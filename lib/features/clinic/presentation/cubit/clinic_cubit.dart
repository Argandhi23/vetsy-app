import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_entity.dart';
import 'package:vetsy_app/features/clinic/domain/usecases/get_clinics_usecase.dart';

part 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  final GetClinicsUseCase getClinicsUseCase;
  // Simpan semua data asli untuk keperluan reset filter
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

  void searchClinics(String query) {
    if (state is! ClinicLoaded) return;
    if (query.isEmpty) {
      emit(ClinicLoaded(clinics: _allClinics));
    } else {
      final filtered = _allClinics.where((clinic) {
        final nameLower = clinic.name.toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower);
      }).toList();
      emit(ClinicLoaded(clinics: filtered));
    }
  }

  // FUNGSI FILTER KATEGORI (BARU)
  void filterByCategory(String category) {
    if (state is! ClinicLoaded) return;
    
    // Jika kategori 'Semua' atau null, tampilkan semua
    if (category == 'Semua') {
      emit(ClinicLoaded(clinics: _allClinics));
      return;
    }

    final filtered = _allClinics.where((clinic) {
      // Cek apakah list categories klinik mengandung kategori yang dipilih
      return clinic.categories.contains(category);
    }).toList();
    
    emit(ClinicLoaded(clinics: filtered));
  }
}