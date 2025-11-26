import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetsy_app/core/services/notification_service.dart'; // Pastikan path ini sesuai
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/usecases/get_my_pets_usecase.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetMyPetsUseCase getMyPetsUseCase;
  final CreateBookingUseCase createBookingUseCase;
  final FirebaseAuth firebaseAuth;
  final MyBookingsCubit myBookingsCubit;
  final BookingRepository bookingRepository;

  BookingCubit({
    required this.getMyPetsUseCase,
    required this.createBookingUseCase,
    required this.firebaseAuth,
    required this.myBookingsCubit,
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

  // --- Submit Booking & Jadwalkan Notifikasi ---
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

    // Gabungkan Tanggal & Waktu
    final DateTime combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final booking = BookingEntity.create(
      userId: userId,
      clinicId: clinicId,
      petId: selectedPet.id,
      petName: selectedPet.name,
      clinicName: clinicName,
      service: service,
      scheduleDate: combinedDateTime,
      status: "Pending",
      totalPrice: totalPrice,
      adminFee: adminFee,
      grandTotal: grandTotal,
      discountAmount: discountAmount,
      paymentMethod: paymentMethod,
      paymentStatus: "Unpaid",
    );

    // Kirim ke Backend/Firebase
    final result = await createBookingUseCase(booking);

    result.fold(
      (failure) {
        // Gagal Booking
        emit(state.copyWith(
          status: BookingPageStatus.error,
          errorMessage: failure.message,
        ));
      },
      (success) async {
        // Sukses Booking -> Jadwalkan Notifikasi
        
        // --- LOGIKA NOTIFIKASI [UPDATED] ---
        try {
          // ID unik dari timestamp (detik) agar tidak bentrok dengan notif lain
          final int notificationId = combinedDateTime.millisecondsSinceEpoch ~/ 1000;
          
          // Hitung waktu pengingat: 2 Jam sebelum jadwal
          DateTime reminderTime = combinedDateTime.subtract(const Duration(hours: 2));
          
          // Cek Apakah Waktu Pengingat Sudah Lewat? (Kasus Booking Dadakan)
          final now = DateTime.now();
          if (reminderTime.isBefore(now)) {
            // Jika jadwalnya < 2 jam lagi, set notif untuk 10 menit dari SEKARANG
            // sebagai konfirmasi/reminder cepat.
            reminderTime = now.add(const Duration(minutes: 10));
          }

          // Pastikan reminderTime tidak melebihi jadwal asli (opsional, tapi aman)
          if (reminderTime.isBefore(combinedDateTime)) {
             await NotificationService().scheduleNotification(
              id: notificationId, 
              title: "Halo, ${selectedPet.name} Siap? 🐶",
              body: "Jangan lupa jadwal ${service.name} di $clinicName sebentar lagi ya!",
              scheduledTime: reminderTime,
            );
            debugPrint("✅ Notifikasi dijadwalkan untuk: $reminderTime");
          } else {
             debugPrint("ℹ️ Waktu booking terlalu dekat, skip notifikasi pengingat.");
          }

        } catch (e) {
          // Error notifikasi tidak boleh mengganggu flow booking
          debugPrint("❌ Gagal menjadwalkan notifikasi: $e");
        }
        // -----------------------------------

        // Refresh list booking & update UI
        myBookingsCubit.fetchMyBookings();
        emit(state.copyWith(status: BookingPageStatus.success));
      },
    );
  }
}