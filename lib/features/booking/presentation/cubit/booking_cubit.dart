import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [PENTING] Tambah ini
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetsy_app/core/services/notification_service.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/usecases/get_my_pets_usecase.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetMyPetsUseCase getMyPetsUseCase;
  final CreateBookingUseCase createBookingUseCase;
  final FirebaseAuth firebaseAuth;
  final BookingRepository bookingRepository;
  
  // Instance Firestore untuk Batch Write
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  BookingCubit({
    required this.getMyPetsUseCase,
    required this.createBookingUseCase,
    required this.firebaseAuth,
    required this.bookingRepository,
  }) : super(const BookingState());

  // --- Mengambil Data Hewan Peliharaan ---
  Future<void> fetchInitialData() async {
    emit(state.copyWith(status: BookingPageStatus.loadingPets));
    final result = await getMyPetsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
          status: BookingPageStatus.error, errorMessage: failure.message)),
      (pets) =>
          emit(state.copyWith(status: BookingPageStatus.petsLoaded, pets: pets)),
    );
  }

  void onPetSelected(PetEntity pet) {
    emit(state.copyWith(selectedPet: pet));
  }

  // --- Cek Slot Waktu ---
  Future<void> onDateSelected(String clinicId, String serviceId, DateTime date) async {
    emit(state.copyWith(
      selectedDate: date,
      selectedTime: null, // Reset jam ketika tanggal berubah
      status: BookingPageStatus.loadingSlots,
    ));

    final result = await bookingRepository.getOccupiedSlots(clinicId, serviceId, date);

    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingPageStatus.error,
        errorMessage: "Gagal cek jadwal: ${failure.message}"
      )),
      (occupiedDates) {
        final busyList = occupiedDates
            .map((dt) => TimeOfDay(hour: dt.hour, minute: dt.minute))
            .toList();
        
        emit(state.copyWith(
          status: BookingPageStatus.slotsLoaded,
          busyTimes: busyList,
        ));
      },
    );
  }

  void onTimeSelected(TimeOfDay time) {
    emit(state.copyWith(selectedTime: time));
  }

  // --- Submit Booking & Payment (Batch Write) ---
  Future<void> submitBooking({
    required String clinicId,
    required String clinicName,
    required ServiceEntity service,
    required double totalPrice,
    required double adminFee,
    required double grandTotal,
    required double discountAmount,
    required String paymentMethod,
    required PetEntity selectedPet,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
  }) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) return;

    emit(state.copyWith(status: BookingPageStatus.submitting));

    try {
      // 1. Siapkan Referensi Dokumen Baru
      final bookingRef = firestore.collection('bookings').doc();
      final paymentRef = firestore.collection('payments').doc();

      // 2. Gabungkan Tanggal & Waktu
      final DateTime combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // 3. Siapkan Data BOOKING (Map)
      final bookingData = {
        'id': bookingRef.id,
        'userId': userId,
        'clinicId': clinicId,
        'petId': selectedPet.id,
        'petName': selectedPet.name,
        'clinicName': clinicName,
        'service': {
          'id': service.id,
          'name': service.name,
          'price': service.price,
        },
        'scheduleDate': Timestamp.fromDate(combinedDateTime),
        'status': 'Pending', // Status operasional booking
        'paymentStatus': 'Unpaid', // Status pembayaran (karena bayar di klinik)
        'grandTotal': grandTotal,
        'paymentMethod': paymentMethod, // "Tunai di Klinik"
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 4. Siapkan Data PAYMENT (Map - Collection Terpisah)
      final paymentData = {
        'id': paymentRef.id,
        'bookingId': bookingRef.id, // Relasi ke Booking
        'userId': userId,
        'clinicId': clinicId,
        'amount': grandTotal,
        'adminFee': adminFee,
        'discount': discountAmount,
        'method': paymentMethod,
        'status': 'Pending', // Pending karena belum dibayar di kasir
        'transactionDate': FieldValue.serverTimestamp(),
        'invoiceNumber': 'INV-${DateTime.now().millisecondsSinceEpoch}',
      };

      // 5. EKSEKUSI BATCH (Simpan ke 2 Collection Sekaligus)
      final batch = firestore.batch();
      batch.set(bookingRef, bookingData);
      batch.set(paymentRef, paymentData);
      
      await batch.commit(); // Kirim ke Firebase

      // 6. LOGIKA NOTIFIKASI (Kode Asli Anda)
      _scheduleNotification(combinedDateTime, service.name, selectedPet.name, clinicName);

      // 7. Sukses
      emit(state.copyWith(status: BookingPageStatus.success));

    } catch (e) {
      emit(state.copyWith(
        status: BookingPageStatus.error,
        errorMessage: "Gagal memproses booking: $e",
      ));
    }
  }

  // --- Helper Notifikasi (Dipisah agar rapi) ---
  Future<void> _scheduleNotification(
    DateTime scheduleTime, 
    String serviceName, 
    String petName, 
    String clinicName
  ) async {
    try {
      final int notificationId = scheduleTime.millisecondsSinceEpoch ~/ 1000;
      final now = DateTime.now();

      // Hitung waktu normal: 2 Jam sebelum jadwal
      DateTime reminderTime = scheduleTime.subtract(const Duration(hours: 2));
      
      // Cek Booking Dadakan
      if (reminderTime.isBefore(now)) {
        reminderTime = now.add(const Duration(minutes: 5));
        debugPrint("⚠️ Booking Dadakan: Notifikasi dijadwalkan 5 menit lagi.");
      } else {
        debugPrint("✅ Booking Normal: Notifikasi dijadwalkan 2 jam sebelum.");
      }

      // Validasi: Jangan notif jika jadwal sudah lewat
      if (reminderTime.isBefore(scheduleTime)) {
          await NotificationService().scheduleNotification(
            id: notificationId, 
            title: "Pengingat Jadwal 🐾",
            body: "Halo! Jadwal $serviceName untuk $petName sebentar lagi dimulai di $clinicName.",
            scheduledTime: reminderTime,
          );
      }
    } catch (e) {
      debugPrint("❌ Gagal notifikasi: $e");
    }
  }
}