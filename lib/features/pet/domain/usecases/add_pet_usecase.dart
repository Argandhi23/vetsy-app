// lib/features/pet/domain/usecases/add_pet_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/pet/domain/repositories/pet_repository.dart';

class AddPetUseCase {
  final PetRepository repository;

  AddPetUseCase({required this.repository});

  Future<Either<Failure, void>> call({
    required String name,
    required String type,
    required String breed,
  }) async {
    return await repository.addPet(
      name: name,
      type: type,
      breed: breed,
    );
  }
}