// lib/features/booking/domain/usecases/get_my_bookings_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

class GetMyBookingsUseCase {
  final BookingRepository repository;
  GetMyBookingsUseCase({required this.repository});

  Future<Either<Failure, List<BookingEntity>>> call() async {
    return await repository.getMyBookings();
  }
}