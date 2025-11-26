import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:vetsy_app/core/services/notification_service.dart';
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

  /// Mengambil daftar booking dari server
  Future<void> fetchMyBookings() async {
    emit(state.copyWith(status: MyBookingsStatus.loading));
    
    final result = await getMyBookingsUseCase();
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: MyBookingsStatus.error, 
        errorMessage: failure.message
      )),
      (bookings) => emit(state.copyWith(
        status: MyBookingsStatus.loaded, 
        bookings: bookings
      )),
    );
  }

  /// Membatalkan booking & menghapus notifikasi
  Future<void> cancelBooking(BookingEntity booking) async {
    // 1. Ubah status ke loading (tapi biarkan data bookings lama tetap tampil di background)
    emit(state.copyWith(status: MyBookingsStatus.loading));

    // 2. Request cancel ke backend
    final result = await cancelBookingUseCase(booking.id, booking.scheduleDate);
    
    result.fold(
      (failure) {
        // [PERBAIKAN] Jika gagal (misal < 2 jam), cukup tampilkan error.
        // JANGAN panggil fetchMyBookings() disini agar pesan error terbaca user.
        emit(state.copyWith(
          status: MyBookingsStatus.error, 
          errorMessage: failure.message,
          // Pastikan list booking lama tidak hilang (biasanya otomatis ter-copy di copyWith)
        ));
      },
      (_) async {
        // 3. Jika Sukses di Backend, Hapus Notifikasi Lokal
        try {
          // Generate ID yang sama persis dengan logic di BookingCubit
          final notificationId = booking.scheduleDate.millisecondsSinceEpoch ~/ 1000;
          
          await NotificationService().cancelNotification(notificationId);
          debugPrint("✅ Notifikasi dibatalkan untuk ID: $notificationId");
        } catch (e) {
          // Error di notifikasi tidak boleh membatalkan kesuksesan cancel booking
          debugPrint("⚠️ Gagal cancel notifikasi: $e");
        }

        // 4. Refresh data terbaru dari server agar status di UI berubah jadi 'Cancelled'
        fetchMyBookings();
      },
    );
  }

  void reset() {
    emit(const MyBookingsState());
  }
}