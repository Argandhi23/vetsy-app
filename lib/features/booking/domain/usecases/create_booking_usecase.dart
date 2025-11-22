import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase({required this.repository});

  Future<Either<Failure, void>> call(BookingEntity booking) async {
    // 1. [BARU] Cek ketersediaan slot terlebih dahulu
    final availabilityResult = await repository.checkAvailability(
      booking.clinicId, 
      booking.scheduleDate
    );

    return availabilityResult.fold(
      // Jika gagal ngecek (koneksi error dll), return Failure
      (failure) => Left(failure), 
      
      // Jika berhasil ngecek, kita lihat hasilnya (true/false)
      (isAvailable) async {
        if (!isAvailable) {
          // 2. Jika slot PENUH, kembalikan Error custom tanpa lanjut proses
          return const Left(ServerFailure(message: "Jadwal penuh! Silakan pilih jam lain."));
        }

        // 3. Jika slot KOSONG (Aman), lanjutkan proses booking seperti biasa
        return await repository.createBooking(booking);
      },
    );
  }
}