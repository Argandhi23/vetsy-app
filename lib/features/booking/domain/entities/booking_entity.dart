// lib/features/booking/domain/entities/booking_entity.dart
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';

class BookingEntity extends Equatable {
  final String id;
  final String clinicId;
  final String petId;
  final String userId;
  final ServiceEntity service;
  final DateTime scheduleDate;
  final String status;
  // Info tambahan
  final String? clinicName;
  final String? petName;

  const BookingEntity({
    required this.id,
    required this.clinicId,
    required this.petId,
    required this.userId,
    required this.service,
    required this.scheduleDate,
    required this.status,
    this.clinicName,
    this.petName,
  });

  // Constructor untuk 'create' (dari Cubit)
  const BookingEntity.create({
    required this.userId,
    required this.clinicId,
    required this.petId,
    required this.service,
    required this.scheduleDate,
    required this.status,
    required this.clinicName, // <-- INI YANG BARU
    required this.petName, // <-- INI YANG BARU
  }) : id = ''; // ID kosong saat create

  @override
  List<Object?> get props => [
        id,
        clinicId,
        petId,
        userId,
        service,
        scheduleDate,
        status,
        clinicName,
        petName
      ];
}