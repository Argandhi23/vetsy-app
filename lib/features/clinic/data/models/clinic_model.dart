import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_entity.dart';

class ClinicModel extends ClinicEntity {
  const ClinicModel({
    required super.id,
    required super.name,
    required super.address,
    required super.imageUrl,
    required super.categories, // <-- Tambah
  });

  factory ClinicModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    
    return ClinicModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      // Konversi List dynamic ke List<String> dengan aman
      categories: List<String>.from(data['categories'] ?? []),
    );
  }
}