import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/clinic/data/models/clinic_detail_model.dart';
import 'package:vetsy_app/features/clinic/data/models/clinic_model.dart';
import 'package:vetsy_app/features/clinic/data/models/review_model.dart'; // Pastikan buat file ini nanti

abstract class ClinicRemoteDataSource {
  Future<List<ClinicModel>> getClinics();
  Future<ClinicDetailModel> getClinicDetail(String clinicId);
  
  // --- [BARU] ---
  Future<void> addReview({required String clinicId, required ReviewModel review});
}

class ClinicRemoteDataSourceImpl implements ClinicRemoteDataSource {
  final FirebaseFirestore firestore;
  ClinicRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ClinicModel>> getClinics() async {
    try {
      final snapshot = await firestore.collection('clinics').get();
      return snapshot.docs.map((doc) => ClinicModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ClinicDetailModel> getClinicDetail(String clinicId) async {
    try {
      final clinicDoc = await firestore.collection('clinics').doc(clinicId).get();
      if (!clinicDoc.exists) throw ServerException(message: "Klinik tidak ditemukan");

      final serviceSnapshot = await clinicDoc.reference.collection('services').get();
      return ClinicDetailModel.fromFirestore(clinicDoc, serviceSnapshot);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // --- [BARU] Implementasi Transaksi Rating ---
  @override
  Future<void> addReview({required String clinicId, required ReviewModel review}) async {
    final clinicRef = firestore.collection('clinics').doc(clinicId);
    final reviewRef = clinicRef.collection('reviews').doc(); // ID otomatis

    try {
      await firestore.runTransaction((transaction) async {
        // 1. Baca data klinik terbaru
        final clinicSnapshot = await transaction.get(clinicRef);
        if (!clinicSnapshot.exists) throw ServerException(message: "Klinik tidak ditemukan");

        final currentRating = (clinicSnapshot.data()?['rating'] ?? 0.0).toDouble();
        final currentTotal = (clinicSnapshot.data()?['totalReviews'] ?? 0).toInt();

        // 2. Hitung Rata-rata Baru
        final newTotal = currentTotal + 1;
        final newRating = ((currentRating * currentTotal) + review.rating) / newTotal;

        // 3. Simpan Review
        transaction.set(reviewRef, review.toFirestore());

        // 4. Update Data Klinik
        transaction.update(clinicRef, {
          'rating': newRating,
          'totalReviews': newTotal,
        });
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}