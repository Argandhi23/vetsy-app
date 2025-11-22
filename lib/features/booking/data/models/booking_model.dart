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
    // [BARU]
    required super.totalPrice,
    required super.adminFee,
    required super.grandTotal,
    required super.paymentMethod,
    required super.paymentStatus,
  });

  factory BookingModel.fromEntity(BookingEntity entity) {
    return BookingModel(
      id: entity.id,
      clinicId: entity.clinicId,
      petId: entity.petId,
      userId: entity.userId,
      service: entity.service,
      scheduleDate: entity.scheduleDate,
      status: entity.status,
      clinicName: entity.clinicName,
      petName: entity.petName,
      // [BARU]
      totalPrice: entity.totalPrice,
      adminFee: entity.adminFee,
      grandTotal: entity.grandTotal,
      paymentMethod: entity.paymentMethod,
      paymentStatus: entity.paymentStatus,
    );
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    final serviceData = data['service'] as Map<String, dynamic>;
    final service = ServiceEntity(
      id: serviceData['id'] ?? '',
      name: serviceData['name'] ?? '',
      price: (serviceData['price'] ?? 0).toDouble(),
    );

    return BookingModel(
      id: doc.id,
      clinicId: data['clinicId'] ?? '',
      petId: data['petId'] ?? '',
      userId: data['userId'] ?? '',
      service: service,
      scheduleDate: (data['scheduleDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'Unknown',
      clinicName: data['clinicName'] ?? 'Klinik Tdk Ditemukan',
      petName: data['petName'] ?? 'Hewan Tdk Ditemukan',
      // [BARU] Ambil data payment (pakai ?? 0.0 biar ga error null)
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      adminFee: (data['adminFee'] ?? 0.0).toDouble(),
      grandTotal: (data['grandTotal'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'Tunai',
      paymentStatus: data['paymentStatus'] ?? 'Unpaid',
    );
  }

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
      'clinicName': clinicName,
      'petName': petName,
      // [BARU] Simpan ke DB
      'totalPrice': totalPrice,
      'adminFee': adminFee,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
    };
  }
}