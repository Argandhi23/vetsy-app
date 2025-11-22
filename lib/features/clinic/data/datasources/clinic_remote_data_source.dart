import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/clinic/data/models/clinic_detail_model.dart';
import 'package:vetsy_app/features/clinic/data/models/clinic_model.dart';
import 'package:vetsy_app/features/clinic/data/models/review_model.dart';
import 'package:vetsy_app/features/clinic/data/models/service_model.dart'; // Pastikan import ini

abstract class ClinicRemoteDataSource {
  Future<List<ClinicModel>> getClinics();
  Future<ClinicDetailModel> getClinicDetail(String clinicId);
  Future<void> addReview({required String clinicId, required ReviewModel review});

  // --- [FITUR BARU ADMIN] ---
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

      final serviceSnapshot = await clinicDoc.reference.collection('services').get();
      return ClinicDetailModel.fromFirestore(clinicDoc, serviceSnapshot);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> addReview({required String clinicId, required ReviewModel review}) async {
    final clinicRef = firestore.collection('clinics').doc(clinicId);
    final reviewRef = clinicRef.collection('reviews').doc(); 

    try {
      await firestore.runTransaction((transaction) async {
        final clinicSnapshot = await transaction.get(clinicRef);
        if (!clinicSnapshot.exists) throw ServerException(message: "Klinik tidak ditemukan");

        final currentRating = (clinicSnapshot.data()?['rating'] ?? 0.0).toDouble();
        final currentTotal = (clinicSnapshot.data()?['totalReviews'] ?? 0).toInt();

        final newTotal = currentTotal + 1;
        final newRating = ((currentRating * currentTotal) + review.rating) / newTotal;

        transaction.set(reviewRef, review.toFirestore());
        transaction.update(clinicRef, {
          'rating': newRating,
          'totalReviews': newTotal,
        });
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // --- [IMPLEMENTASI FITUR BARU] ---
  
  @override
  Future<void> addService({required String clinicId, required ServiceModel service}) async {
    try {
      await firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('services')
          .add(service.toFirestore());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateService({required String clinicId, required ServiceModel service}) async {
    try {
      await firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('services')
          .doc(service.id)
          .update(service.toFirestore());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteService({required String clinicId, required String serviceId}) async {
    try {
      await firestore
          .collection('clinics')
          .doc(clinicId)
          .collection('services')
          .doc(serviceId)
          .delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}