// lib/features/booking/presentation/cubit/booking_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/usecases/create_booking_usecase.dart';
// 1. IMPORT CUBIT JADWAL
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/usecases/get_my_pets_usecase.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetMyPetsUseCase getMyPetsUseCase;
  final CreateBookingUseCase createBookingUseCase;
  final FirebaseAuth firebaseAuth;
  final MyBookingsCubit myBookingsCubit; // <-- 2. TAMBAHKAN DI SINI

  BookingCubit({
    required this.getMyPetsUseCase,
    required this.createBookingUseCase,
    required this.firebaseAuth,
    required this.myBookingsCubit, // <-- 3. TAMBAHKAN DI CONSTRUCTOR
  }) : super(const BookingState());

  // ... (fetchInitialData, onPetSelected, onDateSelected, onTimeSelected tetap sama) ...
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
  void onDateSelected(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }
  void onTimeSelected(TimeOfDay time) {
    emit(state.copyWith(selectedTime: time));
  }
  
  Future<void> submitBooking({
    required String clinicId,
    required String clinicName,
    required ServiceEntity service,
  }) async {
    // ... (Validasi tetap sama) ...
    if (state.selectedPet == null ||
        state.selectedDate == null ||
        state.selectedTime == null) {
      emit(state.copyWith(
        status: BookingPageStatus.error,
        errorMessage: "Harap pilih hewan, tanggal, DAN jam terlebih dahulu.",
      ));
      emit(state.copyWith(status: BookingPageStatus.petsLoaded));
      return;
    }
    // ... (Cek UserID tetap sama) ...
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(state.copyWith(
        status: BookingPageStatus.error,
        errorMessage: "User tidak ditemukan. Silakan login ulang.",
      ));
      return;
    }

    emit(state.copyWith(status: BookingPageStatus.submitting));

    // ... (Gabungkan DateTime tetap sama) ...
    final DateTime combinedDateTime = DateTime(
      state.selectedDate!.year,
      state.selectedDate!.month,
      state.selectedDate!.day,
      state.selectedTime!.hour,
      state.selectedTime!.minute,
    );
    // ... (Buat BookingEntity.create tetap sama) ...
    final booking = BookingEntity.create(
      userId: userId,
      clinicId: clinicId,
      petId: state.selectedPet!.id,
      petName: state.selectedPet!.name,
      clinicName: clinicName,
      service: service,
      scheduleDate: combinedDateTime,
      status: "Pending",
    );

    final result = await createBookingUseCase(booking);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: BookingPageStatus.error,
          errorMessage: failure.message,
        ));
      },
      (success) {
        // ===== 4. INI DIA LOGIKA BARUNYA! =====
        // "Beri tahu" MyBookingsCubit untuk refresh
        myBookingsCubit.fetchMyBookings();
        // ======================================
        
        // Baru kirim state sukses ke UI
        emit(state.copyWith(status: BookingPageStatus.success));
      },
    );
  }
}