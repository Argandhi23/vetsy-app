import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/booking/data/models/booking_model.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRemoteDataSource {
  Future<void> createBooking(BookingEntity booking);
  Future<List<BookingModel>> getMyBookings(String userId);
  
  // 1. TAMBAHKAN INI
  Future<void> cancelBooking(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createBooking(BookingEntity booking) async {
    try {
      final model = BookingModel.fromEntity(booking);
      await firestore.collection('bookings').add(model.toFirestore());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<BookingModel>> getMyBookings(String userId) async {
    try {
      final snapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('scheduleDate', descending: true)
          .get();

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
          
      return bookings;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // 2. IMPLEMENTASI FUNGSI CANCEL
  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      // Update status booking menjadi 'Cancelled'
      await firestore.collection('bookings').doc(bookingId).update({
        'status': 'Cancelled',
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}