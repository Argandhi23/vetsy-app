import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.username,
    super.role,
    super.clinicId,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? 'user', // Baca role, default ke 'user'
      clinicId: data['clinicId'], // Bisa null
    );
  }
}