import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordModel {
  final String id;
  final String title; // misal: Vaksin Rabies
  final String notes; // misal: Disuntik di Klinik A
  final DateTime date;

  MedicalRecordModel({
    required this.id,
    required this.title,
    required this.notes,
    required this.date,
  });

  factory MedicalRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicalRecordModel(
      id: doc.id,
      title: data['title'] ?? '',
      notes: data['notes'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'notes': notes,
      'date': Timestamp.fromDate(date),
    };
  }
}