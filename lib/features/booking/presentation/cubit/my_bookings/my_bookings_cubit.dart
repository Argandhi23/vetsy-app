import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:vetsy_app/features/booking/domain/usecases/cancel_booking_usecase.dart';

part 'my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final GetMyBookingsUseCase getMyBookingsUseCase;
  final CancelBookingUseCase cancelBookingUseCase;

  MyBookingsCubit({
    required this.getMyBookingsUseCase,
    required this.cancelBookingUseCase,
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

  // Fungsi Cancel dengan validasi 2 jam (dari UseCase)
  Future<void> cancelBooking(BookingEntity booking) async {
    emit(state.copyWith(status: MyBookingsStatus.loading));

    final result = await cancelBookingUseCase(booking.id, booking.scheduleDate);
    
    result.fold(
      (failure) {
        // Jika gagal, kembalikan error message dan refresh data
        emit(state.copyWith(
          status: MyBookingsStatus.error, 
          errorMessage: failure.message
        ));
        fetchMyBookings();
      },
      (_) {
        // Jika sukses, refresh data
        fetchMyBookings();
      },
    );
  }

  // [DITAMBAHKAN KEMBALI] Fungsi ini dibutuhkan oleh main.dart saat logout
  void reset() {
    emit(const MyBookingsState());
  }
}