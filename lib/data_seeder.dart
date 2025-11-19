// lib/data_seeder.dart
import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

final List<Map<String, dynamic>> clinics = [
  {
    "name": "Klinik Hewan Sehat Surabaya",
    "address": "Jl. Raya Unesa No. 1, Surabaya",
    "imageUrl": "https://images.pexels.com/photos/208984/pexels-photo-208984.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "latitude": -7.300847,
    "longitude": 112.674367,
    // UPDATE KATEGORI: Tambah "Vaksinasi"
    "categories": ["Dokter", "Grooming", "Vaksinasi"], 
    "services": [
      {"name": "Vaksinasi Rabies", "price": 150000},
      {"name": "Grooming Mandi Jamur", "price": 100000},
      {"name": "Konsultasi Dokter", "price": 75000}
    ]
  },
  {
    "name": "Surabaya PetCare Center",
    "address": "Jl. Lidah Wetan No. 45, Surabaya",
    "imageUrl": "https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "latitude": -7.296400,
    "longitude": 112.665300,
    // UPDATE KATEGORI: Ganti Makanan jadi Steril/Vaksin
    "categories": ["Dokter", "Grooming", "Steril"], 
    "services": [
      {"name": "Sterilisasi Kucing Jantan", "price": 350000},
      {"name": "Grooming Kutu", "price": 120000},
      {"name": "Cek Darah Lengkap", "price": 250000}
    ]
  },
  {
    "name": "Klinik Sahabat Hewan",
    "address": "Jl. Wiyung Indah No. 12",
    "imageUrl": "https://images.pexels.com/photos/5749133/pexels-photo-5749133.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "latitude": -7.315000,
    "longitude": 112.695000,
    // UPDATE KATEGORI
    "categories": ["Pet Hotel", "Dokter", "Vaksinasi"],
    "services": [
      {"name": "Pasang Microchip", "price": 175000},
      {"name": "USG Hewan", "price": 200000},
      {"name": "Penitipan Sehat (Per Hari)", "price": 50000},
      {"name": "Vaksin Lengkap", "price": 180000} // Tambah layanan vaksin
    ]
  }
];

Future<void> seedData() async {
  // ... (Isi fungsi seedData SAMA PERSIS seperti sebelumnya)
  // Copy saja logic loop dan batch.commit() dari file sebelumnya
  print("=== MULAI SEEDING ===");
  final batch = db.batch();
  final clinicsCollection = db.collection("clinics");

  for (final clinicData in clinics) {
    final clinicRef = clinicsCollection.doc();
    
    final clinicPayload = {
      "id": clinicRef.id,
      "name": clinicData['name'],
      "address": clinicData['address'],
      "imageUrl": clinicData['imageUrl'],
      "latitude": clinicData['latitude'],
      "longitude": clinicData['longitude'],
      "categories": clinicData['categories'], 
    };

    batch.set(clinicRef, clinicPayload);

    final services = clinicData['services'] as List<Map<String, dynamic>>;
    for (final serviceData in services) {
      final serviceRef = clinicRef.collection("services").doc();
      batch.set(serviceRef, serviceData);
    }
  }

  await batch.commit();
  print("=== SELESAI ===");
}