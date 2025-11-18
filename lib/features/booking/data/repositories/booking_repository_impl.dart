// lib/features/booking/data/repositories/booking_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:vetsy_app/features/booking/data/models/booking_model.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseAuth,
  });

  @override
  Future<Either<Failure, void>> createBooking(BookingEntity booking) async {
    try {
      // Ubah Entity (bersih) menjadi Model (siap kirim)
      final bookingModel = BookingModel.fromEntity(booking);

      await remoteDataSource.createBooking(bookingModel);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyBookings() async {
    try {
      // Dapatkan user ID
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return Left(ServerFailure(message: "User tidak terautentikasi"));
      }

      final bookings = await remoteDataSource.getMyBookings(user.uid);
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}