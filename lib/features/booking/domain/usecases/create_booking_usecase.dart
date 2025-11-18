// lib/features/booking/domain/usecases/create_booking_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase({required this.repository});

  // Usecase ini bisa dipanggil seperti fungsi biasa
  Future<Either<Failure, void>> call(BookingEntity booking) async {
    return await repository.createBooking(booking);
  }
}