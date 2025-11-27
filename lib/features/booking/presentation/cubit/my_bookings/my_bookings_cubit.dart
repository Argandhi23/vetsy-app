import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsy_app/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/usecases/cancel_booking_usecase.dart';

part 'my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final BookingRemoteDataSource remoteDataSource;
  final CancelBookingUseCase cancelBookingUseCase;
  final FirebaseAuth auth;

  StreamSubscription? _bookingSubscription;

  MyBookingsCubit({
    required this.remoteDataSource,
    required this.cancelBookingUseCase,
    required this.auth,
  }) : super(const MyBookingsState());

  // [PERBAIKAN] Ubah return type jadi Future<void> agar RefreshIndicator senang
  Future<void> fetchMyBookings() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) return;

    // Tidak perlu emit loading karena ini stream realtime
    // emit(state.copyWith(status: MyBookingsStatus.loading));

    _bookingSubscription?.cancel();

    _bookingSubscription = remoteDataSource.getMyBookingsStream(userId).listen(
      (bookings) {
        emit(state.copyWith(
          status: MyBookingsStatus.loaded, 
          bookings: bookings
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          status: MyBookingsStatus.error, 
          errorMessage: error.toString()
        ));
      },
    );
    
    // Tunggu sebentar agar RefreshIndicator punya delay visual (opsional)
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> cancelBooking(BookingEntity booking) async {
    emit(state.copyWith(status: MyBookingsStatus.loading));
    final result = await cancelBookingUseCase(booking.id, booking.scheduleDate);
    
    result.fold(
      (failure) => emit(state.copyWith(status: MyBookingsStatus.error, errorMessage: failure.message)),
      (_) {}, // Stream otomatis update
    );
  }

  @override
  Future<void> close() {
    _bookingSubscription?.cancel();
    return super.close();
  }

  void reset() {
    _bookingSubscription?.cancel();
    emit(const MyBookingsState());
  }
}