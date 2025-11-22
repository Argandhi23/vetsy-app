import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_entity.dart';

class ClinicModel extends ClinicEntity {
  const ClinicModel({
    required super.id,
    required super.name,
    required super.address,
    required super.imageUrl,
    required super.categories,
    required super.rating,        // <-- Tambah
    required super.totalReviews,  // <-- Tambah
  });

  factory ClinicModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    
    return ClinicModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      // [BARU] Ambil rating & totalReviews, default 0 jika belum ada
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
    );
  }
}