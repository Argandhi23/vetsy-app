import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, void>> createBooking(BookingEntity booking);
  Future<Either<Failure, List<BookingEntity>>> getMyBookings();
  Future<Either<Failure, void>> cancelBooking(String bookingId);
  
  // [UPDATE] Tambah serviceId
  Future<Either<Failure, List<DateTime>>> getOccupiedSlots(String clinicId, String serviceId, DateTime date);
}