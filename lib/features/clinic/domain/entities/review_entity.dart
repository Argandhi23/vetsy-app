import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String username;
  final double rating;
  final String comment;
  final DateTime date;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.rating,
    required this.comment,
    required this.date,
  });

  @override
  List<Object?> get props => [id, userId, username, rating, comment, date];
}