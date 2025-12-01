import 'package:cloud_firestore/cloud_firestore.dart';

class VeterinarianModel {
  final String id;
  final String clinicId; // Foreign Key
  final String name;
  final String specialization;
  final double rating;
  final String photoUrl;

  VeterinarianModel({
    required this.id,
    required this.clinicId,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.photoUrl,
  });

  factory VeterinarianModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VeterinarianModel(
      id: doc.id,
      clinicId: data['clinicId'] ?? '',
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? 'Dokter Umum',
      rating: (data['rating'] ?? 0.0).toDouble(),
      photoUrl: data['photoUrl'] ?? '',
    );
  }
}