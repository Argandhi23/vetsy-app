// lib/features/clinic/domain/repositories/clinic_repository.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_detail_entity.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_entity.dart';

abstract class ClinicRepository {
  // Kontraknya: "Beri saya daftar klinik.
  // Jika berhasil, kembalikan List<ClinicEntity> (Right).
  // Jika gagal, kembalikan Failure (Left)."
  Future<Either<Failure, List<ClinicEntity>>> getClinics();

  Future<Either<Failure, ClinicDetailEntity>> getClinicDetail(String clinicId);
  
  // Nanti kita bisa tambah:
  // Future<Either<Failure, ClinicEntity>> getClinicDetail(String id);
}