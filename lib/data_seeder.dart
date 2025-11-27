import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DataSeeder {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> seed() async {
    debugPrint('\n===================================================');
    debugPrint('🧹 1. MEMBERSIHKAN DATA LAMA (AUTO-CLEAN)...');
    debugPrint('===================================================');

    // Hapus semua data lama dulu biar tidak numpuk/double
    await _clearCollection('clinics');
    await _clearCollection('services');
    await _clearCollection('veterinarians');
    await _clearCollection('reviews');
    await _clearCollection('bookings'); 

    debugPrint('\n===================================================');
    debugPrint('🌱 2. MULAI SEEDING 3 KLINIK BARU...');
    debugPrint('===================================================');

    WriteBatch batch = firestore.batch();

    // ==============================================
    // 🏥 KLINIK 1: Vetsy Pusat (Lengkap)
    // ==============================================
    final clinicARef = firestore.collection('clinics').doc();
    final String clinicAId = clinicARef.id;

    batch.set(clinicARef, {
      'id': clinicAId,
      'name': 'Vetsy Care Center (Pusat)',
      'address': 'Jl. Sahabat Satwa No. 1, Jakarta Selatan',
      'description': 'Klinik hewan modern dengan fasilitas terlengkap dan dokter spesialis.',
      'imageUrl': 'https://images.pexels.com/photos/6235233/pexels-photo-6235233.jpeg',
      'rating': 4.9,
      'totalReviews': 150,
      'phone': '081234567890',
      'openTime': '08:00',
      'closeTime': '21:00',
      'categories': ['Dokter', 'Grooming', 'Vaksinasi', 'Steril'],
      'facilities': ['Pet Hotel', 'Grooming', 'USG', 'Operasi'],
    });

    // Service Klinik A (Mahal & Lengkap)
    await _addServices(batch, clinicAId, [
      {'name': 'Vaksin Lengkap (Tricat)', 'price': 185000, 'cat': 'Vaksinasi'},
      {'name': 'Grooming Premium', 'price': 120000, 'cat': 'Grooming'},
      {'name': 'Steril Kucing Jantan', 'price': 450000, 'cat': 'Steril'},
      {'name': 'Konsultasi Spesialis', 'price': 150000, 'cat': 'Dokter'},
    ]);

    _addDummyBooking(batch, clinicAId, 'Vetsy Care Center', 'Mochi', 185000);


    // ==============================================
    // 🏥 KLINIK 2: Happy Paws (Fokus Grooming)
    // ==============================================
    final clinicBRef = firestore.collection('clinics').doc();
    final String clinicBId = clinicBRef.id;

    batch.set(clinicBRef, {
      'id': clinicBId,
      'name': 'Happy Paws Clinic',
      'address': 'Jl. Melati Indah No. 45, Bandung',
      'description': 'Spesialis perawatan bulu dan vaksinasi hewan kesayangan.',
      'imageUrl': 'https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg',
      'rating': 4.5,
      'totalReviews': 80,
      'phone': '089876543210',
      'openTime': '10:00',
      'closeTime': '20:00',
      'categories': ['Grooming', 'Vaksinasi'], // Cuma 2 kategori
      'facilities': ['Parkir Luas', 'WiFi', 'Pet Shop'],
    });

    // Service Klinik B (Murah)
    await _addServices(batch, clinicBId, [
      {'name': 'Mandi Sehat', 'price': 70000, 'cat': 'Grooming'},
      {'name': 'Vaksin Rabies', 'price': 150000, 'cat': 'Vaksinasi'},
      {'name': 'Potong Kuku & Rapikan', 'price': 35000, 'cat': 'Grooming'},
    ]);

    _addDummyBooking(batch, clinicBId, 'Happy Paws', 'Bruno', 70000);


    // ==============================================
    // 🏥 KLINIK 3: Satwa Sejahtera (Fokus Medis)
    // ==============================================
    final clinicCRef = firestore.collection('clinics').doc();
    final String clinicCId = clinicCRef.id;

    batch.set(clinicCRef, {
      'id': clinicCId,
      'name': 'Klinik Satwa Sejahtera',
      'address': 'Jl. Diponegoro No. 12, Surabaya',
      'description': 'Klinik senior dengan layanan gawat darurat 24 jam.',
      'imageUrl': 'https://images.pexels.com/photos/5749133/pexels-photo-5749133.jpeg',
      'rating': 4.7,
      'totalReviews': 210,
      'phone': '081998877665',
      'openTime': '24 Jam', // Buka terus
      'closeTime': '24 Jam',
      'categories': ['Dokter', 'Steril', 'Vaksinasi'],
      'facilities': ['UGD 24 Jam', 'Rontgen', 'Lab Darah'],
    });

    // Service Klinik C (Medis Berat)
    await _addServices(batch, clinicCId, [
      {'name': 'Konsultasi Umum', 'price': 90000, 'cat': 'Dokter'},
      {'name': 'Steril Kucing Betina', 'price': 800000, 'cat': 'Steril'},
      {'name': 'Cek Darah Lengkap', 'price': 300000, 'cat': 'Dokter'},
      {'name': 'Rawat Inap (Per Hari)', 'price': 150000, 'cat': 'Dokter'},
    ]);

    _addDummyBooking(batch, clinicCId, 'Satwa Sejahtera', 'Chiko', 150000);


    // EKSEKUSI SEMUA
    await batch.commit();

    // ==============================================
    // 🖨️ OUTPUT ID ADMIN
    // ==============================================
    debugPrint('\n✅ ===================================================');
    debugPrint('✅ SEEDING SUKSES! DATA LAMA SUDAH BERSIH. 🗑️✨');
    debugPrint('✅ SILAKAN PILIH ADMIN UNTUK SETIAP KLINIK:');
    debugPrint('---------------------------------------------------');
    debugPrint('👉 KLINIK 1 (Vetsy Pusat) ID:     $clinicAId');
    debugPrint('👉 KLINIK 2 (Happy Paws) ID:      $clinicBId');
    debugPrint('👉 KLINIK 3 (Satwa Sejahtera) ID: $clinicCId');
    debugPrint('---------------------------------------------------');
    debugPrint('ℹ️  Copy ID di atas -> Paste ke "clinicId" di Firestore User');
    debugPrint('✅ ===================================================\n');
  }

  // --- HELPER: HAPUS DATA PER COLLECTION ---
  Future<void> _clearCollection(String collectionName) async {
    final snapshot = await firestore.collection(collectionName).limit(500).get();
    
    if (snapshot.docs.isEmpty) return;

    WriteBatch batch = firestore.batch();
    int count = 0;

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
      count++;
      // Commit per 400 dokumen (Batas Firestore 500)
      if (count >= 400) {
        await batch.commit();
        batch = firestore.batch();
        count = 0;
      }
    }
    if (count > 0) await batch.commit();
    
    debugPrint('🗑️  Collection "$collectionName" BERSIH.');
  }

  // --- HELPER: TAMBAH SERVICES ---
  Future<void> _addServices(WriteBatch batch, String clinicId, List<Map> services) async {
    for (var s in services) {
      final ref = firestore.collection('services').doc();
      batch.set(ref, {
        'id': ref.id,
        'clinicId': clinicId,
        'name': s['name'],
        'price': s['price'],
        'category': s['cat'],
      });
    }
  }

  // --- HELPER: TAMBAH DUMMY BOOKING ---
  void _addDummyBooking(WriteBatch batch, String clinicId, String clinicName, String petName, int total) {
    final ref = firestore.collection('bookings').doc();
    batch.set(ref, {
      'id': ref.id,
      'userId': 'user_dummy',
      'clinicId': clinicId,
      'clinicName': clinicName,
      'petName': petName,
      'service': {'name': 'Layanan Contoh', 'price': total},
      'scheduleDate': Timestamp.now(),
      'status': 'Pending',
      'paymentStatus': 'Unpaid',
      'grandTotal': total,
    });
  }
}