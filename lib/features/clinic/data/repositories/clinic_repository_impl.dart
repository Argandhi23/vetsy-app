// lib/features/clinic/data/repositories/clinic_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/exception.dart'; // Pastikan 'exceptions.dart' (dengan 's')
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/clinic/data/datasources/clinic_remote_data_source.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_detail_entity.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_entity.dart';
import 'package:vetsy_app/features/clinic/domain/repositories/clinic_repository.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  final ClinicRemoteDataSource remoteDataSource;
  ClinicRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ClinicEntity>>> getClinics() async {
    // Ini fungsi lama (sudah benar)
    try {
      final List<ClinicEntity> clinics = await remoteDataSource.getClinics();
      return Right(clinics);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // INI IMPLEMENTASI FUNGSI BARU DARI LANGKAH 9
  @override
  Future<Either<Failure, ClinicDetailEntity>> getClinicDetail(
      String clinicId) async {
    try {
      // Panggil "Tukang Bor"
      final clinicDetail = await remoteDataSource.getClinicDetail(clinicId);

      // Sukses! Kembalikan data di sisi 'Right'
      return Right(clinicDetail);
    } on ServerException catch (e) {
      // Gagal!
      return Left(ServerFailure(message: e.message));
    }
  }
}