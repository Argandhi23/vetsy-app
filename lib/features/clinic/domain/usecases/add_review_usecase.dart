import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/clinic/domain/entities/review_entity.dart';
import 'package:vetsy_app/features/clinic/domain/repositories/clinic_repository.dart';

class AddReviewUseCase {
  final ClinicRepository repository;

  AddReviewUseCase({required this.repository});

  Future<Either<Failure, void>> call(String clinicId, ReviewEntity review) async {
    return await repository.addReview(clinicId, review);
  }
}