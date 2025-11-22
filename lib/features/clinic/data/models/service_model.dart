import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      // [BARU] Ambil harga, konversi ke double agar aman
      price: (data['price'] ?? 0).toDouble(), 
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
    };
  }
}