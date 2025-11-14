// lib/features/clinic/data/datasources/clinic_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/features/clinic/data/models/clinic_detail_model.dart';
import 'package:vetsy_app/features/clinic/data/models/clinic_model.dart';

abstract class ClinicRemoteDataSource {
  Future<List<ClinicModel>> getClinics();

  // INI FUNGSI BARU DARI LANGKAH 9
  Future<ClinicDetailModel> getClinicDetail(String clinicId);
}

class ClinicRemoteDataSourceImpl implements ClinicRemoteDataSource {
  final FirebaseFirestore firestore;
  ClinicRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ClinicModel>> getClinics() async {
    // Ini fungsi lama (sudah benar)
    try {
      final snapshot = await firestore.collection('clinics').get();
      final clinics = snapshot.docs
          .map((doc) => ClinicModel.fromFirestore(doc))
          .toList();
      return clinics;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // INI IMPLEMENTASI FUNGSI BARU DARI LANGKAH 9
  @override
  Future<ClinicDetailModel> getClinicDetail(String clinicId) async {
    try {
      // 1. Ambil dokumen klinik
      final clinicDoc =
          await firestore.collection('clinics').doc(clinicId).get();

      if (!clinicDoc.exists) {
        throw ServerException(message: "Klinik tidak ditemukan");
      }

      // 2. Ambil sub-koleksi 'services'
      final serviceSnapshot =
          await clinicDoc.reference.collection('services').get();

      // 3. Gabungkan keduanya menggunakan Model
      return ClinicDetailModel.fromFirestore(clinicDoc, serviceSnapshot);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}