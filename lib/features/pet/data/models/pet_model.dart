import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';

class PetModel extends PetEntity {
  const PetModel({
    required super.id,
    required super.userId, // [BARU]
    required super.name,
    required super.type,
    required super.breed,
    super.age,
    super.weight,
  });

  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PetModel(
      id: doc.id,
      userId: data['userId'] ?? '', // [BARU] Ambil dari database
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
      weight: (data['weight'] ?? 0.0).toDouble(),
    );
  }

  // [PENTING] Tambahkan ini untuk proses simpan/update
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId, // [BARU] Simpan ID pemilik
      'name': name,
      'type': type,
      'breed': breed,
      'age': age,
      'weight': weight,
    };
  }
}