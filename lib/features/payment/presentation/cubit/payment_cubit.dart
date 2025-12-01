import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  PaymentCubit() : super(PaymentInitial());

  Future<void> confirmPaymentAndBooking(String bookingId, String newStatus, {bool autoPay = false}) async {
    emit(PaymentLoading());

    try {
      debugPrint("🚀 [PaymentCubit] Memproses Booking ID: $bookingId -> Status: $newStatus");

      // Gunakan Transaction untuk menjamin konsistensi data (Lebih kuat daripada Batch)
      await firestore.runTransaction((transaction) async {
        // 1. CARI DATA PAYMENT
        final paymentQuery = await firestore
            .collection('payments')
            .where('bookingId', isEqualTo: bookingId)
            .limit(1)
            .get();

        // 2. REFERENSI BOOKING
        final bookingRef = firestore.collection('bookings').doc(bookingId);

        // 3. UPDATE BOOKING
        Map<String, dynamic> bookingUpdate = {'status': newStatus};
        if (autoPay) {
          bookingUpdate['paymentStatus'] = 'Paid';
        }
        transaction.update(bookingRef, bookingUpdate);

        // 4. UPDATE PAYMENT (LOGIKA UTAMA)
        if (paymentQuery.docs.isNotEmpty) {
          final paymentDoc = paymentQuery.docs.first;
          debugPrint("✅ Payment Ditemukan! Mengupdate status...");

          // JIKA COMPLETED -> PAYMENT SUCCESS
          if (newStatus == 'Completed' && autoPay) {
             transaction.update(paymentDoc.reference, {'status': 'Success'});
          } 
          // JIKA REJECTED/CANCELLED -> PAYMENT FAILED
          else if (newStatus == 'Rejected' || newStatus == 'Cancelled') {
             transaction.update(paymentDoc.reference, {'status': 'Failed'});
          }
        } else {
          // 5. SELF-HEALING (Jika payment entah kenapa tidak ada, kita lewati transaksi ini 
          // dan biarkan dia dibuat manual atau abaikan saja agar tidak crash)
          debugPrint("⚠️ Payment tidak ditemukan untuk Booking ini.");
          
          // Opsional: Jika Anda ingin MEMAKSA buat baru di sini, 
          // Anda harus menggunakan 'set' di luar transaction get, tapi untuk update status
          // sebaiknya kita fokus update saja.
        }
      });

      // 6. SUKSES
      debugPrint("🏁 Transaksi Selesai.");
      emit(const PaymentSuccess("Status Berhasil Diperbarui!"));
      
      // Kirim notifikasi (fire & forget)
      _sendNotification(bookingId, newStatus);

    } catch (e) {
      debugPrint("❌ Error PaymentCubit: $e");
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> _sendNotification(String bookingId, String status) async {
    try {
      final doc = await firestore.collection('bookings').doc(bookingId).get();
      if(doc.exists) {
        final data = doc.data()!;
        await firestore.collection('notifications').add({
          'userId': data['userId'],
          'title': 'Status Booking: $status',
          'body': 'Status booking anda diperbarui menjadi $status.',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    } catch (_) {}
  }
}