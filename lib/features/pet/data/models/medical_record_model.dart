import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordModel {
  final String id;
  final String title;
  final String notes;
  final DateTime date;
  final String? petId; // optional

  MedicalRecordModel({
    required this.id,
    required this.title,
    required this.notes,
    required this.date,
    this.petId,
  });

  factory MedicalRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // parse date safely
    final rawDate = data['date'];
    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return MedicalRecordModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      notes: (data['notes'] as String?) ?? '',
      date: parsedDate,
      petId: (data['petId'] as String?) // kalau ada
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      if (petId != null) 'petId': petId,
    };
  }
}
