// lib/features/pet/data/repositories/pet_repository_impl.dart
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
  Future<Either<Failure, List<PetEntity>>> getMyPets() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return Left(ServerFailure(message: "User tidak terautentikasi"));
      }
      final List<PetEntity> pets = await remoteDataSource.getMyPets(user.uid);
      return Right(pets);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addPet({
    required String name,
    required String type,
    required String breed,
    required int age,      // <-- Tambah
    required double weight, // <-- Tambah
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return Left(ServerFailure(message: "User tidak terautentikasi"));
      }
      
      // UPDATE MAP DATA
      final Map<String, dynamic> petData = {
        'name': name,
        'type': type,
        'breed': breed,
        'age': age,        // <-- Masukkan ke map
        'weight': weight,  // <-- Masukkan ke map
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await remoteDataSource.addPet(
        userId: user.uid,
        petData: petData,
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
      if (user == null) {
        return Left(ServerFailure(message: "User tidak terautentikasi"));
      }
      await remoteDataSource.deletePet(
        userId: user.uid,
        petId: petId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePet(PetEntity pet) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return Left(ServerFailure(message: "User tidak terautentikasi"));
      }

      // UPDATE MAP DI SINI JUGA
      final Map<String, dynamic> petData = {
        'name': pet.name,
        'type': pet.type,
        'breed': pet.breed,
        'age': pet.age,       // <-- Ambil dari Entity
        'weight': pet.weight, // <-- Ambil dari Entity
      };

      await remoteDataSource.updatePet(
        userId: user.uid,
        petId: pet.id,
        petData: petData,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}