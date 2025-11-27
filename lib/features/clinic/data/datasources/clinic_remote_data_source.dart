import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/clinic/data/models/clinic_detail_model.dart';
import 'package:vetsy_app/features/clinic/data/models/clinic_model.dart';
import 'package:vetsy_app/features/clinic/data/models/review_model.dart';
import 'package:vetsy_app/features/clinic/data/models/service_model.dart';

abstract class ClinicRemoteDataSource {
  Future<List<ClinicModel>> getClinics();
  Future<ClinicDetailModel> getClinicDetail(String clinicId);
  Future<void> addReview({required String clinicId, required ReviewModel review});

  Future<void> addService({required String clinicId, required ServiceModel service});
  Future<void> updateService({required String clinicId, required ServiceModel service});
  Future<void> deleteService({required String clinicId, required String serviceId});
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

      // [UBAH LOGIC] Ambil services dari Root Collection, filter by clinicId
      final serviceSnapshot = await firestore
          .collection('services')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      return ClinicDetailModel.fromFirestore(clinicDoc, serviceSnapshot);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> addReview({required String clinicId, required ReviewModel review}) async {
    final clinicRef = firestore.collection('clinics').doc(clinicId);
    // [UBAH LOGIC] Simpan review di Root Collection 'reviews'
    final reviewRef = firestore.collection('reviews').doc(); 

    try {
      await firestore.runTransaction((transaction) async {
        final clinicSnapshot = await transaction.get(clinicRef);
        if (!clinicSnapshot.exists) throw ServerException(message: "Klinik tidak ditemukan");

        final currentRating = (clinicSnapshot.data()?['rating'] ?? 0.0).toDouble();
        final currentTotal = (clinicSnapshot.data()?['totalReviews'] ?? 0).toInt();

        final newTotal = currentTotal + 1;
        final newRating = ((currentRating * currentTotal) + review.rating) / newTotal;

        // Siapkan data review dengan clinicId
        final reviewData = review.toFirestore();
        reviewData['clinicId'] = clinicId; // Pastikan clinicId tersimpan

        transaction.set(reviewRef, reviewData);
        transaction.update(clinicRef, {
          'rating': newRating,
          'totalReviews': newTotal,
        });
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // --- ADMIN SERVICES (ROOT COLLECTION) ---
  
  @override
  Future<void> addService({required String clinicId, required ServiceModel service}) async {
    try {
      final serviceData = service.toFirestore();
      serviceData['clinicId'] = clinicId; // Inject clinicId

      await firestore.collection('services').add(serviceData);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateService({required String clinicId, required ServiceModel service}) async {
    try {
      // Update langsung ke Root Collection
      await firestore.collection('services').doc(service.id).update(service.toFirestore());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteService({required String clinicId, required String serviceId}) async {
    try {
      // Delete langsung dari Root Collection
      await firestore.collection('services').doc(serviceId).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}