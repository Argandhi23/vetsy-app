import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/booking/data/models/booking_model.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRemoteDataSource {
  Future<void> createBooking(BookingEntity booking);
  Future<List<BookingModel>> getMyBookings(String userId);
  Future<void> cancelBooking(String bookingId);
  // [BARU] Ambil daftar jam yang sibuk
  Future<List<DateTime>> getOccupiedSlots(String clinicId, DateTime date);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DateTime>> getOccupiedSlots(String clinicId, DateTime date) async {
    try {
      // Cari booking dari jam 00:00 sampai 23:59 di hari tersebut
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await firestore
          .collection('bookings')
          .where('clinicId', isEqualTo: clinicId)
          .where('scheduleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduleDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      final List<DateTime> occupied = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Jika statusnya bukan Cancelled, berarti slot itu TERPAKAI
        if (data['status'] != 'Cancelled') {
          occupied.add((data['scheduleDate'] as Timestamp).toDate());
        }
      }
      return occupied;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

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

      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await firestore.collection('bookings').doc(bookingId).update({'status': 'Cancelled'});
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}