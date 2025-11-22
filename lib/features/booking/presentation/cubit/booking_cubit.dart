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
// [WAJIB] Import Repository
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetMyPetsUseCase getMyPetsUseCase;
  final CreateBookingUseCase createBookingUseCase;
  final FirebaseAuth firebaseAuth;
  final MyBookingsCubit myBookingsCubit;
  // [BARU] Tambahkan ini
  final BookingRepository bookingRepository; 

  BookingCubit({
    required this.getMyPetsUseCase,
    required this.createBookingUseCase,
    required this.firebaseAuth,
    required this.myBookingsCubit,
    required this.bookingRepository, // [BARU]
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

  // [UPDATE] Menerima clinicId untuk cek slot penuh
  Future<void> onDateSelected(String clinicId, DateTime date) async {
    emit(state.copyWith(
      selectedDate: date,
      selectedTime: null, // Reset jam
      status: BookingPageStatus.loadingSlots,
    ));

    // Cek database
    final result = await bookingRepository.getOccupiedSlots(clinicId, date);

    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingPageStatus.error, 
        errorMessage: "Gagal cek jadwal: ${failure.message}"
      )),
      (occupiedDates) {
        // Konversi DateTime ke TimeOfDay untuk dibandingkan di UI
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

  // Fungsi Submit dengan Payment (Sudah Benar)
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