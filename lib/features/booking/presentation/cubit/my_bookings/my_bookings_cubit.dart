import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:vetsy_app/features/booking/domain/usecases/cancel_booking_usecase.dart'; // 1. IMPORT

part 'my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final GetMyBookingsUseCase getMyBookingsUseCase;
  final CancelBookingUseCase cancelBookingUseCase; // 2. TAMBAH VARIABEL

  MyBookingsCubit({
    required this.getMyBookingsUseCase,
    required this.cancelBookingUseCase, // 3. MASUKKAN KE CONSTRUCTOR
  }) : super(const MyBookingsState());

  Future<void> fetchMyBookings() async {
    emit(state.copyWith(status: MyBookingsStatus.loading));
    final result = await getMyBookingsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
          status: MyBookingsStatus.error, errorMessage: failure.message)),
      (bookings) =>
          emit(state.copyWith(status: MyBookingsStatus.loaded, bookings: bookings)),
    );
  }

  // 4. FUNGSI EKSEKUSI CANCEL
  Future<void> cancelBooking(String bookingId) async {
    final result = await cancelBookingUseCase(bookingId);
    
    result.fold(
      (failure) {
        // Jika gagal, tampilkan error (opsional: bisa pakai snackbar di UI)
        emit(state.copyWith(errorMessage: failure.message));
      },
      (_) {
        // Jika sukses, REFRESH data booking
        fetchMyBookings();
      },
    );
  }

  void reset() {
    emit(const MyBookingsState());
  }
}