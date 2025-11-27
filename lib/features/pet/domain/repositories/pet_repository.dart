import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';

abstract class PetRepository {
  // [UBAH KE STREAM] Return Stream langsung, bukan Future Either
  Stream<List<PetEntity>> getMyPetsStream(); 

  Future<Either<Failure, void>> addPet({
    required String name,
    required String type,
    required String breed,
    required int age,
    required double weight,
  });

  Future<Either<Failure, void>> deletePet(String petId);
  Future<Either<Failure, void>> updatePet(PetEntity pet);
}