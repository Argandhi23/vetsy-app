// lib/features/pet/data/datasources/pet_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/pet/data/models/pet_model.dart';

abstract class PetRemoteDataSource {
  Future<List<PetModel>> getMyPets(String userId);

  Future<void> addPet({
    required String userId,
    required Map<String, dynamic> petData,
  });

  Future<void> deletePet({required String userId, required String petId});

  // ===== FUNGSI BARU =====
  Future<void> updatePet({
    required String userId,
    required String petId,
    required Map<String, dynamic> petData,
  });
  // ======================
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final FirebaseFirestore firestore;

  PetRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<PetModel>> getMyPets(String userId) async {
    // ... (Fungsi ini tetap sama)
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .get();

      final pets = snapshot.docs
          .map((doc) => PetModel.fromFirestore(doc))
          .toList();
          
      return pets;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> addPet({
    required String userId,
    required Map<String, dynamic> petData,
  }) async {
    // ... (Fungsi ini tetap sama)
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .add(petData);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePet({
    required String userId,
    required String petId,
  }) async {
    // ... (Fungsi ini tetap sama)
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ===== IMPLEMENTASI FUNGSI BARU =====
  @override
  Future<void> updatePet({
    required String userId,
    required String petId,
    required Map<String, dynamic> petData,
  }) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .update(petData);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
  // ==================================
}