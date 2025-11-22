import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase({required this.repository});

  // [UPDATE] Menerima scheduleDate untuk divalidasi
  Future<Either<Failure, void>> call(String bookingId, DateTime scheduleDate) async {
    final now = DateTime.now();
    final difference = scheduleDate.difference(now);

    // [LOGIC] Cek apakah selisih waktu kurang dari 2 jam?
    if (difference.inHours < 2) {
      // Jika waktu tinggal dikit (kurang dari 2 jam), tolak pembatalan
      return const Left(ServerFailure(
        message: "Maaf, pembatalan hanya dapat dilakukan maksimal 2 jam sebelum jadwal dimulai.",
      ));
    }

    // Cek juga kalau jadwal sudah lewat (masa lalu)
    if (difference.isNegative) {
      return const Left(ServerFailure(
        message: "Tidak dapat membatalkan jadwal yang sudah berlalu.",
      ));
    }

    return await repository.cancelBooking(bookingId);
  }
}