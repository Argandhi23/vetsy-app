import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, void>> createBooking(BookingEntity booking);
  Future<Either<Failure, List<BookingEntity>>> getMyBookings();
  
  // TAMBAHKAN INI
  Future<Either<Failure, void>> cancelBooking(String bookingId);
  Future<Either<Failure, bool>> checkAvailability(String clinicId, DateTime scheduleDate);
}