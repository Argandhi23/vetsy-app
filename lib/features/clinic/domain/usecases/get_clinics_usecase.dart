// lib/features/clinic/domain/usecases/get_clinics_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_entity.dart';
import 'package:vetsy_app/features/clinic/domain/repositories/clinic_repository.dart';

class GetClinicsUseCase {
  final ClinicRepository repository;

  GetClinicsUseCase({required this.repository});

  // Usecase ini bisa dipanggil seperti fungsi biasa
  Future<Either<Failure, List<ClinicEntity>>> call() async {
    return await repository.getClinics();
  }
  
}