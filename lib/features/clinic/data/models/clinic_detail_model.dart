// lib/features/clinic/data/models/clinic_detail_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/clinic/data/models/service_model.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_detail_entity.dart';

class ClinicDetailModel extends ClinicDetailEntity {
  const ClinicDetailModel({
    required super.id,
    required super.name,
    required super.address,
    required super.imageUrl,
    required List<ServiceModel> services, // <-- Tipenya ServiceModel
  }) : super(services: services);

  // Factory untuk menggabungkan Dokumen Klinik + Snapshot Layanan
  factory ClinicDetailModel.fromFirestore(
    DocumentSnapshot clinicDoc,
    QuerySnapshot serviceSnapshot,
  ) {
    Map clinicData = clinicDoc.data() as Map<String, dynamic>;

    // Ubah snapshot layanan menjadi List<ServiceModel>
    List<ServiceModel> services = serviceSnapshot.docs
        .map((doc) => ServiceModel.fromFirestore(doc))
        .toList();

    return ClinicDetailModel(
      id: clinicDoc.id,
      name: clinicData['name'] ?? '',
      address: clinicData['address'] ?? '',
      imageUrl: clinicData['imageUrl'] ?? '',
      services: services,
    );
  }
}