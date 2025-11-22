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

  // --- [DATA BARU: PAYMENT] ---
  final double totalPrice;
  final double adminFee;
  final double grandTotal;
  final double discountAmount; // <-- Ini yang bikin error di Cubit
  final String paymentMethod;
  final String paymentStatus;

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
    // Default values
    this.totalPrice = 0,
    this.adminFee = 0,
    this.grandTotal = 0,
    this.discountAmount = 0,
    this.paymentMethod = 'Tunai',
    this.paymentStatus = 'Unpaid',
  });

  // Constructor 'create' (Dipanggil oleh BookingCubit)
  const BookingEntity.create({
    required this.userId,
    required this.clinicId,
    required this.petId,
    required this.service,
    required this.scheduleDate,
    required this.status,
    required this.clinicName,
    required this.petName,
    // [BARU] Parameter Wajib
    required this.totalPrice,
    required this.adminFee,
    required this.grandTotal,
    required this.discountAmount, // <-- Pastikan ini ada
    required this.paymentMethod,
    required this.paymentStatus,
  }) : id = '';

  @override
  List<Object?> get props => [
        id, clinicId, petId, userId, service, scheduleDate, status,
        clinicName, petName,
        totalPrice, adminFee, grandTotal, discountAmount, paymentMethod, paymentStatus
      ];
}