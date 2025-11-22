import 'package:equatable/equatable.dart';

class ClinicEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final List<String> categories;
  // --- [BARU] Field Rating ---
  final double rating;
  final int totalReviews;

  const ClinicEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.categories = const [],
    // Default 0 agar tidak error data lama
    this.rating = 0.0,
    this.totalReviews = 0,
  });

  @override
  List<Object?> get props => [id, name, address, imageUrl, categories, rating, totalReviews];
}