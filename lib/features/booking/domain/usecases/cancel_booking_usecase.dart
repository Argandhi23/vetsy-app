import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase({required this.repository});

  Future<Either<Failure, void>> call(String bookingId) async {
    return await repository.cancelBooking(bookingId);
  }
}