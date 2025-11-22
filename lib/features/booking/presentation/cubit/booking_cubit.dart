import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/usecases/get_my_pets_usecase.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetMyPetsUseCase getMyPetsUseCase;
  final CreateBookingUseCase createBookingUseCase;
  final FirebaseAuth firebaseAuth;
  final MyBookingsCubit myBookingsCubit;

  BookingCubit({
    required this.getMyPetsUseCase,
    required this.createBookingUseCase,
    required this.firebaseAuth,
    required this.myBookingsCubit,
  }) : super(const BookingState());

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

  // --- [UPDATE: FUNGSI SUBMIT MENERIMA DATA PAYMENT] ---
  // Fungsi ini nanti dipanggil oleh BookingConfirmationScreen
  Future<void> submitBooking({
    required String clinicId,
    required String clinicName,
    required ServiceEntity service,
    // Data Pet & Jadwal (dikirim lagi dari UI konfirmasi)
    required PetEntity selectedPet,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    // Data Payment
    required double totalPrice,
    required double adminFee,
    required double grandTotal,
    required double discountAmount,
    required String paymentMethod,
  }) async {
    
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(state.copyWith(
        status: BookingPageStatus.error,
        errorMessage: "User tidak ditemukan. Silakan login ulang.",
      ));
      return;
    }

    emit(state.copyWith(status: BookingPageStatus.submitting));

    final DateTime combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // [FIX] Masukkan semua parameter payment ke sini
    final booking = BookingEntity.create(
      userId: userId,
      clinicId: clinicId,
      petId: selectedPet.id,
      petName: selectedPet.name,
      clinicName: clinicName,
      service: service,
      scheduleDate: combinedDateTime,
      status: "Pending",
      
      // Bagian Payment
      totalPrice: totalPrice,
      adminFee: adminFee,
      grandTotal: grandTotal,
      discountAmount: discountAmount,
      paymentMethod: paymentMethod,
      paymentStatus: "Unpaid",
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
        myBookingsCubit.fetchMyBookings();
        emit(state.copyWith(status: BookingPageStatus.success));
      },
    );
  }
}