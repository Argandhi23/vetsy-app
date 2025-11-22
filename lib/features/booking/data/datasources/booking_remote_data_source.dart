import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/booking/data/models/booking_model.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRemoteDataSource {
  Future<void> createBooking(BookingEntity booking);
  Future<List<BookingModel>> getMyBookings(String userId);
  Future<void> cancelBooking(String bookingId);
  
  // --- [BARU] Cek Slot ---
  Future<bool> isSlotAvailable({required String clinicId, required DateTime scheduleDate});
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl({required this.firestore});

  // --- [BARU] Implementasi Cek Slot ---
  @override
  Future<bool> isSlotAvailable({required String clinicId, required DateTime scheduleDate}) async {
    try {
      // 1. Ubah DateTime ke Timestamp Firestore
      final Timestamp timestamp = Timestamp.fromDate(scheduleDate);

      // 2. Cari booking di klinik yang sama & jam yang sama
      final snapshot = await firestore
          .collection('bookings')
          .where('clinicId', isEqualTo: clinicId)
          .where('scheduleDate', isEqualTo: timestamp)
          .get();

      // 3. Cek apakah ada yang statusnya BUKAN 'Cancelled'
      // Jika ada booking aktif (Confirmed/Completed/Pending), berarti slot PENUH.
      final hasActiveBooking = snapshot.docs.any((doc) {
        final data = doc.data();
        return data['status'] != 'Cancelled';
      });

      // Return true jika TIDAK ada booking aktif (tersedia)
      return !hasActiveBooking; 
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

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
          
      return bookings;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await firestore.collection('bookings').doc(bookingId).update({
        'status': 'Cancelled',
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}