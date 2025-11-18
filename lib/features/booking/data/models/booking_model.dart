// lib/features/booking/data/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.clinicId,
    required super.petId,
    required super.userId,
    required super.service,
    required super.scheduleDate,
    required super.status,
    super.clinicName,
    super.petName,
  });

  // Factory untuk 'create' (dari Entity)
  factory BookingModel.fromEntity(BookingEntity entity) {
    return BookingModel(
      id: entity.id,
      clinicId: entity.clinicId,
      petId: entity.petId,
      userId: entity.userId,
      service: entity.service,
      scheduleDate: entity.scheduleDate,
      status: entity.status,
      clinicName: entity.clinicName, // <-- INI YANG BARU
      petName: entity.petName, // <-- INI YANG BARU
    );
  }

  // Factory untuk 'read' (dari Firestore)
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    final serviceData = data['service'] as Map<String, dynamic>;
    final service = ServiceEntity(
      id: serviceData['id'] ?? '',
      name: serviceData['name'] ?? '',
      price: serviceData['price'] ?? 0,
    );

    return BookingModel(
      id: doc.id,
      clinicId: data['clinicId'] ?? '',
      petId: data['petId'] ?? '',
      userId: data['userId'] ?? '',
      service: service,
      scheduleDate: (data['scheduleDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'Unknown',
      clinicName: data['clinicName'] ?? 'Klinik Tdk Ditemukan', // <-- INI YANG BARU
      petName: data['petName'] ?? 'Hewan Tdk Ditemukan', // <-- INI YANG BARU
    );
  }

  // Mengubah objek ini menjadi Map untuk dikirim ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'clinicId': clinicId,
      'petId': petId,
      'service': {
        'id': service.id,
        'name': service.name,
        'price': service.price,
      },
      'scheduleDate': Timestamp.fromDate(scheduleDate),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'clinicName': clinicName, // <-- INI YANG BARU
      'petName': petName, // <-- INI YANG BARU
    };
  }
}