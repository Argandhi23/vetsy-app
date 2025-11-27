import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  final String clinicId; // [BARU]

  const ServiceModel({
    required super.id,
    required this.clinicId, // [BARU]
    required super.name,
    required super.price,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      clinicId: data['clinicId'] ?? '', // [BARU]
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clinicId': clinicId, // [BARU]
      'name': name,
      'price': price,
    };
  }
}