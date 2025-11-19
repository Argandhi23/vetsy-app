import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String username;
  final String role; // 'user' atau 'admin'
  final String? clinicId; // Hanya diisi jika role == 'admin'

  const UserEntity({
    required this.uid,
    required this.email,
    required this.username,
    this.role = 'user', // Default user biasa
    this.clinicId,
  });

  @override
  List<Object?> get props => [uid, email, username, role, clinicId];
}