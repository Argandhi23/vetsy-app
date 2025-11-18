// lib/features/pet/data/models/pet_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';

class PetModel extends PetEntity {
  const PetModel({
    required super.id,
    required super.name,
    required super.type,
    required super.breed,
  });

  // Factory constructor untuk mengubah data dari Firestore menjadi objek Model
  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PetModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      breed: data['breed'] ?? '',
    );
  }
}