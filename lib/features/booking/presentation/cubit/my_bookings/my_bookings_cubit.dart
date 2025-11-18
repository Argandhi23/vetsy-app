// lib/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/usecases/get_my_bookings_usecase.dart';

part 'my_bookings_state.dart'; // <-- Pastikan ini ada

// JANGAN TARUH 'enum' ATAU 'MyBookingsState' DI SINI

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final GetMyBookingsUseCase getMyBookingsUseCase;

  MyBookingsCubit({required this.getMyBookingsUseCase})
      : super(const MyBookingsState());

  Future<void> fetchMyBookings() async {
    // INI FUNGSI LENGKAPNYA
    emit(state.copyWith(status: MyBookingsStatus.loading));
    final result = await getMyBookingsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
          status: MyBookingsStatus.error, errorMessage: failure.message)),
      (bookings) =>
          emit(state.copyWith(status: MyBookingsStatus.loaded, bookings: bookings)),
    );
  }
  
  // FUNGSI UNTUK MERESET STATE SAAT LOGOUT
  void reset() {
    emit(const MyBookingsState());
  }
}