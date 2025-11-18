// lib/features/pet/domain/repositories/pet_repository.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';

abstract class PetRepository {
  Future<Either<Failure, List<PetEntity>>> getMyPets();

  Future<Either<Failure, void>> addPet({
    required String name,
    required String type,
    required String breed,
  });

  Future<Either<Failure, void>> deletePet(String petId);

  // ===== FUNGSI BARU =====
  Future<Either<Failure, void>> updatePet(PetEntity pet);
  // ======================
}