// lib/features/pet/domain/usecases/delete_pet_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/pet/domain/repositories/pet_repository.dart';

class DeletePetUseCase {
  final PetRepository repository;

  DeletePetUseCase({required this.repository});

  Future<Either<Failure, void>> call(String petId) async {
    return await repository.deletePet(petId);
  }
}