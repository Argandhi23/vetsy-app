import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase({required this.repository});

  Future<Either<Failure, void>> call(BookingEntity booking) async {
    // Kita langsung create booking.
    // Pengecekan slot penuh sudah dilakukan di UI (BookingScreen -> Grid Slot),
    // di mana user tidak bisa memilih jam yang sudah penuh.
    return await repository.createBooking(booking);
  }
}