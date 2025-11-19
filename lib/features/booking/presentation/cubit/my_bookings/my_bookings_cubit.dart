import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:vetsy_app/features/booking/domain/usecases/cancel_booking_usecase.dart'; // IMPORT BARU

part 'my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final GetMyBookingsUseCase getMyBookingsUseCase;
  final CancelBookingUseCase cancelBookingUseCase; // VARIABEL BARU

  MyBookingsCubit({
    required this.getMyBookingsUseCase,
    required this.cancelBookingUseCase, // MASUKKAN DI CONSTRUCTOR
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

  // FUNGSI BARU: Cancel Booking
  Future<void> cancelBooking(String bookingId) async {
    // Kita tidak perlu ubah status jadi loading penuh, cukup refresh setelah selesai
    final result = await cancelBookingUseCase(bookingId);
    result.fold(
      (failure) => emit(state.copyWith(
          status: MyBookingsStatus.error, errorMessage: failure.message)),
      (_) {
        fetchMyBookings(); // Refresh data otomatis
      },
    );
  }

  void reset() {
    emit(const MyBookingsState());
  }
}