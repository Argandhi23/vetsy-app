import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/clinic/data/models/service_model.dart';
import 'package:vetsy_app/features/clinic/domain/entities/clinic_detail_entity.dart';

class ClinicDetailModel extends ClinicDetailEntity {
  const ClinicDetailModel({
    required super.id,
    required super.name,
    required super.address,
    required super.imageUrl,
    required super.phone, // <-- TAMBAH INI
    required List<ServiceModel> services,
  }) : super(services: services);

  factory ClinicDetailModel.fromFirestore(
    DocumentSnapshot clinicDoc,
    QuerySnapshot serviceSnapshot,
  ) {
    Map data = clinicDoc.data() as Map<String, dynamic>;

    List<ServiceModel> services = serviceSnapshot.docs
        .map((doc) => ServiceModel.fromFirestore(doc))
        .toList();

    return ClinicDetailModel(
      id: clinicDoc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      phone: data['phone'] ?? '', // <-- BACA DARI FIRESTORE
      services: services,
    );
  }
}