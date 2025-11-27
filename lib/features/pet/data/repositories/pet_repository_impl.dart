import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/pet/data/datasources/pet_remote_data_source.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/repositories/pet_repository.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

  PetRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseAuth,
  });

  @override
  Stream<List<PetEntity>> getMyPetsStream() {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    // Langsung return stream dari datasource
    return remoteDataSource.getMyPetsStream(user.uid);
  }

  @override
  Future<Either<Failure, void>> addPet({
    required String name,
    required String type,
    required String breed,
    required int age,
    required double weight,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return Left(ServerFailure(message: "User tidak login"));
      
      await remoteDataSource.addPet(
        userId: user.uid,
        petData: {
          'name': name,
          'type': type,
          'breed': breed,
          'age': age,
          'weight': weight,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String petId) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return Left(ServerFailure(message: "User tidak login"));
      
      await remoteDataSource.deletePet(userId: user.uid, petId: petId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePet(PetEntity pet) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return Left(ServerFailure(message: "User tidak login"));

      await remoteDataSource.updatePet(
        userId: user.uid,
        petId: pet.id,
        petData: {
          'name': pet.name,
          'type': pet.type,
          'breed': pet.breed,
          'age': pet.age,
          'weight': pet.weight,
        },
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}