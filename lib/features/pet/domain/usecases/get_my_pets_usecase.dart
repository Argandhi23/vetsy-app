// lib/features/pet/domain/usecases/get_my_pets_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/repositories/pet_repository.dart';

class GetMyPetsUseCase {
  final PetRepository repository;

  GetMyPetsUseCase({required this.repository});

  // Usecase ini bisa dipanggil seperti fungsi biasa
  Future<Either<Failure, List<PetEntity>>> call() async {
    return await repository.getMyPets();
  }
}