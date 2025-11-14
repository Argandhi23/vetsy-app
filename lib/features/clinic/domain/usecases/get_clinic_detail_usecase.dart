// lib/features/clinic/domain/usecases/get_clinic_detail_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_detail_entity.dart';
import 'package:vetsy_app/features/clinic/domain/repositories/clinic_repository.dart';

class GetClinicDetailUseCase {
  final ClinicRepository repository;

  GetClinicDetailUseCase({required this.repository});

  // Panggil repository dengan parameter ID
  Future<Either<Failure, ClinicDetailEntity>> call(String clinicId) async {
    return await repository.getClinicDetail(clinicId);
  }
}