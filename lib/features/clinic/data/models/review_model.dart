import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/clinic/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  final String clinicId; // [BARU]

  const ReviewModel({
    required super.id,
    required this.clinicId, // [BARU]
    required super.userId,
    required super.username,
    required super.rating,
    required super.comment,
    required super.date,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      clinicId: data['clinicId'] ?? '', // [BARU]
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonim',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clinicId': clinicId, // [BARU]
      'userId': userId,
      'username': username,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.fromDate(date),
    };
  }
}