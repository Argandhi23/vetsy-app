import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/booking/data/models/booking_model.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRemoteDataSource {
  Future<void> createBooking(BookingEntity booking);
  Future<List<BookingModel>> getMyBookings(String userId);
  Future<void> cancelBooking(String bookingId);
  // [UPDATE] Tambah parameter serviceId
  Future<List<DateTime>> getOccupiedSlots(String clinicId, String serviceId, DateTime date);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DateTime>> getOccupiedSlots(String clinicId, String serviceId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // [UPDATE LOGIC] Filter berdasarkan ClinicID DAN ServiceID
      final snapshot = await firestore
          .collection('bookings')
          .where('clinicId', isEqualTo: clinicId)
          .where('service.id', isEqualTo: serviceId) // Kunci agar layanan lain tidak ikut penuh
          .where('scheduleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduleDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      final List<DateTime> occupied = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Hanya masukkan ke daftar sibuk jika statusnya bukan 'Cancelled'
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

      // ID Unik kombinasi Klinik + Layanan + Waktu
      final String uniqueSlotId = 
          '${booking.clinicId}_${booking.service.id}_${booking.scheduleDate.millisecondsSinceEpoch}';

      final docRef = firestore.collection('bookings').doc(uniqueSlotId);

      await firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data['status'] != 'Cancelled') {
            throw ServerException(message: "Maaf, slot waktu ini baru saja diambil pengguna lain.");
          }
        }
        transaction.set(docRef, model.toFirestore());
      });
      
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
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