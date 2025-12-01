import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BannerModel extends Equatable {
  final String id;
  final String imageUrl;
  final String title; // [BARU] Tambahkan ini
  final bool isActive;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title, // [BARU]
    required this.isActive,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '', // [BARU] Ambil title, default string kosong
      isActive: data['isActive'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, imageUrl, title, isActive];
}