// lib/data_seeder.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Ambil referensi ke database
final db = FirebaseFirestore.instance;

// Data klinik dummy kita
final List<Map<String, dynamic>> clinics = [
  {
    "name": "Klinik Hewan Sehat Surabaya",
    "address": "Jl. Raya Unesa No. 1, Surabaya",
    // URL ini VALID
    "imageUrl":
        "https://images.pexels.com/photos/208984/pexels-photo-208984.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "services": [
      {"name": "Vaksinasi Rabies", "price": 150000},
      {"name": "Grooming Mandi Jamur", "price": 100000},
      {"name": "Konsultasi Dokter", "price": 75000}
    ]
  },
  {
    "name": "Surabaya PetCare Center",
    "address": "Jl. Lidah Wetan No. 45, Surabaya",
    
    // ===== INI URL BARU (GANTI DARI YANG LAMA) =====
    "imageUrl":
        "https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1", 
    
    "services": [
      {"name": "Sterilisasi Kucing Jantan", "price": 350000},
      {"name": "Grooming Kutu", "price": 120000},
      {"name": "Cek Darah Lengkap", "price": 250000}
    ]
  },
  {
    "name": "Klinik Sahabat Hewan",
    "address": "Jl. Wiyung Indah No. 12",
    // URL ini VALID
    "imageUrl":
        "https://images.pexels.com/photos/5749133/pexels-photo-5749133.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "services": [
      {"name": "Pasang Microchip", "price": 175000},
      {"name": "USG Hewan", "price": 200000}
    ]
  }
];

// FUNGSI UNTUK DIJALANKAN
Future<void> seedData() async {
  print("Memulai seeding data...");

  final batch = db.batch();
  final clinicsCollection = db.collection("clinics");

  // Loop setiap klinik di data dummy
  for (final clinicData in clinics) {
    
    final clinicRef = clinicsCollection.doc();

    final clinicPayload = {
      "name": clinicData['name'],
      "address": clinicData['address'],
      "imageUrl": clinicData['imageUrl'],
    };

    batch.set(clinicRef, clinicPayload);

    final services = clinicData['services'] as List<Map<String, dynamic>>;

    for (final serviceData in services) {
      final serviceRef = clinicRef.collection("services").doc();
      batch.set(serviceRef, serviceData);
    }
  }

  // Jalankan semua operasi sekaligus
  await batch.commit();

  print("Seeding data selesai!");
}