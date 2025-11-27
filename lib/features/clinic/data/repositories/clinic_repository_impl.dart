import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/clinic/data/datasources/clinic_remote_data_source.dart';
import 'package:vetsy_app/features/clinic/data/models/review_model.dart';
import 'package:vetsy_app/features/clinic/data/models/service_model.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_detail_entity.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_entity.dart';
import 'package:vetsy_app/features/clinic/domain/entities/review_entity.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/clinic/domain/repositories/clinic_repository.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  final ClinicRemoteDataSource remoteDataSource;
  ClinicRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ClinicEntity>>> getClinics() async {
    try {
      final result = await remoteDataSource.getClinics();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ClinicDetailEntity>> getClinicDetail(
    String clinicId,
  ) async {
    try {
      final result = await remoteDataSource.getClinicDetail(clinicId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addReview(
    String clinicId,
    ReviewEntity review,
  ) async {
    try {
      final reviewModel = ReviewModel(
        id: review.id,
        clinicId: clinicId, // [FIX] Wajib diisi (sudah kita tambah di Model)
        userId: review.userId,
        username: review.username,
        rating: review.rating,
        comment: review.comment,
        date: review.date,
      );

      await remoteDataSource.addReview(clinicId: clinicId, review: reviewModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addService(
    String clinicId,
    ServiceEntity service,
  ) async {
    try {
      final model = ServiceModel(
        id: '',
        clinicId: clinicId, // [FIX] Wajib menyertakan clinicId
        name: service.name,
        price: service.price,
      );
      await remoteDataSource.addService(clinicId: clinicId, service: model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateService(
    String clinicId,
    ServiceEntity service,
  ) async {
    try {
      final model = ServiceModel(
        id: service.id,
        clinicId: clinicId, // [FIX] Wajib menyertakan clinicId
        name: service.name,
        price: service.price,
      );
      await remoteDataSource.updateService(clinicId: clinicId, service: model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(
    String clinicId,
    String serviceId,
  ) async {
    try {
      await remoteDataSource.deleteService(
        clinicId: clinicId,
        serviceId: serviceId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}