// lib/features/booking/domain/repositories/booking_repository.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  // Kontrak untuk 'create'
  Future<Either<Failure, void>> createBooking(BookingEntity booking);

  // Kontrak untuk 'read'
  Future<Either<Failure, List<BookingEntity>>> getMyBookings();
}