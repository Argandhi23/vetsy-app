// lib/features/pet/domain/usecases/update_pet_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/repositories/pet_repository.dart';

class UpdatePetUseCase {
  final PetRepository repository;

  UpdatePetUseCase({required this.repository});

  Future<Either<Failure, void>> call(PetEntity pet) async {
    return await repository.updatePet(pet);
  }
}