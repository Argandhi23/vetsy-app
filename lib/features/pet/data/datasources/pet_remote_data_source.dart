import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/pet/data/models/pet_model.dart';

abstract class PetRemoteDataSource {
  // [UBAH KE STREAM]
  Stream<List<PetModel>> getMyPetsStream(String userId);

  Future<void> addPet({required String userId, required Map<String, dynamic> petData});
  Future<void> deletePet({required String userId, required String petId});
  Future<void> updatePet({required String userId, required String petId, required Map<String, dynamic> petData});
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final FirebaseFirestore firestore;

  PetRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<PetModel>> getMyPetsStream(String userId) {
    // [PERBAIKAN LOGIC]
    // 1. Gunakan snapshots() agar Realtime
    // 2. Gunakan Root Collection 'pets'
    // 3. Filter by 'userId'
    return firestore
        .collection('pets') 
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PetModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> addPet({required String userId, required Map<String, dynamic> petData}) async {
    try {
      final data = Map<String, dynamic>.from(petData);
      data['userId'] = userId; // Wajib inject userId
      await firestore.collection('pets').add(data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePet({required String userId, required String petId}) async {
    try {
      await firestore.collection('pets').doc(petId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updatePet({required String userId, required String petId, required Map<String, dynamic> petData}) async {
    try {
      await firestore.collection('pets').doc(petId).update(petData);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}